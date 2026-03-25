return {
  "towolf/vim-helm",
  ft = { "helm" },
  init = function()
    vim.filetype.add({
      pattern = {
        [".*/charts/.*%.yaml$"] = "helm",
        [".*/charts/.*%.yml$"] = "helm",
        [".*/charts/.*%.tpl$"] = "helm",
        [".*/charts/.*%.gotmpl$"] = "helm",
        [".*%.yaml%.gotmpl$"] = "helm",
        [".*%.yml%.gotmpl$"] = "helm",
        [".*helmfile.*%.yaml$"] = "helm",
        [".*helmfile.*%.gotmpl$"] = "helm",
      },
    })
  end,
}
