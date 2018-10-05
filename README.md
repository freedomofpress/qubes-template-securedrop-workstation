# qubes-template-securedrop-workstation

Work in progress, not suitable for production use.

This work was inspired by and reuses code from the Whonix Qubes template: https://github.com/adrelanos/qubes-template-whonix

It is a derivative work under the GPL license, version 3 (see the files `COPYING` and `GPLv3` for details)


## Build instructions

Note that these instructions must be carried out on a Fedora-based Qubes VM. Building templates uses a substantial amount of disk space- your VM should have at least 20GB available for use.

These scripts validate GPG signatures from upstream repos. So before getting started, we'll need to do a couple of things.

First, make sure you've installed Qubes split-gpg tools in the VM you're using to build the templates:

    $ sudo dnf install qubes-gpg-split

Configure your shell to use the right gpg VM (adjust if you're using a different gpg VM):

    $ export QUBES_GPG_DOMAIN=gpg

You should add that line to your .bashrc or equivalent as well. 

Ensure your `~/.gitconfig` is configured to use `qubes-gpg-client-wrapper:

    ...
    [gpg]
    	program = qubes-gpg-client-wrapper
    ...


Finally, be sure to import the Qubes Master Key to your GPG domain. See (https://www.qubes-os.org/security/verifying-signatures/). You may need also to import Qubes developer keys- see https://www.qubes-os.org/security/pack/. You'll also need to import and trust Mickael's key if you haven't, and eventually other FPF developers as well.

### Automatic build

0. Checkout the securedrop workstation repo https://github.com/freedomofpress/securedrop-workstation
1. Navigate to the `builder` directory and run `build-securedrop-template`

### Manual build

0. Clone the qubes-builder repository
2. Copy the securedrop-workstation.conf  ../../builder.conf
3. `make about` should return `securedrop-workstation.conf`
4. run `make install-deps`
5. run `make get-sources`
6. run `make qubes-vm`
7. run `make template`
8. The built template RPM will be in qubes-builder/qubes-src/linux-template-builder/rpm/noarch

## Installation instructions

Copy either the rpm OR `install-templates.sh` script in qubes-builder/qubes-src/linux-template-builder/rm/install-templates.sh

In dom0, run:

    qvm-run --pass-io work 'cat source/file/location' > destination/file/location
    sudo rpm -i template.rpm
