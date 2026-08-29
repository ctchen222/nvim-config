# Craftzdog-inspired Bufferline Style Design

## Status

Approved direction: preserve the existing buffer-based navigation and
Vaporwave theme while adopting the quieter visual hierarchy from craftzdog's
Bufferline.

## Goals

- Keep `mode = "buffers"` so existing file navigation semantics do not change.
- Preserve the existing slanted separators, file icons, NvimTree offset, and
  buffer movement keymaps.
- Give the selected buffer a warm yellow accent and bold text.
- Render inactive buffers with subdued blue-gray colors on a consistent dark
  fill background.
- Remove close icons and reduce diagnostic prominence.
- Derive the palette from the active colorscheme when possible, with stable
  Vaporwave-compatible fallbacks.

## Non-goals

- Switching to Neovim tabpage navigation.
- Installing Solarized Osaka or changing the active Vaporwave colorscheme.
- Modifying Incline, Lualine, tmux, or unrelated keymaps.
- Removing diagnostics entirely.

## Verification

- Assert the resulting Bufferline options preserve buffer mode and slanted
  separators, hide close icons, and retain LSP diagnostics.
- Assert selected, inactive, separator, and fill highlight groups resolve to
  the intended visual hierarchy.
- Load the full Neovim configuration headlessly and confirm there are no
  startup errors.
- Review the final diff and keep unrelated dirty files unstaged.
