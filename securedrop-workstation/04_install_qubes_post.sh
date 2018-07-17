#!/bin/bash -e
# vim: set ts=4 sw=4 sts=4 et :

## Copyright (C) 2012 - 2018 ENCRYPTED SUPPORT LP <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

if [ "$VERBOSE" -ge 2 -o "$DEBUG" == "1" ]; then
    set -x
fi

source "${SCRIPTSDIR}/vars.sh"
source "${SCRIPTSDIR}/distribution.sh"

## If .prepared_debootstrap has not been completed, don't continue.
exitOnNoFile "${INSTALLDIR}/${TMPDIR}/.prepared_qubes" "prepared_qubes installation has not completed!... Exiting"

#### '--------------------------------------------------------------------------
info ' Trap ERR and EXIT signals and cleanup (umount)'
#### '--------------------------------------------------------------------------
trap cleanup ERR
trap cleanup EXIT

prepareChroot

## Qubes R3.1 compatibility.
## Can be removed on Qubes R3.2 and above.
## https://github.com/QubesOS/qubes-issues/issues/1174
if [ "$(type -t chroot_cmd)" = "function" ]; then
   chroot_cmd="chroot_cmd"
else
   chroot_cmd="chroot"
fi

mount --bind /dev "${INSTALLDIR}/dev"

aptInstall apt-transport-https

[ -n "$workstation_repository_suite" ] || workstation_repository_suite="stretch"
[ -n "$workstation_signing_key_fingerprint" ] || workstation_signing_key_fingerprint="4ED79CC3362D7D12837046024A3BE4A92211B03C"
[ -n "$workstation_signing_key_file" ] || workstation_signing_key_file="$BUILDER_DIR/$SRC_DIR/template-securedrop-workstation/keys/apt-test.asc"
[ -n "$gpg_keyserver" ] || gpg_keyserver="keys.gnupg.net"
[ -n "$workstation_repository_uri" ] || workstation_repository_uri="https://apt-test-qubes.freedom.press"
[ -n "$workstation_repository_components" ] || workstation_repository_components="main"
[ -n "$workstation_repository_apt_line" ] || workstation_repository_apt_line="deb $workstation_repository_uri $workstation_repository_suite $workstation_repository_components"
[ -n "$workstation_repository_list" ] || workstation_repository_list="/etc/apt/sources.list.d/securedrop_workstation.list"
[ -n "$workstation_kernel_version" ] || workstation_kernel_version="4.14.53-grsec"
[ -n "$pax_flag" ] || pax_flag="/usr/lib/gnome-terminal/gnome-terminal-server   m"

cat "$workstation_signing_key_file" | $chroot_cmd apt-key add -
## Sanity test. apt-key adv would exit non-zero if not exactly that fingerprint in apt's keyring.
$chroot_cmd apt-key adv --fingerprint "$workstation_signing_key_fingerprint"
echo "${INSTALLDIR}/$workstation_repository_list"
echo "$workstation_repository_apt_line" > "${INSTALLDIR}/$workstation_repository_list"

aptUpdate

aptInstall libelf-dev linux-image-$workstation_kernel_version linux-headers-$workstation_kernel_version paxctld

$chroot_cmd dkms autoinstall -k $workstation_kernel_version
$chroot_cmd update-grub

# Needed for qubes tooling (qubes-open-in-vm and qubes-copy-to-vm)
# If more pax flags are needed in the future, we should manage them through a config file
$chroot_cmd sh -c 'echo "$pax_flag" >> /etc/paxctld.conf'


## Workaround for Qubes bug:
## 'Debian Template: rely on existing tool for base image creation'
## https://github.com/QubesOS/qubes-issues/issues/1055
updateLocale

## Workaround. ntpdate needs to be removed here, because it can not be removed from
## template_debian/packages_qubes.list, because that would break minimal Debian templates.
## https://github.com/QubesOS/qubes-issues/issues/1102
UWT_DEV_PASSTHROUGH="1" aptRemove ntpdate || true

UWT_DEV_PASSTHROUGH="1" \
   DEBIAN_FRONTEND="noninteractive" \
   DEBIAN_PRIORITY="critical" \
   DEBCONF_NOWARNINGS="yes" \
      $chroot_cmd $eatmydata_maybe \
         apt-get ${APT_GET_OPTIONS} autoremove

## Cleanup.
umount_all "${INSTALLDIR}/" || true
trap - ERR EXIT
trap
