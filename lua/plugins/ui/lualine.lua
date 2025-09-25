-- statusline

return {
  "nvim-lualine/lualine.nvim",
  -- dir = '/home/harry/Repos/lualine.nvim/',
  -- branch = 'feature/dynamicModes',
  dependencies = {
    'folke/noice.nvim',
    'nvim-telescope/telescope.nvim',
    'folke/trouble.nvim',
    "nvim-tree/nvim-web-devicons"
  },

  lazy=false,
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  keys = {
    {'<C-U>', function() require('lualineConfig').incrementLevel() end, desc = 'Increment Lualine Display Verbosity Level'},
    {'<C-D>', function() require('lualineConfig').decrementLevel() end, desc = 'Decrement Lualine Display Verbosity Level'},
  },
  opts = require('lualineConfig').getConfig
}
