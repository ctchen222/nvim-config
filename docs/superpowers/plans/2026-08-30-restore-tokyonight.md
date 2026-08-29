# Restore TokyoNight Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing TokyoNight night configuration the active Neovim theme again.

**Architecture:** Add a headless integration assertion for the loaded colorscheme, then change the single `active_theme` selector. Reuse every existing TokyoNight option and preserve all other theme definitions.

**Tech Stack:** Neovim, Lua, lazy.nvim, folke/tokyonight.nvim

## Global Constraints

- Preserve all unrelated dirty files and lockfile changes.
- Do not change TokyoNight palette overrides, fonts, transparency, Incline, Lualine, or bufferline behavior.
- Keep Vaporwave, OneDark Pro, and Catppuccin available but inactive.

---

### Task 1: Select and verify TokyoNight

**Files:**
- Create: `tests/colorscheme_spec.lua`
- Modify: `lua/ctchen/plugins/colorscheme.lua:2`

**Interfaces:**
- Consumes: the normal Neovim startup path and `vim.g.colors_name`.
- Produces: `vim.g.colors_name == "tokyonight-night"` after startup.

- [ ] **Step 1: Write the failing colorscheme integration test**

Create `tests/colorscheme_spec.lua`:

```lua
local expected = "tokyonight-night"
local actual = vim.g.colors_name

if actual ~= expected then
  vim.api.nvim_err_writeln(string.format("expected colorscheme %s, got %s", expected, vim.inspect(actual)))
  vim.cmd("cquit 1")
end

print("TokyoNight colorscheme checks passed")
vim.cmd("qa!")
```

- [ ] **Step 2: Run the test and verify RED**

Run: `nvim --headless "+luafile tests/colorscheme_spec.lua"`

Expected: exit 1 with `got "vaporwave"`.

- [ ] **Step 3: Select the existing TokyoNight configuration**

Change only:

```lua
local active_theme = "tokyonight"
```

- [ ] **Step 4: Verify GREEN and UI regressions**

Run:

```bash
nvim --headless "+luafile tests/colorscheme_spec.lua"
nvim --headless "+luafile tests/streamlined_ui_spec.lua"
nvim --headless "+luafile tests/bufferline_style_spec.lua"
```

Expected: all three commands exit zero.

- [ ] **Step 5: Commit only the theme selector and test**

Stage `tests/colorscheme_spec.lua` and only the `active_theme` hunk from the
already-dirty `colorscheme.lua`, inspect the staged diff, and commit with:

```bash
git commit -m "feat: restore TokyoNight theme"
```
