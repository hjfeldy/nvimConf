local util = require('util')

local M = {}


M.WARNING_FILTER = true

--- Toggle WARNING-level vs HINT-level LSP diagnostics
--- @param force boolean? Force a specific value (true for WARN, false for HINT) rather than just flipping the value
function M.toggleHints(force)
  if force ~= nil then 
    M.WARNING_FILTER = force
  else
    M.WARNING_FILTER = not M.WARNING_FILTER
  end

  local severity = {
    'HINT',
    'INFO',
    'WARN',
    'ERROR'
  }
  if M.WARNING_FILTER then
    table.remove(severity, 1)
  end
  vim.diagnostic.config({
    severity_sort=true,
    signs = {
      severity=severity
    }
  })
end

M.toggleHints(M.WARNING_FILTER)


return M
