return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- JS/TS linting is now handled by ESLint LSP server for better performance
    lint.linters_by_ft = {
      python = { "ruff" },
      markdown = { "vale" },
      sql = { "sqlfluff" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- 移除 BufEnter 以提升效能，只在儲存和離開 insert mode 時 lint
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- 延遲執行以避免阻塞
        vim.defer_fn(function()
          lint.try_lint()
        end, 100)
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
