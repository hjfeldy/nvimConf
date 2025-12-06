return {
  'nvim-telescope/telescope-fzf-native.nvim',
  -- build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
  build = {'cmake -S. -Bbuild "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" -DCMAKE_BUILD_TYPE=Release', 'cmake --build build --config Release'},
  --
  -- config = function() 
  --   require('telescope').load_extension('fzf')
  -- end,
  -- opts = {},
  dependencies = {
    'nvim-telescope/telescope.nvim'
  }

}

8888920012
