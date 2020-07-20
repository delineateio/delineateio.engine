<p align="center">
  <img alt="delineate.io" src="https://github.com/delineateio/.github/blob/master/assets/logo.png?raw=true" height="75" />
  <h2 align="center">delineate.io</h2>
  <p align="center">portray or describe (something) precisely.</p>
</p>

# Enviroment Variables

**Before** provisioning the VM the following files need to be present in `./vm/config/.env`

## cloudflare.env

```shell
export CLOUDFLARE_EMAIL= # Email of the cloudflare account
export CLOUDFLARE_API_KEY= # API key for the cloudflare account
export CLOUDFLARE_ZONE= # Zone for the cloudflare account
export CLOUDFLARE_DOMAIN= # The development cloudflare domain
```

## git.env

```shell
export GIT_NAME= # Real name of the git user
export GIT_EMAIL= # Email address of the git user
```

## google.env

```shell
export GOOGLE_APPLICATION_CREDENTIALS= # location of service key
export GOOGLE_PROJECT= # project id
export GOOGLE_REGION= # default compute region
export GOOGLE_ZONE= # default compute zone
export GOOGLE_CLUSTER_NAME= # name of the cluster
export GOOGLE_SERVICE_ACCOUNT= # Service account of the key
export GOOGLE_REGISTRY= # GCR Registry
```

## synk.env

```shell
export SNYK_TOKEN= # synk account token
```
