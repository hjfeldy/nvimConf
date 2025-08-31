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
      {"<leader>fh", function() require('telescope.builtin').help_tags() end, mode="n"},
      {"<leader>fH", function() require('telescope.builtin').highlights() end, mode="n"},
      {"<leader>fm", function() require('telescope.builtin').man_pages() end, mode="n"},
      {"<leader>fD", function() require('telescope.builtin').diagnostics({severity='warning'}) end, mode="n"},
      {"<leader>fd", function() require('telescope.builtin').diagnostics({bufnr=0, severity='warning'}) end, mode="n"},
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
            },
            n = {
              ["<C-q>"] = function() actions.send_selected_to_qflist() end,
              ["<leader>q"] = function() actions.send_to_qflist() end,
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
