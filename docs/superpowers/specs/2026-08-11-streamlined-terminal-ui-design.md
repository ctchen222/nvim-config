# Streamlined Terminal UI Design

## Status

Approved direction: option A — keep the existing Catppuccin tmux theme while
combining Claude, Kubernetes, and Node information into one context-aware area.

## Context

The current setup has strong operational tooling, but its always-visible UI
layers compete for space:

- Neovim has per-window Lualine statuslines and no floating filename label.
- tmux always shows pane titles, including single-pane windows.
- Git, Kubernetes, Node, directory, and time are configured as separate tmux
  status modules. Kubernetes and Node remain visible merely because their
  commands exist, not because the current project uses them.
- The configured Claude status module is absent from the rendered runtime
  statusline.

The desired result is a quieter interface without removing the existing
workflow features or manual pane-title ownership.

## Goals

1. Show the active Neovim buffer filename in an Incline label at the upper
   right of each editor window.
2. Use one global Lualine row through `laststatus=3` and
   `options.globalstatus=true`.
3. Keep only Git, context plus directory, and time as persistent tmux status
   sections.
4. Show Claude, Kubernetes, and Node context only when it is relevant.
5. Show tmux pane titles only in windows containing at least two panes.

## Non-goals

- Replacing Vaporwave, Catppuccin, or the Ghostty theme.
- Removing sessionx, floax, notes, voice input, resurrect, or other tmux
  workflow features.
- Allowing applications to overwrite manually assigned pane titles.
- Updating or replacing the installed Catppuccin tmux fork.

## Design

### Neovim filename label

Add a dedicated `incline.nvim` plugin specification. Load it before reading a
buffer and render:

- the filetype icon when available;
- the buffer filename, falling back to `[No Name]`;
- a compact modified marker when the buffer has unsaved changes.

Derive the active and inactive label colors from the existing `PmenuSel` and
`NormalFloat` highlight groups, with the current Vaporwave surface colors as
fallbacks. This keeps the label integrated if the configured Neovim theme is
changed later. Inactive-window styling remains subdued.

### Global Lualine

Set `vim.opt.laststatus = 3` in the core options and explicitly set
`globalstatus = true` in Lualine. Keeping both makes the intended editor state
clear even if Lualine initialization changes later.

The existing AI spinner, Lazy update count, encoding, file format, and filetype
components remain unchanged.

### Context-aware tmux status

Replace the right-side module list with:

```text
Git | context + directory | time
```

A user-owned `status-context.sh` receives a shell-escaped
`#{pane_current_path}` and emits a compact, plain-text prefix for the
directory module. Context items are joined with ` · ` and the script emits
nothing when none apply.

Context rules:

- Claude: show the waiting-agent count only when `/tmp/claude-wait` contains
  state files. Do not show project and pane details in the compact bar.
- Node: in a Git worktree, walk from the current directory up to and including
  the Git root and show `node -v` when an examined directory contains
  `package.json`. Outside Git, examine only the current directory.
- Kubernetes: use the same bounded ancestor walk and show the shortened current
  kubectl context when an examined directory contains `Chart.yaml`,
  `helmfile.yaml`, `helmfile.yml`, `kustomization.yaml`, or a `k8s`,
  `kubernetes`, `helm`, `charts`, or `deploy` directory. Do not run a
  recursive filesystem search.

Missing commands, unreadable paths, invalid state files, and non-project
directories are normal conditions and must produce no status item or error.
The script must not source NVM on every status refresh.

### Conditional pane titles

Keep `allow-set-title off` and the current `pane-border-format`. Change the
default `pane-border-status` to `off`, then use the
`window-layout-changed` hook to set it to:

- `top` when `#{window_panes}` is greater than one;
- `off` when a window returns to one pane.

Run the same reconciliation once when the tmux configuration loads so existing
windows immediately receive the correct state.

## Files

Expected implementation surfaces:

- `lua/ctchen/plugins/incline.lua`
- `lua/ctchen/core/options.lua`
- `lua/ctchen/plugins/lualine.lua`
- `lazy-lock.json` (Incline entry only)
- `~/.config/tmux/tmux.conf`
- `~/.config/tmux/script/status-context.sh`
- `~/.config/tmux/script/update-pane-borders.sh`
- focused Neovim and tmux behavior tests

The tmux configuration directory is not a Git repository. The Neovim changes
and this design document live on
`feature/260811-streamlined-terminal-ui`; unrelated existing dirty files must
remain untouched and uncommitted.

## Verification

1. Run focused tests that fail without the new Neovim and tmux behavior.
2. Start Neovim headlessly and assert Incline loads, `laststatus` is `3`, and
   Lualine reports `globalstatus=true`.
3. Test context output with temporary plain, Node, and Kubernetes project
   fixtures, plus empty and populated Claude state directories.
4. Parse the tmux configuration with `source-file -n`.
5. Use an isolated tmux server to prove the pane title state transitions
   `off -> top -> off` as pane count changes `1 -> 2 -> 1`.
6. Reload the live tmux configuration and inspect the rendered `status-right`
   and per-window pane-border state.
7. Review the final Git diff and stage only files belonging to this change.

## Rollback

Remove the Incline plugin specification, restore Lualine's previous options,
restore the original tmux module list, remove the two user-owned scripts and
hook, and set `pane-border-status` back to `top`. Existing manual pane titles
and unrelated workflow plugins remain unaffected.
