# Streamlined Terminal UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an upper-right Incline filename label and one global Lualine row in Neovim, then reduce the tmux status bar to persistent Git/directory/time sections with contextual Claude/Kubernetes/Node information and pane titles shown only for multi-pane windows.

**Architecture:** Neovim keeps UI ownership in small Lazy plugin specifications and core options. tmux keeps Catppuccin as the renderer, while two user-owned shell scripts determine contextual status text and per-window pane-border visibility without modifying plugin internals.

**Tech Stack:** Neovim Lua, lazy.nvim, lualine.nvim, incline.nvim, nvim-web-devicons, tmux 3.6a, Bash, Catppuccin tmux.

## Global Constraints

- Work on Neovim branch `feature/260811-streamlined-terminal-ui`.
- Preserve the pre-existing unstaged changes in `lazy-lock.json`, `colorscheme.lua`, `linting.lua`, `openspec.lua`, and `wilder.lua`, plus existing untracked logs/backups.
- In `lazy-lock.json`, stage only the new `incline.nvim` entry. The existing removal of `99` and addition of `onedarkpro.nvim` belong to the user.
- `/Users/ctchen/.config/tmux` is not a Git repository. Back up `tmux.conf` before editing and report the backup path; do not invent a commit for those files.
- Keep `allow-set-title off`, the existing `pane-border-format`, all existing keybindings, and the current AI/Lazy/encoding/file-format/filetype Lualine components.
- Do not edit Catppuccin plugin files or source NVM during tmux status refreshes.
- Use isolated tmux sockets for automated tests; reload the live server only during final acceptance.

## File Map

| Path | Responsibility |
|---|---|
| `/Users/ctchen/.config/nvim/tests/streamlined_ui_spec.lua` | Focused Neovim regression checks |
| `/Users/ctchen/.config/nvim/lua/ctchen/core/options.lua` | Set global statusline mode |
| `/Users/ctchen/.config/nvim/lua/ctchen/plugins/lualine.lua` | Enable Lualine global status |
| `/Users/ctchen/.config/nvim/lua/ctchen/plugins/incline.lua` | Render upper-right filename labels |
| `/Users/ctchen/.config/nvim/lazy-lock.json` | Pin Incline only |
| `/Users/ctchen/.config/tmux/tests/status-context-test.sh` | Context detection regression checks |
| `/Users/ctchen/.config/tmux/script/status-context.sh` | Emit contextual Claude/Kube/Node prefix |
| `/Users/ctchen/.config/tmux/tests/pane-borders-test.sh` | Pane-border state and tmux wiring checks |
| `/Users/ctchen/.config/tmux/script/update-pane-borders.sh` | Reconcile border visibility per window |
| `/Users/ctchen/.config/tmux/tmux.conf` | Wire scripts into Catppuccin and tmux hooks |

---

### Task 1: Add the Neovim global statusline and Incline filename label

**Files:**

- Create: `/Users/ctchen/.config/nvim/tests/streamlined_ui_spec.lua`
- Create: `/Users/ctchen/.config/nvim/lua/ctchen/plugins/incline.lua`
- Modify: `/Users/ctchen/.config/nvim/lua/ctchen/core/options.lua:25-30`
- Modify: `/Users/ctchen/.config/nvim/lua/ctchen/plugins/lualine.lua:71-76`
- Modify: `/Users/ctchen/.config/nvim/lazy-lock.json` (Incline entry only)

- [ ] **Step 1: Write the focused failing Neovim test**

Create `tests/streamlined_ui_spec.lua`:

```lua
local root = vim.fn.getcwd()

local function assert_equal(expected, actual, message)
  if expected ~= actual then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_truthy(value, message)
  if not value then
    error(message)
  end
end

local function flatten(value)
  if type(value) == "string" then
    return value
  end
  if type(value) ~= "table" then
    return ""
  end

  local parts = {}
  for _, item in ipairs(value) do
    parts[#parts + 1] = flatten(item)
  end
  return table.concat(parts)
end

dofile(root .. "/lua/ctchen/core/options.lua")
assert_equal(3, vim.o.laststatus, "Neovim must use one global statusline")

local lualine_options
package.loaded["lualine"] = {
  setup = function(options)
    lualine_options = options
  end,
}
package.loaded["lazy.status"] = {
  updates = function()
    return ""
  end,
  has_updates = function()
    return false
  end,
}

local lualine_spec = dofile(root .. "/lua/ctchen/plugins/lualine.lua")
lualine_spec.config()
assert_truthy(lualine_options, "Lualine setup must run")
assert_equal(true, lualine_options.options.globalstatus, "Lualine must render globally")

local incline_options
package.loaded["incline"] = {
  setup = function(options)
    incline_options = options
  end,
}
package.loaded["nvim-web-devicons"] = {
  get_icon_color = function(filename)
    if filename == "example.lua" then
      return "", "#51a0cf"
    end
  end,
}

vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#fff7e8", bg = "#3a334f" })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#c3ccdc", bg = "#211c32" })

local incline_spec = dofile(root .. "/lua/ctchen/plugins/incline.lua")
assert_equal("BufReadPre", incline_spec.event, "Incline must load before a buffer is read")
incline_spec.config()

assert_truthy(incline_options, "Incline setup must run")
assert_equal("right", incline_options.window.placement.horizontal, "Incline must sit on the right")
assert_equal("top", incline_options.window.placement.vertical, "Incline must sit at the top")
assert_truthy(incline_options.highlight.groups.InclineNormal.guibg, "Active label must have a background")
assert_truthy(incline_options.highlight.groups.InclineNormalNC.guibg, "Inactive label must have a background")

local buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buffer, root .. "/example.lua")
vim.bo[buffer].modified = true

local rendered = flatten(incline_options.render({ buf = buffer, focused = true }))
assert_truthy(rendered:find("", 1, true), "Incline must render the filetype icon")
assert_truthy(rendered:find("example.lua", 1, true), "Incline must render the filename")
assert_truthy(rendered:find("●", 1, true), "Incline must render a modified marker")

local unnamed = vim.api.nvim_create_buf(true, false)
local unnamed_rendered = flatten(incline_options.render({ buf = unnamed, focused = false }))
assert_truthy(unnamed_rendered:find("[No Name]", 1, true), "Incline must label unnamed buffers")

print("streamlined Neovim UI checks passed")
vim.cmd("qa!")
```

- [ ] **Step 2: Run the test and confirm RED**

Run:

```bash
cd /Users/ctchen/.config/nvim
nvim --headless -u NONE -l tests/streamlined_ui_spec.lua
```

Expected: non-zero exit because `laststatus` is still `2` and `lua/ctchen/plugins/incline.lua` does not exist.

- [ ] **Step 3: Implement the minimal Neovim configuration**

Add this near the other visual options in `lua/ctchen/core/options.lua`:

```lua
opt.laststatus = 3
```

Add `globalstatus` without changing existing Lualine sections:

```lua
lualine.setup({
  options = {
    theme = my_lualine_theme,
    globalstatus = true,
  },
```

Create `lua/ctchen/plugins/incline.lua`:

```lua
return {
  "b0o/incline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "BufReadPre",
  priority = 1200,
  config = function()
    local devicons = require("nvim-web-devicons")

    local function highlight_color(group, attribute, fallback)
      local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
      local value = highlight[attribute]
      return value and string.format("#%06x", value) or fallback
    end

    local active_background = highlight_color("PmenuSel", "bg", "#3A334F")
    local active_foreground = highlight_color("PmenuSel", "fg", "#FFF7E8")
    local inactive_background = highlight_color("NormalFloat", "bg", "#211C32")
    local inactive_foreground = highlight_color("NormalFloat", "fg", "#C3CCDC")

    require("incline").setup({
      highlight = {
        groups = {
          InclineNormal = {
            guibg = active_background,
            guifg = active_foreground,
          },
          InclineNormalNC = {
            guibg = inactive_background,
            guifg = inactive_foreground,
          },
        },
      },
      window = {
        margin = { horizontal = 1, vertical = 0 },
        padding = 0,
        placement = { horizontal = "right", vertical = "top" },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end

        local icon, icon_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified

        return {
          " ",
          icon and { icon, guifg = icon_color } or "",
          icon and " " or "",
          { filename, gui = props.focused and "bold" or nil },
          modified and { " ●", guifg = "#FFDA7B" } or "",
          " ",
        }
      end,
    })
  end,
}
```

- [ ] **Step 4: Run the focused test and confirm GREEN**

Run:

```bash
cd /Users/ctchen/.config/nvim
nvim --headless -u NONE -l tests/streamlined_ui_spec.lua
```

Expected: `streamlined Neovim UI checks passed` and exit code `0`.

- [ ] **Step 5: Install only Incline and update its lock entry**

Run:

```bash
cd /Users/ctchen/.config/nvim
nvim --headless "+Lazy! sync incline.nvim" "+qa!"
git diff -- lazy-lock.json
```

Expected: a new `incline.nvim` entry appears. Existing user-owned `99` and `onedarkpro.nvim` lockfile changes remain present but are not reverted.

- [ ] **Step 6: Verify the real Lazy load path**

Run:

```bash
cd /Users/ctchen/.config/nvim
nvim --headless tests/streamlined_ui_spec.lua "+lua assert(vim.o.laststatus == 3)" "+lua assert(package.loaded.incline ~= nil)" "+qa!"
```

Expected: exit code `0`; opening a real buffer triggers `BufReadPre` and loads Incline.

- [ ] **Step 7: Stage only this task and commit**

Run:

```bash
cd /Users/ctchen/.config/nvim
git add lua/ctchen/core/options.lua lua/ctchen/plugins/lualine.lua lua/ctchen/plugins/incline.lua tests/streamlined_ui_spec.lua
git add -p lazy-lock.json
git diff --cached -- lazy-lock.json
git diff --cached --name-only
git commit -m "feat(nvim): add global status and incline filename"
```

During `git add -p`, decline the pre-existing `99` removal and `onedarkpro.nvim` addition; accept only the `incline.nvim` hunk. If Git combines hunks, use patch-edit mode and retain only the single Incline line. Before committing, the cached lockfile diff must contain exactly the Incline entry.

---

### Task 2: Add context-aware Claude, Kubernetes, and Node status output

**Files:**

- Create: `/Users/ctchen/.config/tmux/tests/status-context-test.sh`
- Create: `/Users/ctchen/.config/tmux/script/status-context.sh`

- [ ] **Step 1: Write the failing shell behavior test**

Create `tests/status-context-test.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

tmux_root="/Users/ctchen/.config/tmux"
context_script="$tmux_root/script/status-context.sh"
fixture_root="$(mktemp -d)"
stub_bin="$fixture_root/bin"
state_dir="$fixture_root/claude-state"

cleanup() {
  rm -rf "$fixture_root"
}
trap cleanup EXIT

assert_equal() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$expected" != "$actual" ]]; then
    printf 'FAIL: %s\nexpected: <%s>\nactual:   <%s>\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

mkdir -p "$stub_bin" "$state_dir" "$fixture_root/plain"

printf '%s\n' '#!/usr/bin/env bash' 'printf "v22.22.2\n"' > "$stub_bin/node"
printf '%s\n' '#!/usr/bin/env bash' 'printf "corp/dev-cluster\n"' > "$stub_bin/kubectl"
chmod +x "$stub_bin/node" "$stub_bin/kubectl"

test_path="$stub_bin:/usr/bin:/bin:/usr/sbin:/sbin"

actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/plain")"
assert_equal "" "$actual" "plain directory stays quiet"

mkdir -p "$fixture_root/node-project/apps/web/src"
git -C "$fixture_root/node-project" init -q
touch "$fixture_root/node-project/package.json"
actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/node-project/apps/web/src")"
assert_equal "󰎙 v22.22.2  " "$actual" "Node marker is found up to the Git root"

mkdir -p "$fixture_root/kube-project/service" "$fixture_root/kube-project/charts"
git -C "$fixture_root/kube-project" init -q
actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/kube-project/service")"
assert_equal "⎈ dev-cluster  " "$actual" "Kubernetes marker renders the shortened context"

mkdir -p "$fixture_root/outside-parent/child"
touch "$fixture_root/outside-parent/package.json"
actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/outside-parent/child")"
assert_equal "" "$actual" "non-Git paths inspect only the current directory"

printf 'invalid\n' > "$state_dir/invalid"
actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/plain")"
assert_equal "" "$actual" "invalid Claude state is ignored"

printf 'session|window|pane 1|project\n' > "$state_dir/valid"
touch "$fixture_root/node-project/Chart.yaml"
actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/node-project/apps/web/src")"
assert_equal "󰚩 1 · ⎈ dev-cluster · 󰎙 v22.22.2  " "$actual" "contexts use stable order and separators"

actual="$(CLAUDE_WAIT_STATE_DIR="$state_dir" PATH="$test_path" "$context_script" "$fixture_root/missing")"
assert_equal "" "$actual" "missing paths fail silently"

printf 'status context checks passed\n'
```

- [ ] **Step 2: Run the test and confirm RED**

Run:

```bash
chmod +x /Users/ctchen/.config/tmux/tests/status-context-test.sh
/Users/ctchen/.config/tmux/tests/status-context-test.sh
```

Expected: non-zero exit because `script/status-context.sh` does not exist.

- [ ] **Step 3: Implement bounded context detection**

Create `script/status-context.sh`:

```bash
#!/usr/bin/env bash
set -u

pane_path="${1:-}"
if [[ ! -d "$pane_path" ]]; then
  exit 0
fi

pane_path="$(cd "$pane_path" 2>/dev/null && pwd -P)" || exit 0
search_root="$pane_path"
git_root="$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -n "$git_root" && -d "$git_root" ]]; then
  canonical_git_root="$(cd "$git_root" 2>/dev/null && pwd -P)" || canonical_git_root=""
  if [[ -n "$canonical_git_root" ]]; then
    search_root="$canonical_git_root"
  fi
fi

has_node=0
has_kube=0
current="$pane_path"

while :; do
  if [[ -f "$current/package.json" ]]; then
    has_node=1
  fi

  for marker in Chart.yaml helmfile.yaml helmfile.yml kustomization.yaml; do
    if [[ -f "$current/$marker" ]]; then
      has_kube=1
      break
    fi
  done

  if ((has_kube == 0)); then
    for marker in k8s kubernetes helm charts deploy; do
      if [[ -d "$current/$marker" ]]; then
        has_kube=1
        break
      fi
    done
  fi

  if [[ "$current" == "$search_root" || "$search_root" == "$pane_path" ]]; then
    break
  fi

  parent="$(dirname "$current")"
  if [[ "$parent" == "$current" ]]; then
    break
  fi
  if [[ "$parent" != "$search_root" && "$parent" != "$search_root/"* ]]; then
    break
  fi
  current="$parent"
done

contexts=()
state_dir="${CLAUDE_WAIT_STATE_DIR:-/tmp/claude-wait}"
claude_count=0

if [[ -d "$state_dir" ]]; then
  shopt -s nullglob
  state_files=("$state_dir"/*)
  for state_file in "${state_files[@]}"; do
    [[ -f "$state_file" ]] || continue
    state_line="$(head -n 1 "$state_file" 2>/dev/null || true)"
    IFS='|' read -r session window pane project extra <<< "$state_line"
    if [[ -n "$session" && -n "$window" && -n "$pane" && -n "$project" ]]; then
      ((claude_count += 1))
    fi
  done
fi

if ((claude_count > 0)); then
  contexts+=("󰚩 $claude_count")
fi

if ((has_kube == 1)) && command -v kubectl >/dev/null 2>&1; then
  kube_context="$(kubectl config current-context 2>/dev/null || true)"
  if [[ -n "$kube_context" ]]; then
    contexts+=("⎈ ${kube_context##*/}")
  fi
fi

if ((has_node == 1)) && command -v node >/dev/null 2>&1; then
  node_version="$(node -v 2>/dev/null || true)"
  if [[ -n "$node_version" ]]; then
    contexts+=("󰎙 $node_version")
  fi
fi

if ((${#contexts[@]} > 0)); then
  output=""
  for context in "${contexts[@]}"; do
    if [[ -n "$output" ]]; then
      output+=" · "
    fi
    output+="$context"
  done
  printf '%s  ' "$output"
fi
```

- [ ] **Step 4: Make the script executable and confirm GREEN**

Run:

```bash
chmod +x /Users/ctchen/.config/tmux/script/status-context.sh
/Users/ctchen/.config/tmux/tests/status-context-test.sh
```

Expected: `status context checks passed` and exit code `0`.

---

### Task 3: Wire the simplified tmux status and conditional pane titles

**Files:**

- Create: `/Users/ctchen/.config/tmux/tests/pane-borders-test.sh`
- Create: `/Users/ctchen/.config/tmux/script/update-pane-borders.sh`
- Modify: `/Users/ctchen/.config/tmux/tmux.conf:42-45,100-131,133-134`

- [ ] **Step 1: Back up the non-Git tmux configuration**

Run:

```bash
cp /Users/ctchen/.config/tmux/tmux.conf /Users/ctchen/.config/tmux/tmux.conf.bak-260811-streamlined-ui
```

Expected: the backup exists and remains outside the Neovim commit.

- [ ] **Step 2: Write the failing pane-border and wiring test**

Create `tests/pane-borders-test.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

tmux_root="/Users/ctchen/.config/tmux"
config="$tmux_root/tmux.conf"
border_script="$tmux_root/script/update-pane-borders.sh"
socket="streamlined-ui-test-$$"

cleanup() {
  tmux -L "$socket" kill-server 2>/dev/null || true
}
trap cleanup EXIT

assert_equal() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$expected" != "$actual" ]]; then
    printf 'FAIL: %s\nexpected: <%s>\nactual:   <%s>\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

grep -Fq 'set -g pane-border-status off' "$config"
grep -Fq 'set-hook -g window-layout-changed' "$config"
grep -Fq '@catppuccin_status_modules_right "git directory date_time"' "$config"
grep -Fq 'status-context.sh #{q:pane_current_path}' "$config"
grep -Fq 'set -g allow-set-title off' "$config"

tmux -L "$socket" -f /dev/null new-session -d -s streamlined
window_id="$(tmux -L "$socket" display-message -p '#{window_id}')"

TMUX_SOCKET_NAME="$socket" "$border_script" "$window_id"
actual="$(tmux -L "$socket" show-options -w -v -t "$window_id" pane-border-status)"
assert_equal "off" "$actual" "one pane hides the title border"

tmux -L "$socket" split-window -d -t "$window_id"
TMUX_SOCKET_NAME="$socket" "$border_script" "$window_id"
actual="$(tmux -L "$socket" show-options -w -v -t "$window_id" pane-border-status)"
assert_equal "top" "$actual" "two panes show the title border"

pane_to_kill="$(tmux -L "$socket" list-panes -t "$window_id" -F '#{pane_id}' | tail -n 1)"
tmux -L "$socket" kill-pane -t "$pane_to_kill"
TMUX_SOCKET_NAME="$socket" "$border_script" "$window_id"
actual="$(tmux -L "$socket" show-options -w -v -t "$window_id" pane-border-status)"
assert_equal "off" "$actual" "returning to one pane hides the title border"

printf 'pane border checks passed\n'
```

- [ ] **Step 3: Run the test and confirm RED**

Run:

```bash
chmod +x /Users/ctchen/.config/tmux/tests/pane-borders-test.sh
/Users/ctchen/.config/tmux/tests/pane-borders-test.sh
```

Expected: non-zero exit because the config still uses `pane-border-status top`, the simplified module list is absent, and `update-pane-borders.sh` does not exist.

- [ ] **Step 4: Implement the pane-border reconciler**

Create `script/update-pane-borders.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

command -v tmux >/dev/null 2>&1 || exit 0

tmux_args=()
if [[ -n "${TMUX_SOCKET_NAME:-}" ]]; then
  tmux_args=(-L "$TMUX_SOCKET_NAME")
fi

tmux_call() {
  tmux "${tmux_args[@]}" "$@"
}

update_window() {
  local window_id="$1"
  local pane_count
  local border_status="off"

  pane_count="$(tmux_call display-message -p -t "$window_id" '#{window_panes}' 2>/dev/null)" || return 0
  if ((pane_count > 1)); then
    border_status="top"
  fi

  tmux_call set-option -w -t "$window_id" pane-border-status "$border_status"
}

if (($# > 0)); then
  update_window "$1"
  exit 0
fi

while read -r window_id; do
  [[ -n "$window_id" ]] || continue
  update_window "$window_id"
done < <(tmux_call list-windows -a -F '#{window_id}')
```

Run:

```bash
chmod +x /Users/ctchen/.config/tmux/script/update-pane-borders.sh
```

- [ ] **Step 5: Wire the scripts into tmux without changing pane-title ownership**

Apply these focused changes to `tmux.conf`:

```tmux
# One-pane windows stay clean; the layout hook enables titles for split windows.
set -g pane-border-status off
set -g pane-border-format "#{?pane_active,#[fg=#1e2030 bg=#89b4fa bold]  #{pane_index} #{?pane_title,: #{pane_title}, } #[default],#[fg=#cdd6f4 bg=#313244]  #{pane_index} #{?pane_title,: #{pane_title}, } #[default]}"
set-hook -g window-layout-changed 'run-shell -b "$HOME/.config/tmux/script/update-pane-borders.sh #{q:window_id}"'
```

Keep `allow-set-title off` unchanged. Replace the right-side module list:

```tmux
set -g @catppuccin_status_modules_right "git directory date_time"
```

Delete only the unused `@catppuccin_claude_*`, `@catppuccin_kube_*`, and `@catppuccin_node_*` option blocks. Leave their legacy scripts on disk for rollback. Replace the directory text option with:

```tmux
set -g @catppuccin_directory_text "#($HOME/.config/tmux/script/status-context.sh #{q:pane_current_path})#{b:pane_current_path}"
```

Immediately after the TPM run line, reconcile already-open windows:

```tmux
run-shell -b "$HOME/.config/tmux/script/update-pane-borders.sh"
```

- [ ] **Step 6: Confirm the focused test is GREEN**

Run:

```bash
/Users/ctchen/.config/tmux/tests/pane-borders-test.sh
```

Expected: `pane border checks passed` and exit code `0`.

- [ ] **Step 7: Parse the complete tmux configuration**

Run:

```bash
tmux source-file -n /Users/ctchen/.config/tmux/tmux.conf
```

Expected: no syntax error and exit code `0`.

---

### Task 4: Run integrated acceptance and protect unrelated state

**Files:**

- Verify: all files from Tasks 1-3
- Do not modify: existing unrelated Neovim dirty files or Catppuccin plugin files

- [ ] **Step 1: Run all focused tests**

Run:

```bash
cd /Users/ctchen/.config/nvim
nvim --headless -u NONE -l tests/streamlined_ui_spec.lua
/Users/ctchen/.config/tmux/tests/status-context-test.sh
/Users/ctchen/.config/tmux/tests/pane-borders-test.sh
tmux source-file -n /Users/ctchen/.config/tmux/tmux.conf
```

Expected: all four commands exit `0`.

- [ ] **Step 2: Reload the live tmux configuration**

Run:

```bash
tmux source-file /Users/ctchen/.config/tmux/tmux.conf
```

Expected: the live server accepts the configuration; existing sessions and panes remain open.

- [ ] **Step 3: Verify live module and pane-border state**

Run:

```bash
tmux show-option -gqv @catppuccin_status_modules_right
tmux show-option -gqv @catppuccin_directory_text
tmux show-option -gqv allow-set-title
tmux list-windows -a -F '#{session_name}:#{window_index} panes=#{window_panes} border=#{pane-border-status}'
tmux display-message -p '#{E:status-right}'
```

Expected:

- Modules are exactly `git directory date_time`.
- Directory text invokes `status-context.sh` before the basename.
- `allow-set-title` remains `off`.
- Every one-pane window reports `border=off`; every multi-pane window reports `border=top`.
- The rendered status has no permanent standalone Claude/Kube/Node pills.

- [ ] **Step 4: Perform a manual Neovim visual smoke check**

Open Neovim in a normal terminal session, split one named file and one modified file, then verify:

- one Lualine row spans the editor;
- each normal editor window has an upper-right filename label;
- the active label uses the brighter theme-derived surface;
- the inactive label is subdued;
- the modified buffer shows `●`;
- floating/special windows do not receive distracting labels.

- [ ] **Step 5: Audit Git scope and final diff**

Run:

```bash
cd /Users/ctchen/.config/nvim
git status --short
git show --stat --oneline HEAD
git show --format=fuller --no-ext-diff HEAD -- lua/ctchen/core/options.lua lua/ctchen/plugins/lualine.lua lua/ctchen/plugins/incline.lua tests/streamlined_ui_spec.lua lazy-lock.json
git diff -- lazy-lock.json lua/ctchen/plugins/colorscheme.lua lua/ctchen/plugins/linting.lua lua/ctchen/plugins/openspec.lua lua/ctchen/plugins/wilder.lua
```

Expected: the implementation commit contains only Task 1 files and only the Incline lock entry. The user's pre-existing unstaged/untracked files remain present and uncommitted.

## Completion Criteria

- All four approved behaviors are implemented.
- Focused Neovim and tmux tests pass.
- Incline loads through the real Lazy event path.
- tmux syntax and isolated `off -> top -> off` transitions pass.
- The live tmux status and per-window border states match the design.
- Existing manual pane-title protection and unrelated dirty files remain intact.
