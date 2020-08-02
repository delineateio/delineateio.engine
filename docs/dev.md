<p align="center">
  <img alt="delineate.io" src="https://github.com/delineateio/.github/blob/master/assets/logo.png?raw=true" height="75" />
  <h2 align="center">delineate.io</h2>
  <p align="center">portray or describe (something) precisely.</p>
</p>

# Standards

## Contributions

**The project is looking for contributors and collaborators**. If you are interested in contributing then please refer to the organisation [Code of Conduct](https://github.com/delineateio/.github/blob/master/CODE_OF_CONDUCT.md) and [Contributing Guidelines](https://github.com/delineateio/.github/blob/master/CONTRIBUTING.md).

## Key Principles

|Name|Description|Rationale|Consequences|
|---|---|---|---|
|**Dependency Versioning**|All dependencies are to be strongly versioned (e.g. image tags, package versions, tool versions).| The purpose of this principle is to mitigate any version drift that causes unexpected issues|By strongly versioning dependencies this does mean that versions will need to be bumped regularly.
|**Secrets Management**|All local secrets are to be stored outside the working tree.|This is to limit the likelihood of secrets being committed via `git` unintentionally.| Whereever possible secrets should be stored remotely and in secret management solutions.
|**Microservice Isolation**|All files related to a specific service are to be isolated in a service sub directory.|By isolating services like this it makes them portable via [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).|This means careful design of the repo structure as the solution evolves.

> Please note that additional steps have been taken to avoid unintentional commiting of secrets.  This is documented in more detail within the Development Standards below (e.g. Detect Secrets `git` hook).

## Development Standards

### Pre-Commit Checks

Quality checks are provided through the excellent [pre-commit](https://pre-commit.com/) framework for managing `git hooks`.  The configuration of these hooks can be seen by reviewing `./.pre-commit-config.yaml`.  The following checks are being applied:

* Golang linting
* CircleCI validation
* Ansible linting
* Terraform validation
* Terraform linting
* Detect secrets
* Yaml validation
* Check for large files
* Fix file ending between

`pre-commit` will be automatically run when `git commit` is invoked or can be manually invoked at any time.

```shell
# invoke checks manually
pre-commit
```

### Detect Secrets

To ensure that secrets are not intentionally committed to `git` the [detect secrets](https://github.com/Yelp/detect-secrets).  If during `git commit` operation potential secrets are identified these should be properly investigated before following the documented instructions to resolve.

### IDE Use

> Whilst any IDE can be used the `vscode` config has been committed given it's wide use within the community.

## Environments

There are a number of environments that have been setup and defined through which changes are developed and then strictly promoted.

|Prefix|Domain|Description|Updated By|
|---|---|---|---|
|**dev**|delineate.dev|Cloud environment that can updated manually by developers and is updated by the CI/CD pipeline on a push to a non-controlled branch.|Manual & CircleCi|
|**pub**|delineate.pub|Cloud published envoironment (a.k.a. pub) that is the pre-production staging environment.  The environment is controlled and can not be updated manually, it is updated by merging PR to the `main` branch|CircleCI|

> In addition to the above the repo and configuration has been setup so that services can be debugged from the host machine using a `debug` configuration.
