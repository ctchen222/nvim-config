return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql", "mongodb" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    keys = {
      { "<leader>Dt", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "Add DB Connection" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
      { "<leader>Dl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last Query Info" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql", "mongodb" },
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "<leader>De", "<cmd>%DB<cr>", { buffer = bufnr, desc = "Execute All" })
          vim.keymap.set("n", "<leader>Dr", "<cmd>.DB<cr>", { buffer = bufnr, desc = "Execute Line" })
          vim.keymap.set("v", "<leader>De", ":DB<cr>", { buffer = bufnr, desc = "Execute Selection" })
        end,
      })
    end,
  },
}
