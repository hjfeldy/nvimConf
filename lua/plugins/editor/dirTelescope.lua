
 return {
   "princejoogie/dir-telescope.nvim",
  dependencies = {"nvim-telescope/telescope.nvim"},
  opts = {
    -- these are the default options set
    hidden = true,
    no_ignore = false,
    show_preview = true,
    follow_symlinks = false,
  },
  config = function()
    require('telescope').load_extension('dir')
  end,
  keys = {
    -- { '<leader>fF', '<cmd>Telescope dir find_files<cr>' }
    {
      '<leader>fF',
      function() require('telescopeHelpers').dirFindFiles() end, 
      desc = 'Find Files in a Directory'
    }
  }
}
