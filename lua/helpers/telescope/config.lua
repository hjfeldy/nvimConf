local lspHelpers = require('helpers.lsp')
local M = {}

M.SHOW_HIDDEN = false
M.RESPECT_IGNORE = true

--- Whether or not to show warnings or hints 
--- (tied to the global lsp configuration, which is also toggleable)
M.WARNING_FILTER = lspHelpers.WARNING_FILTER
-- Whether or not the telescope-diagnostics pertain 
-- to the entire workspace vs just the current file
M.LOCAL_DIAGNOSTICS = nil

--- File-browser depth (incrementable/decrementable)
M.FILE_DEPTH = 1

M.WRAP_TEXT = false

return M
