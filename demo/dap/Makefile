SHELL := /bin/bash
.PHONY: run debug env

DLV ?= $(shell command -v dlv 2>/dev/null || echo $(HOME)/.local/share/nvim/mason/bin/dlv)
DLV_PORT ?= 2345

# Mirror chariot/go/apps/video/Makefile: load env in the shell that starts Delve.
load-api-env:
	@test -f .env.api || cp .env.api.example .env.api
	$(eval include .env.api)
	$(eval export)

run: load-api-env
	go run ./cmd/main.go api

# Terminal 1: start headless Delve with your real env (same as video `make debug`).
debug: load-api-env
	$(DLV) debug --headless --listen=:$(DLV_PORT) --api-version=2 --accept-multiclient ./cmd/main.go -- api

# Terminal 2 (nvim): open cmd/main.go, set breakpoints, press <leader>da
attach-env:
	@echo "export DAP_ATTACH_PORT=$(DLV_PORT)"
