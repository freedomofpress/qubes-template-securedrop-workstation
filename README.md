# qubes-template-securedrop-workstation

This work was inspired by and reuses code from the Whonix Qubes template: https://github.com/adrelanos/qubes-template-whonix
It is a derivative work under the GPL license, version 3 (see the files `COPYING` and `GPLv3` for details)


## Build instructions

Note that these instructions must be carried out on a Fedora-based Qubes VM. Building templates uses a substantial amount of disk space.

### Set up build VM:
1. Create a fedora-31 based AppVM for building the templates
2. Increase the disk size to at least 20GB (as the build uses over 10GB): qvm-volume extend sd-template-builder:private 15GB (if your VM is not named sd-template-builder, adjust that command)
3. Import the QubesOS master key and the GPG key used to sign tags (see https://www.qubes-os.org/security/verifying-signatures/)

### Automatic build

1. `make template`
2. The Template RPM can be found in ./qubes-builder/qubes-src/linux-template-builder/rpm/

### Testing changes to builder logic

1. Repace the following value in `securedrop-workstation.conf`: ` BRANCH_template_securedrop_workstation ?= $TEST_BRANCH` 
2. Sign the tag using a trusted key (or edit the `builder/build-workstation-template` script to import/trust the key)
3. `make template`

### Manual build

1. Import and trust the [Qubes Master Key](https://www.qubes-os.org/security/verifying-signatures/) and the FPF authority key into your gpg keyring or GPG domain's keyring
2. Clone the [qubes-builder repository](https://github.com/qubesos/qubes-builder)
3. Change directories into the `qubes-builder` repo
4. Copy the `securedrop-workstation.conf` from this repo as `builder.conf` inside the `qubes-builder` repo
5. `make about` should return `securedrop-workstation.conf`
6. Run `make install-deps`
7. Run `make get-sources`
8. Run `make qubes-vm`
9. Run `make template`
10. The built template RPM will be in `qubes-builder/qubes-src/linux-template-builder/rpm/noarch`

## Installation instructions

1. Copy the template to dom0:

```
qvm-run --pass-io work 'cat source/file/location' > destination/<file>.rpm
sudo rpm -i <file>.rpm
```

2. Create a VM based on this template for testing:

```
qvm-create --template securedrop-workstation test-securedrop-workstation --class AppVM --property virt_mode=hvm --property kernel='' --label green
```
