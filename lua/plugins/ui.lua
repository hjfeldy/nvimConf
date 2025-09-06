local icons = require('icons')
local util = require('util')
local api = vim.api

return {
  -- ui components
  { "MunifTanjim/nui.nvim", lazy = true },
  {"nvim-tree/nvim-web-devicons"},

  -- git-diff statuscolumn / git-hunk navigation
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    -- lazy=false,
    keys = {
      { "<leader>G", "", mode="n", desc="+GitSigns"},
      { "<leader>Gl", function() require('gitsigns').nav_hunk("last") end, mode="n", desc="Last Hunk" },
      { "<leader>Gf", function() require('gitsigns').nav_hunk("first") end, mode="n", desc="First Hunk" },
      { "<leader>Gn", function() require('gitsigns').nav_hunk("next") end, mode="n", desc="Next Hunk" },
      { "<leader>Gp", function() require('gitsigns').nav_hunk("prev") end, mode="n", desc="Previous Hunk" },
      { "<leader>Gs", "<cmd>Gitsigns stage_hunk<CR>", mode={ "n", "v" }, desc="Stage/Unstage Hunk" },
      -- { "<leader>Gu", function() require('gitsigns').undo_stage_hunk() end, mode="n", desc="Undo Stage Hunk"},
      -- map({ "n", "v" }, "<leader>Ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      {"<leader>GS", function() require('gitsigns').stage_buffer() end, mode="n", desc="Stage Buffer"},
      -- {"<leader>ghR", gs.reset_buffer, mode="n", desc="Reset Buffer"},
      {"<leader>Gb", function() require('gitsigns').blame_line({ full = true }) end, mode="n", desc="Blame Line"},
      {"<leader>GB", function() require('gitsigns').blame() end, mode="n", desc="Blame Buffer"},
      {"<leader>Gd", function() require('gitsigns').diffthis() end, mode="n", desc="Diff This"},
      -- {"<leader>GD", function() gs.diffthis("~") end, mode="n", desc="Diff This ~"},
      -- { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode={ "o", "x" }, desc="Select Hunk")
    },

    opts = {
      signcolumn=true,
      sign_priority=100,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },


  -- tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "g", "", desc = "+BufferLine"},
      { "gh", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "gl", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "gM", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "gm", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
      { "gk", "gg", desc = "Top of buffer" },
      { "gj", "GG", desc = "Bottom of buffer" },
    },
    opts = {
      options = {
        -- stylua: ignore
        close_command = function(n) require('snacks').bufdelete(n) end,
        -- stylua: ignore
        right_mouse_command = function(n) require('snacks').bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        custom_filter = function(bufnr, bufnrs)
          local bufType = vim.api.nvim_get_option_value('filetype', {buf=bufnr})
          local blacklist = { ['grug-far'] = true }
          return not blacklist[bufType]
        end,
        diagnostics_indicator = function(_, _, diag)
          local ret = (diag.error and icons.diagnostics.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.diagnostics.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "snacks_layout_box",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  -- statusline
  {
    -- "nvim-lualine/lualine.nvim",
    dir = '/home/harry/Repos/lualine.nvim/',
    branch = 'feature/dynamicModes',
    dependencies = {
      'folke/noice.nvim',
      'nvim-telescope/telescope.nvim',
      'folke/trouble.nvim',
      "nvim-tree/nvim-web-devicons"
    },

    -- event = "VeryLazy",
    lazy=false,
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- PERF: we don't need this lualine require madness 🤷
      local lualine_require = require("lualine_require")
      local telescopeHelpers = require('telescopeHelpers')
      local lualineHelpers = require('lualineHelpers')

      -- lualine_require.require = require

      local trouble = require('trouble')

      -- local icons = LazyVim.config.icons

      vim.o.laststatus = vim.g.lualine_laststatus
      local Snacks = require('snacks')

      -- ensure border is drawn
      local ensureBorder = {function() return "" end, draw_empty=true}

      -- telescope show/hide HUD
      local telescopeConfig = {

        ensureBorder,
        -- diagnostic icon (is the LSP log level WARNING or HINT?)
        {
          function() return icons.kinds.Telescope end, separator = "",
          color = function() 
            -- color not working - always grey (TODO fix)
            local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
            return vim.o.filetype == 'TelescopePrompt' and whiteBlack or 'lualine_c_normal'
          end
        },
        {
          function()
            return telescopeHelpers.WARNING_FILTER and icons.diagnostics.Warn or icons.diagnostics.Info
          end,
          color = function()
            local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
            return {fg = telescopeHelpers.WARNING_FILTER and "orange" or whiteBlack  }
          end,
          separator="",
          padding = { left = 0, right = 0 }
        },

        -- telescope show-hidden-files
        {
          function() 
            return telescopeHelpers.SHOW_HIDDEN and icons.showHide.Show or icons.showHide.Hide
          end,
          color = function() 
            local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
            return {fg=telescopeHelpers.SHOW_HIDDEN and "green" or whiteBlack}
          end,
          separator="",
          padding = { left = 0, right = 0 }
        },

        -- telescope respect-gitignore
        {
          function() 
            return icons.git.Logo
          end,
          color = function() 
            return {fg=telescopeHelpers.RESPECT_IGNORE and "green" or "red"}
          end,
          separator="",
          padding = { left = 0, right = 1 }
        },
        ensureBorder
      }

      local renderHome = function()
        local cwd = vim.uv.cwd() or '__notfound__'
        local home = os.getenv('HOME') or '__notfound__'
        return " " .. string.gsub(cwd, home, '~')
      end


      local shortenPathFunc = function(maxComponents) 
        return function() 
          local path = api.nvim_buf_get_name(api.nvim_get_current_buf())
          maxComponents = vim.o.filetype == 'Terminal' and 1 or maxComponents
          return util.shortenPath(path, maxComponents)
        end
      end

      return {
        options = {
          theme = "NeoSolarized",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
          --[[ section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' }, ]]
        },
        --[[ component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''}, ]]
        inactive_sections = {
          lualine_c = util.mergeArrays(
            {
              { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
              {shortenPathFunc(1), separator=''},
            },
            telescopeConfig
          ),
          lualine_z = {
            renderHome
          }
        },

        -- sections = lualineHelpers.parseConfig(),
        sections = {
          lualine_a = {
            {
              "mode" ,
              alts = {
                test = { function() return 'ASDF' end }
              }
            },
          },
          lualine_b = {
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = { left = 1, right = 0 } 
            },
            {
              shortenPathFunc(2)
            },
            {
              "branch",
              separator = "",
            },
            {
              "diff",
              symbols = {
                added = icons.git.Added,
                modified = icons.git.Modified,
                removed = icons.git.Removed
              },
            },
          },

          lualine_c = util.mergeArrays(
            telescopeConfig,
            {
              {
              trouble.statusline({ 
                mode = "symbols",
                groups = {},
                title = false,
                filter = { range = true },
                format = "{kind_icon}{symbol.name:Normal}",
                hl_group = "lualine_c_normal",
                -- hl_group = "Normal",
              }).get,
              separator=""
              }
            }
          ),
          lualine_x = {
            Snacks.profiler.status(),
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = Snacks.util.color("Statement") } end,
            },
            -- stylua: ignore
            --[[ {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = function() return { fg = Snacks.util.color("Constant") } end,
            }, ]]
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = Snacks.util.color("Debug") } end,
            },
            -- stylua: ignore
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function() return { fg = Snacks.util.color("Special") } end,
            },
          },
          lualine_y = {
            ensureBorder,
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint
              },
            },
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            renderHome
          },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }
    end,
  },

  -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  -- stolen from LazyVim config
  {
    "folke/noice.nvim",
    lazy=false,
    -- event = "VeryLazy",
    opts = function() 
      print('loading noice with DEBUG = ' .. (vim.g.NOICE_DEBUG and 'true' or 'false')) 
      return {
        notify = {
          enabled = true,
        },
        lsp = {
          hover = {
            enabled = false,
          }
          --[[ override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          }, ]]
        },

        routes = {
          {
            -- filter out debug logs whenever NOICE_DEBUG is false
            -- requires a call to "Lazy reload noice.nvim" to pick up changes to the DEBUG variable
            opts = { skip = true },
            filter = {
              event = 'notify',
              kind = vim.g.NOICE_DEBUG and '' or 'debug'
            }
          },

          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
        },

        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },

        messages = {
          enabled = true,
        },
        popupmenu = {
          enabled = true,
          backend = 'nui'
        },
        commands = {
          history = {
            view = 'popup'
          }
        },
      }
    end,
    -- stylua: ignore
    keys = {
      { "<leader>n", "", desc = "+Noice Notifications"},
      {
        "<S-Enter>",
        function() require("noice").redirect(vim.fn.getcmdline()) end,
        mode = "c", desc = "Redirect Cmdline"
      },
      {
        "<leader>nl",
        function() require("noice").cmd("last") end,
        desc = "Noice Last Message"
      },
      {
        "<leader>nh",
        function() require("noice").cmd("history") end,
        desc = "Noice History"
      },
      {
        "<leader>na",
        function() require("noice").cmd("all") end,
        desc = "Noice All"
      },
      {
        "<leader>nd",
        function() require("noice").cmd("dismiss") end,
        desc = "Dismiss All"
      },
      {
        "<leader>nD",
        function() 
          util.toggleDebug()
        end,
        desc = "Toggle Debug"
      },
      --[[ {
        "<leader>nt",
        function() require("noice").cmd("pick") end,
        desc = "Noice Picker (Telescope/FzfLua)"
      }, ]]
      {
        "<c-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Forward",
        mode = {"i", "n", "s"}
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Backward",
        mode = {"i", "n", "s"}
      },
    },
    --config = function(_, opts)
    --  -- HACK: noice shows messages from before it was enabled,
    --  -- but this is not ideal when Lazy is installing plugins,
    --  -- so clear the messages in this case.
    --  if vim.o.filetype == "lazy" then
    --    vim.cmd([[messages clear]])
    --  end
    --  require("noice").setup(opts)
    --end,
  },
}
