#!/bin/bash -e
# vim: set ts=4 sw=4 sts=4 et :

## Copyright (C) 2012 - 2018 ENCRYPTED SUPPORT LP <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

if [ "$VERBOSE" -ge 2 ] || [ "$DEBUG" == "1" ]; then
    set -x
fi

# shellcheck source=/dev/null
source "${SCRIPTSDIR}/vars.sh"
# shellcheck source=/dev/null
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

aptInstall apt-transport-https qubes-vm-recommended

[ -n "$workstation_repository_suite" ] || workstation_repository_suite="bullseye"
[ -n "$workstation_test_key_fingerprint" ] || workstation_test_key_fingerprint="4ED79CC3362D7D12837046024A3BE4A92211B03C"
[ -n "$workstation_test_key_file" ] || workstation_test_key_file="$BUILDER_DIR/$SRC_DIR/template-securedrop-workstation/keys/test-key.asc"
[ -n "$workstation_repository_uri" ] || workstation_repository_uri="https://apt-test.freedom.press"
[ -n "$workstation_repository_components" ] || workstation_repository_components="main"
[ -n "$workstation_repository_apt_line" ] || workstation_repository_apt_line="deb $workstation_repository_uri $workstation_repository_suite $workstation_repository_components"
[ -n "$workstation_repository_list" ] || workstation_repository_list="/etc/apt/sources.list.d/securedrop_workstation.list"

# These keys are necessary only for bootstrapping the FPF apt repo config.
# Below, the 'securedrop-keyring' package is installed, which will manage
# key rotation for the life of the template.
$chroot_cmd apt-key add - < "$workstation_test_key_file"
## Sanity test. apt-key adv would exit non-zero if not exactly that fingerprint in apt's keyring.
$chroot_cmd apt-key adv --fingerprint "$workstation_test_key_fingerprint"

echo "${INSTALLDIR}/$workstation_repository_list"
echo "$workstation_repository_apt_line" > "${INSTALLDIR}/$workstation_repository_list"

aptUpdate

aptInstall securedrop-workstation-grsec securedrop-workstation-config securedrop-keyring

# Needed for qubes tooling (qubes-open-in-vm and qubes-copy-to-vm)
# If more pax flags are needed in the future, we should manage them through a config file
$chroot_cmd sh -c 'echo "/usr/lib/gnome-terminal/gnome-terminal-server   m" >> /etc/paxctld.conf'

## Workaround for Qubes bug:
## 'Debian Template: rely on existing tool for base image creation'
## https://github.com/QubesOS/qubes-issues/issues/1055
updateLocale

## Workaround. ntpdate needs to be removed here, because it can not be removed from
## template_debian/packages_qubes.list, because that would break minimal Debian templates.
## https://github.com/QubesOS/qubes-issues/issues/1102
UWT_DEV_PASSTHROUGH="1" aptRemove ntpdate || true

# Disable word-splitting warnings on APT_GET_OPTIONS. It's defined
# as a string, and extended in certain parts of qubes-builder.
# We cannot rewrite the var as type array (which would satisfy shellcheck)
# because we don't maintain that code.
# shellcheck disable=SC2086
UWT_DEV_PASSTHROUGH="1" \
   DEBIAN_FRONTEND="noninteractive" \
   DEBIAN_PRIORITY="critical" \
   DEBCONF_NOWARNINGS="yes" \
      $chroot_cmd "${eatmydata_maybe:-}" \
         apt-get ${APT_GET_OPTIONS} autoremove

## Cleanup.
umount_all "${INSTALLDIR}/" || true
trap - ERR EXIT
trap
