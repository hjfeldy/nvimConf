local actionState = require("telescope.actions.state")
local actions = require("telescope.actions")
local builtin = require('telescope.builtin')

local util = require('util')
local telescopeUtil = require('helpers.telescope.utils')
local telescopeConf = require('helpers.telescope.config')

local LOGGER = require('neoWin.logger'):new('vimConf.helpers.telescope.pick')

local M = {}

--- If there is an existing telescope prompt,
--- extend the telescope prompt args with the current text and input-mode
--- @param args table
--- @param prompt_bufnr integer prompt buffer
--- @return table
function M.extendArgs(args, prompt_bufnr)
  local logger = LOGGER:withAttrs({logMethod="extendArgs"});
  local mode = vim.fn.mode() == 'n' and 'normal' or 'insert'
  args.initial_mode = mode
  local currentText = actionState.get_current_line()
  args.default_text = currentText
  local picker = actionState.get_current_picker(prompt_bufnr)
  local entry = actionState.get_selected_entry()

  logger:debug('PICKER: ' .. vim.inspect(picker))
  if picker ~= nil then
    args.cwd = picker.cwd
  end

  -- prefer entry's cwd if it exists (ie. for file-browser)
  if entry and entry.cwd then
    args.cwd = entry.cwd
  end

  return args
end


--- Generate args for a telescope file-finder (find_files or file_browser)
--- Show hidden/ignored files based on the current configuration
--- @param args table? Existing arguments (applicable if telescope is already open, and we're re-calling a finder function in response to a keypress)
--- @param prefix string Prefix for the prompt title
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
--- @return table
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
  local logger = LOGGER:withAttrs({logMethod="getFilebrowseArgs"});
  args = M.getFileArgs(args, 'File Browser', prompt_bufnr)
  args.depth = telescopeConf.FILE_DEPTH
  args.prompt_title = 'File Browser (' .. util.renderHome() .. ')'
  logger:debug('FILEBROWSER ARGS FOR PROMPT ' .. (vim.inspect(prompt_bufnr) or 'nil') .. ': ' .. vim.inspect(args))

  return prompt_bufnr ~= nil and M.extendArgs(args, prompt_bufnr) or args
end

--- Generate args for the telescope buffer-browser 
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.getBufferBrowserArgs(args, prompt_bufnr)
  args = args or {}
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
  local logger = LOGGER:withAttrs({logMethod="getDiagnosticsArgs"});
  args = args or {}
  if args.severity_limit == nil then
    args.severity_limit = telescopeConf.WARNING_FILTER and 'warn' or 'hint'
  end
  logger:debug('Set severity-limit to ' .. (args.severity_limit or "nil"))

  -- Keep track of whether or not the diagnostics prompt was opened for the current buffer vs the entire workspace
  -- When we call diagnosticsToggleHints, we will retain this option
  if telescopeConf.LOCAL_DIAGNOSTICS == nil then
    telescopeConf.LOCAL_DIAGNOSTICS = args.bufnr ~= nil
    logger:debug('Set LOCAL_DIAGNOSTICS to ' .. (telescopeConf.LOCAL_DIAGNOSTICS and 'true' or 'false'))
  elseif telescopeConf.LOCAL_DIAGNOSTICS then
    logger:debug('Using  LOCAL_DIAGNOSTICS value (setting bufnr = 0)')
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
  args = M.getBufferBrowserArgs(args, prompt_bufnr)
  if telescopeConf.SHOW_ALL_BUFFERS then
    require('telescope').load_extension('scope').buffers()
  else
    builtin.buffers(args)
  end
end

--- Browse open tabpages and switch to the selected tab.
--- @param args table? Telescope picker options
function M.tabpages(args)
  args = args or {}
  local api = vim.api
  local current_tab = api.nvim_get_current_tabpage()
  local entries = {}

  for _, tabpage in ipairs(api.nvim_list_tabpages()) do
    local tabnr = api.nvim_tabpage_get_number(tabpage)
    local ok, tab_name = pcall(api.nvim_tabpage_get_var, tabpage, 'name')
    local win = api.nvim_tabpage_get_win(tabpage)
    local bufnr = api.nvim_win_get_buf(win)
    local buffer_name = api.nvim_buf_get_name(bufnr)
    local cwd = api.nvim_win_call(win, vim.fn.getcwd)

    entries[#entries + 1] = {
      tabpage = tabpage,
      tabnr = tabnr,
      name = ok and tab_name or ('Tab ' .. tabnr),
      buffer = buffer_name == '' and '[No Name]' or vim.fn.fnamemodify(buffer_name, ':~:.'),
      cwd = vim.fn.fnamemodify(cwd, ':~'),
      current = tabpage == current_tab,
    }
  end

  require('telescope.pickers').new(args, {
    prompt_title = 'Tabpages',
    finder = require('telescope.finders').new_table({
      results = entries,
      entry_maker = function(entry)
        local marker = entry.current and '*' or ' '
        local display = string.format('%s %d: %s  %s  (%s)', marker, entry.tabnr, entry.name, entry.buffer, entry.cwd)
        return {
          value = entry,
          display = display,
          ordinal = table.concat({ entry.name, entry.buffer, entry.cwd, tostring(entry.tabnr) }, ' '),
        }
      end,
    }),
    sorter = require('telescope.config').values.generic_sorter(args),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = actionState.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and api.nvim_tabpage_is_valid(selection.value.tabpage) then
          api.nvim_set_current_tabpage(selection.value.tabpage)
        end
      end)
      return true
    end,
  }):find()
end

--- Browse filesystem with Telescope
--- @param args table? applicable
--- @param prompt_bufnr integer? The prompt_bufnr of the currently-open telescope prompt buffer (if we're re-calling)
function M.fileBrowser(args, prompt_bufnr)
  local logger = LOGGER:withAttrs({logMethod="fileBrowser"});
  require('lualine').refresh()
  args = M.getFilebrowseArgs(args, prompt_bufnr)
  logger:debug('Args: ' .. vim.inspect(args))
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

-- function M.buffers

return M
