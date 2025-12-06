local api = vim.api
local util = require('util')
local resession = require('resession')
local telescopeUtils = require('helpers.telescope.utils')
local telescopeConf = require('helpers.telescope.config')

-- clear fugitive buffers when 
api.nvim_create_autocmd('BufReadPost', {
  pattern = { 'fugitive://*' },
  callback = function()
    vim.o.bufhidden = 'delete'
  end
})

api.nvim_create_autocmd('BufReadPost', {
  pattern = { '*.md' },
  callback = function()
    vim.cmd('TSBufEnable highlight')
  end
})

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
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    resession.save(ENTERED_CWD or vim.fn.getcwd(), { notify = false })
  end,
})
vim.api.nvim_create_autocmd('StdinReadPre', {
  callback = function()
    -- Store this for later
    vim.g.using_stdin = true
  end,
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
