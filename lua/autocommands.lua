local api = vim.api

local group = api.nvim_create_augroup('VimConfAutocommands', { clear = true })

-- Clear fugitive and man buffers when their windows are deleted.
api.nvim_create_autocmd('BufReadPost', {
  group = group,
  pattern = { 'fugitive://*', 'man://*' },
  callback = function(ev)
    vim.bo[ev.buf].bufhidden = 'delete'
  end,
})

api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = '*',
  callback = function(ev)
    -- Some 0.12 runtime ftplugins enable Treesitter themselves. Avoid
    -- replacing an existing highlighter when they do, or when FileType is
    -- emitted again for a buffer.
    if vim.treesitter.highlighter.active[ev.buf] then return end

    -- Missing parsers and highlight queries are expected for filetypes not in
    -- the configured parser set. Native start() reports those as errors, so
    -- leave those buffers on their normal syntax highlighter quietly.
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- Neovim starts with a single unnamed buffer. Delete that specific placeholder
-- after another buffer is read instead of scanning every buffer on every read.
local initial_buffer = api.nvim_get_current_buf()
api.nvim_create_autocmd('BufReadPost', {
  group = group,
  pattern = '*',
  callback = function(ev)
    if not initial_buffer then return end

    if ev.buf == initial_buffer then
      initial_buffer = nil
      return
    end

    local buf = initial_buffer
    initial_buffer = nil
    if api.nvim_buf_is_valid(buf)
        and api.nvim_buf_get_name(buf) == ''
        and vim.bo[buf].buflisted
        and vim.bo[buf].filetype ~= 'qf' then
      api.nvim_buf_delete(buf, {})
    end
  end,
})

-- Load the session for the current directory at startup when no command-line
-- arguments were passed and Neovim is not reading stdin.
local entered_cwd
local session_load_pending = false
local session_load_failed = false
local exiting = false

local function name_initial_tab()
  if #api.nvim_list_tabpages() == 1 and vim.t[0].name == nil then
    api.nvim_tabpage_set_var(0, 'name', 'Tab 1')
  end
end

api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    -- StdinReadPre runs before VimEnter. Preserve that signal rather than
    -- overwriting it when stdin was supplied without any file arguments.
    vim.g.using_stdin = vim.g.using_stdin == true or vim.fn.argc(-1) ~= 0
    if not vim.g.using_stdin then
      entered_cwd = vim.fn.getcwd()
      session_load_pending = true
      -- Let Neovim draw its first frame before restoring what may be a large
      -- session. Keep the startup cwd captured above: a scheduled callback may
      -- otherwise observe a directory changed by another startup callback.
      vim.schedule(function()
        if exiting then return end

        local ok, err = pcall(function()
          require('resession').load(entered_cwd, { silence_errors = true })
        end)
        session_load_pending = false
        if not ok then
          -- A failed load may already have replaced part of the editor state.
          -- Never overwrite the saved session with that partial restoration.
          session_load_failed = true
          vim.notify(('Unable to restore session: %s'):format(err), vim.log.levels.ERROR)
        end
        name_initial_tab()
      end)
    else
      name_initial_tab()
    end
  end,
  nested = true,
})

api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = function()
    exiting = true
    -- If VimLeavePre beats the scheduled load, saving the initial empty state
    -- would destroy the session that was about to be restored.
    if vim.g.using_stdin or session_load_pending or session_load_failed then return end
    require('resession').save(entered_cwd or vim.fn.getcwd(), { notify = false })
  end,
})

api.nvim_create_autocmd('StdinReadPre', {
  group = group,
  callback = function()
    vim.g.using_stdin = true
  end,
})

-- Only the fugitive window which caused a terminal to close should reopen it.
-- WinClosed supplies a window id in ev.match; ev.buf is not the closed window's
-- buffer, so record the relevant window and tab when Fugitive emits its event.
local fugitive_windows = {}

api.nvim_create_autocmd('WinClosed', {
  group = group,
  pattern = '*',
  callback = function(ev)
    local win = tonumber(ev.match)
    local tab = win and fugitive_windows[win]
    if not tab then return end

    fugitive_windows[win] = nil
    -- WinClosed may be emitted while closing a window in an inactive tab (or
    -- while closing the tab itself). The terminal API is scoped to the current
    -- tab, so never let that event toggle terminals in an unrelated tab.
    if not api.nvim_tabpage_is_valid(tab) or api.nvim_get_current_tabpage() ~= tab then
      return
    end
    require('neoWin.terminals').toggle()
  end,
})

api.nvim_create_autocmd('User', {
  group = group,
  pattern = { 'FugitiveEditor', 'FugitiveIndex', 'FugitivePager' },
  callback = function()
    local terms = require('neoWin.terminals')
    if terms.firstWindowId() == nil then return end

    local win = api.nvim_get_current_win()
    fugitive_windows[win] = api.nvim_get_current_tabpage()
    terms.toggle()
    vim.schedule(function()
      if api.nvim_win_is_valid(win) then
        api.nvim_win_call(win, function()
          vim.cmd.resize(math.floor(0.5 * vim.o.lines))
        end)
      end
    end)
  end,
})

-- Whenever leaving a Telescope prompt, turn off all dynamic lualine icons.
api.nvim_create_autocmd('WinLeave', {
  group = group,
  pattern = '*',
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft ~= 'TelescopeResults' and ft ~= 'TelescopePrompt' then return end

    local telescope_utils = require('helpers.telescope.utils')
    local telescope_conf = require('helpers.telescope.config')
    telescope_utils.unsetLualineMode('telescopeFiles')
    telescope_utils.unsetLualineMode('telescopeDiagnostics')
    telescope_conf.LOCAL_DIAGNOSTICS = nil
  end,
})
