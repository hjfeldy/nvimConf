local util = require('util')

return {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>f", "", desc = "+Telescope"},
      {
        "<leader>fc",
        function() require('telescope.builtin').command_history() end,
        mode="n",
        desc='Find Files'
      },
      {
        "<leader>ff",
        function() require('telescopeHelpers').findFiles() end,
        mode="n",
        desc='Find Files'
      },
      {
        "<leader>fF",
        function() require('telescopeHelpers').fileBrowser() end,
        mode="n",
        desc='File Browser'
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
      {
        "<leader>fu",
        function() require("telescope").extensions.undo.undo() end,
        mode="n",
        desc='Undo History'
      },
      {
        "<leader>fG",
        function() require("telescope.builtin").git_branches() end,
        mode="n",
        desc='Git Branches'
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      local actionState = require("telescope.actions.state")
      local helpers = require('telescopeHelpers')
      local fileBrowserActions = require("telescope").extensions.file_browser.actions

      return {
        extensions = {
          file_browser = {
            hijack_netrw = true,
            grouped = true,
            -- theme = 'ivy',
            mappings = {
              n = {
                ["c"] = fileBrowserActions.change_cwd,
                ["C"] = fileBrowserActions.goto_cwd,
                ["O"] = function(prompt_bufnr) return helpers.openFileInTab(prompt_bufnr, true) end,
                ["o"] = function(prompt_bufnr) return helpers.openFileInTab(prompt_bufnr) end,
                ["<C-h>"] = function() helpers.fileBrowserToggleHidden() end,
                ["<C-g>"] = function() helpers.fileBrowserToggleIgnore() end,
                ["<C-u>"] = function() helpers.fileBrowserIncrementDepth() end,
                ["<C-d>"] = function() helpers.fileBrowserDecrementDepth() end,
              },
              i = {
                ["<C-h>"] = function() helpers.fileBrowserToggleHidden() end,
                ["<C-g>"] = function() helpers.fileBrowserToggleIgnore() end,
                ["<C-u>"] = function() helpers.fileBrowserIncrementDepth() end,
                ["<C-d>"] = function() helpers.fileBrowserDecrementDepth() end,
              }
            }
          },
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          }
        },
        defaults = {
          -- dynamic_preview_title = true,
          -- results_title = util.renderHome,
          color_devicons=true,
          mappings = {
            i = {
              ['<C-p>'] = actions.cycle_history_prev,
              ['<C-n>'] = actions.cycle_history_next,
              ["<C-h>"] = helpers.findFilesToggleHidden,
              ["<C-g>"] = helpers.findFilesToggleIgnore,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-e>"] = function() print ('ah!') end,
              ["<C-t>"] = helpers.telescopeTrouble,
              ["<C-c>"] = actions.close,
              ["<C-j>"] = actions.preview_scrolling_down,
              ["<C-k>"] = actions.preview_scrolling_up,
              -- ["<C-q>"] = helpers.sendSelectedTroubleQflist
            },
            n = {
              ["<C-c>"] = actions.close,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-t>"] = helpers.telescopeTrouble,
              ["<C-e>"] = helpers.debugPicker,
              ["<leader>q"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-j>"] = actions.preview_scrolling_down,
              ["<C-k>"] = actions.preview_scrolling_up,
              ["K"] = actions.move_to_top,
              ["J"] = actions.move_to_bottom,
              --[[ ["<C-q>"] = helpers.sendSelectedTroubleQflist,
              ["<leader>q"] = helpers.sendAllTroubleQfList ]]
            }
          }
        },
        pickers = {
          git_branches = {
            mappings = {
              n = {
                ["L"] = function(prompt_bufnr) 
                  local entry = actionState.get_selected_entry()
                  local branch = entry.value
                  vim.cmd('G log ' .. branch .. ' --decorate')
                  -- return actions.close(prompt_bufnr)
                end
              }
            }
          },
          diagnostics = {
            mappings = {
              i = {
              ["<C-d>"] = helpers.diagnosticsToggleHints,
              },
            }
          },
          live_grep = {
            mappings = {
              n = {
                ["<C-h>"] = function() helpers.liveGrepToggleHidden() end,
                ["<C-g>"] = function() helpers.liveGrepToggleIgnore() end,
              },
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
