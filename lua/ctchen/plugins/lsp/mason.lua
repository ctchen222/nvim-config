-- return {
--   {
--     "williamboman/mason.nvim",
--     version = "1.10.0",
--     lazy = false,
--     config = function()
--       require("mason").setup({
--         ui = {
--           icons = {
--             package_installed = "✓",
--             package_pending = "➜",
--             package_uninstalled = "✗",
--           },
--         },
--         log_level = vim.log.levels.DEBUG, -- 啟用調試日誌
--       })
--     end,
--   },
--   {
--     "williamboman/mason-lspconfig.nvim", -- 修正倉庫名稱
--     version = "1.31.0",
--     lazy = false,
--     dependencies = { "williamboman/mason.nvim" },
--     config = function()
--       require("mason-lspconfig").setup({
--         ensure_installed = {
--           "html",
--           "cssls",
--           "tailwindcss",
--           "lua_ls",
--           "graphql",
--           "emmet_ls",
--           "pyright",
--           "eslint",
--           "gopls",
--         },
--         automatic_installation = true,
--       })
--     end,
--   },
--   {
--     "jay-babu/mason-null-ls.nvim",
--     lazy = false,
--     dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
--     config = function()
--       require("mason-null-ls").setup({
--         ensure_installed = {
--           "prettier", -- js/ts formatter
--           "stylua", -- lua formatter
--           "isort", -- python formatter
--           "black", -- python formatter
--           "pylint", -- python linter
--           "eslint", -- js/ts linter
--         },
--         automatic_installation = false,
--       })
--     end,
--   },
--   {
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--     lazy = false,
--     dependencies = { "williamboman/mason.nvim" },
--     config = function()
--       require("mason-tool-installer").setup({
--         ensure_installed = {
--           "stylua", -- lua formatter
--           "isort", -- python formatter
--           "black", -- python formatter
--           "pylint", -- python linter
--           "eslint", -- js/ts linter
--         },
--       })
--     end,
--   },
--   config = function()
--     -- import plugins safely
--     local mason = require("mason")
--     local mason_lspconfig = require("mason-lspconfig")
--     local mason_null_ls = require("mason-null-ls")
--     local mason_tool_installer = require("mason-tool-installer")
--
--     -- enable mason and configure icons
--     mason.setup({
--       ui = {
--         icons = {
--           package_installed = "✓",
--           package_pending = "➜",
--           package_uninstalled = "✗",
--         },
--       },
--     })
--
--     -- configure lsp servers to be installed
--     mason_lspconfig.setup({
--       ensure_installed = {
--         "html",
--         "cssls",
--         "tailwindcss",
--         "lua_ls",
--         "graphql",
--         "emmet_ls",
--         "pyright",
--         "eslint",
--         "gopls",
--       },
--     })
--
--     -- configure formatters/linters to be installed
--     mason_tool_installer.setup({
--       ensure_installed = {
--         "stylua", -- lua formatter
--         "isort", -- python formatter
--         "black", -- python formatter
--         "pylint", -- python linter
--         "eslint", -- js/ts linter
--       },
--     })
--
--     -- configure null-ls sources to be installed
--     mason_null_ls.setup({
--       ensure_installed = {
--         "prettier", -- js/ts formatter
--         "stylua", -- lua formatter
--         "isort", -- python formatter
--         "black", -- python formatter
--         "pylint", -- python linter
--         "eslint", -- js/ts linter
--       },
--       -- automatically setup null-ls with the installed sources
--       automatic_installation = false,
--     })
--   end,
-- }
--
return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        -- "tsserver",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "sqls",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint",
        "eslint_d",
        "sqlfluff", -- sql formatter
      },
    })
  end,
}
