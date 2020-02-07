# qubes-template-securedrop-workstation

This work was inspired by and reuses code from the Whonix Qubes template: https://github.com/adrelanos/qubes-template-whonix
It is a derivative work under the GPL license, version 3 (see the files `COPYING` and `GPLv3` for details)


## Build instructions

Note that these instructions must be carried out on a Fedora-based Qubes VM. Building templates uses a substantial amount of disk space.
Your VM should have at least 20GB available for use in the private volume.

### Automatic build

1. `make template`

### Testing changes to builder logic

1. Repace the following value in `securedrop-workstation.conf`: ` BRANCH_template_securedrop_workstation ?= $TEST_BRANCH` 
2. Sign the tag using a trusted key (or edit the `builder/build-workstation-template` script to import/trust the key)
3. `make template`

### Manual build

0. Import and trust the [Qubes Master Key](https://www.qubes-os.org/security/verifying-signatures/) and the FPF authority key into your gpg keyring or GPG domain's keyring.
1. Clone the [qubes-builder repository](https://github.com/qubesos/qubes-builder)
2. Change directories into the `qubes-builder` repo
3. Copy the `securedrop-workstation.conf` from this repo as `builder.conf` inside the `qubes-builder` repo
4. `make about` should return `securedrop-workstation.conf`
5. Run `make install-deps`
6. Run `make get-sources`
7. Run `make qubes-vm`
8. Run `make template`
9. The built template RPM will be in `qubes-builder/qubes-src/linux-template-builder/rpm/noarch`

## Installation instructions

Copy either the rpm OR `install-templates.sh` script in qubes-builder/qubes-src/linux-template-builder/rm/install-templates.sh

In dom0, run:

```
qvm-run --pass-io work 'cat source/file/location' > destination/file/location
sudo rpm -i template.rpm
```
