-- statusline

local icons = require('icons')
local util = require('util')
local api = vim.api

local function NO_OP() return "" end

local function changeLevel(plus)
  local dynamicModes = require('lualine.dynamicMode')
  local registeredModes = dynamicModes.registeredModes()
  local registeredModesMap = {}
  for _, mode in ipairs(registeredModes) do
    registeredModesMap[mode] = true
  end

  print('Registered modes: ' .. vim.inspect(registeredModes))
  local mode = dynamicModes.getMode('__GLOBAL__')
  local levelLen = ('level'):len()
  local newMode
  if mode:sub(1, levelLen) == 'level' and mode:len() == levelLen+1 then
    local add = plus and 1 or -1
    local level = tonumber(mode:sub(levelLen+1))
    newMode = 'level' .. (level+add)
    print('New mode is ' .. newMode)
    if registeredModesMap[newMode] == nil then
      print('wrapping')
      newMode = plus and 'level1' or 'level5'
    end
  else
    newMode = plus and 'level4' or 'level2'
  end
  dynamicModes.setGlobalMode(newMode)
end

local function incrementLevel() changeLevel(true) end
local function decrementLevel() changeLevel(false) end

return {
  "hjfeldy/lualine.nvim",
  -- dir = '/home/harry/Repos/lualine.nvim/',
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
  keys = {
    {'<C-U>', incrementLevel, desc = 'Increment Lualine Display Verbosity Level'},
    {'<C-D>', decrementLevel, desc = 'Decrement Lualine Display Verbosity Level'}
  },
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
      padding = { left = 1, right = 0 },
      altModes = {'normal', 'level2', 'level3', 'level4', 'level5'}
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
      altModes = {'normal', 'telescopeDiagnostics', 'level2', 'level3', 'level4', 'level5'},
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

    local shortenPathFunc = function(maxComponents, skipReplaceCwd) 
      return function() 
        local path = api.nvim_buf_get_name(api.nvim_get_current_buf())
        maxComponents = vim.o.filetype == 'Terminal' and 1 or maxComponents
        if maxComponents == nil or maxComponents < 1 then
          maxComponents = 999
        end

        if not skipReplaceCwd then
          local cwd = vim.uv.cwd() or '__ERR__'
          path = path:gsub(cwd, '.')
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
            return vim.fn.mode():sub(1, 1):upper()
          end
        }
      }
    }

    local homeComponent = {
      NO_OP,
      alts = {
        level1 = {NO_OP},
        level2 = {NO_OP},
        level3 = {NO_OP},
        level4 = {util.renderHome},
        level5 = {function() return util.renderHome(true) end},
      }
    }

    local filenameComponent = {
      shortenPathFunc(2),
      component_name='filename',
      alts = {
        level1 = { shortenPathFunc(1) },
        level2 = { shortenPathFunc(2) },
        level3 = { shortenPathFunc(2) },
        level4 = { shortenPathFunc(999) },
        level5 = { shortenPathFunc(999, true) },
      }
    }

    local branchComponent = {
      "branch",
      separator = "",
      altModes = {'normal', 'level3', 'level4', 'level5'}
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
        level1 = {NO_OP},
        level2 = {
          symbols = {
            added = "",
            modified = "",
            removed = ""
          }
        }
      }
    }

    return {
      options = {
        -- theme = "NeoSolarized",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        always_show_tabline = true
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
          filenameComponent
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
        lualine_z = {
          homeComponent
        }
      },


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
          {
            "branch",
            separator = "",
            altModes = {'normal', 'level3', 'level4', 'level5'}
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
              level1 = {NO_OP},
              level2 = {
                symbols = {
                  added = "",
                  modified = "",
                  removed = ""
                }
              }
            }
          }
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
            altModes = {"normal", "level3", "level4", "level5"},
          },

          {
            troubleStat,
            separator=""
          }
        },

        lualine_x = {

          Snacks.profiler.status(),
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
            altModes = {'normal', 'level2', 'level3', 'level4', 'level5'}
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

          {
            "progress",
            altModes = {'normal', 'level2', 'level3', 'level4', 'level5'},
            -- separator=''
          },
          {
            "location",
            altModes = {'level4', 'level5'}
          },

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
          -- ensureBorder,
          -- { "progress", separator = " ", padding = { left = 1, right = 0 } },
          -- { "location", padding = { left = 0, right = 1 } },
        },

        lualine_z = {homeComponent},
      },

      extensions = {
        "lazy",
        "fzf",
        "fugitive",
        "quickfix",

        {
          filetypes = {'Outline'},
          sections = {
            lualine_a = {'filetype'},
          }
        },

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
            lualine_z = {homeComponent}
          }
        },

      },
    }
  end,
}
