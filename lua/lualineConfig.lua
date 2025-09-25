local util = require('util')
local api = vim.api


local M = {}

local MAX_LEVEL = 5

--- Configurable mode, for lualine components' cond functions to react to
M.CURRENT_MODE = 'normal'

--- Configurable level, for dynamic configuration overrides
M.CURRENT_LEVEL = 3


--- Set the mode (ie. to toggle telescope components on/off)
function M.setMode(mode) 
  M.CURRENT_MODE = mode or 'normal'
end

--- Set the mode (to determine whether to render telescope components)
function M.getMode() 
  return M.CURRENT_MODE
end

--- Refresh the statusline to make level/mode changes take effect
function M.refreshConfig() 
  require('lualine').setup(M.getConfig())
end

--- Increment/Decrement the level (wraps around) to trigger different configuration overrides
local function changeLevel(plus)
    local add = plus and 1 or -1
  M.CURRENT_LEVEL = (M.CURRENT_LEVEL + add) % MAX_LEVEL
  if M.CURRENT_LEVEL == 0 then M.CURRENT_LEVEL = MAX_LEVEL end
  M.refreshConfig()
end

--- Increment the level (wraps around) to trigger different configuration overrides
function M.incrementLevel() changeLevel(true) end

--- Decrement the level (wraps around) to trigger different configuration overrides
function M.decrementLevel() changeLevel(false) end

--- lualine condition functions for telescope

local telescopeFileMode = function() return M.getMode() == 'telescopeFiles' end
local telescopeDiagnosticsMode = function() return M.getMode() == 'telescopeDiagnostics' end
local telescopeMode = function() return telescopeFileMode() or telescopeDiagnosticsMode() end

local noTelescopeFilesMode = function() return not telescopeFileMode() end
-- local noTelescopeDiagnosticsMode = function() return not telescopeDiagnosticsModeMode() end
local noTelescopeMode = function() return not telescopeMode() end

local shortenPathFunc = util.shortenPathFunc
local function NO_OP() return "" end
local NO_OP_COMPONENT = {NO_OP}

--- Add an "index" field to a component's configuration
--- this allows us to manually the order of non-array table elements
--- eg. { lualine_a = { namedComponent = {componentConfig..., index=1} } } 
--- instead of lualine_a = { {componentConfig...} }
--- we can then selectively access/modify these components by name while we construct our configs
--- and then convert to arrays later, preserving the order
local function addIndex(component, index) 
  return vim.tbl_extend('keep', component, {index=index})
end

--- Generate a lualine configuration based on the current level and mode
--- "mode" determines whether or not to show/hide telescope-specific logic - via the cond function
--- "level" determines the display behavior of regular (non-telescope-specific) logic - via configuration overrides
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

  --- Filetype icon
  local filetypeComponent = {
    "filetype",
    icon_only = true,
    separator = "",
    padding = { left = 1, right = 0 } 
  }

  --- Visual indicator of the current diagnostics filter level (either hints or warnings)
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
  --

  -- stylua: ignore
  local lastCharComponent = {
      function() return require("noice").api.status.command.get() end,
      cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
      color = function() return { fg = Snacks.util.color("Statement") } end,
    }

  --- Indicator of the git additions / modifications / deletions
  local diffComponent = {
    "diff",
    padding = { left = 1, right = 1 },
    symbols = {
      added = icons.git.Added,
      modified = icons.git.Modified,
      removed = icons.git.Removed
    },
  }


  --- Base configuration for inactive sections 
  --- lualine_{a/b/c/x/y/z} tables will be converted to array later
  --- ie. 'lualine_a = { mode = {"mode"} }' becomes 'lualine_a = { {"mode"} }
  local inactive_base = {
    lualine_a = {},
    lualine_b = {
      ft = filetypeComponent,
      path = {shortenPathFunc(2)}
    },
    lualine_c = {},

    lualine_x = {},
    lualine_y = {
      telescopeIndicator = telescopeIcon,
      hiddenIndicator = showHiddenIcon,
      gitignoreIndicator = respectGitignoreIcon,
      diagnosticsIndicator = diagnosticsFilterIcon,
      debugIndicator = debugLogsIcon,
    },
    lualine_z = {
      home = {util.renderHome, cond=noTelescopeMode}
    }
  }


  -- Tiered extensions of the inactive_sections base config

  local inactiveLvl1 = util.recursiveMerge(inactive_base, {
    lualine_b = { path = NO_OP_COMPONENT },
    lualine_y = { debugIndicator = NO_OP_COMPONENT },
    lualine_z = { home = NO_OP_COMPONENT }
  })
  local inactiveLvl2 = util.recursiveMerge(inactive_base, {
    lualine_z = { home = NO_OP_COMPONENT }
  })
  local inactiveLvl3 = util.recursiveMerge(inactive_base, {
    lualine_b = { path = {shortenPathFunc(3)} },
  })
  local inactiveLvl4 = util.recursiveMerge(inactive_base, {
    lualine_b = { path = {shortenPathFunc(999)} }
  })
  local inactiveLvl5 = util.recursiveMerge(inactive_base, {
    lualine_b = { path = {shortenPathFunc(999, true)} },
    lualine_z = { home = {function() return util.renderHome(true) end} },
  })


  --- Base configuration for active sections 
  --- lualine_{a/b/c/x/y/z} tables will be converted to array later
  --- ie. 'lualine_a = { mode = {"mode"} }' becomes 'lualine_a = { {"mode"} }
  local active_base = {
    lualine_a = { 
      mode = addIndex({"mode"}, 1),
    },

    lualine_b = {
      ft = addIndex(filetypeComponent, 1),
      path = addIndex({ shortenPathFunc(2) }, 2),
      branch = addIndex({ "branch", separator = "" }, 3),
      diff = addIndex(diffComponent, 4),
    },

    lualine_c = {
      diagnostics = addIndex(diagnosticsComponent, 1),
      troubleStat = addIndex({ troubleStat, separator="" }, 2)
    },

    lualine_x = {

      progBar = addIndex(Snacks.profiler.status(), 1),
      lastChar = addIndex(lastCharComponent, 2),
      fileProgress = addIndex({ "progress", draw_empty = true }, 3),
      cursorLocation = addIndex({ "location", draw_empty = true }, 4),
      border = addIndex(ensureBorder, 5)
    },

    lualine_y = {
      lspStat = addIndex(lspStatusIcon, 1),
      lazyUpdates = addIndex(lazyUpdateIcon, 2),
      diagnosticsIndicator = addIndex(diagnosticsFilterIcon, 3),
      debugIndicator = addIndex(debugLogsIcon, 4),
      border = addIndex(ensureBorder, 5)
    },

    lualine_z = { home = addIndex({util.renderHome}) },
  }


  -- Tiered extensions of the sections base config

  local activeLvl1 = util.recursiveMerge(active_base, {
    lualine_a = { mode = NO_OP_COMPONENT },
    lualine_b = {
      -- hide all but filetype component
      path = NO_OP_COMPONENT,
      branch = NO_OP_COMPONENT,
      diff = NO_OP_COMPONENT
    },
    lualine_c = {
      diagnostics = NO_OP_COMPONENT,
      -- leave in the troubleStat component- this level1 mode is intended for when troubleStat is super long,
      -- and we basically remove the entire reset of the statusline
    },

    lualine_x = {
      progBar = NO_OP_COMPONENT,
      lastChar = NO_OP_COMPONENT,
      fileProgress = { NO_OP, draw_empty=false, separator="" },
      cursorLocation = { NO_OP, draw_empty=false, separator="" },
      border = { NO_OP, draw_empty=false },
    },
    lualine_z = { home = NO_OP_COMPONENT }
  })


  local activeLvl2 = util.recursiveMerge(active_base, {
    lualine_a = { mode = NO_OP_COMPONENT },
    lualine_b = {
      path = { shortenPathFunc(1) },
      branch = { NO_OP, separator="" },
      diff = { 
        separator="",
        symbols = {
          added = "",
          modified = "",
          removed = ""
        }
      }
    },

    lualine_x = {
      progBar = { NO_OP },
      fileProgress = { separator = "" },
      cursorLocation = { NO_OP },
    },
    lualine_z = { home = { NO_OP } }
  })


  local activeLvl3 = util.recursiveMerge(active_base, {
    lualine_b = {
      path = { shortenPathFunc(2) },
    },
    lualine_x = {
      fileProgress = { separator = "" },
      cursorLocation = { NO_OP }
    },
  })


  local activeLvl4 = util.recursiveMerge(active_base, {
    lualine_b = {
      path = { shortenPathFunc(999) },
    },
  })


  local activeLvl5 = util.recursiveMerge(active_base, {
    lualine_b = {
      path = { shortenPathFunc(999) },
    },
    lualine_z = { home = {function() return util.renderHome(true) end} },
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

  -- Perform the conversion mentioned earlier
  -- (convert human readable named components { lualine_<letter> = {name: string -> component} } 
  -- to lualine-compatible arrays { lualine_<letter> = component[] })

  local sectionLetters = {'a', 'b', 'c', 'x', 'y', 'z'}
  for _, tbls in ipairs({activeExtensions, inactiveExtensions}) do
    for _, tbl in ipairs(tbls) do
      for _, letter in ipairs(sectionLetters) do
        local key = 'lualine_' .. letter
        local section = tbl[key]
        if section ~= nil then
          tbl[key] = util.tblToArray(section)
        end
      end
    end
  end


  local filetypeExtension = {
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
  }

  -- Someone has already put a PR to make this a builtin extension
  local outlineExtension = {
    filetypes = {'Outline'},
    sections = {
      lualine_a = {'filetype'},
    }
  }

  local config = {
    options = {
      -- theme = "NeoSolarized",
      globalstatus = vim.o.laststatus == 3,
      disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
      always_show_tabline = true
    },

    inactive_sections = inactiveExtensions[M.CURRENT_LEVEL],
    sections = activeExtensions[M.CURRENT_LEVEL],


    extensions = {
      "lazy",
      "fzf",
      "fugitive",
      "quickfix",
      outlineExtension,
      filetypeExtension
    },
  }
  return config
end



return M
