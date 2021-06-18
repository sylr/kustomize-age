PLATFORMS ?= darwin/amd64 linux/amd64 windows/amd64
GOPATH     = /tmp/go-kustomize-age

GO                  ?= go
AGE_SRC             ?= $(GOPATH)/src/filippo.io/age
AGE_SYLR_REPO       ?= https://github.com/sylr/age.git
KUSTOMIZE_SRC       ?= $(GOPATH)/src/sigs.k8s.io/kustomize/kustomize
KUSTOMIZE_SYLR_REPO ?= https://github.com/sylr/kustomize.git

KUSTOMIZE_AGE_SUPPORT_COMMIT ?= b8dce3201b944037333374bf551b84954132e946

export GOPATH

.PHONY: all make-binaries kustomize-git-reset kustomize-binary

all: make-binaries

make-binaries: kustomize-binary

$(KUSTOMIZE_SRC):
	# mkdir -p $(shell dirname $(KUSTOMIZE_SRC))
	git clone $(KUSTOMIZE_SYLR_REPO) $(shell dirname $(KUSTOMIZE_SRC))

kustomize-git-reset:
	git -C "$(KUSTOMIZE_SRC)/.." remote add sylr $(KUSTOMIZE_SYLR_REPO) || true
	git -C "$(KUSTOMIZE_SRC)/.." remote update
	git -C "$(KUSTOMIZE_SRC)/.." rev-parse --verify kustomize-age || git -C "$(KUSTOMIZE_SRC)/.." checkout -b kustomize-age $(KUSTOMIZE_AGE_SUPPORT_COMMIT)
	git -C "$(KUSTOMIZE_SRC)/.." rev-parse --verify kustomize-age && git -C "$(KUSTOMIZE_SRC)/.." checkout kustomize-age && git -C "$(KUSTOMIZE_SRC)/.." reset --hard $(KUSTOMIZE_AGE_SUPPORT_COMMIT)

kustomize-binary: $(KUSTOMIZE_SRC) kustomize-git-reset
	cd $(KUSTOMIZE_SRC); \
	for platform in $(PLATFORMS); do \
	  GOOS=$$(cut -d / -f1 <<<$$platform); \
	  GOARCH=$$(cut -d / -f2 <<<$$platform); \
	  OUTPUT=$$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD); \
	  test "$$GOOS" == "windows" && OUTPUT=$${OUTPUT}.exe; \
	  GOOS=$$GOOS GOARCH=$$GOARCH go build -ldflags="-s -w" -trimpath -o $$OUTPUT .; \
	  cp $$OUTPUT $(CURDIR)/bin; \
	done
