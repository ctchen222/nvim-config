local selections = {
  ["a="] = "@assignment.outer",
  ["i="] = "@assignment.inner",
  ["l="] = "@assignment.lhs",
  ["r="] = "@assignment.rhs",
  ["a:"] = "@property.outer",
  ["i:"] = "@property.inner",
  ["l:"] = "@property.lhs",
  ["r:"] = "@property.rhs",
  aa = "@parameter.outer",
  ia = "@parameter.inner",
  ai = "@conditional.outer",
  ii = "@conditional.inner",
  al = "@loop.outer",
  il = "@loop.inner",
  af = "@call.outer",
  ["if"] = "@call.inner",
  am = "@function.outer",
  im = "@function.inner",
  ac = "@class.outer",
  ic = "@class.inner",
}

local swaps = {
  ["<leader>na"] = { direction = "next", query = "@parameter.inner" },
  ["<leader>n:"] = { direction = "next", query = "@property.outer" },
  ["<leader>nm"] = { direction = "next", query = "@function.outer" },
  ["<leader>pa"] = { direction = "previous", query = "@parameter.inner" },
  ["<leader>p:"] = { direction = "previous", query = "@property.outer" },
  ["<leader>pm"] = { direction = "previous", query = "@function.outer" },
}

local movements = {
  ["]f"] = { method = "goto_next_start", query = "@call.outer" },
  ["]m"] = { method = "goto_next_start", query = "@function.outer" },
  ["]c"] = { method = "goto_next_start", query = "@class.outer" },
  ["]i"] = { method = "goto_next_start", query = "@conditional.outer" },
  ["]l"] = { method = "goto_next_start", query = "@loop.outer" },
  ["]s"] = { method = "goto_next_start", query = "@local.scope", group = "locals" },
  ["]z"] = { method = "goto_next_start", query = "@fold", group = "folds" },
  ["]F"] = { method = "goto_next_end", query = "@call.outer" },
  ["]M"] = { method = "goto_next_end", query = "@function.outer" },
  ["]C"] = { method = "goto_next_end", query = "@class.outer" },
  ["]I"] = { method = "goto_next_end", query = "@conditional.outer" },
  ["]L"] = { method = "goto_next_end", query = "@loop.outer" },
  ["[f"] = { method = "goto_previous_start", query = "@call.outer" },
  ["[m"] = { method = "goto_previous_start", query = "@function.outer" },
  ["[c"] = { method = "goto_previous_start", query = "@class.outer" },
  ["[i"] = { method = "goto_previous_start", query = "@conditional.outer" },
  ["[l"] = { method = "goto_previous_start", query = "@loop.outer" },
  ["[F"] = { method = "goto_previous_end", query = "@call.outer" },
  ["[M"] = { method = "goto_previous_end", query = "@function.outer" },
  ["[C"] = { method = "goto_previous_end", query = "@class.outer" },
  ["[I"] = { method = "goto_previous_end", query = "@conditional.outer" },
  ["[L"] = { method = "goto_previous_end", query = "@loop.outer" },
}

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    for key, query in pairs(selections) do
      local query_string = query
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(query_string, "textobjects")
      end, { desc = "Select " .. query_string })
    end

    local swap = require("nvim-treesitter-textobjects.swap")
    for key, action in pairs(swaps) do
      local method = "swap_" .. action.direction
      local query = action.query
      vim.keymap.set("n", key, function()
        swap[method](query)
      end, { desc = method .. " " .. query })
    end

    local move = require("nvim-treesitter-textobjects.move")
    for key, action in pairs(movements) do
      local method = action.method
      local query = action.query
      local group = action.group or "textobjects"
      vim.keymap.set({ "n", "x", "o" }, key, function()
        move[method](query, group)
      end, { desc = method .. " " .. query })
    end

    local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
    vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", repeat_move.repeat_last_move_opposite)
    vim.keymap.set({ "n", "x", "o" }, "f", repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", repeat_move.builtin_T_expr, { expr = true })
  end,
}
