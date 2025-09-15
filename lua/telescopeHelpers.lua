local builtin = require('telescope.builtin')
local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local util = require('util')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local entry_maker = require('telescope.make_entry')
local conf = require('telescope.config').values
local lspHelpers = require('lspHelpers')
local dynamicMode = require('lualine.dynamicMode')
local extensions = require('telescope').extensions.dir


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

local function toggleIcons(on, withDiagnostics) 
  local mode = on and 'telescope' or nil
  util.debug('Toggling icons to state ' .. (mode or 'nil'))
  dynamicMode.setMode('showHiddenIcon', mode )
  dynamicMode.setMode('respectGitignore', mode)
  dynamicMode.setMode('telescopeIcon', mode)

  -- By default, diagnostics icon is always on.
  -- however, we want to turn it off when we open telescope,
  -- EXCEPT for when we're using telescope diagnostics
  if on and not withDiagnostics then
    dynamicMode.setMode('diagnosticsFilter', 'inactive')
  else 
    dynamicMode.setMode('diagnosticsFilter', nil)
  end
end


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
  dynamicMode.setGlobalMode('telescopeFiles', true)
  -- toggleIcons(true, false)
  -- require('lualine.dynamicMode').setMode('showHiddenIcon', nil)
  -- require('lualine.dynamicMode').setMode('respectGitignore', nil)
end

function M.dirFindFiles(args)
  require('lualine').refresh()
  args = args or {}
  if args.hidden == nil then
    args.hidden = M.SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not M.RESPECT_IGNORE
  end
  args.prompt_title = 'Find Files in a Directory (' .. util.renderHome() .. ')'
  extensions.find_files(args) 
end

function M.findFilesToggleHidden(prompt_bufnr)
  M.toggleHidden()
  local currentText = actionState.get_current_line()
  M.findFiles({default_text=currentText})
end

function M.findFilesToggleIgnore(prompt_bufnr)
  M.toggleIgnore()
  local currentText = actionState.get_current_line()
  M.findFiles({default_text=currentText})
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
  dynamicMode.setGlobalMode('telescopeFiles', true)
  -- toggleIcons(true, false)
end

function M.liveGrepToggleHidden(prompt_bufnr)
  M.toggleHidden()
  local currentText = actionState.get_current_line()
  M.liveGrep({default_text=currentText})
end

function M.liveGrepToggleIgnore(prompt_bufnr)
  M.toggleIgnore()
  local currentText = actionState.get_current_line()
  M.liveGrep({default_text=currentText})
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
  
  dynamicMode.setGlobalMode('telescopeDiagnostics', true)
  -- toggleIcons(true, true)
  builtin.diagnostics(args)
end

function M.diagnosticsToggleHints(prompt_bufnr)
  M.toggleHints()
  lspHelpers.toggleHints(M.WARNING_FILTER)
  -- builtin.diagnostic doesn't work with bufnr = 0
  -- args.bufnr = M.LOCAL_DIAGNOSTICS and 0 or nil

  local currentText = actionState.get_current_line()
  local diagnostics = vim.diagnostic.get(nil)
  local severityLimit = M.WARNING_FILTER and 2 or 4
  local hintCount = 0
  -- print('Got diagnostics:\n' .. vim.inspect(diagnostics))
  for _, item in ipairs(diagnostics) do
    if item.severity <= severityLimit then
      hintCount = hintCount + 1
    end
  end
  -- print('Got ' .. hintCount .. ' diagnostics past the severity threshold of ' .. severityLimit)
  local currentText = actionState.get_current_line()
  if hintCount == 0 then
    -- print('No warning/error diagnostics')
    return actions.close(prompt_bufnr)
  end
  M.diagnostics({bufnr=nil, default_text=currentText})

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
      dynamicMode.setGlobalMode('telescopeFiles', false)
      dynamicMode.setGlobalMode('telescopeDiagnostics', false)
      -- toggleIcons(false)
    end

    -- util.debug('Winclosed event for buffer "' .. bufName .. '" (filetype ', ft .. ')')
  end
})

return M
