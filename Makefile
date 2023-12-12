# ____________________________________________________________________________________________________ #
# Functions && Properties start block
# ____________________________________________________________________________________________________ #

PROJECT_PATH=github.com/evgenivanovi
PROJECT_NAME=platform-proto
PROJECT_NAME_GO=$(PROJECT_NAME)-go
PROJECT_NAME_JAVA=$(PROJECT_NAME)-java
PROJECT_NAME_KOTLIN=$(PROJECT_NAME)-kt

API_PB_GO_MODULE_NAME=$(PROJECT_PATH)/$(PROJECT_NAME_GO)
API_PB_JAVA_MODULE_NAME=$(PROJECT_PATH)/$(PROJECT_NAME_JAVA)
API_PB_KOTLIN_MODULE_NAME=$(PROJECT_PATH)/$(PROJECT_NAME_KOTLIN)

API_PB_SRC_PATH=$(CURDIR)
API_PB_GEN_PATH=$(CURDIR)/gen

API_PB_GO_GEN_PATH=$(API_PB_GEN_PATH)/go
API_PB_GO_GEN_FULL_PATH=$(API_PB_GO_GEN_PATH)/$(API_PB_GO_MODULE_NAME)

# __________________________________________________ #
# GO Properties
# __________________________________________________ #

GOBIN?=$(GOPATH)/bin
LOCAL_BIN:=$(CURDIR)/bin
export PATH:=$(PATH):$(GOBIN)

# ____________________________________________________________________________________________________ #
# Functions && Properties end block
# ____________________________________________________________________________________________________ #

# ____________________________________________________________________________________________________ #
# Scripts start block
# ____________________________________________________________________________________________________ #

.PHONY: init
init:
	@echo 'Project initialization.'

	@echo 'Installing dependencies.'

	@mkdir -p $(LOCAL_BIN)

	@ls $(LOCAL_BIN)/protoc-gen-go &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

	@ls $(LOCAL_BIN)/protoc-gen-go-grpc &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

	@ls $(LOCAL_BIN)/buf &> /dev/null || \
    		GOBIN=$(LOCAL_BIN) go install github.com/bufbuild/buf/cmd/buf@latest

# __________________________________________________ #

.PHONY: go/tidy
go/tidy:
	@find $(CURDIR) \
		-name 'go.mod' \
		-exec bash -c 'pushd "$${1%go.mod}" && go mod tidy && popd' _ {} \; \
		> /dev/null

# __________________________________________________ #

.PHONY: proto/go/deps
proto/go/deps:
	@echo 'Installing dependencies.'

	@mkdir -p $(LOCAL_BIN)

	@ls $(LOCAL_BIN)/protoc-gen-go &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

	@ls $(LOCAL_BIN)/protoc-gen-go-grpc &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# __________________________________________________ #

.PHONY: proto/go/init
proto/go/init: proto/go/deps
	@echo 'Creating directories for proto files.'
	@mkdir -p $(API_PB_GO_GEN_FULL_PATH)
	
	@echo 'Generating module.'
	@pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && go mod init $(API_PB_GO_MODULE_NAME) || true && popd > /dev/null
	@pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && go mod tidy || true && popd > /dev/null

# __________________________________________________ #

.PHONY: proto/go/clean
proto/go/clean: init
	@echo 'Cleaning generated proto files.'
	@$(shell find $(API_PB_GO_GEN_PATH) -name '*.pb.go' -exec rm -rf {} \;)
	@$(shell find $(API_PB_GO_GEN_PATH) -name 'go.mod' -exec rm -rf {} \;)
	@$(shell find $(API_PB_GO_GEN_PATH) -name 'go.sum' -exec rm -rf {} \;)

# __________________________________________________ #

.PHONY: proto/go/compile
proto/go/compile: init proto/go/init
	@echo 'Installing dependencies for module'
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && \
		go get google.golang.org/protobuf@latest && \
		go get google.golang.org/grpc@latest && \
		popd > /dev/null

	@echo 'Compiling proto files.'
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	protoc \
        --proto_path vendor \
        --proto_path $(API_PB_SRC_PATH) \
        --go_out=$(API_PB_GO_GEN_FULL_PATH) \
        --go_opt=paths=source_relative \
        --go-grpc_out=$(API_PB_GO_GEN_FULL_PATH) \
        --go-grpc_opt=paths=source_relative \
        $(shell find $(API_PB_SRC_PATH) -name '*.proto')

	@echo 'Finalizing'
	@pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && go mod tidy || true && popd > /dev/null

# __________________________________________________ #

.PHONY: buf/go/deps
buf/go/deps:
	@echo 'Installing dependencies.'

	@mkdir -p $(LOCAL_BIN)

	@ls $(LOCAL_BIN)/protoc-gen-go &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

	@ls $(LOCAL_BIN)/protoc-gen-go-grpc &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

	@ls $(LOCAL_BIN)/buf &> /dev/null || \
    		GOBIN=$(LOCAL_BIN) go install github.com/bufbuild/buf/cmd/buf@latest

# __________________________________________________ #

.PHONY: buf/go/init
buf/go/init: buf/go/deps
	@echo 'Creating directories for proto files.'
	@mkdir -p $(API_PB_GO_GEN_FULL_PATH)

	@echo 'Generating module.'
	@pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && go mod init $(API_PB_GO_MODULE_NAME) || true && popd > /dev/null
	@pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && go mod tidy || true && popd > /dev/null

# __________________________________________________ #

.PHONY: buf/go/clean
buf/go/clean: init
	@echo 'Cleaning generated proto files.'
	@$(shell find $(API_PB_GO_GEN_PATH) -name '*.pb.go' -exec rm -rf {} \;)
	@$(shell find $(API_PB_GO_GEN_PATH) -name 'go.mod' -exec rm -rf {} \;)
	@$(shell find $(API_PB_GO_GEN_PATH) -name 'go.sum' -exec rm -rf {} \;)

# __________________________________________________ #

.PHONY: buf/go/compile
buf/go/compile: buf/go/init
	@echo 'Installing dependencies for module'
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && \
		go get google.golang.org/protobuf@latest && \
		go get google.golang.org/grpc@latest && \
		popd > /dev/null

	@echo 'Compiling proto files.'
	@@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	$(LOCAL_BIN)/buf generate

	@echo 'Finalizing'
	@pushd $(API_PB_GO_GEN_FULL_PATH) > /dev/null && go mod tidy || true && popd > /dev/null

# ____________________________________________________________________________________________________ #
# Scripts end block
# ____________________________________________________________________________________________________ #
