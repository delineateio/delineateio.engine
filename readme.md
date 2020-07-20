<p align="center">
  <img alt="delineate.io" src="https://github.com/delineateio/.github/blob/master/assets/logo.png?raw=true" height="75" />
  <h2 align="center">delineate.io</h2>
  <p align="center">portray or describe (something) precisely.</p>
</p>

#

[![CircleCI](https://circleci.com/gh/delineateio/delineateio.engine.svg?style=shield)](https://circleci.com/gh/delineateio/delineateio.engine)
[![codebeat badge](https://codebeat.co/badges/f382bda1-32b7-406a-b793-9ae515ae8e52)](https://codebeat.co/projects/github-com-delineateio-delineateio-engine-master)
[![Go Report Card](https://goreportcard.com/badge/github.com/delineateio/delineateio.engine)](https://goreportcard.com/report/gtithub.com/delineateio/delineateio.engine)
[![Github All Releases](https://img.shields.io/github/downloads/delineateio/delineateio.engine/total.svg)](https://github.com/delineateio/delineateio.engine/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Purpose

Delineate is a platform for taking business ideas to end users without losing clarity of the orginal idea. This repo will provide the core services for the delineate.io platform.  Currently this repo only contains an example service which has been used to refine the developer workflow and tooling.

Once the project is more elaborated then PR will be actively encouraged.  You can see more on the project standards [here](./docs/standards.md).

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-ff69b4.svg)](https://github.com/delineateio/delineateio.engine/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22+)

## Local Development

> Specific attention has been given minimise the effort required to setup up a working development environment.

The development environment has been implemented by using [hashicorp vagrant](https://www.vagrantup.com/) an automatically configured VM with all the required tools imnstalled.  For more information on `vagrant` review the offical documentation.

### Required Dependencies

|Package|Version|Purpose|Link
|---|---|---|---|
|vagrant|v2.2.9|Manage local VM development machine|[link](https://www.vagrantup.com/)|
|mkcert|v1.4.1|Manage self-signed certificates|[link](https://github.com/FiloSottile/mkcert)|

### Local Configuration

Before running `vagrant` there is some configuration to perform on the local machine.

The following files need to be added in `./vm/config/.env` and export the following variables e.g. `export CLOUDFLARE_EMAIL={EMAIL}`.

* google.env
* cloudflare.env
* snyk.env
* git.env

> More information has been provided on these env variable requirements [here](./docs/env.md).

### SSH Keys

As part of the VM provisioning the identity SSH keys are copied from the host into the VM for `github` authentication.

Once the VM is provisioned use `ssh -T git@github.com` from inside the VM to test the `github` authentication.

### Development VM

After install of `vagrant` the following commands will create the development Ubuntu VM.  The `vagrant` configuration uses `ansible` to configure the VM.

```shell
# Create the VM
vagrant up

# SSH into the VM
vagrant ssh
```

> The `vagrantfile` has been configured to use `vmware fusion` which is a commercial product. If `vmware fusion` is not present provisioning will fallback to `virtualbox`.

More details on exactly what is installed and configured inside the VM can be found [here](./docs/vm.md).

### Host Configuration

After the vagrant VM is stood up there is additional host configuration required to access tools running inside the VM.  Run `./host.sh` to configure the host.

> If the VM is destroyed and recreated then the `host.sh` script will need to be re-run as the self-sign cert will be regenerated.
