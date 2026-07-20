local isWindows = package.config:sub(1,1) == '\\'

return {
  'nvim-telescope/telescope-fzf-native.nvim',
  lazy = true,
  build = isWindows and {
      'cmake -S. -Bbuild "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" -DCMAKE_BUILD_TYPE=Release',
      'cmake --build build --config Release --target install'
    } or 'make',
  -- build = {'cmake -S. -Bbuild "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" -DCMAKE_BUILD_TYPE=Release', 'cmake --build build --config Release'},

  config = function()
    local telescope = require('telescope')
    telescope.load_extension('fzf')
  end,
}
