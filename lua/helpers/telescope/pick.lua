local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local builtin = require('telescope.builtin')

local util = require('util')
local telescopeUtil = require('helpers.telescope.utils')
local telescopeConf = require('helpers.telescope.config')

local M = {}

--- If there is an existing telescope prompt,
--- extend the telescope prompt args with the current text and input-mode
--- @param args table
--- @param prompt_bufnr integer prompt buffer
function M.extendArgs(args, prompt_bufnr)
  local mode = vim.fn.mode() == 'n' and 'normal' or 'insert'
  args.initial_mode = mode
  local currentText = actionState.get_current_line()
  args.default_text = currentText
  local picker = actionState.get_current_picker(prompt_bufnr)
  local entry = actionState.get_selected_entry()

  util.debug('PICKER: ' .. vim.inspect(picker))
  if picker ~= nil then
    print('Setting CWD')
    args.cwd = picker.cwd
  end

  -- prefer entry's cwd if it exits
  if entry then
    print('Entry: ' .. vim.inspect(entry))
    args.cwd = entry.cwd
  end
  print('Augmented Args: ' .. vim.inspect(args))

  return args
end


--- Generate args for a telescope file-finder (find_files or file_browser)
--- Show hidden/ignored files based on the current configuration
--- @param args table? Existing arguments (applicable if telescope is already open, and we're re-calling a finder function in response to a keypress)
--- @param prefix string Prefix for the prompt title
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.getFileArgs(args, prefix, prompt_bufnr)
  args = args or {}
  if args.hidden == nil then
    args.hidden = telescopeConf.SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not telescopeConf.RESPECT_IGNORE
  end

  args.prompt_title = prefix .. ' (' .. util.renderHome() .. ')'
  return prompt_bufnr ~= nil and M.extendArgs(args, prompt_bufnr) or args
end


--- Generate args for the telescope file-browser (extend getFileArgs() output)
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.getFilebrowseArgs(args, prompt_bufnr)
  args = M.getFileArgs(args, 'File Browser', prompt_bufnr)
  args.depth = telescopeConf.FILE_DEPTH
  args.prompt_title = 'File Browser (' .. util.renderHome() .. ')'
  util.debug('FILEBROWSER ARGS FOR PROMPT ' .. (vim.inspect(prompt_bufnr) or 'nil') .. ': ' .. vim.inspect(args))

  return prompt_bufnr ~= nil and M.extendArgs(args, prompt_bufnr) or args
end


--- Generate args for telescope live_grep 
--- (same logic as getFileArgs, but live_grep args expect different format with "additional_args")
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.getLiveGrepArgs(args, prompt_bufnr)
  args = args or {}
  local additional_args = args.additional_args or {}
  if telescopeConf.SHOW_HIDDEN then
    additional_args[#additional_args+1] = "--hidden"
  end
  if not telescopeConf.RESPECT_IGNORE then
    additional_args[#additional_args+1] = "--no-ignore"
  end
  args.additional_args = additional_args
  args.prompt_title = 'Live Grep (' .. util.renderHome() .. ')'
  return prompt_bufnr ~= nil and M.extendArgs(args, prompt_bufnr) or args
end


--- Generate args for telescope diagnostics
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.getDiagnosticsArgs(args, prompt_bufnr)
  args = args or {}
  if args.severity_limit == nil then
    args.severity_limit = telescopeConf.WARNING_FILTER and 'warn' or 'hint'
  end
  util.debug('Set severity-limit to ' .. (args.severity_limit or "nil"))

  -- Keep track of whether or not the diagnostics prompt was opened for the current buffer vs the entire workspace
  -- When we call diagnosticsToggleHints, we will retain this option
  if telescopeConf.LOCAL_DIAGNOSTICS == nil then
    telescopeConf.LOCAL_DIAGNOSTICS = args.bufnr ~= nil
    util.debug('Set LOCAL_DIAGNOSTICS to ' .. (telescopeConf.LOCAL_DIAGNOSTICS and 'true' or 'false'))
  elseif telescopeConf.LOCAL_DIAGNOSTICS then
    util.debug('Using  LOCAL_DIAGNOSTICS value (setting bufnr = 0)')
    args.bufnr = 0
  end

  return prompt_bufnr ~= nil and M.extendArgs(args, prompt_bufnr) or args
end


-- TELESCOPE PICKER-OPENERS 

--- Find-files with Telescope
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.findFiles(args, prompt_bufnr)
  require('lualine').refresh()
  args = M.getFileArgs(args, 'Find Files', prompt_bufnr)
  builtin.find_files(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end

function M.browseBuffers(args, prompt_bufnr) 
  args = M.extendArgs(args or {})
  builtin.buffers(args)
end

--- Browse filesystem with Telescope
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.fileBrowser(args, prompt_bufnr)
  require('lualine').refresh()
  args = M.getFilebrowseArgs(args, prompt_bufnr)
  util.debug('Args: ' .. vim.inspect(args))
  require("telescope").extensions.file_browser.file_browser(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end


--- Live-Grep with Telescope
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.liveGrep(args, prompt_bufnr)
  args = M.getLiveGrepArgs(args, prompt_bufnr)
  builtin.live_grep(args)
  telescopeUtil.setLualineMode('telescopeFiles')
end

--- Browse buffer/workspace diagnostics with Telescope
--- (according to the current LOCAL_DIAGNOSTICS configuraiton,
--- whose toggle-function should be bound to some key)
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.diagnostics(args, prompt_bufnr)
  args = M.getDiagnosticsArgs(args, prompt_bufnr)
  if prompt_bufnr ~= nil then
    -- Close the current prompt, or else the 0 bufNr points to the telescope prompt buffer itself
    -- this will trigger the autocmd at the bottom of this file (resetting LOCAL_DIAGNOSTICS to nil), 
    -- so we need to explicitly undo that trigger - kinda gross
    -- This could all be avoidable if we could specify a specific buffer to open the diagnostics in
    -- But the bufnr parameter is documented incorrectly 
    -- it either opens diagnostics for the entire workspace (bufnr=nil), or the current buffer (bufnr~=nil)
    local preClose = telescopeConf.LOCAL_DIAGNOSTICS
    actions.close(prompt_bufnr)
    telescopeConf.LOCAL_DIAGNOSTICS = preClose
  end

  local numDiagnostics = telescopeUtil.diagnosticCount(args.bufnr ~= nil)
  if numDiagnostics > 0 then
    telescopeUtil.setLualineMode('telescopeDiagnostics')
  end
  builtin.diagnostics(args)
end

return M
