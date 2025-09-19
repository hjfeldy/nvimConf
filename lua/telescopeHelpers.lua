local builtin = require('telescope.builtin')
local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local fileBrowserActions = require("telescope").extensions.file_browser.actions
local util = require('util')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local entry_maker = require('telescope.make_entry')
local conf = require('telescope.config').values
local lspHelpers = require('lspHelpers')
-- local dynamicMode = require('lualine.dynamicMode')
-- local extensions = require('telescope').extensions.dir


local M = {}

M.SHOW_HIDDEN = false
M.RESPECT_IGNORE = true

M.WARNING_FILTER = lspHelpers.WARNING_FILTER
M.LOCAL_DIAGNOSTICS = true
M.DIAGNOSTICS_BUFFER = nil

function M.toggleHints()
  M.WARNING_FILTER = not M.WARNING_FILTER
end

 function M.toggleIgnore()
  M.RESPECT_IGNORE = not M.RESPECT_IGNORE
end

function M.toggleHidden()
  M.SHOW_HIDDEN = not M.SHOW_HIDDEN
end

-- local function toggleIcons(on, withDiagnostics) 
--   local mode = on and 'telescope' or nil
--   util.debug('Toggling icons to state ' .. (mode or 'nil'))
--   dynamicMode.setMode('showHiddenIcon', mode )
--   dynamicMode.setMode('respectGitignore', mode)
--   dynamicMode.setMode('telescopeIcon', mode)
--
--   -- By default, diagnostics icon is always on.
--   -- however, we want to turn it off when we open telescope,
--   -- EXCEPT for when we're using telescope diagnostics
--   if on and not withDiagnostics then
--     dynamicMode.setMode('diagnosticsFilter', 'inactive')
--   else 
--     dynamicMode.setMode('diagnosticsFilter', nil)
--   end
-- end


function M.findFiles(args)
  require('lualine').refresh()
  args = args or {}
  if args.hidden == nil then
    args.hidden = M.SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not M.RESPECT_IGNORE
  end
  args.prompt_title = 'Find Files (' .. util.renderHome() .. ')'
  -- args.find_command = {'fdfind', '-l'}
  builtin.find_files(args)
  require('lualine.dynamicMode').setGlobalMode('telescopeFiles')
  -- toggleIcons(true, false)
  -- require('lualine.dynamicMode').setMode('showHiddenIcon', nil)
  -- require('lualine.dynamicMode').setMode('respectGitignore', nil)
end

local function getFileArgs(args) 
  args = args or {}
  if args.hidden == nil then
    args.hidden = M.SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not M.RESPECT_IGNORE
  end

  return args
end


function M.fileBrowser(args)
  require('lualine').refresh()
  args = getFileArgs(args)
  -- args.find_command = {'fdfind', '-l'}
  require("telescope").extensions.file_browser.file_browser(args)
  require('lualine.dynamicMode').setGlobalMode('telescopeFiles')
  -- toggleIcons(true, false)
  -- require('lualine.dynamicMode').setMode('showHiddenIcon', nil)
  -- require('lualine.dynamicMode').setMode('respectGitignore', nil)
end

function M.liveGrep(args)

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
  -- print(vim.inspect(args.additional_args))
  builtin.live_grep(args)
  require('lualine.dynamicMode').setGlobalMode('telescopeFiles')
  -- toggleIcons(true, false)
end

--- Wrap a telescope function (ie findFiles or liveGrep) 
--- such that it calls toggleHiden() / toggleIgnore() first.
--- These wrapped functions can be called while a telescope prompt is already open,
--- reopening a new telescope inplace which uses the newly toggled configuration value
local function wrapWithToggle(finderFunc, togglerFunc)
  local wrapped = function(prompt_bufnr)
    togglerFunc()
    local currentText = actionState.get_current_line()
    return finderFunc({default_text=currentText})
  end
  return wrapped
end

M.fileBrowserToggleHidden = wrapWithToggle(M.fileBrowser, M.toggleHidden)
M.fileBrowserToggleIgnore = wrapWithToggle(M.fileBrowser, M.toggleIgnore)
M.findFilesToggleHidden = wrapWithToggle(M.findFiles, M.toggleHidden)
M.findFilesToggleIgnore = wrapWithToggle(M.findFiles, M.toggleIgnore)
M.liveGrepToggleHidden = wrapWithToggle(M.liveGrep, M.toggleHidden)
M.liveGrepToggleIgnore = wrapWithToggle(M.liveGrep, M.toggleIgnore)


M.FILE_DEPTH = 1

function M.fileBrowserIncrementDepth(args)
  args = getFileArgs(args)
  M.FILE_DEPTH = M.FILE_DEPTH + 1
  args.depth = M.FILE_DEPTH

  local currentText = actionState.get_current_line()
  args.default_text = currentText
  require("telescope").extensions.file_browser.file_browser(args)
  require('lualine.dynamicMode').setGlobalMode('telescopeFiles')
end

function M.fileBrowserDecrementDepth(args)
  args = getFileArgs(args)
  M.FILE_DEPTH = M.FILE_DEPTH - 1
  args.depth = M.FILE_DEPTH
  local currentText = actionState.get_current_line()
  args.default_text = currentText
  require("telescope").extensions.file_browser.file_browser(args)
  require('lualine.dynamicMode').setGlobalMode('telescopeFiles')
end

function M.debugPicker(prompt_bufnr)
  local picker = actionState.get_current_picker(prompt_bufnr)
  local title = picker.prompt_title
  local titleWords = util.split(title, ' ')
  if #titleWords > 1 and titleWords[2] == 'Diagnostics' then
  end
  util.debug('Prompt Title:', title)
end

function M.diagnostics(args)
  args = args or {}
  if args.severity_limit == nil then
    args.severity_limit = M.WARNING_FILTER and 'warn' or 'hint'
  end
  util.debug('Set severity-limit to ' .. (args.severity_limit or "nil"))
  -- local picker = actionState.get_current_picker(
  -- cache the buffer that the user explicitly opened diagnostics for
  -- would work if builtin.diagnostics({bufnr=n}) worked,
  -- but it seems to be just a binary flag for global/local
  M.LOCAL_DIAGNOSTICS = args.bufnr ~= nil
  if M.LOCAL_DIAGNOSTICS then
    if tonumber(args.bufnr) > 0 then
      M.DIAGNOSTICS_BUFFER = args.bufnr
    else
      local currentBuf = vim.api.nvim_get_current_buf()
      M.DIAGNOSTICS_BUFFER = currentBuf
    end
  end
  
  local diagnosticCount = M.diagnosticCount(args.bufnr ~= nil)
  if diagnosticCount > 0 then
    -- print('found ' .. diagnosticCount .. 'diagnostics')
    require('lualine.dynamicMode').setGlobalMode('telescopeDiagnostics')
  end
  -- toggleIcons(true, true)
  builtin.diagnostics(args)
end

function M.diagnosticCount(currBuf)
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

function M.diagnosticsToggleHints(prompt_bufnr)
  M.toggleHints()
  lspHelpers.toggleHints(M.WARNING_FILTER)
  -- builtin.diagnostic doesn't work with bufnr = 0
  -- args.bufnr = M.LOCAL_DIAGNOSTICS and 0 or nil

  local currentText = actionState.get_current_line()
  local diagnostics = vim.diagnostic.get(nil)
  local severityLimit = M.WARNING_FILTER and 2 or 4
  local diagnosticCount = M.diagnosticCount(false)
  if diagnosticCount == 0 then
    -- print('No warning/error diagnostics')
    return actions.close(prompt_bufnr)
  end
  M.diagnostics({bufnr=nil, default_text=currentText})

end


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

function M.sendAllTroubleQfList(prompt_bufnr)
  require('telescope.actions').send_to_qflist(prompt_bufnr)
  vim.cmd('Trouble qflist')
end

function M.sendSelectedTroubleQflist(prompt_bufnr)
  require('telescope.actions').send_selected_to_qflist(prompt_bufnr)
  vim.cmd('Trouble qflist')
end

function M.openTrouble() 
  vim.cmd('Trouble qflist focus=true')
end

function M.telescopeTrouble(...)
  return require('trouble.sources.telescope').open(...)
end


vim.api.nvim_create_autocmd('WinLeave', {
  pattern = {'*'},
  callback = function(ev)
    local ft = vim.api.nvim_get_option_value('filetype', {buf=ev.buf})
    local fname = vim.api.nvim_buf_get_name(ev.buf)
    -- util.debug('New Win event:', ev)
    -- util.debug('Filetype:', ft)
    -- if #bufName == 0 or ft == 'TelescopeResults' or ft == 'TelescopePrompt' then return end

    if ft == 'TelescopeResults' or ft == 'TelescopePrompt' then
      util.debug('Left Telescope:', ev)
      require('lualine.dynamicMode').setGlobalMode('normal')
      -- require('lualine.dynamicMode').setGlobalMode('normal', true)
      -- toggleIcons(false)
    end

    -- util.debug('Winclosed event for buffer "' .. bufName .. '" (filetype ', ft .. ')')
  end
})

return M
