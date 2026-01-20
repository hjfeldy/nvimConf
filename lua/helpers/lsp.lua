local M = {}

local function getLogger()
  if M.LOGGER ~= nil then
    return M.LOGGER
  end
  local logger = require('neoWin.logger'):new('vimConf.helpers.lsp')
  M.LOGGER = logger
  return logger
end

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

--- Custom andler for whe nan LSP goto command finds multiple results
--- (ie goto-definition with multiple definition-site candidates)
--- Default behavior is to open the quickfix list,
--- but sometimes there are multiple results all on the same line...
--- In tohse cases we want to just jump to the first
function M.listHandler(lspResults)
  local logger = getLogger():withAttrs({logMethod="listHandler"});

  -- Some LSPs will give multiple results which are all from the same line
  -- ie. "some.member = function() ..." will match on "member" and "function" 
  -- This should not open up the quickfix list, we should just go to the first one
  local matchingLineNums = {}
  local matchingFiles = 0

  -- if all results are from the same file and line-number, treat them as a single result
  local allSame = true
  for _, match in ipairs(lspResults.items) do
    if matchingLineNums[match.filename] == nil then
      matchingLineNums[match.filename] = match.lnum
      matchingFiles = matchingFiles+1
      if matchingFiles > 1 then
        allSame = false
      end
    elseif matchingLineNums[match.filename] ~= match.lnum then
      allSame = false
    end
  end

  if allSame and #lspResults.items > 1 then
    logger:debug(#lspResults.items .. ' definitions found, but all are on the same line')
  end

  logger:debug('Lsp multi-results: ' .. vim.inspect(lspResults))
  vim.cmd("normal! m`")

  if allSame or #lspResults.items == 1 then

    -- vim.api.nvim_win_set_buf(0, lspResults.items[1].bufnr)
    local currFile = vim.api.nvim_buf_get_name(0)
    local firstResult = lspResults.items[1]
    logger:debug("Current file: " .. currFile .. "\nResult File: " .. firstResult.filename:lower())
    if currFile:lower() ~= firstResult.filename:lower() then
      vim.cmd('keepjumps edit ' .. firstResult.filename)
    end

    -- add current position to jumplist
    -- vim.cmd("normal! m`")
    vim.api.nvim_win_set_cursor(0, {firstResult.lnum, firstResult.col - 1})
    return
  end
  -- local a = lspResults.items[1]

  -- default lsp behavior is to open the quickfix list when there are multiple potential definitions
  -- we override with trouble.nvim here
  vim.fn.setqflist(lspResults.items)
  if #lspResults.items == 1 or allSame then
    vim.cmd.cfirst()
    vim.fn.setqflist({})
  else
    vim.cmd('Trouble qflist focus=true auto_preview=false')
  end
end


return M
