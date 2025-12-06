local api = vim.api
local util = require('util')
local resession = require('resession')
local telescopeUtils = require('helpers.telescope.utils')
local telescopeConf = require('helpers.telescope.config')
local terms = require('neoWin.terminals')

-- clear fugitive buffers when their windows are deleted
api.nvim_create_autocmd('BufReadPost', {
  pattern = { 'fugitive://*' },
  callback = function()
    vim.o.bufhidden = 'delete'
  end
})

-- For Markview (is this necessary?)
-- api.nvim_create_autocmd('BufReadPost', {
--   pattern = { '*.md' },
--   callback = function()
--     vim.cmd('TSBufEnable highlight')
--   end
-- })

api.nvim_create_autocmd('BufReadPost', {
  pattern = { '*' },
  callback = function()
    for _, buf in ipairs(api.nvim_list_bufs()) do
      local bo = vim.bo[buf]
      local name = api.nvim_buf_get_name(buf)
      if string.len(name) == 0 and bo.buflisted and bo.filetype ~= 'qf' then
        util.debug('deleting empty buffer')
        api.nvim_buf_delete(buf, {})
        return
      end
    end
  end
})

-- Load Session for the current directory at startup
-- (if no cmdline args were passed to nvim)
local ENTERED_CWD = nil
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only load the session if nvim was started with no args and without reading from stdin
    if vim.fn.argc(-1) == 0 and not vim.g.using_stdin then
      local cwd = vim.fn.getcwd()
      ENTERED_CWD = cwd
      resession.load(cwd, { silence_errors = true })
    end
  end,
  nested = true,
})

-- Save Session for the current directory at shutdown
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    resession.save(ENTERED_CWD or vim.fn.getcwd(), { notify = false })
  end,
})

-- Record that a cmdline arg was passed to Neovim
vim.api.nvim_create_autocmd('StdinReadPre', {
  callback = function()
    -- Store this for later
    vim.g.using_stdin = true
  end,
})

--- Keep track of whether or not a fugitive window (git status, git log, etc) is open in each tab
--- This allows us to close and reopen the terminal window whenever a fugitive window
--- @type { [integer]: boolean }
local FUGITIVE_STATUS = {}

--- Reopen the terminal window when fugitive windows are closed 
--- (only if the fugitive window triggered an auto-close of the terminal window when it was opened)
vim.api.nvim_create_autocmd('WinClosed', {
  pattern = {'*'},
  callback = function(ev)
    local tab = vim.api.nvim_get_current_tabpage()
    local fugitiveStatus = FUGITIVE_STATUS[tab] and FUGITIVE_STATUS[tab]
    local bufType = vim.bo[ev.buf].filetype
    if bufType == 'fugitive' and fugitiveStatus then
      terms.toggle()
      FUGITIVE_STATUS[tab] = false
    end

  end
})

--- Close the terminal window (if its open) whenever a fugitive window is opened
vim.api.nvim_create_autocmd('User', {
  pattern = {'FugitiveEditor', 'FugitiveIndex', 'FugitivePager'},
  callback = function(ev)
    print('Caught fugitive event:\n' .. vim.inspect(ev))
    local firstWindowId = terms.firstWindowId()
    local tab = vim.api.nvim_get_current_tabpage()
    if firstWindowId ~= nil then
      terms.toggle()
      FUGITIVE_STATUS[tab] = true
    end
  end
})

--- Whenever leaving a telescope prompt, turn off all dynamic lualine icons
vim.api.nvim_create_autocmd('WinLeave', {
  pattern = {'*'},
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype

    if ft == 'TelescopeResults' or ft == 'TelescopePrompt' then
      util.debug('Left Telescope:', ev)
      telescopeUtils.unsetLualineMode('telescopeFiles')
      telescopeUtils.unsetLualineMode('telescopeDiagnostics')
      if telescopeConf.LOCAL_DIAGNOSTICS ~= nil then
        util.debug('Resetting LOCAL_DIAGNOSTICS') 
      end

      telescopeConf.LOCAL_DIAGNOSTICS = nil
    end
  end
})
