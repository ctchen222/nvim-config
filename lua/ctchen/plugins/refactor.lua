return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    lazy = false,
    config = function()
      require("refactoring").setup({})

      -- visual mode
      local keymap = vim.keymap
      keymap.set("x", "<leader>re", ":Refactor extract ")
      keymap.set("x", "<leader>rf", ":Refactor extract_to_file ")

      -- normal mode
      keymap.set("n", "<leader>rI", ":Refactor inline_func")
      keymap.set("n", "<leader>rb", ":Refactor extract_block")
    end,
  },
}
