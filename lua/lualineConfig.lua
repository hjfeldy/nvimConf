local util = require('util')
local api = vim.api


local M = {}

M.CURRENT_MODE = 'normal'

function M.setMode(mode) 
  M.CURRENT_MODE = mode or 'normal'
end

function M.getMode() 
  return M.CURRENT_MODE
end

local telescopeFileMode = function() return M.getMode() == 'telescopeFiles' end
local telescopeDiagnosticsMode = function() return M.getMode() == 'telescopeDiagnostics' end
local telescopeMode = function() return telescopeFileMode() or telescopeDiagnosticsMode() end

local noTelescopeFilesMode = function() return not telescopeFileMode() end
-- local noTelescopeDiagnosticsMode = function() return not telescopeDiagnosticsModeMode() end
local noTelescopeMode = function() return not telescopeMode() end

local shortenPathFunc = util.shortenPathFunc
local function NO_OP() return "" end
local NO_OP_COMPONENT = {NO_OP}


function M.getConfig()
  local icons = require('icons')
  local telescopeHelpers = require('telescopeHelpers')
  local Snacks = require('snacks')
  local trouble = require('trouble')

  vim.o.laststatus = vim.g.lualine_laststatus

  --- Trouble.nvim statusline component
  --- (Very useful - displays the current treesitter function / class / etc)
  local troubleStat = trouble.statusline({ 
    mode = "symbols",
    groups = {},
    title = false,
    filter = { range = true },
    format = "{kind_icon}{symbol.name:Normal}",
    hl_group = "lualine_c_normal",
    -- hl_group = "Normal",
  }).get


  -- ensure border is drawn
  local ensureBorder = {function() return "" end, draw_empty=true}


  --- Visual notification of available plugin updates
  local lazyUpdateIcon = {
    require("lazy.status").updates,
    color = function() return { fg = Snacks.util.color("Special") } end,
    separator = "",
    padding = { left = 1, right = 0 },
    cond = function()
      local hasUpdates = require('lazy.status').has_updates()
      return hasUpdates and noTelescopeMode()
    end
    -- altModes = {'normal', 'level2', 'level3', 'level4', 'level5'}
  }


  --- Visual notification that Noice debug logs are turned on
  local debugLogsIcon = {
    function() return vim.g.NOICE_DEBUG and icons.dap.Debugging or "" end,
    separator = "",
    cond = noTelescopeMode,
  }

  --- Currently attached LSP
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
      return ''
    end,
    cond = function() return #vim.lsp.get_clients() > 0 and noTelescopeMode() end,
    padding = { right = 0, left = 1 }
  }


  -- Visual indicator of whether we are currently filtering diagnostics for hints (" ") or warnings (" ")
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
    cond = noTelescopeFilesMode
  }

  --- Visual indicator for adjacent icons ("These relate to Telescope ->")
  local telescopeIcon = {
    function() return icons.kinds.Telescope end, separator = "",
    color = function() 
      local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
      return {fg = whiteBlack}
    end,
    cond = telescopeMode,
  }


  --- Do we show hidden files in telescope prompts?
  local showHiddenIcon = {
    function() 
      return telescopeHelpers.SHOW_HIDDEN and icons.showHide.Show or icons.showHide.Hide
    end,
    color = function() 
      local whiteBlack = vim.o.background == 'dark' and 'white' or 'black'
      return {fg=telescopeHelpers.SHOW_HIDDEN and "green" or whiteBlack}
    end,
    separator="",
    padding = { left = 1, right = 0 },
    cond = telescopeFileMode
  }


  --- Do we respect .ignore/.gitignore in telescope prompts?S
  local respectGitignoreIcon = {
    function() 
      return icons.git.Logo
    end,
    separator="",
    padding = { left = 0, right = 0 },
    color = function() 
      return {fg=telescopeHelpers.RESPECT_IGNORE and "green" or "red"}
    end,
    cond = telescopeFileMode
  }


  local filetypeComponent = {
    "filetype",
    icon_only = true,
    separator = "",
    padding = { left = 1, right = 0 } 
  }



  local diagnosticsComponent = {
    "diagnostics",
    symbols = {
      error = icons.diagnostics.Error,
      warn = icons.diagnostics.Warn,
      info = icons.diagnostics.Info,
      hint = icons.diagnostics.Hint
    }
  }

  -- stylua: ignore
  -- maybe cool - leaving comments in case I want later, but I don't really use any debuggers lol
  -- local dapComponent = {
  --   function() return icons.dap.Debugging .. require("dap").status() end,
  --   cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
  --   color = function() return { fg = Snacks.util.color("Debug") } end,
  -- }

  local diffComponent = {
    "diff",
    padding = { left = 1, right = 1 },
    symbols = {
      added = icons.git.Added,
      modified = icons.git.Modified,
      removed = icons.git.Removed
    },
  }


  local inactive_base = {
    lualine_a = {},
    lualine_b = {
      filetypeComponent,
      {shortenPathFunc(2)}
    },
    lualine_c = {},

    lualine_x = {},
    lualine_y = {
      telescopeIcon,
      showHiddenIcon,
      respectGitignoreIcon,
      diagnosticsFilterIcon,
      debugLogsIcon,
      -- ensureBorder,
    },
    lualine_z = {
      {util.renderHome, cond=noTelescopeMode}
    }
  }

  -- TODO express these as named keys, not integer keys
  -- when generating the *actual* config for lualine,
  -- convert the {name -> component} tables to component[] arrays 

  -- override:
  -- lualine_b[1] (filetype)
  -- lualine_y[1] (debugLogsIcon)
  -- lualine_z[1] (home icon)

  local inactiveLvl1 = util.recursiveMerge(inactive_base, {
    lualine_b = {[2] = NO_OP_COMPONENT },
    lualine_y = {[1] = NO_OP_COMPONENT },
    lualine_z = {[1] = NO_OP_COMPONENT }
  })
  local inactiveLvl2 = util.recursiveMerge(inactive_base, {
    lualine_z = {[1] = NO_OP_COMPONENT }
  })
  local inactiveLvl3 = util.recursiveMerge(inactive_base, {
    lualine_b = {[2] = {shortenPathFunc(3)} },
  })
  local inactiveLvl4 = util.recursiveMerge(inactive_base, {
    lualine_b = {[2] = {shortenPathFunc(999)} }
  })
  local inactiveLvl5 = util.recursiveMerge(inactive_base, {
    lualine_b = {[2] = {shortenPathFunc(999, true)} },
    lualine_z = {function() return util.renderHome(true) end},
  })


  local active_base = {
    lualine_a = { 
      {"mode"},
    },

    lualine_b = {
      filetypeComponent,
      { shortenPathFunc(2) },
      { "branch", separator = "" },
      diffComponent,
    },

    lualine_c = {
      diagnosticsComponent,
      { troubleStat, separator="" }
    },

    lualine_x = {

      Snacks.profiler.status(),
      -- stylua: ignore
      {
        function() return require("noice").api.status.command.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
        color = function() return { fg = Snacks.util.color("Statement") } end,
      },

      { "progress", draw_empty = true },
      { "location", draw_empty = true },
      ensureBorder
    },

    lualine_y = {
      lspStatusIcon,
      lazyUpdateIcon,
      diagnosticsFilterIcon,
      debugLogsIcon,
      -- ensureBorder,
      -- { "progress", separator = " ", padding = { left = 1, right = 0 } },
      -- { "location", padding = { left = 0, right = 1 } },
    },

    lualine_z = { {util.renderHome} },
  }


  local activeLvl1 = util.recursiveMerge(active_base, {
    lualine_a = { NO_OP_COMPONENT },
    lualine_b = {
      -- override all but filetype component
      [2] = NO_OP_COMPONENT,
      [3] = NO_OP_COMPONENT,
      [4] = NO_OP_COMPONENT
    },
    lualine_c = {
      [1] = NO_OP_COMPONENT,
      -- leave in 2 (troubleStat)
    },
    -- remove editor-status info entirely
    lualine_x = {
      [1] = NO_OP_COMPONENT,
      [2] = NO_OP_COMPONENT,
      [3] = { NO_OP, draw_empty=false, separator="" },
      [4] = { NO_OP, draw_empty=false, separator="" },
      [5] = { NO_OP, draw_empty=false },
    },
    -- leave lualine_y as-is (most conds only trigger for telescope modes anyway)
    -- remove home component
    lualine_z = { [1] = NO_OP_COMPONENT }
  })


  local activeLvl2 = util.recursiveMerge(active_base, {
    lualine_a = { NO_OP_COMPONENT },
    lualine_b = {
      -- override path component, override diff component symbols 
      [2] = { shortenPathFunc(1) },
      [3] = { NO_OP, separator="" },
      -- remove diff symbols
      [4] = { 
        separator="",
        symbols = {
          added = "",
          modified = "",
          removed = ""
        }
      }
    },
    lualine_c = {
      -- leave in 2 (troubleStat)
      -- 
    },
    lualine_x = {
      -- remove 1 (progress bar)
      [1] = { NO_OP },
      -- leave in 2 (noice status)
      -- leave in 3 (file progress) but remove separator
      [3] = { separator = "" },
      -- remove 4 (location)
      [4] = { NO_OP },
    },
    -- leave lualine_y as-is (most conds only trigger for telescope modes anyway)
    -- remove home component
    lualine_z = { [1] = { NO_OP } }
  })


  local activeLvl3 = util.recursiveMerge(active_base, {
    -- leave lualine_a (mode component) as is
    lualine_b = {
      -- override path component
      [2] = { shortenPathFunc(2) },
      -- leave 3 in (enable branch component)
    },
    lualine_c = {
      -- leave 1 (diagnostics) as is
      -- leave in 2 (troubleStat)
    },
    lualine_x = {
      -- leave in 1 (progress bar)
      -- leave in 2 (noice status)
      -- leave in 3 (file progress) but remove separator
      [3] = { separator = "" },
      -- remove 4 (location)
      [4] = { NO_OP }
    },
    -- leave lualine_y as-is
    -- leave lualine_z as-is (enable home component)
  })


  local activeLvl4 = util.recursiveMerge(active_base, {
    -- leave lualine_a (mode component) as is
    lualine_b = {
      -- override path component (full path)
      [2] = { shortenPathFunc(999) },
      -- leave 3 in (enable branch component)
      -- leave in 4 (location)
    },
    -- leave lualine_y as-is
    -- leave lualine_z as-is (enable home component)
  })


  local activeLvl5 = util.recursiveMerge(active_base, {
    -- leave lualine_a (mode component) as is
    lualine_b = {
      -- override path component (full path, no substitutions)
      [2] = { shortenPathFunc(999) },
      -- leave 3 in (enable branch component)
    },
    -- leave lualine_y as-is
    -- lengthen home component (no substitutions)
    lualine_z = {function() return util.renderHome(true) end},
  })


  local activeExtensions = {
    activeLvl1,
    activeLvl2,
    activeLvl3, 
    activeLvl4,
    activeLvl5
  }


  local inactiveExtensions = {
    inactiveLvl1,
    inactiveLvl2,
    inactiveLvl3, 
    inactiveLvl4,
    inactiveLvl5
  }


  local config = {
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

    inactive_sections = inactiveExtensions[M.CURRENT_LEVEL],
    sections = activeExtensions[M.CURRENT_LEVEL],


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
          lualine_b = { {shortenPathFunc(2)} },
          lualine_y = {
            { "progress", separator = "", padding = { left = 1, right = 1 } },
            { "location", padding = { left = 0, right = 1 } },
          },
        },

        sections = {
          lualine_a = { {"mode"} },
          lualine_b = { {shortenPathFunc(2)} },
          lualine_y = {
            { "progress", separator = "", padding = { left = 1, right = 1 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = { {util.renderHome} }
        }
      },

    },
  }
  return config
end

M.CURRENT_LEVEL = 3
local MAX_LEVEL = 5

function M.refreshConfig() 
  require('lualine').setup(M.getConfig())
end

local function changeLevel(plus)
    local add = plus and 1 or -1
  M.CURRENT_LEVEL = (M.CURRENT_LEVEL + add) % MAX_LEVEL
  if M.CURRENT_LEVEL == 0 then M.CURRENT_LEVEL = MAX_LEVEL end
  M.refreshConfig()
end

function M.incrementLevel() changeLevel(true) end
function M.decrementLevel() changeLevel(false) end


return M
