> By contributing to this project, you agree to abide by our [Code of Conduct](https://github.com/freedomofpress/.github/blob/main/CODE_OF_CONDUCT.md).

# qubes-template-securedrop-workstation

Repository for managing the TemplateVM RPM used by the [SecureDrop Workstation] in provisioning custom VMs.

## Build instructions

Note that these instructions must be carried out on a Fedora-based Qubes VM.
Building templates uses a substantial amount of disk space.

### Set up build VM:
Set up a long-lived VM that you can use for building SDW templates.
This should be a separate VM from the (Debian-based) `sd-dev` recommended
in the [SDW setup docs](https://github.com/freedomofpress/securedrop-workstation/#development-environment).
You'll only need to perform this step once, although you should confirm
whether your Fedora version remains current each time.

1. Create an AppVM based on the most recent fedora release: `qvm-create --label purple --template fedora-XX sd-template-builder`
2. Increase the disk size to at least 20GB (as the build uses over 10GB): `qvm-volume resize sd-template-builder:private 20G`
3. Clone this repository into the AppVM: `git clone https://github.com/freedomofpress/qubes-template-securedrop-workstation`

### Automatic build
We maintain a wrapper script that handles the interoperation with the upstream [qubes-builder] logic.
Typically, you'll need only this short-and-sweet workflow to build a new template RPM.
If you encounter problems, see the manual build instructions below.

1. Run `sudo dnf upgrade -y` to ensure your machine is up to date.
2. `make template`
3. The Template RPM can be found in `./qubes-builder/qubes-src/linux-template-builder/rpm/`

### Testing changes to builder logic

The qubes-builder logic expects signed tags on the most recent HEAD commit of the target branch.
The tag and commit must be present on the _remote_, i.e. this repository. Simply creating them
locally isn't enough, you'll need to push them up to the remote.
If you're making changes to the build logic in this repo, you won't have a prod-signed tag yet,
since you're still testing! Create a test-only tag signed with your individual GPG key.

0. Make the changes you intend to test on a branch of this repo.
1. Edit `securedrop-workstation.conf` and set ` BRANCH_template_securedrop_workstation ?= <YOUR_BRANCH_NAME>`
2. Edit `build-workstation-template` to include your individual fingerprint, so the tag can be verified
3. Create a signed tag on that branch: `git tag -s $(date +%Y%m%d-test)`, and push to the remote
4. `make template`

As your make changes to the feature branch, you must update or replace the signed git tags, so that HEAD remains signed.
There are settings such as `LESS_SECURE_SIGNED_COMMITS_SUFFICIENT` for the `builder.conf`, which may be useful for testing.

### Manual build

The wrapper script can get out of sync with the qubes-builder logic (which isn't pinned via submodule,
see [relevant issue](https://github.com/freedomofpress/qubes-template-securedrop-workstation/issues/14)).
If that happens, run through the steps manually. The steps below closely mirror the script logic within
`build-workstation-template`, so compare with the latest there.

1. Import and trust the [Qubes Master Key](https://www.qubes-os.org/security/verifying-signatures/)
   and the SecureDrop Release Signing Key to the local gpg keyring in your `sd-template-builder` AppVM.
2. Clone the [qubes-builder] repository
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
qvm-run --pass-io sd-template-builder 'cat source/file/location' > destination/sdw.rpm
sudo dnf install sdw.rpm
```

2. Create a VM based on this template for testing:

```
qvm-create --template securedrop-workstation-buster test-sdw-buster --class AppVM --property virt_mode=hvm --property kernel='' --label green
```

## Acknowledgments
This work was inspired by and reuses code from the Whonix Qubes template: https://github.com/adrelanos/qubes-template-whonix
It is a derivative work under the GPL license, version 3 (see the files `COPYING` and `GPLv3` for details)


[SecureDrop Workstation]: https://github.com/freedomofpress/securedrop-workstation
[qubes-builder]: https://github.com/qubesos/qubes-builder
