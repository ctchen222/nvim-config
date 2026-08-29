# Restore TokyoNight

## Goal

Switch Neovim from the current Vaporwave theme back to the already configured
TokyoNight night theme.

## Design

Change only `active_theme` in `lua/ctchen/plugins/colorscheme.lua` from
`vaporwave` to `tokyonight`. Reuse the existing TokyoNight setup, including its
Coolnight-compatible background colours and plugin integrations. Do not delete
Vaporwave, OneDark Pro, Catppuccin, or their configuration; they remain
available for future switching.

## Verification

Load the real Neovim configuration headlessly and assert that
`vim.g.colors_name` is `tokyonight-night`. Run the existing streamlined UI and
bufferline style specifications to ensure the theme switch does not alter the
approved UI layout.

## Boundaries

- Preserve all unrelated dirty Neovim files and lockfile changes.
- Do not change fonts, Incline, Lualine, bufferline mode, transparency, or
  TokyoNight palette overrides.
