PLATFORMS ?= darwin/amd64 linux/amd64 windows/amd64

all: make-binaries

make-binaries: age-binaries kustomize-binaries

age-binaries:
	cd $$(go env GOPATH)/src/filippo.io/age; \
	for platform in $(PLATFORMS); do \
	  GOOS=$$(cut -d / -f1 <<<$$platform); \
	  GOARCH=$$(cut -d / -f2 <<<$$platform); \
	  GOOS=$$GOOS GOARCH=$$GOARCH go build -ldflags="-s -w" -trimpath -o $$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD) ./cmd/age; \
	  upx $$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD); \
	  cp $$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD) $(CURDIR)/bin; \
	done

kustomize-binaries:
	cd $$(go env GOPATH)/src/sigs.k8s.io/kustomize/kustomize; \
	for platform in $(PLATFORMS); do \
	  GOOS=$$(cut -d / -f1 <<<$$platform); \
	  GOARCH=$$(cut -d / -f2 <<<$$platform); \
	  GOOS=$$GOOS GOARCH=$$GOARCH go build -ldflags="-s -w" -trimpath -o $$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD) .; \
	  upx $$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD); \
	  cp $$(basename $$PWD)-$$GOOS-$$GOARCH-$$(git rev-parse --short=8 HEAD) $(CURDIR)/bin; \
	done
