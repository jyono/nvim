---@type LazySpec
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Before VimEnter so get_lsp_capabilities() exists on `nvim file.py`.
      { 'saghen/blink.cmp', version = '1.*' },
      {
        'mason-org/mason.nvim',
        opts = {
          pip = {
            -- Corporate pip.conf / PIP_INDEX_URL (e.g. CodeArtifact) breaks Mason installs.
            install_args = { '--isolated', '-i', 'https://pypi.org/simple' },
          },
        },
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local go_dev = require 'config.go'

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Lazy-load Snacks on keypress; LspAttach can run before VimEnter.
          -- Buffer-local maps override Nvim 0.12 defaults (grr/gri/grt/gO → quickfix).
          map('grr', function() Snacks.picker.lsp_references() end, '[R]eferences')
          map('gri', function() Snacks.picker.lsp_implementations() end, '[I]mplementation')
          map('grd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
          map('gO', function() Snacks.picker.lsp_symbols() end, 'Open Document Symbols')
          map('gW', function() Snacks.picker.lsp_workspace_symbols() end, 'Open Workspace Symbols')
          map('grt', function() Snacks.picker.lsp_type_definitions() end, '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- gopls advertises semantic tokens in capabilities but not server_capabilities.
          if client and client.name == 'gopls' and not client.server_capabilities.semanticTokensProvider then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            if semantic then
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('config-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('config-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'config-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            -- `<leader>th` is terminal horizontal split in config.keymaps.
            map('<leader>ti', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle [I]nlay hints')
          end
        end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      --- nvim-lspconfig nests root_markers; vim.fs.root wants a flat list (neovim#34099).
      ---@param markers (string|string[])[]|string[]|nil
      local function flatten_root_markers(markers)
        if not markers then
          return nil
        end

        local needs_flatten = false
        for _, item in ipairs(markers) do
          if type(item) == 'table' then
            needs_flatten = true
            break
          end
        end
        if not needs_flatten then
          return markers
        end

        local flat = {}
        for _, item in ipairs(markers) do
          if type(item) == 'string' then
            flat[#flat + 1] = item
          else
            vim.list_extend(flat, item)
          end
        end
        return flat
      end

      ---@type table<string, vim.lsp.Config>
      local servers = {
        clangd = {},
        gopls = {
          cmd = { 'gopls', '-remote=auto' },
          settings = {
            gopls = {
              buildFlags = go_dev.gopls_build_flags, -- monorepo tags; see config.go
              completeUnimported = true,
              usePlaceholders = true,
              deepCompletion = true,
              matcher = 'Fuzzy',
              hoverKind = 'FullDocumentation',
              linkTarget = 'pkg.go.dev',
              linksInHover = true,
              expandWorkspaceToModule = true,
              staticcheck = true,
              analyses = {
                asmdecl = true,
                assign = true,
                atomic = true,
                atomicalign = true,
                bools = true,
                buildtag = true,
                cgocall = true,
                composites = true,
                copylock = true,
                defers = true,
                directive = true,
                errorsas = true,
                framepointer = true,
                httpresponse = true,
                ifaceassert = true,
                loopclosure = true,
                lostcancel = true,
                nilfunc = true,
                printf = true,
                shift = true,
                sigchanyzer = true,
                slog = true,
                stdmethods = true,
                stringintconv = true,
                structtag = true,
                testinggoroutine = true,
                tests = true,
                timeformat = true,
                unmarshal = true,
                unreachable = true,
                unsafeptr = true,
                unusedresult = true,
                deepequalerrors = true,
                embed = true,
                fillreturns = true,
                infertypeargs = true,
                nilness = true,
                nonewvars = true,
                noresultvalues = true,
                shadow = true,
                simplifycompositelit = true,
                simplifyrange = true,
                simplifyslice = true,
                sortslice = true,
                stubmethods = true,
                undeclaredname = true,
                unusedparams = true,
                unusedvariable = true,
                unusedwrite = true,
                useany = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
                vulncheck = true,
              },
              gofumpt = true,
              directoryFilters = { '-vendor' },
            },
          },
          on_attach = function(client, bufnr)
            if client.name == 'gopls' then
              vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.code_action {
                    context = { diagnostics = {}, only = { 'source.organizeImports' } },
                    apply = true,
                  }
                end,
              })
            end
          end,
        },
        pyright = {},
        rust_analyzer = {},
        ts_ls = {
          settings = {},
          root_dir = function(bufnr, on_dir)
            local root_markers = flatten_root_markers {
              { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' },
              { '.git' },
            }
            -- Prefer deno.json roots; skip when deno.lock is nested under a node project.
            local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
            local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
            local project_root = vim.fs.root(bufnr, root_markers)
            if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
              return
            end
            if deno_root and (not project_root or #deno_root >= #project_root) then
              return
            end
            on_dir(project_root or vim.fn.getcwd())
          end,
          on_attach = function(client, bufnr)
            -- Prettier via conform (`<leader>f`), not ts_ls.
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            vim.b[bufnr].disable_autoformat = true
          end,
        },
        stylua = {},
        lua_ls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false

            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              -- Respect project .luarc; only patch Neovim config workspace.
              if path ~= vim.fn.stdpath 'config'
                and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
              then
                return
              end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                  '${3rd}/luv/library',
                  '${3rd}/busted/library',
                }),
              },
            })
          end,
          settings = {
            Lua = { format = { enable = false } },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, {
        'stylua',
        'sql-formatter',
        'prettier',
        'ruff',
        'markdownlint',
        'staticcheck',
        'goimports',
        'gofumpt',
        'gomodifytags',
        'impl',
        'golangci-lint',
        'delve',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- servers come from the explicit `servers` table only
        automatic_installation = false,
      }

      require 'lspconfig'

      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        local merged = vim.tbl_deep_extend('force', vim.lsp.config[server_name] or {}, server)
        merged.root_markers = flatten_root_markers(merged.root_markers)
        vim.lsp.config[server_name] = merged
        vim.lsp.enable(server_name)
      end
    end,
  },
}
