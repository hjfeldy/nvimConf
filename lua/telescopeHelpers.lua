local builtin = require('telescope.builtin')
local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local util = require('util')
local lspHelpers = require('lspHelpers')


local M = {}

M.SHOW_HIDDEN = false
M.RESPECT_IGNORE = true

M.WARNING_FILTER = lspHelpers.WARNING_FILTER
M.LOCAL_DIAGNOSTICS = true

M.FILE_DEPTH = 1

-- UTILITES 

--- Set the lualine dynamic mode 
local function setLualineMode(mode)
  require('lualine.dynamicMode').setGlobalMode(mode)
end

function M.toggleHints()
  M.WARNING_FILTER = not M.WARNING_FILTER
end

 function M.toggleIgnore()
  M.RESPECT_IGNORE = not M.RESPECT_IGNORE
end

function M.toggleHidden()
  M.SHOW_HIDDEN = not M.SHOW_HIDDEN
end

--- Count total diagnostics in the current buffer (or the entire workspace),
--- based on the current filter (warnings vs hints)
local function diagnosticCount(currBuf)
  local severity = {
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.WARN,
    vim.diagnostic.severity.ERROR,
  }
  if not M.WARNING_FILTER then
    table.insert(severity, 1, vim.diagnostic.severity.HINT)
  end

  local bufNr
  if currBuf then bufNr = 0 else bufNr = nil end
  return vim.tbl_count(vim.diagnostic.get(bufNr, {severity=severity}))
end


--- If there is an existing telescope prompt,
--- extend the telescope prompt args with the current text and input-mode
local function extendArgs(args)
  local entry = actionState.get_selected_entry()
  if entry then
    local mode = vim.fn.mode() == 'n' and 'normal' or 'insert'
    args.initial_mode = mode
    local currentText = actionState.get_current_line()
    args.default_text = currentText
  end
  return args
end


--- Generate args for a telescope file-finder (find_files or file_browser)
--- Show hidden/ignored files based on the current configuration
local function getFileArgs(args, prefix)
  args = args or {}
  if args.hidden == nil then
    args.hidden = M.SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not M.RESPECT_IGNORE
  end

  args.prompt_title = prefix .. ' (' .. util.renderHome() .. ')'
  return extendArgs(args)
end


--- Generate args for the telescope file-browser (extend getFileArgs() output)
local function getFilebrowseArgs(args)
  args = getFileArgs(args, 'File Browser')
  args.depth = M.FILE_DEPTH
  args.prompt_title = 'File Browser (' .. util.renderHome() .. ')'

  return extendArgs(args)
end


--- Generate args for telescope live_grep 
--- (same logic as getFileArgs, but live_grep args expect different format with "additional_args")
local function getLiveGrepArgs(args)
  args = args or {}
  local additional_args = args.additional_args or {}
  if M.SHOW_HIDDEN then
    additional_args[#additional_args+1] = "--hidden"
  end
  if not M.RESPECT_IGNORE then
    additional_args[#additional_args+1] = "--no-ignore"
  end
  args.additional_args = additional_args
  args.prompt_title = 'Live Grep (' .. util.renderHome() .. ')'
  return extendArgs(args)
end


--- Generate args for telescope diagnostics
local function getDiagnosticsArgs(args)
  args = args or {}
  if args.severity_limit == nil then
    args.severity_limit = M.WARNING_FILTER and 'warn' or 'hint'
  end
  util.debug('Set severity-limit to ' .. (args.severity_limit or "nil"))

  -- Keep track of whether or not the diagnostics prompt was opened for the current buffer vs the entire workspace
  -- When we call diagnosticsToggleHints, we will retain this option
  M.LOCAL_DIAGNOSTICS = args.bufnr ~= nil
  return extendArgs(args)
end


-- TELESCOPE PICKER-OPENERS 

function M.findFiles(args)
  require('lualine').refresh()
  args = getFileArgs(args, 'Find Files')
  builtin.find_files(args)
  setLualineMode('telescopeFiles')
end


function M.fileBrowser(args)
  require('lualine').refresh()
  args = getFilebrowseArgs(args)
  require("telescope").extensions.file_browser.file_browser(args)
  setLualineMode('telescopeFiles')
end


function M.liveGrep(args)
  args = getLiveGrepArgs(args)
  builtin.live_grep(args)
  setLualineMode('telescopeFiles')
end


function M.diagnostics(args)
  args = getDiagnosticsArgs(args)

  local numDiagnostics = diagnosticCount(args.bufnr ~= nil)
  if numDiagnostics > 0 then
    -- print('found ' .. diagnosticCount .. 'diagnostics')
    setLualineMode('telescopeDiagnostics')
  end
  builtin.diagnostics(args)
end


-- TELESCOPE ACTIONS 

--- Wrap a telescope function (ie findFiles or liveGrep) 
--- such that it calls toggleHiden() / toggleIgnore() first.
--- These wrapped functions can be called while a telescope prompt is already open,
--- reopening a new telescope inplace which uses the newly toggled configuration value
local function wrapWithToggle(finderFunc, togglerFunc)
  local wrapped = function(prompt_bufnr)
    togglerFunc()
    return finderFunc()
  end
  return wrapped
end

--- Telescope actions to open a telescope prompt from an existing prompt, with toggled arguments
M.fileBrowserToggleHidden = wrapWithToggle(M.fileBrowser, M.toggleHidden)
M.fileBrowserToggleIgnore = wrapWithToggle(M.fileBrowser, M.toggleIgnore)
M.findFilesToggleHidden = wrapWithToggle(M.findFiles, M.toggleHidden)
M.findFilesToggleIgnore = wrapWithToggle(M.findFiles, M.toggleIgnore)
M.liveGrepToggleHidden = wrapWithToggle(M.liveGrep, M.toggleHidden)
M.liveGrepToggleIgnore = wrapWithToggle(M.liveGrep, M.toggleIgnore)


--- Increase/Decrease the file-depth for the current file-browser prompt
function M.fileBrowserChangeDepth(args, plus)
  M.FILE_DEPTH = M.FILE_DEPTH + (plus and 1 or -1)
  args = getFilebrowseArgs(args)
  require("telescope").extensions.file_browser.file_browser(args)
  setLualineMode('telescopeFiles')
end


--- Increase the file-depth for the current file-browser prompt
function M.fileBrowserIncrementDepth(args)
  return M.fileBrowserChangeDepth(args, true)
end


--- Decrease the file-depth for the current file-browser prompt
function M.fileBrowserDecrementDepth(args)
  return M.fileBrowserChangeDepth(args, false)
end


--- Jump to the user's home directory in the current file-browser prompt
function M.fileBrowserGotoHome(args)
  args = getFilebrowseArgs(args)
  args.cwd = os.getenv('HOME')
  require("telescope").extensions.file_browser.file_browser(args)
  setLualineMode('telescopeFiles')
end


--- Toggle between hint-level and warning-level diagnostics filter for the current diagnostics prompt
function M.diagnosticsToggleHints(prompt_bufnr)
  M.toggleHints()
  lspHelpers.toggleHints(M.WARNING_FILTER)

  local currentText = actionState.get_current_line()
  local diagnosticCount = diagnosticCount(false)
  if diagnosticCount == 0 then
    return actions.close(prompt_bufnr)
  end
  local mode = vim.fn.mode() == 'n' and 'normal' or 'insert'

  -- if diagnostics were originally triggered for the current buffer,
  -- make sure we retain that option
  local diagnosticsBuf = nil
  if M.LOCAL_DIAGNOSTICS then
    -- Close the current prompt, or else the 0 bufNr points to the telescope prompt buffer itself
    actions.close(prompt_bufnr)
    diagnosticsBuf = 0
  end
  M.diagnostics({
    bufnr=diagnosticsBuf,
    default_text=currentText,
    initial_mode=mode
  })
end


--- FileBrowser action - open a new tabpage whose working directory is the selected directory
function M.openFileInTab(prompt_bufnr, focus)
  local entry = actionState.get_selected_entry()
  local dir = entry.value
  vim.cmd('tabnew')
  vim.cmd('tcd ' .. dir)
  local pathSep = package.config:sub(1,1)
  local pathComponents = util.split(dir, pathSep)
  local pathBasename = pathComponents[#pathComponents]
  vim.cmd('BufferLineTabRename ' .. pathBasename)
  if not focus then
    vim.cmd('tabprevious')
  end
end

--- Send all results to Trouble
function M.telescopeTrouble(...)
  return require('trouble.sources.telescope').open(...)
end


--- Whenever leaving a telescope prompt, turn off all dynamic lualine icons
vim.api.nvim_create_autocmd('WinLeave', {
  pattern = {'*'},
  callback = function(ev)
    local ft = vim.api.nvim_get_option_value('filetype', {buf=ev.buf})

    if ft == 'TelescopeResults' or ft == 'TelescopePrompt' then
      util.debug('Left Telescope:', ev)
      setLualineMode('normal')
    end
  end
})

return M
