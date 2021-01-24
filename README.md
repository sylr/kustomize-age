# kustomize+age

This is a demo repository to demonstrate how we could encrypt data with [age](https://github.com/FiloSottile/age)
in a kustomization git repository and have `kustomize` decrypt them at build time.

The `age.key` file is here for the demo, in real life it __SHOULD ABSOLUTELY NOT__ be
checked in the repository otherwise all secrecy purposes would be defeated.

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
$ bin/kustomize-v3.8.7-162-gd5c7bf48-$(go env GOOS)-$(go env GOARCH) build .
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
