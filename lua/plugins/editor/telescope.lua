local telescopeConf = require('helpers.telescope.config')

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
        function() require('helpers.telescope.pick').findFiles() end,
        mode="n",
        desc='Find Files'
      },
      {
        "<leader>fF",
        function() require('helpers.telescope.pick').fileBrowser() end,
        mode="n",
        desc='File Browser'
      },
      {
        "<leader>ft",
        function() require('neoWin.customPicker').termPick({localTab=true}) end,
        mode="n",
        desc='Pick Terminals'
      },
      {
        "<leader>fT",
        function() require('neoWin.customPicker').termPick({localTab=false}) end,
        mode="n",
        desc='Pick Terminals'
      },
      {
        "<leader>fg",
        function() require('helpers.telescope.pick').liveGrep() end, 
        mode="n",
        desc='Grep Files'
      },
      {
        "<leader>fd",
        function() require('helpers.telescope.pick').diagnostics({bufnr=0}) end,
        mode="n",
        desc='File Diagnostics'
      },
      {
        "<leader>fD",
        function() require('helpers.telescope.pick').diagnostics({}) end,
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
      local actionUtils = require("telescope.actions.utils")
      local actionState = require("telescope.actions.state")
      local customActions = require('helpers.telescope.act')
      local fileBrowserActions = require("telescope").extensions.file_browser.actions

      return {
        extensions = {
          file_browser = {
            hijack_netrw = true,
            grouped = true,
            mappings = {
              n = {
                ["c"] = customActions.fileBrowserTabCD,
                ["C"] = fileBrowserActions.goto_cwd,
                ["H"] = customActions.fileBrowserGotoHome,
                ["h"] = customActions.fileBrowserGotoVimHome,
                ["O"] = function(prompt_bufnr) return customActions.openFileInTab(prompt_bufnr, true) end,
                ["o"] = function(prompt_bufnr) return customActions.openFileInTab(prompt_bufnr, false) end,
                ["<C-h>"] = customActions.fileBrowserToggleHidden,
                ["<C-g>"] = customActions.fileBrowserToggleIgnore,
                ["<C-u>"] = customActions.fileBrowserIncrementDepth,
                ["<C-d>"] = customActions.fileBrowserDecrementDepth,
              },
              i = {
                ["<C-h>"] = customActions.fileBrowserToggleHidden,
                ["<C-g>"] = customActions.fileBrowserToggleIgnore,
                ["<C-u>"] = customActions.fileBrowserIncrementDepth,
                ["<C-d>"] = customActions.fileBrowserDecrementDepth,
              }
            }
          },

          -- fzf = {
          --   fuzzy = true,                    -- false will only do exact matching
          --   override_generic_sorter = true,  -- override the generic sorter
          --   override_file_sorter = true,     -- override the file sorter
          --   case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          -- }
        },

        defaults = {
          -- wrap_results = telescopeConf.WRAP_TEXT,
          -- dynamic_preview_title = true,
          -- results_title = util.renderHome,
          color_devicons=true,
          mappings = {
            i = {
              ['<C-p>'] = actions.cycle_history_prev,
              ['<C-n>'] = actions.cycle_history_next,
              ["<C-h>"] = customActions.findFilesToggleHidden,
              ["<C-g>"] = customActions.findFilesToggleIgnore,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-o>"] = function(prompt_bufnr) 
                actionUtils.map_selections(prompt_bufnr, function(entry)
                  actions.close(prompt_bufnr)
                  local filename = entry[1]
                  vim.cmd('edit ' .. filename)
                end)

              end,
              ["<C-t>"] = customActions.telescopeTrouble,
              ["<C-c>"] = actions.close,
              ["<C-j>"] = actions.preview_scrolling_down,
              ["<C-k>"] = actions.preview_scrolling_up,
            },
            n = {
              ["<C-c>"] = actions.close,
              ["<C-h>"] = customActions.findFilesToggleHidden,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-t>"] = customActions.telescopeTrouble,
              ["<leader>q"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-j>"] = actions.preview_scrolling_down,
              ["<C-k>"] = actions.preview_scrolling_up,
              ["K"] = actions.move_to_top,
              ["J"] = actions.move_to_bottom,
            }
          }
        },

        pickers = {
          buffers = {
            mappings = {
              n = {
                [ "D" ] = function(prompt_bufnr) customActions.deleteSelectedBuffers(prompt_bufnr, true) end,
                [ "d" ] = function(prompt_bufnr) customActions.deleteSelectedBuffers(prompt_bufnr, false) end
              }
            }
          },
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
              ["<C-d>"] = customActions.diagnosticsToggleHints,
              },
            }
          },

          live_grep = {
            mappings = {
              n = {
                ["<C-h>"] = customActions.liveGrepToggleHidden,
                ["<C-g>"] = customActions.liveGrepToggleIgnore,
              },
              i = {
                ["<C-h>"] = customActions.liveGrepToggleHidden,
                ["<C-g>"] = customActions.liveGrepToggleIgnore,
              }
            }
          }
        }
      }
    end,
  }
}
