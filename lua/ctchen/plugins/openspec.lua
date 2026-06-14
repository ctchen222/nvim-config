return {
  dir = "/Users/ctchen/Development/project/openspec.nvim",
  name = "openspec.nvim",
  config = function()
    require("openspec").setup({
      context = {
        model_routing = {
          enabled = true,
          profiles = {
            {
              name = "Spec planning",
              model = "gpt-5.5",
              effort = "xhigh",
              command = "/model gpt-5.5 xhigh",
              use_for = "proposal, design, spec delta, task shaping, and scope decisions",
            },
            {
              name = "Task implementation",
              model = "gpt-5.4",
              effort = "high",
              command = "/model gpt-5.4 high",
              use_for = "code edits, focused tests, documentation updates, and small refactors",
            },
            {
              name = "Verification/audit",
              model = "gpt-5.4",
              effort = "high",
              command = "/model gpt-5.4 high",
              use_for = "failed checks, review notes, audit evidence, and unclear acceptance criteria",
            },
          },
          switch_rules = {
            "Use Spec planning while shaping proposal, design, spec delta, tasks, or acceptance criteria.",
            "Switch to Task implementation before editing code, tests, docs, or OpenSpec task implementation details.",
            "Switch back to Spec planning only when requirements, scope, or acceptance criteria become unclear.",
            "Use Verification/audit for failed checks, review, and completion evidence.",
          },
        },
      },
    })
  end,
}
