local util = require('util')

local M = {}


M.WARNING_FILTER = true

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
    signs = {
      severity=severity
    }
  })
end

M.toggleHints(M.WARNING_FILTER)


return M
