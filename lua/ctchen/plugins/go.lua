return {
  "ray-x/go.nvim",
  dependencies = { -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("go").setup()

    vim.keymap.set("n", "<leader>gm", "<cmd>GoMockGen<cr>", { desc = "Generate Mocks" })
    vim.keymap.set("n", "<leader>gc", "<cmd>GoCmt<cr>", { desc = "Go Comments" })
    vim.keymap.set("n", "<leader>gat", "<cmd>GoAddTag<cr>", { desc = "Go Add Tag" })
    vim.keymap.set("n", "<leader>grt", "<cmd>GoRmTag<cr>", { desc = "Go Remove Tag" })

    -- Test Related
    vim.keymap.set("n", "<leader>gta", "<cmd>GoAddTest<cr>", { desc = "Generate Function Test" })
    vim.keymap.set("n", "<leader>gtA", "<cmd>GoAddAllTest<cr>", { desc = "Generate All Tests" })
    vim.keymap.set("n", "<leader>gtf", "<cmd>GoTestFunc<cr>", { desc = "Run Test on Function" })
    vim.keymap.set("n", "<leader>gtF", "<cmd>GoTestFile<cr>", { desc = "Run Test of File" })
  end,
  event = { "CmdlineEnter" },
  ft = { "go", "gomod" },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
