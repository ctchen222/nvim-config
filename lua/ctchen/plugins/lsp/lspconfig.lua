return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    -- neodev.nvim is removed as we are configuring lua_ls manually.
  },
  config = function()
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
        ["tsserver"] = function()
          lspconfig["tsserver"].setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "none",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = false,
                  includeInlayVariableTypeHints = false,
                  includeInlayPropertyDeclarationTypeHints = false,
                  includeInlayFunctionLikeReturnTypeHints = false,
                  includeInlayEnumMemberValueHints = false,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "none",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = false,
                  includeInlayVariableTypeHints = false,
                  includeInlayPropertyDeclarationTypeHints = false,
                  includeInlayFunctionLikeReturnTypeHints = false,
                  includeInlayEnumMemberValueHints = false,
                },
              },
            },
            -- 優化效能：限制初始化行為
            init_options = {
              preferences = {
                disableSuggestions = false,
                includeCompletionsForModuleExports = true,
                includeCompletionsWithSnippetText = true,
                includeAutomaticOptionalChainCompletions = true,
              },
              maxTsServerMemory = 4096,
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

