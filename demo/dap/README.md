# DAP attach demo

Minimal Go app for debugging with **external headless Delve** + **nvim attach**.

Same workflow as `chariot/go/apps/video/Makefile`: run the process in a terminal with real env vars, connect the debugger from nvim.

## Why attach externally?

- Process inherits env from your shell (`make load-api-env`, `.env.api`, kubectl context checks, etc.)
- Nvim only connects the debugger — it does not re-launch the binary
- Matches IntelliJ / vs**** “Remote JVM/Debug” and “attach to Delve” patterns

## Layout

```
demo/dap/
  cmd/main.go          # `api` subcommand; reads DEMO_* env vars
  pkg/mathx/           # small package + unit test
  Makefile             # run, debug (headless delve)
  .env.api.example     # copy to .env.api
```

## Prerequisites

- Go
- Delve (`dlv`) — Mason install: `:MasonInstall delve`, or on `PATH`
- nvim config with DAP enabled (`lua/config/plugins/debug.lua`)

## Quick start

### 1. Env file

```bash
cd ~/.config/nvim/demo/dap
cp .env.api.example .env.api   # first time only
```

Edit `.env.api` if you want different values:

```
DEMO_LOG_LEVEL=debug
DEMO_PORT=8080
```

### 2. Terminal 1 — start headless Delve

```bash
make debug
```

This loads `.env.api`, then runs:

```bash
dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient ./cmd/main.go -- api
```

Leave this running. Delve waits for a client on port **2345**.

### 3. Terminal 2 — attach from nvim

```bash
cd ~/.config/nvim/demo/dap
nvim cmd/main.go
```

1. Set a breakpoint (e.g. in `runAPI()`)
2. `<leader>da` — attach to Delve on `127.0.0.1:2345`
3. dap-ui opens; execution stops at breakpoints
4. Inspect **Variables** — `DEMO_LOG_LEVEL`, `DEMO_PORT` come from the external process env

### Other nvim keys

| Key | Action |
|-----|--------|
| `<leader>da` | Attach (default port 2345) |
| `<leader>dA` | Attach (prompt for port) |
| `<leader>dc` | Continue / pick config (includes attach entries) |
| `<leader>db` | Toggle breakpoint |
| `<leader>du` | Toggle dap-ui |
| `<leader>dt` | Debug nearest Go test (launch mode, not attach) |

## Custom port

**Terminal 1:**

```bash
DLV_PORT=4444 make debug
```

**Terminal 2 (before nvim, or use `<leader>dA`):**

```bash
export DAP_ATTACH_PORT=4444
nvim cmd/main.go
```

Port resolution order in nvim: `DAP_ATTACH_PORT` → `DLV_PORT` → default `2345`.

## Run without debugger

```bash
make run
```

## Unit tests (launch mode)

```bash
go test ./...
# or in nvim, cursor inside TestAdd:
# <leader>dt
```

## Chariot video app

Same pattern in `chariot/go/apps/video`:

```bash
cd chariot/go/apps/video
make debug    # load-api-env + delve on :2345
```

In nvim, open any file under that module → breakpoint → `<leader>da`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Delve not found` | `:MasonInstall delve` or install `dlv` on PATH |
| Attach fails / connection refused | Ensure `make debug` still running; check port |
| Breakpoints grey / unbound | Open the same source tree Delve built from; `cd` into module before nvim |
| Wrong env in variables | Env comes from **terminal 1** — fix `.env.api` / Makefile there, restart `make debug` |
