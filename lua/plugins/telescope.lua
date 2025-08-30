return {
  {
  'nvim-telescope/telescope-fzf-native.nvim',
  build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' 
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {"<leader>ff", function() require('telescopeHelpers').findFiles() end, mode="n"},
      {"<leader>fg", function() require('telescopeHelpers').liveGrep() end, mode="n"},
    },
    opts = function() 
      local actions = require("telescope.actions")
      local helpers = require('telescopeHelpers')

      return {
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = function() helpers.findFilesToggleHidden() end,
              ["<C-g>"] = function() helpers.findFilesToggleIgnore() end,
            }
          }
        },
        pickers = {
          live_grep = {
            mappings = {
              i = {
                ["<C-h>"] = function() helpers.liveGrepToggleHidden() end,
                ["<C-g>"] = function() helpers.liveGrepToggleIgnore() end,
              }
            }
          }
        }
      }
    end,
  }
}
