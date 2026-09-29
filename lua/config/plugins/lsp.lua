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
          local map = function(keys, func, desc, mode) vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

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
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            map('grh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf }) end, 'Toggle inlay [H]ints')
          end

          -- Lenses are computed by the server but not drawn until enabled; Nvim then
          -- re-requests them itself (debounced, via nvim_buf_attach) on every change.
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
            map('grl', vim.lsp.codelens.run, 'Run code [L]ens')
            vim.lsp.codelens.enable(true, { bufnr = event.buf })
          end
        end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      --- nvim-lspconfig nests root_markers; vim.fs.root wants a flat list (neovim#34099).
      ---@param markers (string|string[])[]|string[]|nil
      local function flatten_root_markers(markers)
        if not markers then return nil end

        local needs_flatten = false
        for _, item in ipairs(markers) do
          if type(item) == 'table' then
            needs_flatten = true
            break
          end
        end
        if not needs_flatten then return markers end

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
              usePlaceholders = true,
              staticcheck = true,
              gofumpt = true,
              directoryFilters = { '-vendor' },
              -- Everything else in gopls' default analyzer set is already on.
              analyses = { shadow = true },
              -- Only non-default lens worth having; `generate`/`tidy`/`govulncheck` are on already.
              codelenses = { test = true },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
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
        -- Disabled. Kept for reference: graphql-lsp works in js/apps/horus and js/apps/ui,
        -- but upstream calls on_dir(nil) when no GraphQL config is found, which starts the
        -- server rootless for every ts/tsx buffer. The root_dir below is the needed guard.
        -- graphql = {
        --   root_dir = function(bufnr, on_dir)
        --     local root = vim.fs.root(bufnr, function(name) return name:match '^%.graphqlrc' ~= nil or name:match '^%.?graphql%.config%.' ~= nil end)
        --     if root then on_dir(root) end
        --   end,
        -- },
        pyright = {},
        rust_analyzer = {},
        ts_ls = {
          on_attach = function(client, bufnr)
            -- Prettier via conform (`<leader>f`), not ts_ls.
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            vim.b[bufnr].disable_autoformat = true
          end,
        },
        lua_ls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false

            local root = client.workspace_folders and client.workspace_folders[1].name
            if root then
              -- Respect project .luarc; only patch Neovim config workspace.
              if root ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(root .. '/.luarc.json') or vim.uv.fs_stat(root .. '/.luarc.jsonc')) then return end
            end

            -- nvim_get_runtime_file includes the config dir itself. Left in, lua_ls scans
            -- the workspace a second time as a library and reports "Loading workspace" twice.
            local library = { '${3rd}/luv/library', '${3rd}/busted/library' }
            for _, dir in ipairs(vim.api.nvim_get_runtime_file('', true)) do
              if not root or vim.fs.normalize(dir) ~= vim.fs.normalize(root) then library[#library + 1] = dir end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                library = library,
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
        -- gopls vendors gofumpt/staticcheck and organizes imports itself; no standalone binaries.
        'golangci-lint',
        'delve',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- servers come from the explicit `servers` table only
        automatic_enable = false,
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
