# Craftzdog-inspired Bufferline Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the existing buffer-based Bufferline with craftzdog-inspired visual hierarchy without changing navigation semantics or the Vaporwave theme.

**Architecture:** Keep `akinsho/bufferline.nvim` in buffer mode and configure its existing Lazy plugin specification. Resolve selected, inactive, separator, and fill colors from active Neovim highlight groups with Vaporwave-compatible fallbacks, then verify the resulting options in a focused headless test.

**Tech Stack:** Neovim Lua, lazy.nvim plugin specs, akinsho/bufferline.nvim, headless Neovim tests

## Global Constraints

- Keep `mode = "buffers"`.
- Preserve slanted separators, file icons, NvimTree offset, diagnostics, and existing keymaps.
- Do not modify Incline, Lualine, tmux, or the active Vaporwave colorscheme.
- Do not stage or alter unrelated dirty files.

---

### Task 1: Restyle Bufferline without changing buffer navigation

**Files:**
- Modify: `lua/ctchen/plugins/bufferline.lua`
- Create: `tests/bufferline_style_spec.lua`

**Interfaces:**
- Consumes: Neovim highlight groups `Normal`, `NormalFloat`, `Comment`, and `CursorLineNr`
- Produces: a lazy.nvim Bufferline spec whose `opts()` returns the verified options and highlights

- [ ] **Step 1: Write the failing focused test**

Create a headless Lua test that loads the plugin spec and asserts:

```lua
assert_equal("buffers", options.options.mode, "Bufferline must preserve buffer navigation")
assert_equal("slant", options.options.separator_style, "Bufferline must keep slanted separators")
assert_equal(false, options.options.show_buffer_close_icons, "Buffer close icons must stay hidden")
assert_equal(false, options.options.show_close_icon, "The global close icon must stay hidden")
assert_equal("nvim_lsp", options.options.diagnostics, "LSP diagnostics must remain enabled")
assert_equal("#E5C77A", options.highlights.buffer_selected.bg, "Selected buffers must use the warm accent")
assert_equal(true, options.highlights.buffer_selected.bold, "Selected buffers must be bold")
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
nvim --headless "+luafile tests/bufferline_style_spec.lua" "+qa!"
```

Expected: non-zero exit because the current specification does not explicitly preserve buffer mode, hide close icons, or define the selected highlight.

- [ ] **Step 3: Implement the minimal style configuration**

Change the plugin `opts` to a function that resolves colors safely and returns:

```lua
options = {
  mode = "buffers",
  separator_style = "slant",
  show_buffer_close_icons = false,
  show_close_icon = false,
  diagnostics = "nvim_lsp",
}

highlights = {
  fill = { bg = fill_background },
  background = { fg = inactive_foreground, bg = inactive_background },
  buffer_visible = { fg = inactive_foreground, bg = inactive_background },
  buffer_selected = { fg = selected_foreground, bg = selected_background, bold = true, italic = false },
  separator = { fg = inactive_background, bg = fill_background },
  separator_visible = { fg = inactive_background, bg = fill_background },
  separator_selected = { fg = selected_background, bg = fill_background },
}
```

Retain the existing NvimTree offset and keymap side effects. Simplify the diagnostics indicator to a subdued numeric count without the bright error/warning glyph.

- [ ] **Step 4: Run focused and full configuration verification**

Run:

```bash
nvim --headless "+luafile tests/bufferline_style_spec.lua" "+qa!"
nvim --headless "+lua require('lazy').load({ plugins = { 'bufferline.nvim' } })" "+qa!"
```

Expected: both commands exit zero; the focused test prints `Bufferline style checks passed` and the full configuration emits no startup errors.

- [ ] **Step 5: Review and commit only scoped files**

```bash
git diff --check -- lua/ctchen/plugins/bufferline.lua tests/bufferline_style_spec.lua
git add lua/ctchen/plugins/bufferline.lua tests/bufferline_style_spec.lua
git diff --cached
git commit -m "feat(nvim): restyle bufferline navigation"
```
