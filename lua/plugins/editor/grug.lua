-- search/replace in multiple files

return {
  "MagicDuck/grug-far.nvim",
  lazy=false,
  opts = {
    headerMaxWidth = 80,
    keymaps = {
      replace = { n = '<leader>r' },
      syncLine = { n = '<leader>sl' },
      syncFile = { n = '<leader>sf' },
    }
  },
  cmd = "GrugFar"
}
