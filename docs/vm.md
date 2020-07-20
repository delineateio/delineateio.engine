<p align="center">
  <img alt="delineate.io" src="https://github.com/delineateio/.github/blob/master/assets/logo.png?raw=true" height="75" />
  <h2 align="center">delineate.io</h2>
  <p align="center">portray or describe (something) precisely.</p>
</p>

# Provisioned VM

## Installed Components

The `vagrantfile` ensures that the following components are installed and configured correct to provide a fully formed developer desktop.

|Tool|Use|
|---|---|
|[Go](https://golang.org/)|Core `golang` and associated libraries
|[golangci-lint](https://golangci-lint.run/)|Fast application of multiple `golang` linters|
|[Git](https://git-scm.com/)|Source code management|
|[pre-commit](https://pre-commit.com/)|Framework for using `git` hooks|
|[Detect Secrets](https://github.com/Yelp/detect-secrets)|Integrates with `pre-commit` to mitigate secrets commits|
|[yq](https://github.com/mikefarah/yq)|Command line for working with `yaml`|
|[jq](https://stedolan.github.io/jq/)|Command line for working with `json`|
|[Shellcheck](https://github.com/koalaman/shellcheck)|Shell script static code analysis|
|[Siege](https://github.com/JoeDog/siege)|Command line for loading basic load testing of HTTP endpoints|
|[Httpie](https://httpie.org/)|HTTP/S requests from the command line|
|[Microk8s](https://microk8s.io/)|Local `k8s` cluster|
[Octant](https://octant.dev/)|Provide visual insight into multiple `k8s` clusters|
|[Docker](https://www.docker.com/)|Standard containerisation functionality|
|[Skaffold](https://skaffold.dev/)|Support easier deployments to clusters|
|[Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)|Interact with local and cloud hosted `k8s` clusters|
|[Image Structure Test](https://github.com/GoogleContainerTools/container-structure-test)|Test structure of images after Docker image builds|
|[Snyk](https://snyk.io/)|Container security platform|
|[Trivy](https://github.com/aquasecurity/trivy)|Additional OSS container scanning from Aqua security|
|[gCloud](https://cloud.google.com/sdk)|Interact with Google Cloud Platform|
|[Terraform](https://www.terraform.io/)|Provisioning of cloud infrastructure|
|[Packer](https://www.packer.io/)|Provisioning of cloud VM images
|[CircleCI](https://circleci.com/docs/2.0/local-cli/)|Local features for validating config and testing `circleci` jobs|
|[NGINX](https://www.nginx.com/)|Secure reverse proxy into the VM services|

### Postgres Database

Debugging is undertaken from in the main from the host desktop using the developers IDE of choice. A postgres database runs inside the VM with port forwarding from the host therefore avoiding manual setup on the host.

### Services

The following services are installed:

|Service|Purpose|
|---|---|
|nginx.service|Routes the reverse proxy to route traffic from the host|
|octant.service|Runs the VMWare Octant application for insight into 'k8s'|

If the services need to be managed the standard `systemd` commands can be used:

```shell
systemctl daemon-reload
systemctl enable $SERVICE
systemctl start $SERVICE
systemctl status $SERVICE
```
