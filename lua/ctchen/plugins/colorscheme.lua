-- Set active colorscheme: "catppuccin", "tokyonight", or an OneDark Pro theme
local active_theme = "vaporwave"
local transparent = false -- set to true to enable transparency
local default_guifont = vim.o.guifont
local vaporwave_guifont = "Operator Mono:h14"

local onedarkpro_themes = {
  onedark = true,
  onelight = true,
  onedark_vivid = true,
  onedark_dark = true,
  vaporwave = true,
}

local vaporwave_highlights = active_theme == "vaporwave" and {
  Comment = { fg = "#A79AE8", italic = true },
  String = { fg = "#F7A8D8" },
  Character = { fg = "#F7A8D8" },
  Number = { fg = "#FFD580" },
  Constant = { fg = "#FFD580" },
  Function = { fg = "#7DE8FF" },
  Keyword = { fg = "#FF79C6", bold = true },
  Type = { fg = "#F6E58D" },
  Operator = { fg = "#75DDE8" },
  Identifier = { fg = "#FF8FB3" },
  Special = { fg = "#7DE8FF" },
} or {}

return {
  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = active_theme ~= "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
        transparent_background = transparent,
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          mini = true,
          telescope = { enabled = true },
          which_key = true,
          mason = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
        },
      })

      if active_theme == "catppuccin" then
        vim.cmd.colorscheme("catppuccin")
      end
    end,
  },

  -- OneDark Pro themes: onedark, onelight, onedark_vivid, onedark_dark, vaporwave
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = not onedarkpro_themes[active_theme],
    config = function()
      require("onedarkpro").setup({
        highlights = vaporwave_highlights,
        options = {
          transparency = transparent,
          terminal_colors = true,
        },
      })

      -- Operator Mono is only applied to Vaporwave in GUI clients.
      if vim.fn.has("gui_running") == 1 then
        vim.opt.guifont = active_theme == "vaporwave" and vaporwave_guifont or default_guifont
      end

      if onedarkpro_themes[active_theme] then
        vim.cmd.colorscheme(active_theme)
      end
    end,
  },

  -- TokyoNight theme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = active_theme ~= "tokyonight",
    config = function()
      local bg = "#011628"
      local bg_dark = "#011423"
      local bg_highlight = "#143652"
      local bg_search = "#0A64AC"
      local bg_visual = "#275378"
      local fg = "#CBE0F0"
      local fg_dark = "#B4D0E9"
      local fg_gutter = "#627E97"
      local border = "#547998"

      require("tokyonight").setup({
        style = "night",
        transparent = transparent,
        styles = {
          sidebars = transparent and "transparent" or "dark",
          floats = transparent and "transparent" or "dark",
        },
        on_colors = function(colors)
          colors.bg = bg
          colors.bg_dark = transparent and colors.none or bg_dark
          colors.bg_float = transparent and colors.none or bg_dark
          colors.bg_highlight = bg_highlight
          colors.bg_popup = bg_dark
          colors.bg_search = bg_search
          colors.bg_sidebar = transparent and colors.none or bg_dark
          colors.bg_statusline = transparent and colors.none or bg_dark
          colors.bg_visual = bg_visual
          colors.border = border
          colors.fg = fg
          colors.fg_dark = fg_dark
          colors.fg_float = fg
          colors.fg_gutter = fg_gutter
          colors.fg_sidebar = fg_dark
        end,
      })

      if active_theme == "tokyonight" then
        vim.cmd.colorscheme("tokyonight")
      end
    end,
  },
}
