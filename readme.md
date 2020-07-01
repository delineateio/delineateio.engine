# Delineate Engine

[![CircleCI](https://circleci.com/gh/delineateio/delineateio.engine.svg?style=shield)](https://circleci.com/gh/delineateio/delineateio.engine)

## Purpose

The purpose of this project is to provide core services for the delineate.io engine.

Currently this repo only contains an example service which has been used to refine the developer workflow and tooling that will be used to develop the ongoing features.

## Principles

* All dependencies must be strongly versioned (e.g. image tags, package versions, tool versions) to mitigate any version drift that causes unexpected issues
* All sensitive keys must be stored in `./.env` so that they are excluded from being committed to the remote repo
* All files related to a specific service must be contained in a service sub directory in `./dev/services` to mitigate tight coupling

## Required Secrets

The following secrets should be stored within `./.env` directory.  These will need to be confirmed on a user by user basis.  These secrets are appended into the `~/.bash_file` so are available at runtime.

### Cloudflare Credentials

The `./.env/cloudflare.env` needs to be present contain the following env variables.

```shell
export CLOUDFLARE_EMAIL=${VAR}
export CLOUDFLARE_ZONE=${VAR}
export CLOUDFLARE_TOKEN=${VAR}
```

Review the Cloudflare documentation [here](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys) for more detailson obtaining the credentials info.

### GCP Service Account Key

The `./.env/gcloud.json` file is required to contain a GCP service account key with the required permissions. Please refer to the [GCP Documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for creating service account keys if required.

### Snyk Token

The `./.env/snyk.env` should be present and a API token for an `snyk` account.

```shell
export SNYK_TOKEN=${VAR}
```

To obtain a token the [offical documentation](https://support.snyk.io/hc/en-us/articles/360004037557-Authentication-for-API) should be consulted if required.

## Development Environment

### Overview

To make setup of the development environment as easy as possible a Hashicorp Vagrant file has been provided with an Ansible playbooks to install dependencies.

*Please note that the `vagrantfile` contains specific configuration to run using VMWare provider, which is a commercial product.  This can be commented out if required, for example to use Virtualbox.*

### Installed Components

The `vagrantfile` ensures that the following components are installed and configured correct to provide a fully formed developer desktop.

* [Microk8s](https://microk8s.io/) -> Local K8s cluster
* [Docker](https://www.docker.com/) -> standard containerisation functionality
* [Skaffold](https://skaffold.dev/) -> Support easier deployments to clusters
* [Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) -> Interact with local and cloud hosed clusters
* [Httpie](https://httpie.org/) -> HTTP/S requests from the command line
* [Snyk](https://snyk.io/) -> Container security platform
* [Trivy](https://github.com/aquasecurity/trivy) -> Additional OSS container scanning
* [Terraform](https://www.terraform.io/) - Provisioning of cloud infrastructure
* [Packer](https://www.packer.io/) - Provisioning of cloud VM images
* [gCloud](https://cloud.google.com/sdk) - Interact with Google Cloud Platform
* [Go](https://golang.org/) - Core `golang` and associated libraries
* [Git](https://git-scm.com/) -> Source code management
* [yq](https://github.com/mikefarah/yq) -> Command line for working with `yaml`
* [jq](https://stedolan.github.io/jq/) -> Command line for working with `json`
* [Shellcheck](https://github.com/koalaman/shellcheck) -> Shell script static code analysis
* [Siege](https://github.com/JoeDog/siege) -> Command line for loading basic load testing of HTTP endpoints
* [CircleCI](https://circleci.com/docs/2.0/local-cli/) -> Local features for validating config and testing CircleCI jobs

## Host Machine

## Desktop Requirements

No other mandatory software required to be installed on the desktop except for `vagrant` which provides a consistent developer desktop.  The [getting started](https://www.vagrantup.com/intro) have the details on the installation and getting started with `vagrant`.

The `.vscode` folder has intentionally been committed to the repo so that convience lauches are immedaitely available as required.  However it is not manadatory to use VSCode.

### Vagrant Command

For details on using Vagrant the [offical documentation](https://www.vagrantup.com) is a great place to start.  The basic commands are:

```shell
# Provisions the VM & SSH in
vagrant up --provision
vagrant ssh

# Restarts the VM
vagrant reload

# Destroy the VM
vagrant destroy
```

## Git Configuration

Git configuration is difficult to fully automate.  Currently configuration is semi automated.  For now the SSH key is copied from the host to the guest VM to replicate the host user identity when interacting with `git`.  There maybe a better way so all proposals are welcome!

## Useful Scripts

The following documented scripts have been provided for convience to aid development rather than hand crafting repetitive commands.

### Container Script

The `./dev/services/container.sh $SERVICE` script performs a series of steps that can be run by developers to validate the quality of a specific service container.

The script runs the following steps:

* Static code analysis using [staticcheck](https://staticcheck.io/)
* Runs unit tests implemented using [go test](https://golang.org/pkg/cmd/go/internal/test/)
* Runs HTTP tests implemented using [go test](https://golang.org/pkg/cmd/go/internal/test/)
* Static code security scann is performed through [go sec](https://github.com/securego/gosec)
* Container structure test using [structure tests](https://github.com/GoogleContainerTools/container-structure-test)
* Container security scan using [snyk](https://snyk.io/)
* Container security scan using [trivy](https://github.com/aquasecurity/trivy)

### Up Script

The `up` script provided at `./dev/stack/up.sh` uses `docker-compose` to stand up a lightweight stack for testing purposes.  Re-running the script will take down and they put up the stack.

For the full documentation please refer to `docker` and the `docker-compose` [offical documentation](https://github.com/docker/compose).

```shell
# Displays the running containers
docker ps

# Retrieves the logs for the specificed container
docker logs $CONTAINER
```

### Local Script

The script provided at `./dev/services/local.sh $SERVICE` will switch to the local `microk8s` cluster and  use `skaffold` to deploy the specified service.

```shell
# To list the pods post deployment
kubectl get pods

# Retrieve
kubectl logs $POD $CONTAINER

# Delete a specific pod
kubectl delete pods $POD

# Deletes all the pods in the current namespace
kubectl delete pods --all
```

## Host Debugging

Debugging is undertaken from in the main from the host desktop using the developers IDE of choice.

To enable this there is port forwarding implemented between the host and the guest for port `5432` to enable connection to `postgres` which is running inside the guest VM.  This is configured within `./vagrantfile`.
