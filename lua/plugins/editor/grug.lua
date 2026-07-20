-- search/replace in multiple files

return {
  "MagicDuck/grug-far.nvim",
  keys = {
    {'<leader>r', '<cmd>GrugFar<CR>', mode='n', desc='Find/Replace'}
  },
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
