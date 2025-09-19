-- statusline

local icons = require('icons')
local util = require('util')
local api = vim.api

return {
  -- "hjfeldy/lualine.nvim",
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
        local clients = vim.lsp.get_clients({bufnr=0})
        if #clients == 0 then return '' end

        local client = clients[1]
        local currBuf = api.nvim_get_current_buf()
        if client.attached_buffers[currBuf] then
          local attachedLsp = icons.lsp[client.config.name] or client.config.name
          return icons.kinds.Copilot .. attachedLsp
        end
        -- return icons.kinds.Copilot ..  s
        return ''
      end,
      cond = function() return #vim.lsp.get_clients() > 0 end,
      -- icon = icons.kinds.Copilot,
      padding = { right = 0, left = 1 }

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
      altModes = {'normal', 'telescopeDiagnostics'}
    }

    local telescopeIcon = {
      function() return icons.kinds.Telescope end, separator = "",
      color = function() 
        local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
        return {fg = whiteBlack}
      end,
      -- component_name="telescopeIcon",
      altModes = {'telescopeFiles', 'telescopeDiagnostics'}
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
      -- component_name = "showHiddenIcon",
      separator="",
      padding = { left = 1, right = 0 },
      altModes = {'telescopeFiles'}
    }

    local respectGitignoreIcon = {
      function() 
        return icons.git.Logo
      end,
      -- component_name = "respectGitignore",
      separator="",
      padding = { left = 0, right = 0 },
      color = function() 
        return {fg=telescopeHelpers.RESPECT_IGNORE and "green" or "red"}
      end,
      altModes = {'telescopeFiles'},
    }

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

    local modeComponent = {
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
    }

    local filenameComponent = {
      shortenPathFunc(2),
      component_name='filename',
      alts = {
        short = { shortenPathFunc(1) },
      }
    }

    local branchComponent = {
      "branch",
      separator = "",
      alts = {
        short = { function() return "" end }
      }
    }

    local diffComponent = {
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
    }

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

      -- REAL CONFIG - commenting out for demo
      -- inactive_sections = {
      --   lualine_a = {},
      --   lualine_b = {
      --     {
      --       "filetype",
      --       icon_only = true,
      --       separator = "",
      --       padding = { left = 1, right = 0 } 
      --     },
      --     {
      --       shortenPathFunc(2),
      --       component_name='filename',
      --       alts = {
      --         short = { shortenPathFunc(1) },
      --       }
      --     },
      --   },
      --   lualine_x = {},
      --   lualine_c = {},
      --   lualine_y = {
      --     telescopeIcon,
      --     showHiddenIcon,
      --     respectGitignoreIcon,
      --     diagnosticsFilterIcon,
      --     debugLogsIcon,
      --     ensureBorder,
      --   },
      --   lualine_z = {
      --     {
      --       util.renderHome,
      --       altModes = {'normal'},
      --     }
      --   }
      -- },
      --
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
            "filename",
            symbols = {
              unnamed = '[Empty Buffer]'
            },
            path = 0,
            alts = {
                mode1 = {
                    path = 1
                },
                mode2 = {
                    path = 2
                },
                mode3 = {
                    path = 3
                },

            }
          },
        },
        lualine_x = {},
        lualine_c = {},
        lualine_y = {
          {
            function() return " " end,
            separator = "",

            -- component will not display unless its mode (or the global mode)
            -- is equal to "telescopeFiles"
            altModes = {'telescopeFiles'}
          },
          {
            function() 
              -- retrieve a dynamic configuration value "SHOW_HIDDEN" 
              -- Determine the logo to display based on this value
              return telescopeHelpers.SHOW_HIDDEN and "󰈈 " or "󰈉 " -- open/closed eyeball icons
            end,
            separator="",
            padding = { left = 1, right = 0 },
            -- component will not display unless its mode (or the global mode)
            -- is equal to "telescopeFiles"
            altModes = {'telescopeFiles'}
          },
          {
            function() 
              return " " -- git logo
            end,
            separator="",
            color = function() 
              -- Retrieve a dynamic configuration value "RESPECT_IGNORE" 
              -- Determine the color of the git logo based on this value
              return {fg=telescopeHelpers.RESPECT_IGNORE and "green" or "red"}
            end,
            padding = { left = 0, right = 0 },
            -- component will not display unless its mode (or the global mode)
            -- is equal to "telescopeFiles"
            altModes = {'telescopeFiles'},
          }
        },
        lualine_z = {
          {
            function() 
                return 'CWD: ' .. vim.uv.cwd():gsub(os.getenv('HOME'), '~')
            end,
            -- component will not display unless its mode (or the global mode)
            -- is equal to "normal" (this is the default mode for a component, when no component/global mode has been explicitly set)
            -- In effect, this configuration says "Do not display this component when *any* mode has been set"
            altModes = {'normal'}
          }
        }
      },

      -- winbar = {
      --   lualine_a = { 
      --     modeComponent,
      --   },
      -- },

      -- sections = lualineHelpers.parseConfig(),
      sections = {
        lualine_a = { 
          modeComponent,
        },
        lualine_b = {
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 } 
          },
          filenameComponent,
          branchComponent,
          diffComponent,
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
          { "progress"}, -- , separator = ""}, --, padding = { left = 1, right = 1 } },
          -- { "location", padding = { left = 0, right = 1 } },
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
          {
            util.renderHome,
          }
        },
      },
      extensions = {
        "neo-tree",
        "lazy",
        "fzf",
        "fugitive",
        "quickfix",
        {
          filetypes = {'Terminal'},
          inactive_sections = {
            lualine_a = {},
            lualine_b = {filenameComponent},
            lualine_y = {
              { "progress", separator = "", padding = { left = 1, right = 1 } },
              { "location", padding = { left = 0, right = 1 } },
            },
          },
          sections = {
            lualine_a = {modeComponent},
            lualine_b = {filenameComponent},
            lualine_y = {
              { "progress", separator = "", padding = { left = 1, right = 1 } },
              { "location", padding = { left = 0, right = 1 } },
            },
            lualine_z = {
              {util.renderHome},
            }
          }
        },
        {
          filetypes = {'Outline'},
          sections = {
            lualine_a = {'filetype'},
          }
        }
      },
    }
  end,
}
