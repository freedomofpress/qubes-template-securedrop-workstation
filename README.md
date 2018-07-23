# qubes-template-securedrop-workstation

Work in progress, not suitable for production use.

This work was inspired by and reuses code from the Whonix Qubes template: https://github.com/adrelanos/qubes-template-whonix

It is a derivative work under the GPL license, version 3 (see the files `COPYING` and `GPLv3` for details)


## Build instructions

0. Ensure your .gitconfig contains qubes-gpg-client-wrapper and import the Qubes Master Key (https://www.qubes-os.org/security/verifying-signatures/)
:
```
...
[gpg]
	program = qubes-gpg-client-wrapper
...

### Automatic build
0. Checkout the securedrop workstation repo https://github.com/freedomofpress/securedrop-workstation
1. Navigate to the `builder` directory and run `build-securedrop-template`

### Manual build
```
0. Clone the qubes-builder repository
2. Copy the securedrop-workstation.conf  ../../builder.conf
3. `make about` should return `securedrop-workstation.conf`
4. run `make get-deps`
5. run `make get-sources`
6. run `make qubes-vm`
7. run `make template`
8. The built template RPM will be in qubes-builder/qubes-src/linux-template-builder/rpm/noarch

## Installation instructions

Copy either the rpm OR `install-templates.sh` script in qubes-builder/qubes-src/linux-template-builder/rm/install-templates.sh
In dom0, run:
```
qvm-run --pass-io work 'cat source/file/location' > destination/file/location
sudo rpm -i template.rpm
```
