local lspHelpers = require('helpers.lsp')
local lualineConf = require('lualineConfig')
local telescopeConf = require('helpers.telescope.config')

local M = {}

--- Set the lualine dynamic mode 
--- @param mode string
function M.setLualineMode(mode)
  lualineConf.setMode(mode)
end

--- If the current lualine mode is {mode}, switch to normal mode
--- @param mode string
function M.unsetLualineMode(mode)
  local dynamicMode = lualineConf.getMode()
  local isOn = dynamicMode == mode
  if isOn then lualineConf.setMode('normal') end
end

--- Toggle the Telescope preview window's wrap-text option
--- (propagate to global LSP toggleable configuration)
function M.toggleWrap()
  telescopeConf.WRAP_TEXT = not telescopeConf.WRAP_TEXT
end

--- Toggle the WARNING/HINT level filter for diagnostics
--- (propagate to global LSP toggleable configuration)
function M.toggleHints()
  telescopeConf.WARNING_FILTER = not telescopeConf.WARNING_FILTER
  lspHelpers.toggleHints(telescopeConf.WARNING_FILTER)
end

--- Toggle respect-gitignore config
 function M.toggleIgnore()
  telescopeConf.RESPECT_IGNORE = not telescopeConf.RESPECT_IGNORE
end

--- Toggle show-hidden-files config
function M.toggleHidden()
  telescopeConf.SHOW_HIDDEN = not telescopeConf.SHOW_HIDDEN
end

--- Count total diagnostics in the current buffer (or the entire workspace),
--- based on the current filter (warnings vs hints)
--- @param currBuf boolean Should the count be local to the current buffer? 
function M.diagnosticCount(currBuf)
  local severity = {
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.WARN,
    vim.diagnostic.severity.ERROR,
  }
  if not telescopeConf.WARNING_FILTER then
    table.insert(severity, 1, vim.diagnostic.severity.HINT)
  end

  local bufNr
  if currBuf then bufNr = 0 else bufNr = nil end
  return vim.tbl_count(vim.diagnostic.get(bufNr, {severity=severity}))
end

return M
