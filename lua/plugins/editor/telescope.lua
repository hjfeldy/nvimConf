return {
  {
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.8',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      "nvim-tree/nvim-web-devicons",
      'nvim-telescope/telescope-file-browser.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'debugloop/telescope-undo.nvim',
      'tiagovla/scope.nvim',
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
        "<leader>fa",
        function() require('helpers.telescope.pick').tabpages() end,
        mode="n",
        desc='Tabpages'
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
        function()
          require('helpers.telescope.pick').browseBuffers({})
        end,
        mode="n",
        desc='Buffers (visible only)'
      },
      {
        "<leader>fB",
        function()
          -- use the scope.nvim extension to view all buffers across all tabs
          -- sadly we can't define any actions here
          vim.cmd('Telescope scope buffers')
        end,
        mode="n",
        desc='Buffers (all)'
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
        "",
        mode="n",
        desc='+Git'
      },
      {
        "<leader>fGb",
        function() require('telescope.builtin').git_bcommits() end,
        mode="n",
        desc='Buffer Commits'
      },
      {
        "<leader>fGb",
        function() require('telescope.builtin').git_bcommits_range() end,
        mode="x",
        desc='Range Commits'
      },
      {
        "<leader>fGB",
        function() require('telescope.builtin').git_branches() end,
        mode="n",
        desc='Git Branches'
      },
      {
        "<leader>fGl",
        function() require('telescope.builtin').git_commits() end,
        mode="n",
        desc='Git Commits'
      },
      {
        "<leader>fGL",
        function() require('helpers.telescope.pick').gitCommitsForRef() end,
        mode="n",
        desc='Git Commits for Ref'
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      local actionUtils = require("telescope.actions.utils")
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
          dynamic_preview_title = true,
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
          git_bcommits = {
            attach_mappings = function()
              actions.select_default:replace(actions.select_vertical)
              return true
            end,
          },
          git_bcommits_range = {
            attach_mappings = function()
              actions.select_default:replace(actions.select_vertical)
              return true
            end,
          },
          git_branches = {
            attach_mappings = function(_, map)
              actions.select_default:replace(actions.nop)
              map({ 'i', 'n' }, '<C-t>', actions.nop)
              map({ 'i', 'n' }, '<C-a>', actions.nop)
              map({ 'i', 'n' }, '<C-s>', actions.nop)
              map({ 'i', 'n' }, '<C-r>', actions.git_rebase_branch)
              map({ 'i', 'n' }, '<C-S-r>', customActions.gitInteractiveRebase)
              map({ 'i', 'n' }, '<C-d>', actions.git_delete_branch)
              map({ 'i', 'n' }, '<C-y>', actions.git_merge_branch)
              return true
            end,
          },
          git_commits = {
            attach_mappings = function(_, map)
              actions.select_default:replace(customActions.gitCommitDiff)
              map({ 'i', 'n' }, '<C-r>', actions.git_rebase_branch)
              map({ 'i', 'n' }, '<C-S-r>', customActions.gitInteractiveRebase)
              map({ 'i', 'n' }, '<C-y>', customActions.gitCherryPick)
              map({ 'i', 'n' }, '<C-o>', actions.git_checkout)
              return true
            end,
          },
          buffers = {
            mappings = {
              n = {
                [ "D" ] = function(prompt_bufnr) customActions.deleteSelectedBuffers(prompt_bufnr, true) end,
                [ "d" ] = function(prompt_bufnr) customActions.deleteSelectedBuffers(prompt_bufnr, false) end,
                [ "h" ] = customActions.unlistSelectedBuffers
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
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      telescope.load_extension('file_browser')
      telescope.load_extension('fzf')
      telescope.load_extension('scope')
      telescope.load_extension('undo')
    end,
  }
}
