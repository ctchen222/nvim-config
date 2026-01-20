# Neovim Lua API Reference

## vim.api (Core API)

### Buffer Functions

```lua
-- Get/set current buffer
vim.api.nvim_get_current_buf() -> bufnr
vim.api.nvim_set_current_buf(bufnr)

-- Buffer info
vim.api.nvim_buf_get_name(bufnr) -> string (filepath)
vim.api.nvim_buf_set_name(bufnr, name)
vim.api.nvim_buf_is_valid(bufnr) -> boolean
vim.api.nvim_buf_is_loaded(bufnr) -> boolean
vim.api.nvim_buf_get_option(bufnr, name) -> value  -- deprecated, use vim.bo[bufnr]
vim.api.nvim_buf_line_count(bufnr) -> integer

-- Buffer content
vim.api.nvim_buf_get_lines(bufnr, start, end, strict) -> string[]
vim.api.nvim_buf_set_lines(bufnr, start, end, strict, lines)
vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {}) -> string[]
vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, lines)

-- Buffer modifications
vim.api.nvim_buf_delete(bufnr, { force = false, unload = false })
vim.api.nvim_create_buf(listed, scratch) -> bufnr

-- Marks and extmarks
vim.api.nvim_buf_get_mark(bufnr, name) -> {row, col}
vim.api.nvim_buf_set_mark(bufnr, name, row, col, {})
vim.api.nvim_buf_get_extmarks(bufnr, ns_id, start, end, opts) -> marks
vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, col, opts) -> id
vim.api.nvim_buf_del_extmark(bufnr, ns_id, id)
```

### Window Functions

```lua
-- Get/set current window
vim.api.nvim_get_current_win() -> winnr
vim.api.nvim_set_current_win(winnr)

-- Window info
vim.api.nvim_win_get_buf(winnr) -> bufnr
vim.api.nvim_win_set_buf(winnr, bufnr)
vim.api.nvim_win_get_cursor(winnr) -> {row, col}  -- row is 1-indexed!
vim.api.nvim_win_set_cursor(winnr, {row, col})
vim.api.nvim_win_get_height(winnr) -> integer
vim.api.nvim_win_set_height(winnr, height)
vim.api.nvim_win_get_width(winnr) -> integer
vim.api.nvim_win_set_width(winnr, width)
vim.api.nvim_win_get_position(winnr) -> {row, col}
vim.api.nvim_win_is_valid(winnr) -> boolean

-- Window management
vim.api.nvim_win_close(winnr, force)
vim.api.nvim_open_win(bufnr, enter, config) -> winnr  -- floating window
vim.api.nvim_win_set_config(winnr, config)
vim.api.nvim_win_get_config(winnr) -> config

-- List windows
vim.api.nvim_list_wins() -> winnr[]
vim.api.nvim_tabpage_list_wins(tabpage) -> winnr[]
```

### Floating Window Config

```lua
vim.api.nvim_open_win(bufnr, true, {
  relative = "editor",  -- "editor", "win", "cursor", "mouse"
  row = 10,
  col = 10,
  width = 50,
  height = 20,
  anchor = "NW",  -- "NW", "NE", "SW", "SE"
  style = "minimal",
  border = "rounded",  -- "none", "single", "double", "rounded", "solid", "shadow"
  title = "Title",
  title_pos = "center",  -- "left", "center", "right"
  footer = "Footer",
  focusable = true,
  zindex = 50,
})
```

### Tabpage Functions

```lua
vim.api.nvim_get_current_tabpage() -> tabpage
vim.api.nvim_set_current_tabpage(tabpage)
vim.api.nvim_list_tabpages() -> tabpage[]
vim.api.nvim_tabpage_get_win(tabpage) -> winnr
vim.api.nvim_tabpage_is_valid(tabpage) -> boolean
```

### Keymaps

```lua
-- Modern API (preferred)
vim.keymap.set(mode, lhs, rhs, opts)
vim.keymap.del(mode, lhs, opts)

-- Options
{
  buffer = bufnr,      -- Buffer-local keymap
  silent = true,       -- Don't echo
  noremap = true,      -- Non-recursive (default true)
  nowait = true,       -- Don't wait for other keys
  expr = true,         -- rhs is expression
  desc = "Description",
  callback = function() end,  -- Alternative to string rhs
  remap = false,       -- Allow recursive mapping
}

-- Legacy API
vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
vim.api.nvim_del_keymap(mode, lhs)
vim.api.nvim_buf_del_keymap(bufnr, mode, lhs)
vim.api.nvim_get_keymap(mode) -> keymaps
vim.api.nvim_buf_get_keymap(bufnr, mode) -> keymaps
```

### User Commands

```lua
vim.api.nvim_create_user_command(name, command, opts)
vim.api.nvim_buf_create_user_command(bufnr, name, command, opts)
vim.api.nvim_del_user_command(name)

-- Command callback receives:
function(opts)
  opts.args      -- string: arguments
  opts.fargs     -- string[]: split arguments
  opts.bang      -- boolean: command had !
  opts.line1     -- integer: start line (range)
  opts.line2     -- integer: end line (range)
  opts.range     -- integer: 0, 1, or 2 (range count)
  opts.count     -- integer: count
  opts.reg       -- string: register
  opts.mods      -- table: command modifiers
  opts.smods     -- table: structured modifiers
end

-- Options
{
  nargs = 0,         -- 0, 1, "*", "?", "+"
  bang = true,       -- Accept !
  range = true,      -- Accept range (true, "%", or number)
  count = true,      -- Accept count
  addr = "lines",    -- "lines", "arguments", "buffers", "loaded_buffers", etc.
  complete = "file", -- Completion type or function
  desc = "Description",
  force = true,      -- Overwrite existing
  preview = function(opts, ns, buf) end,  -- Preview function
}
```

### Autocommands

```lua
-- Create autocommand group
local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })

-- Create autocommand
vim.api.nvim_create_autocmd(event, {
  group = group,
  pattern = "*.lua",  -- or buffer = bufnr
  callback = function(ev)
    ev.id        -- autocommand id
    ev.event     -- event name
    ev.group     -- group id
    ev.match     -- expanded <amatch>
    ev.buf       -- buffer number
    ev.file      -- expanded <afile>
    ev.data      -- arbitrary data
  end,
  -- Alternative to callback:
  command = "echo 'Hello'",
  desc = "Description",
  once = true,    -- Run only once
  nested = true,  -- Allow nested autocmds
})

-- Delete autocommand
vim.api.nvim_del_autocmd(id)
vim.api.nvim_clear_autocmds({ group = "MyGroup" })

-- Get autocommands
vim.api.nvim_get_autocmds({
  group = "MyGroup",
  event = "BufEnter",
  pattern = "*.lua",
})

-- Execute autocommands
vim.api.nvim_exec_autocmds(event, {
  group = group,
  pattern = pattern,
  data = data,
})
```

### Common Events

```lua
-- File events
"BufNewFile"      -- Starting to edit a new file
"BufReadPre"      -- Before reading a file
"BufReadPost"     -- After reading a file
"BufWritePre"     -- Before writing a file
"BufWritePost"    -- After writing a file
"BufEnter"        -- After entering a buffer
"BufLeave"        -- Before leaving a buffer
"BufWinEnter"     -- After a buffer is displayed in a window
"BufWinLeave"     -- Before a buffer is removed from a window
"BufDelete"       -- Before deleting a buffer
"BufUnload"       -- Before unloading a buffer
"BufHidden"       -- Just after a buffer becomes hidden

-- Window events
"WinNew"          -- After creating a new window
"WinEnter"        -- After entering a window
"WinLeave"        -- Before leaving a window
"WinClosed"       -- After closing a window
"WinResized"      -- After window was resized

-- Cursor events
"CursorMoved"     -- After cursor moved (normal mode)
"CursorMovedI"    -- After cursor moved (insert mode)
"CursorHold"      -- User doesn't press key for 'updatetime'
"CursorHoldI"     -- Same, in insert mode

-- Insert mode events
"InsertEnter"     -- Entering insert mode
"InsertLeave"     -- Leaving insert mode
"InsertCharPre"   -- Before inserting a char

-- Text change events
"TextChanged"     -- After text changed (normal mode)
"TextChangedI"    -- After text changed (insert mode)
"TextChangedP"    -- After text changed (completion popup)
"TextYankPost"    -- After text yanked

-- UI events
"VimEnter"        -- After all startup tasks
"VimLeave"        -- Before exiting Vim
"UIEnter"         -- After UI attaches
"ColorScheme"     -- After loading colorscheme
"TermOpen"        -- After opening terminal
"TermClose"       -- After closing terminal

-- LSP events
"LspAttach"       -- After LSP client attaches
"LspDetach"       -- Before LSP client detaches

-- Filetype
"FileType"        -- When 'filetype' is set
```

### Highlight and Namespace

```lua
-- Create namespace
local ns_id = vim.api.nvim_create_namespace("my-namespace")

-- Set highlight
vim.api.nvim_set_hl(0, "MyHighlight", {
  fg = "#ff0000",
  bg = "#000000",
  bold = true,
  italic = true,
  underline = true,
  undercurl = true,
  strikethrough = true,
  reverse = true,
  link = "OtherHighlight",  -- Link to another group
  default = true,           -- Don't override if already set
  sp = "#00ff00",           -- Special color (underline/undercurl)
  blend = 50,               -- Transparency (0-100)
})

-- Get highlight
vim.api.nvim_get_hl(0, { name = "MyHighlight" }) -> table
vim.api.nvim_get_hl_id_by_name("MyHighlight") -> id

-- Add highlight to buffer
vim.api.nvim_buf_add_highlight(bufnr, ns_id, "MyHighlight", line, col_start, col_end)
vim.api.nvim_buf_clear_namespace(bufnr, ns_id, line_start, line_end)
```

## vim.fn (Vimscript Functions)

```lua
-- System/files
vim.fn.expand("%:p")        -- Full path of current file
vim.fn.fnamemodify(path, ":h")  -- Directory of path
vim.fn.filereadable(path)   -- File exists and readable
vim.fn.isdirectory(path)    -- Is directory
vim.fn.glob(pattern)        -- Glob files
vim.fn.globpath(path, pattern)  -- Glob with path
vim.fn.readfile(path)       -- Read file lines
vim.fn.writefile(lines, path)   -- Write file
vim.fn.delete(path)         -- Delete file
vim.fn.mkdir(path, "p")     -- Create directory
vim.fn.getcwd()             -- Current working directory
vim.fn.chdir(path)          -- Change directory
vim.fn.executable(name)     -- Is executable (0 or 1)
vim.fn.exepath(name)        -- Path to executable
vim.fn.system(cmd)          -- Run command, return output
vim.fn.systemlist(cmd)      -- Run command, return lines
vim.fn.jobstart(cmd, opts)  -- Start async job

-- Buffer/window
vim.fn.bufnr()              -- Current buffer number
vim.fn.bufname(nr)          -- Buffer name
vim.fn.bufexists(nr)        -- Buffer exists
vim.fn.buflisted(nr)        -- Buffer is listed
vim.fn.win_getid()          -- Current window ID
vim.fn.win_gotoid(id)       -- Go to window by ID
vim.fn.winnr()              -- Current window number
vim.fn.tabpagenr()          -- Current tab number
vim.fn.line(".")            -- Current line number
vim.fn.col(".")             -- Current column
vim.fn.getline(lnum)        -- Get line content
vim.fn.setline(lnum, text)  -- Set line content
vim.fn.getpos(expr)         -- Get position [bufnr, lnum, col, off]
vim.fn.setpos(expr, pos)    -- Set position
vim.fn.cursor(lnum, col)    -- Move cursor

-- String
vim.fn.strlen(s)            -- String length (bytes)
vim.fn.strchars(s)          -- String length (chars)
vim.fn.strwidth(s)          -- Display width
vim.fn.substitute(s, pat, rep, flags)
vim.fn.matchstr(s, pat)     -- Match string
vim.fn.matchlist(s, pat)    -- Match list
vim.fn.split(s, pat)        -- Split string
vim.fn.join(list, sep)      -- Join list

-- Input/output
vim.fn.input(prompt)        -- Get user input
vim.fn.inputlist(items)     -- Show selection list
vim.fn.confirm(msg, choices)-- Confirm dialog
vim.fn.feedkeys(keys, mode) -- Send keys

-- Register
vim.fn.getreg(name)         -- Get register content
vim.fn.setreg(name, value)  -- Set register

-- JSON
vim.fn.json_encode(value)   -- Encode to JSON
vim.fn.json_decode(string)  -- Decode from JSON
```

## vim.opt / vim.o / vim.bo / vim.wo

```lua
-- Global options
vim.o.option = value        -- Simple get/set
vim.opt.option = value      -- With special methods
vim.opt.option:get()        -- Get value
vim.opt.option:append(v)    -- Append to list/set
vim.opt.option:prepend(v)   -- Prepend to list/set
vim.opt.option:remove(v)    -- Remove from list/set

-- Buffer-local options
vim.bo[bufnr].option = value
vim.bo.option = value       -- Current buffer

-- Window-local options
vim.wo[winnr].option = value
vim.wo.option = value       -- Current window

-- Common options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")
```

## vim.g / vim.b / vim.w / vim.t / vim.v / vim.env

```lua
-- Global variables (g:)
vim.g.variable = value
vim.g.mapleader = " "

-- Buffer variables (b:)
vim.b[bufnr].variable = value
vim.b.variable = value

-- Window variables (w:)
vim.w[winnr].variable = value
vim.w.variable = value

-- Tabpage variables (t:)
vim.t[tabnr].variable = value
vim.t.variable = value

-- Vim variables (v:)
vim.v.count
vim.v.register
vim.v.errmsg

-- Environment variables
vim.env.HOME
vim.env.PATH
```

## vim.lsp

```lua
-- Get clients
vim.lsp.get_clients({ bufnr = bufnr })
vim.lsp.get_client_by_id(id)

-- Buffer methods
vim.lsp.buf.hover()
vim.lsp.buf.definition()
vim.lsp.buf.declaration()
vim.lsp.buf.type_definition()
vim.lsp.buf.implementation()
vim.lsp.buf.references()
vim.lsp.buf.rename()
vim.lsp.buf.code_action()
vim.lsp.buf.format({ async = true })
vim.lsp.buf.signature_help()
vim.lsp.buf.document_symbol()
vim.lsp.buf.workspace_symbol()
vim.lsp.buf.incoming_calls()
vim.lsp.buf.outgoing_calls()

-- Start/stop
vim.lsp.start(config)
vim.lsp.stop_client(client_id)

-- Handlers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, { border = "rounded" }
)
```

## vim.diagnostic

```lua
-- Get diagnostics
vim.diagnostic.get(bufnr, opts)
vim.diagnostic.get_next()
vim.diagnostic.get_prev()

-- Set diagnostics
vim.diagnostic.set(ns_id, bufnr, diagnostics)
vim.diagnostic.reset(ns_id, bufnr)

-- Display
vim.diagnostic.open_float(opts)
vim.diagnostic.setloclist()
vim.diagnostic.setqflist()

-- Navigate
vim.diagnostic.goto_next()
vim.diagnostic.goto_prev()

-- Configure
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

-- Severity levels
vim.diagnostic.severity.ERROR
vim.diagnostic.severity.WARN
vim.diagnostic.severity.INFO
vim.diagnostic.severity.HINT
```

## vim.treesitter

```lua
-- Get parser
local parser = vim.treesitter.get_parser(bufnr, lang)
local tree = parser:parse()[1]
local root = tree:root()

-- Get node at cursor
local node = vim.treesitter.get_node()
local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })

-- Node methods
node:type()              -- Node type
node:start()             -- Start row, col, byte
node:end_()              -- End row, col, byte
node:range()             -- start_row, start_col, end_row, end_col
node:parent()            -- Parent node
node:child(index)        -- Child by index
node:child_count()       -- Number of children
node:named_child(index)  -- Named child
node:named_child_count() -- Number of named children
node:next_sibling()      -- Next sibling
node:prev_sibling()      -- Previous sibling
node:field(name)         -- Get field

-- Query
local query = vim.treesitter.query.parse(lang, [[
  (function_declaration
    name: (identifier) @function.name)
]])

for id, node, metadata in query:iter_captures(root, bufnr) do
  local name = query.captures[id]
  local text = vim.treesitter.get_node_text(node, bufnr)
end

-- Highlight
vim.treesitter.start(bufnr, lang)
vim.treesitter.stop(bufnr)
```

## vim.loop (libuv)

```lua
local uv = vim.loop

-- Timer
local timer = uv.new_timer()
timer:start(delay_ms, repeat_ms, vim.schedule_wrap(callback))
timer:stop()
timer:close()

-- File system
uv.fs_stat(path, callback)
uv.fs_readdir(path, callback)
uv.fs_open(path, flags, mode, callback)
uv.fs_read(fd, size, offset, callback)
uv.fs_write(fd, data, offset, callback)
uv.fs_close(fd, callback)

-- Process
local handle, pid = uv.spawn(cmd, {
  args = args,
  stdio = { stdin, stdout, stderr },
  cwd = cwd,
  env = env,
}, function(code, signal)
  -- on exit
end)

-- Async
local async = uv.new_async(vim.schedule_wrap(callback))
async:send()
async:close()

-- Current time
uv.now()           -- milliseconds
uv.hrtime()        -- nanoseconds
```

## Utility Functions

```lua
-- Inspect/debug
vim.inspect(value)         -- Pretty print table
vim.pretty_print(value)    -- Print with vim.inspect
print(vim.inspect(t))      -- Debug to :messages

-- Tables
vim.tbl_deep_extend("force", t1, t2)  -- Deep merge
vim.tbl_extend("force", t1, t2)       -- Shallow merge
vim.tbl_keys(t)            -- Get keys
vim.tbl_values(t)          -- Get values
vim.tbl_contains(t, val)   -- Check if contains
vim.tbl_isempty(t)         -- Check if empty
vim.tbl_islist(t)          -- Check if list-like
vim.tbl_count(t)           -- Count elements
vim.tbl_filter(f, t)       -- Filter table
vim.tbl_map(f, t)          -- Map table
vim.list_extend(dst, src)  -- Extend list
vim.list_slice(list, s, e) -- Slice list

-- Strings
vim.split(s, sep, opts)    -- Split string
vim.trim(s)                -- Trim whitespace
vim.startswith(s, prefix)  -- Check prefix
vim.endswith(s, suffix)    -- Check suffix

-- Validation
vim.validate({
  arg1 = { value, "string" },
  arg2 = { value, "number", true },  -- optional
  arg3 = { value, { "string", "table" } },
  arg4 = { value, function(v) return v > 0 end, "positive number" },
})

-- Scheduling
vim.schedule(callback)     -- Schedule on main loop
vim.schedule_wrap(fn)      -- Wrap function for scheduling
vim.defer_fn(fn, ms)       -- Defer execution
vim.wait(ms, condition)    -- Wait with optional condition

-- Notify
vim.notify(msg, level, opts)
vim.log.levels.TRACE
vim.log.levels.DEBUG
vim.log.levels.INFO
vim.log.levels.WARN
vim.log.levels.ERROR

-- Deep copy
vim.deepcopy(t)

-- Regex
vim.regex(pattern)
regex:match_str(string)
regex:match_line(bufnr, line)

-- UI
vim.ui.input(opts, callback)
vim.ui.select(items, opts, callback)
```
