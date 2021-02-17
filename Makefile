PLATFORMS ?= darwin/amd64 linux/amd64 windows/amd64
GOPATH     = /tmp/go-kustomize-age

GO                  ?= go
AGE_SRC             ?= $(GOPATH)/src/filippo.io/age
AGE_SYLR_REPO       ?= https://github.com/sylr/age.git
KUSTOMIZE_SRC       ?= $(GOPATH)/src/sigs.k8s.io/kustomize/kustomize
KUSTOMIZE_SYLR_REPO ?= https://github.com/sylr/kustomize.git

AGE_YAML_SUPPORT_COMMIT      ?= d3cd2ad563ad35a349339e899a8ed39f7e29dc02
KUSTOMIZE_AGE_SUPPORT_COMMIT ?= be09d792963483bf6c5f82aa6b36d522ee963634

export GOPATH

.PHONY: all make-binaries age-git-reset kustomize-git-reset age-binaries kustomize-binaries

all: make-binaries

make-binaries: age-binaries kustomize-binaries

$(AGE_SRC):
	GOPATH=$(GOPATH) $(GO) get -d filippo.io/age/...

age-git-reset:
	git -C "$(AGE_SRC)" remote add sylr $(AGE_SYLR_REPO) || true
	git -C "$(AGE_SRC)" remote update
	git -C "$(AGE_SRC)" rev-parse --verify kustomize-age || git -C "$(AGE_SRC)" checkout -b kustomize-age $(AGE_YAML_SUPPORT_COMMIT)
	git -C "$(AGE_SRC)" rev-parse --verify kustomize-age && git -C "$(AGE_SRC)" checkout kustomize-age && git -C "$(AGE_SRC)" reset --hard $(AGE_YAML_SUPPORT_COMMIT)

$(KUSTOMIZE_SRC):
	GOPATH=$(GOPATH) $(GO) get -d sigs.k8s.io/kustomize/kustomize/...

kustomize-git-reset:
	git -C "$(KUSTOMIZE_SRC)/.." remote add sylr $(KUSTOMIZE_SYLR_REPO) || true
	git -C "$(KUSTOMIZE_SRC)/.." remote update
	git -C "$(KUSTOMIZE_SRC)/.." rev-parse --verify kustomize-age || git -C "$(KUSTOMIZE_SRC)/.." checkout -b kustomize-age $(KUSTOMIZE_AGE_SUPPORT_COMMIT)
	git -C "$(KUSTOMIZE_SRC)/.." rev-parse --verify kustomize-age && git -C "$(KUSTOMIZE_SRC)/.." checkout kustomize-age && git -C "$(KUSTOMIZE_SRC)/.." reset --hard $(KUSTOMIZE_AGE_SUPPORT_COMMIT)

age-binaries: $(AGE_SRC) age-git-reset
	cd $(AGE_SRC); \
	for platform in $(PLATFORMS); do \
	  GOOS=$$(cut -d / -f1 <<<$$platform); \
	  GOARCH=$$(cut -d / -f2 <<<$$platform); \
	  OUTPUT=$$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD); \
	  test "$$GOOS" == "windows" && OUTPUT=$${OUTPUT}.exe; \
	  GOOS=$$GOOS GOARCH=$$GOARCH go build -ldflags="-s -w" -trimpath -o $$OUTPUT ./cmd/age; \
	  upx $$OUTPUT; \
	  cp $$OUTPUT $(CURDIR)/bin; \
	done

kustomize-binaries: $(KUSTOMIZE_SRC) kustomize-git-reset
	cd $(KUSTOMIZE_SRC); \
	for platform in $(PLATFORMS); do \
	  GOOS=$$(cut -d / -f1 <<<$$platform); \
	  GOARCH=$$(cut -d / -f2 <<<$$platform); \
	  OUTPUT=$$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD); \
	  test "$$GOOS" == "windows" && OUTPUT=$${OUTPUT}.exe; \
	  GOOS=$$GOOS GOARCH=$$GOARCH go build -ldflags="-s -w" -trimpath -o $$OUTPUT .; \
	  upx $$OUTPUT; \
	  cp $$OUTPUT $(CURDIR)/bin; \
	done
