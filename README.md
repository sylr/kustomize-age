# kustomize+age

This is a demo repository to demonstrate how we could encrypt data with [age](https://github.com/FiloSottile/age)
in a kustomization git repository and have `kustomize` decrypt them at build time.

The `age.key` file is here for the demo, in real life it __SHOULD ABSOLUTELY NOT__ be
checked in the repository otherwise all secrecy purposes would be defeated.

By default `kustomize` and `age` look for ssh keys to use as identities in `~/.ssh/id_rsa` and `~/.ssh/id_ed25519`.
If those files exists kustomize will try to use them to decrypt data so you don't need to specify anything in `ageIdentities`
if the data have been encrypted with one of these keys' public key.

## Binaries

You'll find binaries of age with YAML support and kustomize with age support at https://github.com/sylr/kustomize-age/releases.

## Pull requests

- https://github.com/FiloSottile/age/pull/162
- https://github.com/kubernetes-sigs/kustomize/pull/3313

## Kustomization

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
configMapGenerator:
- name: myconfig
  files:
  - assets/config.yaml.age # reference to the encrypted yaml
  ageIdentities:
  - ./age.key
```

## Build
```shell
$ kustomize-$(go env GOOS)-$(go env GOARCH)-xxxxxxxx build .
apiVersion: v1
data:
  config.yaml: |
    this-is-a-config: hehehe
    this-is-a-credential: !crypto/age |
      MyVerySecretPasswordWhichShouldNotBeClearInGit
    this-is-anoter-config: hahaha
kind: ConfigMap
metadata:
  name: myconfig-mdc8kgh747
```
