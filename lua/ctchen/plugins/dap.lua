return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "theHamsta/nvim-dap-virtual-text",
    "leoluz/nvim-dap-go",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      ensure_installed = { "go", "node2" },
      handlers = {},
    })

    require("dapui").setup()
    require("dap-go").setup()

    dap.configurations.javascript = {
      {
        type = "node2",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = vim.fn.getcwd(),
      },
    }

    dap.configurations.typescript = {
      {
        type = "node2",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = vim.fn.getcwd(),
      },
    }

    local keymap = vim.keymap
    keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    keymap.set("n", "<Leader>dc", dap.continue, { desc = "Continue" })
    keymap.set("n", "<Leader>di", dap.step_into, { desc = "Step into" })
    keymap.set("n", "<Leader>do", dap.step_over, { desc = "Step over" })
    keymap.set("n", "<Leader>dO", dap.step_out, { desc = "Step out" })
    keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Open REPL" })
    keymap.set("n", "<Leader>dl", dap.run_last, { desc = "Run last" })
    keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
    keymap.set("n", "<Leader>dt", dap.terminate, { desc = "Terminate" })

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
