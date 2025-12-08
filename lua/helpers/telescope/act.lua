local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local actionUtils = require("telescope.actions.utils")

local telescopeUtil = require('helpers.telescope.utils')
local telescopeConf = require('helpers.telescope.config')
local customPickers = require('helpers.telescope.pick')
local util = require('util')

local M = {}

function M.debugEntry(prompt_bufnr)
  local entry = actionState.get_selected_entry()
  print('Entry: ' .. vim.inspect(entry))
end

function M.deleteBufferSelection(entry, force) 
  -- local entry = actionState.get_selected_entry()
  -- actionState.g
  local isVisible = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == entry.bufnr then
      isVisible = true
    end
  end
  if isVisible then
    local name = vim.api.nvim_buf_get_name(entry.bufnr)
    name = name and name:match("([^\\/]+)$")
    return vim.notify('Buffer "' .. (name or 'nil') .. '" is visible!', vim.log.levels.WARN)
  end

  require('neoWin.smartDelete').smartDeleteBuffer(force, entry.bufnr, false)
  -- customPickers.browseBuffers({}, prompt_bufnr)
end

function M.deleteSelectedBuffers(prompt_bufnr, force)
  local selected = {}
  actionUtils.map_selections(prompt_bufnr, function(entry) selected[#selected+1] = entry end)
  if #selected > 1 then
    actionUtils.map_selections(prompt_bufnr, function(entry) return M.deleteBufferSelection(entry, force) end)
  else
    M.deleteBufferSelection(actionState.get_selected_entry(), force)
  end
  customPickers.browseBuffers({}, prompt_bufnr)
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
function M.fileBrowserChangeDepth(args, prompt_bufnr, plus)
  telescopeConf.FILE_DEPTH = telescopeConf.FILE_DEPTH + (plus and 1 or -1)
  if telescopeConf.FILE_DEPTH < 1 then
    telescopeConf.FILE_DEPTH = 1
  end
  args = customPickers.getFilebrowseArgs(args, prompt_bufnr)
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
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
  args = customPickers.getFilebrowseArgs(args, prompt_bufnr)
  args.cwd = os.getenv('HOME')
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end

function M.fileBrowserGotoVimHome(args, prompt_bufnr)
  args = customPickers.getFilebrowseArgs(args, prompt_bufnr)
  args.cwd = vim.cmd('pwd')
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end

function M.fileBrowserTabCD(args, prompt_bufnr)
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
