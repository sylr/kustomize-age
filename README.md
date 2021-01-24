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

## Example

### Encrypt YAML with age
```shell
# assets/config.yaml will be crypted with 2 keys
$ age-darwin-amd64-d3cd2ad5 -R ~/.ssh/id_ed25519.pub -R ./age.pub -y assets/config.yaml | tee assets/config.yaml.age
this-is-a-config: hehehe
this-is-a-credential: !crypto/age:NoTag |-
  -----BEGIN AGE ENCRYPTED FILE-----
  YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IHNzaC1lZDI1NTE5IGYxc1ZMQSBlbTVY
  NFBhZmpOazZFN1VWdEwyVkRwME9ZT2NlOU5XTlZlcm1SY0JXZWdJCnJxZlZGQ05j
  b0NuWkpFTzNiNW5nVmNiVi9YWGdSc0dOd2xFNnRlMDNvQTgKLT4gWDI1NTE5IHRk
  L1ZwSDlmZzJzVm9CeFFrTWgzRnUrUTdqTjJUdXVITWRBZ09VRk14a2sKZVArMTRz
  amhUM0x4Q0RYMU55SmxJbW1aWkVubm94UHZhYklyUHZZZ3hUSQotLS0gbm5TejNm
  MGtHckg3VHBTa1ovbHp5dUtnMXdPU1NQTGxMTWJOZnJjc1VZZwpQJ4yennXD9GU5
  9RR9cIiTeQ7wr5eAQwTqoUcy2tTI7y9AykCzaA72Z06ruBrC+0gPeJrq2ZOFna4Y
  uAVOmxQG7p8i0hZWFFe2dHLz/r0=
  -----END AGE ENCRYPTED FILE-----
this-is-another-config: hahaha
```

### Decrypt YAML with age
```shell
# assets/config.yaml.age is decrypted using ~/.ssh/id_ed25519
$ age-darwin-amd64-d3cd2ad5 -d -y assets/config.yaml.age
Enter passphrase for "/Users/sylr/.ssh/id_ed25519":
this-is-a-config: hehehe
this-is-a-credential: MyVerySecretPasswordWhichShouldNotBeClearInGit
this-is-another-config: hahaha
```

### Kustomize build
```shell
$ kustomize-darwin-amd64-9cf05d72 build .
Enter passphrase for "/Users/s.rabot/.ssh/id_ed25519":
apiVersion: v1
data:
  config.yaml: |
    this-is-a-config: hehehe
    this-is-a-credential: MyVerySecretPasswordWhichShouldNotBeClearInGit
    this-is-another-config: hahaha
kind: ConfigMap
metadata:
  name: myconfig-f5m5dh6844
```

### Re-key age encrypted file with a different set of keys
```shell
# assets/config.yaml.age is decrypted using ~/.ssh/id_ed25519 and then recrypted
# using only the ./age.pub key
$ age-darwin-amd64-d3cd2ad5 -d -y --yaml-discard-notag assets/config.yaml.age | \
    age-darwin-amd64-d3cd2ad5 -R ./age.pub -y
Enter passphrase for "/Users/sylr/.ssh/id_ed25519":
this-is-a-config: hehehe
this-is-a-credential: !crypto/age:NoTag |-
  -----BEGIN AGE ENCRYPTED FILE-----
  YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSAybVI4ZEl2eVIxUnNRU2w1
  N2xIdnhiWlVXR1hrcTlHRUI5d2d6ZVRwWlNzCjMzQzJFdGtQaUdwR3hUSUphOUhP
  TXFmaWJacVR4SFQrYXByREp4ay9WNEkKLS0tIERNWFRvLytzUUhEaTl3WThPTDVJ
  MTVwYmhqYzhsby9zZmY1b1hlSGJnR2MKd8nAjUkEovGVZoEtlBfe30H8zxeEY6Rd
  FUfgKGWqjX/Zr6eOAncTKDR6Oaoyeb4PBbvS0SoBfBcBh4sbozf8YHUIuwTvkFOZ
  fvaicZmG
  -----END AGE ENCRYPTED FILE-----
this-is-another-config: hahaha
```
