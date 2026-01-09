return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      go = { "goimports" },
      cs = { "csharpier" },
      xml = { "xmlformatter" },
      sql = { "sqlfluff" },
      mysql = { "sqlfluff" },
      plsql = { "sqlfluff" },
      python = { "ruff_format", "ruff_organize_imports" },
    },
    formatters = {
      sqlfluff = {
        args = { "format", "--dialect", "postgres", "-" },
      },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return false
      end
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
  },
}
