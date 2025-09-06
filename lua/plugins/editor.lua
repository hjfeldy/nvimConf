return {
  { "tpope/vim-fugitive" },
  {
    "numToStr/Comment.nvim",
    opts = function()
      return {
        toggler = {
          line = '<leader>l',
        },
        opleader = {
          block = '<leader>l',
        }
      }
    end,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    }
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    ensure_installed = {
      "c",
      "python",
      "javascript",
      "typescript",
      "java",
      "csharp",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline"
    },
  },

  -- quality-of-life
  {
    "folke/snacks.nvim",
    opts = {
      animate = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      words = { enabled = true },
      statuscolumn = {
        enabled = false,
        left = { "mark", "fold" }, -- priority of signs on the left (high to low)
        right = { "git" }, -- priority of signs on the right (high to low)
        folds = {
          open = true, -- show open fold icons
          git_hl = true, -- use Git Signs hl for fold icons
        },
        git = {
          -- patterns to match Git signs
          patterns = { "GitSign", "MiniDiffSign" },
        },
        refresh = 50, -- refresh at most every 50ms
      }
    }
  },

  -- diagnostics
  {
    "folke/trouble.nvim",
    lazy=false,
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>x",
        "",
        desc = "+Trouble Diagnostics",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Global Diagnostics",
      },
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>xf",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List",
      },
      --[[ {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      }, ]]
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
    }
  },

  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    lazy=false,
    opts = {
      headerMaxWidth = 80,
      keymaps = {
        replace = { n = '<leader>r' },
        syncLine = { n = '<leader>sl' },
        syncFile = { n = '<leader>sf' },
      }
    },
    cmd = "GrugFar"
  },

  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific
  -- location.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          char_actions = function(motion)
            return {
              [';'] = 'next',
              [','] = 'prev',
              --[[ [motion:upper()] = nil,
              [motion:lower()] = nil, ]]
            }
          end
        }
      }
    },
    -- stylua: ignore
    keys = {
      {"<leader>s", "", desc="+Flash Search"},
      { 
        "<leader>ss",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash"
      },
      {
        "<leader>st",
        mode = { "n", "o", "x" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter"
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = function() 
      return {
        delay=333,
        preset = 'modern',
        presets = {},
        filter = function(mapping)
          return mapping.noremap == 1
        end,
        triggers = {
          { "<leader>" , mode={"n", "v"}},
          { "g" , mode={"n", "v"}},
          { "q" , mode={"n", "v"}},
        },
        replace = {
          key = {
            function(key)
              if key == "<Space>" then
                return "Commands"
              end
              local out = require('which-key.view').format(key)
              if out ~= key then 
                -- print('Replacing "' .. key .. '" with "' .. out .. '"')
              end
            end
          }
        }
        --[[ filter = function(entry) 
          -- print('Filtering entry:\n' .. vim.inspect(entry))
        end ]]
      }
  end
  }
}
