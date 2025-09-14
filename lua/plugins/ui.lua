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
      { "<leader>G", "", mode="n", desc="+Git"},
      { "<leader>Gg", function() require('gitsigns').nav_hunk("last") end, mode="n", desc="Last Hunk" },
      { "<leader>GG", function() require('gitsigns').nav_hunk("first") end, mode="n", desc="First Hunk" },
      { "<leader>Gn", function() require('gitsigns').nav_hunk("next") end, mode="n", desc="Next Hunk" },
      { "<leader>GN", function() require('gitsigns').nav_hunk("prev") end, mode="n", desc="Previous Hunk" },
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
    keys = util.mergeArrays({
      { "g", "", desc = "+BufferLine"},
      { "gh", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "gl", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "gM", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "gm", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
      { "gk", "gg", desc = "Top of buffer" },
      { "gj", "GG", desc = "Bottom of buffer" }
      },
      (function()
        local numBindings = {}
        for i = 1,9 do
          numBindings[i] = {"g" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", desc = "Go to buffer " .. i}
        end
        return numBindings
      end)()
    ),
    opts = {
      options = {
        -- stylua: ignore
        close_command = function(n) require('snacks').bufdelete(n) end,
        numbers = 'ordinal',
        -- stylua: ignore
        right_mouse_command = function(n) require('snacks').bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        custom_filter = function(bufnr, bufnrs)
          local bufType = vim.api.nvim_get_option_value('filetype', {buf=bufnr})
          local blacklist = { ['grug-far'] = true, ['help'] = true }
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

      local troubleStat = trouble.statusline({ 
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
        -- hl_group = "Normal",
      }).get

      -- local icons = LazyVim.config.icons

      vim.o.laststatus = vim.g.lualine_laststatus
      local Snacks = require('snacks')

      -- ensure border is drawn
      local ensureBorder = {function() return "" end, draw_empty=true}

      local telescopeIcon = {
        function() return icons.kinds.Telescope end, separator = "",
        color = function() 
          local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
          return {fg = whiteBlack}
        end,
        component_name="telescopeIcon",
        altModes = {'telescopeFiles', 'telescopeDiagnostics'}
      }

      local lazyUpdateIcon = {
        require("lazy.status").updates,
        cond = require("lazy.status").has_updates,
        color = function() return { fg = Snacks.util.color("Special") } end,
        separator = "",
        padding = { left = 1, right = 0 }
      }

      -- Are neovim (noice) debug logs turned on?
      local debugLogsIcon = {
        function() return vim.g.NOICE_DEBUG and icons.dap.Debugging or "" end,
        separator = "",
      }
    
      -- Currently attached LSP
      local lspStatusIcon = {
        function() 
          local clients = vim.lsp.get_clients()
          local s = ''
          for i, client in ipairs(clients) do
            s = s .. client.config.name
            if i < #clients then
              s = s .. ', '
            end
          end
          -- return icons.kinds.Copilot ..  s
          return s
        end,
        cond = function() return #vim.lsp.get_clients() > 0 end,
        icon = icons.kinds.Copilot,
      }

      -- Whether filtering for hints (" ") or warnings (" ")
      local diagnosticsFilterIcon = {
        function()
          return telescopeHelpers.WARNING_FILTER and icons.diagnostics.Warn or icons.diagnostics.Info
        end,
        component_name = 'diagnosticsFilter',
        color = function()
          local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
          return {fg = telescopeHelpers.WARNING_FILTER and "orange" or whiteBlack  }
        end,
        separator="",
        padding = { left = 1, right = 0 },
        altModes = {'telescopeDiagnostics'}
      }

      local showHiddenIcon = {
        -- function() return "" end,
        function() 
          return telescopeHelpers.SHOW_HIDDEN and icons.showHide.Show or icons.showHide.Hide
        end,
        -- color = {fg='white', bg='black'}
        color = function() 
          local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
          return {fg=telescopeHelpers.SHOW_HIDDEN and "green" or whiteBlack}
        end,
        component_name = "showHiddenIcon",
        separator="",
        padding = { left = 0, right = 0 },
        altModes = {'telescopeFiles'}
      }

      local respectGitignoreIcon = {
        function() 
          return icons.git.Logo
        end,
        component_name = "respectGitignore",
        separator="",
        padding = { left = 0, right = 0 },
        color = function() 
          return {fg=telescopeHelpers.RESPECT_IGNORE and "green" or "red"}
        end,
        altModes = {'telescopeFiles'},
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
          if maxComponents == nil or maxComponents < 1 then
            maxComponents = 999
          end
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
          lualine_a = {},
          lualine_b = {
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = { left = 1, right = 0 } 
            },
            {
              shortenPathFunc(2),
              component_name='filename',
              alts = {
                short = { shortenPathFunc(1) },
              }
            },
          },
          lualine_x = {},
          lualine_c = {},
          lualine_y = {
            telescopeIcon,
            showHiddenIcon,
            respectGitignoreIcon,
            diagnosticsFilterIcon,
            debugLogsIcon,
            ensureBorder,
          },
          lualine_z = { renderHome }
        },
        -- sections = lualineHelpers.parseConfig(),
        sections = {
          lualine_a = {
            {
              "mode",
              component_name = 'mode',
              alts = {
                short = {
                  function() 
                    local mode = vim.fn.mode()
                    return string.upper(vim.fn.mode()) 
                  end
                }
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
              shortenPathFunc(2),
              component_name='filename',
              alts = {
                short = { shortenPathFunc(1) },
              }
            },
            {
              "branch",
              separator = "",
              alts = {
                short = { function() return "" end }
              }
            },
            {
              "diff",
              padding = { left = 1, right = 1 },
              symbols = {
                added = icons.git.Added,
                modified = icons.git.Modified,
                removed = icons.git.Removed
              },
              alts = {
                short = {
                  symbols = {
                    added = "",
                    modified = "",
                    removed = ""
                  },
                }
              }
            },
          },

          lualine_c = {
            -- showHiddenIcon,
            -- respectGitignoreIcon,
            -- diagnosticsFilterIcon,
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
            {
              troubleStat,
              separator="",
              alts = {
                short = {
                  function() 
                    local status = troubleStat()
                    local statusPieces = util.split(status, ' ')
                    -- util.debug('Status pieces:', statusPieces)
                    return statusPieces[#statusPieces-1] .. statusPieces[#statusPieces]
                    -- Status pieces: { "%#TroubleStatusline0#󰊕", "%*%#TroubleStatusline1#opts%*", "%#TroubleStatusline0#󰊕", "%*%#TroubleStatusline1#[1]%*" } 
                  end
                }
              }
            }
          },

          lualine_x = {

            Snacks.profiler.status(),
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = Snacks.util.color("Statement") } end,
            },
            -- stylua: ignore
            -- maybe cool - leaving comments in case I want later, but I don't really use any debuggers lol
            -- {
            --   function() return icons.dap.Debugging .. require("dap").status() end,
            --   cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            --   color = function() return { fg = Snacks.util.color("Debug") } end,
            -- },
            -- debugLogsIcon,
            -- ensureBorder,
            { "progress", separator = "", padding = { left = 1, right = 1 } },
            { "location", padding = { left = 0, right = 1 } },
            ensureBorder
          },

          lualine_y = {
            showHiddenIcon,
            respectGitignoreIcon,
            lspStatusIcon,
            lazyUpdateIcon,
            diagnosticsFilterIcon,
            debugLogsIcon,
            ensureBorder,
            -- { "progress", separator = " ", padding = { left = 1, right = 0 } },
            -- { "location", padding = { left = 0, right = 1 } },
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
    -- lazy=false,
    event = "VeryLazy",
    opts = function() 
      return {
        notify = {
          enabled = true,
        },
        lsp = {
          hover = {
            enabled = false,
          },
          signature = {
            -- enabled = false
          }
          --[[ override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          }, ]]
        },

        routes = {

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
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true
        },

        messages = {
          enabled = true,
        },
        popupmenu = {
          enabled = false,
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
        "<leader>nt",
        function() require("noice").cmd("telescope") end,
        desc = "Noice Telescope"
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
