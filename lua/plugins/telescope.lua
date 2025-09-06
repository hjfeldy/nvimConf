return {
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim' ,
      'nvim-telescope/telescope-fzf-native.nvim',
      -- "nvim-mini/mini.icons",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>f", "", desc = "+Telescope"},
      {
        "<leader>ff",
        function() require('telescopeHelpers').findFiles() end,
        mode="n",
        desc='Find Files'
      },
      {
        "<leader>ft",
        function() require('neoWin.customPicker').termPick() end,
        mode="n",
        desc='Pick Terminals'
      },
      {
        "<leader>fg",
        function() require('telescopeHelpers').liveGrep() end, 
        mode="n",
        desc='Grep Files'
      },
      {
        "<leader>fd",
        function() require('telescopeHelpers').diagnostics({bufnr=0}) end,
        mode="n",
        desc='File Diagnostics'
      },
      {
        "<leader>fD",
        function() require('telescopeHelpers').diagnostics({}) end,
        mode="n",
        desc='Workspace Diagnostics'
      },
      {
        "<leader>fb",
        function() require('telescope.builtin').buffers() end,
        mode="n",
        desc='Buffers'
      },
      {
        "<leader>fh",
        function() require('telescope.builtin').help_tags() end,
        mode="n",
        desc='Help Tags'
      },
      {
        "<leader>fH",
        function() require('telescope.builtin').highlights() end,
        mode="n",
        desc='Highlights'
      },
      {
        "<leader>fm",
        function() require('telescope.builtin').man_pages() end,
        mode="n",
        desc='Man Pages'
      },
      {
        "<leader>fn",
        function() require("noice").cmd("pick") end,
        mode="n",
        desc='Notifications'
      },
    },
    after = function() 
      require('telescope').load_extension('fzf')
    end,
    opts = function()
      local actions = require("telescope.actions")
      local helpers = require('telescopeHelpers')

      return {
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          }
        },
        defaults = {
          color_devicons=true,
          mappings = {
            i = {
              ['<C-p>'] = actions.cycle_history_prev,
              ['<C-n>'] = actions.cycle_history_next,
              ["<C-h>"] = helpers.findFilesToggleHidden,
              ["<C-g>"] = helpers.findFilesToggleIgnore,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-t>"] = helpers.telescopeTrouble,
              -- ["<C-q>"] = helpers.sendSelectedTroubleQflist
            },
            n = {
              ["<C-c>"] = actions.close,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-t>"] = helpers.telescopeTrouble,
              ["<leader>q"] = actions.send_to_qflist + actions.open_qflist
              --[[ ["<C-q>"] = helpers.sendSelectedTroubleQflist,
              ["<leader>q"] = helpers.sendAllTroubleQfList ]]
            }
          }
        },
        pickers = {
          diagnostics = {
            mappings = {
              i = {
              ["<C-d>"] = helpers.diagnosticsToggleHints,
              },
            }
          },
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
