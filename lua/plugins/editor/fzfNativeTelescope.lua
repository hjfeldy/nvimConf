return {
  'nvim-telescope/telescope-fzf-native.nvim',
  build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
  -- build = {'cmake -S. -Bbuild "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" -DCMAKE_BUILD_TYPE=Release', 'cmake --build build --config Release'},
  --
  -- config = function() 
  --   require('telescope').load_extension('fzf')
  -- end,
  -- opts = {},
  dependencies = {
    'nvim-telescope/telescope.nvim'
  },
  config = function(plugin) 
    local telescope = require('telescope')
    telescope.load_extension('fzf')
    telescope.load_extension('file_browser')
    telescope.load_extension('undo')
  end,
}
