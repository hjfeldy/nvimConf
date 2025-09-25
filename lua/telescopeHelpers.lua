local builtin = require('telescope.builtin')
local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local util = require('util')
local lspHelpers = require('lspHelpers')
local lualineConf = require('lualineConfig')

local M = {}

M.SHOW_HIDDEN = false
M.RESPECT_IGNORE = true

M.WARNING_FILTER = lspHelpers.WARNING_FILTER
M.LOCAL_DIAGNOSTICS = nil

M.FILE_DEPTH = 1

-- UTILITES 

--- Set the lualine dynamic mode 
local function setLualineMode(mode)
  lualineConf.setMode(mode)
end

local function unsetLualineMode(mode)
  local dynamicMode = lualineConf.getMode()
  local isOn = dynamicMode == mode
  if isOn then lualineConf.setMode('normal') end
end


function M.toggleHints()
  M.WARNING_FILTER = not M.WARNING_FILTER
  lspHelpers.toggleHints(M.WARNING_FILTER)
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
  -- local picker = actionState.get_current_picker(
  local entry = actionState.get_selected_entry()
  if entry then
    -- print('Found entry: ' .. vim.inspect(entry))

    local mode = vim.fn.mode() == 'n' and 'normal' or 'insert'
    args.initial_mode = mode
    local currentText = actionState.get_current_line()
    args.default_text = currentText
    args.cwd = entry.cwd
  end
  return args
end


--- Generate args for a telescope file-finder (find_files or file_browser)
--- Show hidden/ignored files based on the current configuration
local function getFileArgs(args, prefix, prompt_bufnr)
  args = args or {}
  if args.hidden == nil then
    args.hidden = M.SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not M.RESPECT_IGNORE
  end

  args.prompt_title = prefix .. ' (' .. util.renderHome() .. ')'
  return prompt_bufnr ~= nil and extendArgs(args) or args
end


--- Generate args for the telescope file-browser (extend getFileArgs() output)
local function getFilebrowseArgs(args, prompt_bufnr)
  args = getFileArgs(args, 'File Browser', prompt_bufnr)
  args.depth = M.FILE_DEPTH
  args.prompt_title = 'File Browser (' .. util.renderHome() .. ')'

  return prompt_bufnr ~= nil and extendArgs(args) or args
end


--- Generate args for telescope live_grep 
--- (same logic as getFileArgs, but live_grep args expect different format with "additional_args")
local function getLiveGrepArgs(args, prompt_bufnr)
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
  return prompt_bufnr ~= nil and extendArgs(args) or args
end


--- Generate args for telescope diagnostics
local function getDiagnosticsArgs(args, prompt_bufnr)
  args = args or {}
  if args.severity_limit == nil then
    args.severity_limit = M.WARNING_FILTER and 'warn' or 'hint'
  end
  util.debug('Set severity-limit to ' .. (args.severity_limit or "nil"))

  -- Keep track of whether or not the diagnostics prompt was opened for the current buffer vs the entire workspace
  -- When we call diagnosticsToggleHints, we will retain this option
  if M.LOCAL_DIAGNOSTICS == nil then
    M.LOCAL_DIAGNOSTICS = args.bufnr ~= nil
    print('Set LOCAL_DIAGNOSTICS to ' .. (M.LOCAL_DIAGNOSTICS and 'true' or 'false'))
  elseif M.LOCAL_DIAGNOSTICS then
    print('Using  LOCAL_DIAGNOSTICS value (setting bufnr = 0)')
    args.bufnr = 0
  end

  return prompt_bufnr ~= nil and extendArgs(args) or args
end


-- TELESCOPE PICKER-OPENERS 

function M.findFiles(args, prompt_bufnr)
  require('lualine').refresh()
  args = getFileArgs(args, 'Find Files', prompt_bufnr)
  builtin.find_files(args)
  setLualineMode('telescopeFiles')
end


function M.fileBrowser(args, prompt_bufnr)
  require('lualine').refresh()
  args = getFilebrowseArgs(args, prompt_bufnr)
  require("telescope").extensions.file_browser.file_browser(args)
  setLualineMode('telescopeFiles')
end


function M.liveGrep(args, prompt_bufnr)
  args = getLiveGrepArgs(args, prompt_bufnr)
  builtin.live_grep(args)
  setLualineMode('telescopeFiles')
end

function M.diagnostics(args, prompt_bufnr)
  args = getDiagnosticsArgs(args, prompt_bufnr)
  if prompt_bufnr ~= nil then
    -- Close the current prompt, or else the 0 bufNr points to the telescope prompt buffer itself
    -- this will trigger the autocmd at the bottom of this file (resetting LOCAL_DIAGNOSTICS to nil), 
    -- so we need to explicitly undo that trigger - kinda gross
    -- This could all be avoidable if we could specify a specific buffer to open the diagnostics in
    -- But the bufnr parameter is documented incorrectly 
    -- it either opens diagnostics for the entire workspace (bufnr=nil), or the current buffer (bufnr~=nil)
    local preClose = M.LOCAL_DIAGNOSTICS
    actions.close(prompt_bufnr)
    M.LOCAL_DIAGNOSTICS = preClose
  end

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
    return finderFunc({}, prompt_bufnr)
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
M.diagnosticsToggleHints = wrapWithToggle(M.diagnostics, M.toggleHints)


--- Increase/Decrease the file-depth for the current file-browser prompt
function M.fileBrowserChangeDepth(args, prompt_bufnr, plus)
  M.FILE_DEPTH = M.FILE_DEPTH + (plus and 1 or -1)
  args = getFilebrowseArgs(args, prompt_bufnr)
  require("telescope").extensions.file_browser.file_browser(args)
  setLualineMode('telescopeFiles')
end


--- Increase the file-depth for the current file-browser prompt
function M.fileBrowserIncrementDepth(args, prompt_bufnr)
  return M.fileBrowserChangeDepth(args, prompt_bufnr, true)
end


--- Decrease the file-depth for the current file-browser prompt
function M.fileBrowserDecrementDepth(args, prompt_bufnr)
  return M.fileBrowserChangeDepth(args, prompt_bufnr, false)
end


--- Jump to the user's home directory in the current file-browser prompt
function M.fileBrowserGotoHome(args, prompt_bufnr)
  args = getFilebrowseArgs(args, prompt_bufnr)
  args.cwd = os.getenv('HOME')
  require("telescope").extensions.file_browser.file_browser(args)
  setLualineMode('telescopeFiles')
end

function M.fileBrowserTabCD(args, prompt_bufnr)
  local cwd = actionState.get_selected_entry().value
  vim.cmd('tcd ' .. cwd)
  actions.close(prompt_bufnr)
end


-- --- Toggle between hint-level and warning-level diagnostics filter for the current diagnostics prompt
-- function M.diagnosticsToggleHints(prompt_bufnr)
--   M.toggleHints()
--
--   local currentText = actionState.get_current_line()
--   local diagnosticCount = diagnosticCount(false)
--   if diagnosticCount == 0 then
--     return actions.close(prompt_bufnr)
--   end
--   local mode = vim.fn.mode() == 'n' and 'normal' or 'insert'
--
--   -- if diagnostics were originally triggered for the current buffer,
--   -- make sure we retain that option
--   local diagnosticsBuf = nil
--   if M.LOCAL_DIAGNOSTICS then
--     -- Close the current prompt, or else the 0 bufNr points to the telescope prompt buffer itself
--     actions.close(prompt_bufnr)
--     diagnosticsBuf = 0
--   end
--   M.diagnostics({
--     bufnr=diagnosticsBuf,
--     default_text=currentText,
--     initial_mode=mode
--   })
-- end


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
      unsetLualineMode('telescopeFiles')
      unsetLualineMode('telescopeDiagnostics')
      if M.LOCAL_DIAGNOSTICS ~= nil then
        print('Resetting LOCAL_DIAGNOSTICS')
      end

      M.LOCAL_DIAGNOSTICS = nil
    end
  end
})

return M
