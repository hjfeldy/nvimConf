local isWindows = package.config:sub(1,1) == '\\'

return {
  'nvim-telescope/telescope-fzf-native.nvim',
  build = isWindows and {
      'cmake -S. -Bbuild "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" -DCMAKE_BUILD_TYPE=Release',
      'cmake --build build --config Release --target install'
    } or 'make',
  -- build = {'cmake -S. -Bbuild "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" -DCMAKE_BUILD_TYPE=Release', 'cmake --build build --config Release'},

  dependencies = {
    'nvim-telescope/telescope.nvim'
  },
  config = function(plugin) 
    local telescope = require('telescope')
    telescope.load_extension('fzf')
    telescope.load_extension('file_browser')
    telescope.load_extension('scope')
    telescope.load_extension('undo')
  end,
}
