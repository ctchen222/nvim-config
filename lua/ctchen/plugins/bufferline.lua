return {
  {
    "akinsho/bufferline.nvim",
    opts = function()
      local function highlight_color(group, attribute, fallback)
        local ok, highlight = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        local value = ok and highlight[attribute] or nil
        return value and string.format("#%06X", value) or fallback
      end

      local fill_background = highlight_color("Normal", "bg", "#171521")
      local inactive_background = highlight_color("NormalFloat", "bg", "#211C32")
      local inactive_foreground = highlight_color("Comment", "fg", "#9187B8")
      local selected_background = highlight_color("CursorLineNr", "fg", "#E5C77A")
      local selected_foreground = fill_background

      return {
        options = {
          mode = "buffers",
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count)
            return " " .. count
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              separator = true,
              text_align = "center",
            },
          },

          vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true }),
          vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true }),
          vim.api.nvim_set_keymap("n", "<S-R>", ":bdelete<CR>", { noremap = true, silent = true }),
          vim.api.nvim_set_keymap("n", "<C-y>", ":BufferLineMovePrev<CR>", { noremap = true, silent = true }),
          vim.api.nvim_set_keymap("n", "<C-o>", ":BufferLineMoveNext<CR>", { noremap = true, silent = true }),
        },
        highlights = {
          fill = { bg = fill_background },
          background = { fg = inactive_foreground, bg = inactive_background, italic = false },
          buffer_visible = { fg = inactive_foreground, bg = inactive_background, italic = false },
          buffer_selected = {
            fg = selected_foreground,
            bg = selected_background,
            bold = true,
            italic = false,
          },
          separator = { fg = inactive_background, bg = fill_background },
          separator_visible = { fg = inactive_background, bg = fill_background },
          separator_selected = { fg = selected_background, bg = fill_background },
        },
      }
    end,
  },
}
