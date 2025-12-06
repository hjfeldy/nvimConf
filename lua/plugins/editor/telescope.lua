local util = require('util')

local function defaultArgs(func)
  local function wrapped(prompt_bufnr)
    return func({}, prompt_bufnr)
  end
  return wrapped
end

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
        function() require('telescopeHelpers.pick').findFiles() end,
        mode="n",
        desc='Find Files'
      },
      {
        "<leader>fF",
        function() require('telescopeHelpers.pick').fileBrowser() end,
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
        function() require('telescopeHelpers.pick').liveGrep() end, 
        mode="n",
        desc='Grep Files'
      },
      {
        "<leader>fd",
        function() require('telescopeHelpers.pick').diagnostics({bufnr=0}) end,
        mode="n",
        desc='File Diagnostics'
      },
      {
        "<leader>fD",
        function() require('telescopeHelpers.pick').diagnostics({}) end,
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
      local customActions = require('telescopeHelpers.act')
      local fileBrowserActions = require("telescope").extensions.file_browser.actions

      return {
        extensions = {
          file_browser = {
            hijack_netrw = true,
            grouped = true,
            mappings = {
              n = {
                ["c"] = defaultArgs(customActions.fileBrowserTabCD),
                ["C"] = fileBrowserActions.goto_cwd,
                ["H"] = defaultArgs(customActions.fileBrowserGotoHome),
                ["h"] = defaultArgs(customActions.fileBrowserGotoVimHome),
                ["O"] = function(prompt_bufnr) return customActions.openFileInTab(prompt_bufnr, true) end,
                ["o"] = function(prompt_bufnr) return customActions.openFileInTab(prompt_bufnr, false) end,
                ["<C-h>"] = defaultArgs(customActions.fileBrowserToggleHidden),
                ["<C-g>"] = defaultArgs(customActions.fileBrowserToggleIgnore),
                ["<C-u>"] = defaultArgs(customActions.fileBrowserIncrementDepth),
                ["<C-d>"] = defaultArgs(customActions.fileBrowserDecrementDepth),
              },
              i = {
                ["<C-h>"] = defaultArgs(customActions.fileBrowserToggleHidden),
                ["<C-g>"] = defaultArgs(customActions.fileBrowserToggleIgnore),
                ["<C-u>"] = defaultArgs(customActions.fileBrowserIncrementDepth),
                ["<C-d>"] = defaultArgs(customActions.fileBrowserDecrementDepth),
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
              ["<C-t>"] = customActions.telescopeTrouble,
              ["<C-c>"] = actions.close,
              ["<C-j>"] = actions.preview_scrolling_down,
              ["<C-k>"] = actions.preview_scrolling_up,
            },
            n = {
              ["<C-c>"] = actions.close,
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
                ["<C-h>"] = defaultArgs(customActions.liveGrepToggleHidden),
                ["<C-g>"] = defaultArgs(customActions.liveGrepToggleIgnore),
              },
              i = {
                ["<C-h>"] = defaultArgs(customActions.liveGrepToggleHidden),
                ["<C-g>"] = defaultArgs(customActions.liveGrepToggleIgnore),
              }
            }
          }
        }
      }
    end,
  }
}
