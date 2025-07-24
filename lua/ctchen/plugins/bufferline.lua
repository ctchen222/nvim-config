return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "slant",
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            separator = true,
            text_align = "center",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<S-R>", ":bdelete<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-y>", ":BufferLineMovePrev<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-o>", ":BufferLineMoveNext<CR>", { noremap = true, silent = true })
    end,
  },
}
