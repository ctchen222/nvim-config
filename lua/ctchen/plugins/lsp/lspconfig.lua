return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    -- neodev.nvim is removed as we are configuring lua_ls manually.
  },
  config = function()
    -- Configure diagnostics display
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●", -- or "■", "▎", "x"
        source = "if_many", -- show source if multiple diagnostics
        spacing = 4,
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
      underline = true,
      update_in_insert = false, -- don't update while typing
      severity_sort = true, -- show errors first
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
      },
    })

    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    local lsp_attach = function(client, bufnr)
      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local opts = { buffer = bufnr, silent = true }

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup({
      handlers = {
        -- Manual setup for lua_ls to ensure it knows about the Neovim runtime
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })
        end,
        ["svelte"] = function()
          -- configure svelte server
          lspconfig["svelte"].setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = { "*.js", "*.ts" },
                callback = function(ctx)
                  -- Here use ctx.match instead of ctx.file
                  client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                end,
              })
            end,
          })
        end,
        ["graphql"] = function()
          -- configure graphql language server
          lspconfig["graphql"].setup({
            capabilities = capabilities,
            filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
          })
        end,
        ["emmet_ls"] = function()
          -- configure emmet language server
          lspconfig["emmet_ls"].setup({
            capabilities = capabilities,
            filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
          })
        end,
        ["tailwindcss"] = function()
          lspconfig["tailwindcss"].setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
            -- 移除純 typescript/javascript，只在有 HTML/JSX 的檔案啟用
            filetypes = {
              "html",
              "typescriptreact",
              "javascriptreact",
              "css",
              "sass",
              "scss",
              "svelte",
              "heex",
              "phoenix-heex",
              "eruby",
            },
          })
        end,
        ["htmx"] = function()
          lspconfig["htmx"].setup({
            capabilities = capabilities,
            filetypes = { "html", "htmldjango", "templ" },
          })
        end,
        ["sqls"] = function()
          lspconfig["sqls"].setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              lsp_attach(client, bufnr)
              -- sqls specific keymaps
              local opts = { buffer = bufnr, silent = true }
              vim.keymap.set("n", "<leader>se", "<cmd>SqlsExecuteQuery<CR>", { buffer = bufnr, desc = "Execute SQL query" })
              vim.keymap.set("v", "<leader>se", "<cmd>SqlsExecuteQuery<CR>", { buffer = bufnr, desc = "Execute selected SQL" })
              vim.keymap.set("n", "<leader>sd", "<cmd>SqlsSwitchDatabase<CR>", { buffer = bufnr, desc = "Switch database" })
              vim.keymap.set("n", "<leader>sc", "<cmd>SqlsSwitchConnection<CR>", { buffer = bufnr, desc = "Switch connection" })
            end,
            settings = {
              sqls = {
                connections = {
                  -- Add your database connections here, e.g.:
                  -- {
                  --   driver = "postgresql",
                  --   dataSourceName = "host=localhost port=5432 user=postgres password=pass dbname=mydb sslmode=disable",
                  -- },
                  -- {
                  --   driver = "mysql",
                  --   dataSourceName = "user:password@tcp(localhost:3306)/dbname",
                  -- },
                },
              },
            },
          })
        end,
        -- vtsls: faster TypeScript language server (replaces tsserver)
        ["vtsls"] = function()
          lspconfig["vtsls"].setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            -- 只在有 tsconfig/package.json 的專案啟動，單檔案不啟動
            single_file_support = false,
            root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "jsconfig.json", "package.json"),
            settings = {
              typescript = {
                tsserver = {
                  maxTsServerMemory = 4096,
                  watchOptions = {
                    watchFile = "useFsEvents",
                    watchDirectory = "useFsEvents",
                    fallbackPolling = "dynamicPriorityPolling",
                    synchronousWatchDirectory = false,
                    excludeDirectories = { "**/node_modules", "**/.git", "**/dist", "**/build" },
                  },
                },
                -- Disable expensive features for large projects
                referencesCodeLens = { enabled = false },
                implementationsCodeLens = { enabled = false },
                inlayHints = {
                  parameterNames = { enabled = "none" },
                  parameterTypes = { enabled = false },
                  variableTypes = { enabled = false },
                  propertyDeclarationTypes = { enabled = false },
                  functionLikeReturnTypes = { enabled = false },
                  enumMemberValues = { enabled = false },
                },
                updateImportsOnFileMove = { enabled = "always" },
                suggestionActions = { enabled = false },
                preferences = {
                  importModuleSpecifier = "relative",
                },
              },
              javascript = {
                tsserver = {
                  maxTsServerMemory = 4096,
                  watchOptions = {
                    watchFile = "useFsEvents",
                    watchDirectory = "useFsEvents",
                    fallbackPolling = "dynamicPriorityPolling",
                    synchronousWatchDirectory = false,
                    excludeDirectories = { "**/node_modules", "**/.git", "**/dist", "**/build" },
                  },
                },
                referencesCodeLens = { enabled = false },
                implementationsCodeLens = { enabled = false },
                inlayHints = {
                  parameterNames = { enabled = "none" },
                  parameterTypes = { enabled = false },
                  variableTypes = { enabled = false },
                  propertyDeclarationTypes = { enabled = false },
                  functionLikeReturnTypes = { enabled = false },
                  enumMemberValues = { enabled = false },
                },
                updateImportsOnFileMove = { enabled = "always" },
                suggestionActions = { enabled = false },
              },
              vtsls = {
                autoUseWorkspaceTsdk = true,
                enableMoveToFileCodeAction = true,
                experimental = {
                  completion = {
                    enableServerSideFuzzyMatch = true,
                    entriesLimit = 50,
                  },
                },
              },
            },
          })
        end,
        -- Keep tsserver handler disabled (replaced by vtsls)
        ["tsserver"] = function() end,
        -- Skip jdtls here, nvim-jdtls plugin handles it
        ["jdtls"] = function() end,
        ["yamlls"] = function()
          lspconfig["yamlls"].setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
            settings = {
              yaml = {
                schemas = {
                  ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                  ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
                  ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
                  ["https://json.schemastore.org/helmfile.json"] = "helmfile*.{yml,yaml}",
                  ["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
                  ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                  kubernetes = {
                    "**/deployment*.yaml",
                    "**/service*.yaml",
                    "**/configmap*.yaml",
                    "**/secret*.yaml",
                    "**/ingress*.yaml",
                    "**/pod*.yaml",
                    "**/namespace*.yaml",
                    "**/statefulset*.yaml",
                    "**/daemonset*.yaml",
                    "**/cronjob*.yaml",
                    "**/job*.yaml",
                    "**/pv*.yaml",
                    "**/pvc*.yaml",
                    "**/role*.yaml",
                    "**/clusterrole*.yaml",
                    "**/serviceaccount*.yaml",
                  },
                },
                validate = true,
                completion = true,
                hover = true,
              },
            },
          })
        end,
        ["eslint"] = function()
          lspconfig["eslint"].setup({
            capabilities = capabilities,
            on_attach = lsp_attach, -- 使用標準 attach，不再自動修復
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            settings = {
              workingDirectories = { mode = "auto" },
              -- 減少 ESLint 的工作負擔
              codeAction = {
                disableRuleComment = { enable = false },
                showDocumentation = { enable = true },
              },
              -- 只在需要時驗證，不要太頻繁
              run = "onSave", -- 改為儲存時才執行，而非即時
            },
          })
        end,
        -- Default handler for all other servers
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
          })
        end,
      },
    })
  end,
}

