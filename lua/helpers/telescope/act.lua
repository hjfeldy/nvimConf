local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local actionUtils = require("telescope.actions.utils")

local telescopeUtil = require('helpers.telescope.utils')
local telescopeConf = require('helpers.telescope.config')
local customPickers = require('helpers.telescope.pick')
local util = require('util')

local LOGGER = require('neoWin.logger'):new('vimConf.helpers.telescope.act')

local M = {}


function M.deleteBufferSelection(entry, force)
  local logger = LOGGER:withAttrs({logMethod="deleteBufferSelection"});
  logger:debug('Deleting entry: ' .. vim.inspect(entry))
  require('neoWin.smartDelete').smartDeleteBuffer(force, entry.bufnr, true, false)
end

function M.unlistBufferSelection(entry)
  require('neoWin.smartDelete').smartDeleteBuffer(false, entry.bufnr, true, true)
end

function M.actOnBufferSelection(prompt_bufnr, callback)
  local selected = {}
  actionUtils.map_selections(prompt_bufnr, function(entry) selected[#selected+1] = entry end)
  if #selected > 1 then
    actionUtils.map_selections(prompt_bufnr, function(entry) return callback(entry) end)
  else
    callback(actionState.get_selected_entry())
  end
  customPickers.browseBuffers({}, prompt_bufnr)
end

function M.deleteSelectedBuffers(prompt_bufnr, force)
  M.actOnBufferSelection(prompt_bufnr, function(entry) M.deleteBufferSelection(entry, force) end)
end

function M.unlistSelectedBuffers(prompt_bufnr)
  M.actOnBufferSelection(prompt_bufnr, function(entry) M.unlistBufferSelection(entry) end)
end

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
M.fileBrowserToggleHidden = wrapWithToggle(customPickers.fileBrowser, telescopeUtil.toggleHidden)
M.fileBrowserToggleIgnore = wrapWithToggle(customPickers.fileBrowser, telescopeUtil.toggleIgnore)
M.findFilesToggleHidden = wrapWithToggle(customPickers.findFiles, telescopeUtil.toggleHidden)
M.findFilesToggleIgnore = wrapWithToggle(customPickers.findFiles, telescopeUtil.toggleIgnore)
M.liveGrepToggleHidden = wrapWithToggle(customPickers.liveGrep, telescopeUtil.toggleHidden)
M.liveGrepToggleIgnore = wrapWithToggle(customPickers.liveGrep, telescopeUtil.toggleIgnore)
M.diagnosticsToggleHints = wrapWithToggle(customPickers.diagnostics, telescopeUtil.toggleHints)


--- Increase/Decrease the file-depth for the current file-browser prompt
function M.fileBrowserChangeDepth(prompt_bufnr, plus)
  telescopeConf.FILE_DEPTH = telescopeConf.FILE_DEPTH + (plus and 1 or -1)
  if telescopeConf.FILE_DEPTH < 1 then
    telescopeConf.FILE_DEPTH = 1
  end
  local args = customPickers.getFilebrowseArgs({}, prompt_bufnr)
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end


--- Increase the file-depth for the current file-browser prompt
function M.fileBrowserIncrementDepth(prompt_bufnr)
  return M.fileBrowserChangeDepth(prompt_bufnr, true)
end


--- Decrease the file-depth for the current file-browser prompt
function M.fileBrowserDecrementDepth(prompt_bufnr)
  return M.fileBrowserChangeDepth(prompt_bufnr, false)
end


--- Jump to the user's home directory in the current file-browser prompt
function M.fileBrowserGotoHome(prompt_bufnr)
  local logger = LOGGER:withAttrs({logMethod="fileBrowserGotoHome"});
  logger:debug('GOING HOME (prompt ' .. (prompt_bufnr or 'nil') .. ')')
  local args = customPickers.getFilebrowseArgs({}, prompt_bufnr)
  args.cwd = os.getenv('HOME')
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end

function M.fileBrowserGotoVimHome(prompt_bufnr)
  local args = customPickers.getFilebrowseArgs({}, prompt_bufnr)
  args.cwd = vim.cmd('pwd')
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end

function M.fileBrowserTabCD(prompt_bufnr)
  local cwd = actionState.get_selected_entry().value
  vim.cmd('tcd ' .. cwd)
  vim.api.nvim_tabpage_set_var(0, 'name', vim.fs.basename(cwd))
  actions.close(prompt_bufnr)
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


return M
