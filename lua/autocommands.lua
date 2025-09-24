local api = vim.api
local util = require('util')
local resession = require('resession')

-- go to last known cursor position when opening a file
-- api.nvim_create_autocmd('BufReadPost', {
--   pattern = { '*' },
--   callback = function()
--     if vim.o.filetype ~= 'fugitive' then
--       vim.cmd("normal! '\"");
--     end
--   end
-- })

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
      local listed = api.nvim_get_option_value('buflisted', {buf=buf})
      local ftype = api.nvim_get_option_value('filetype', {buf=buf})
      local name = api.nvim_buf_get_name(buf)
      if string.len(name) == 0 and listed and ftype ~= 'qf' then
        api.nvim_buf_delete(buf, {})
        return
      end
    end
  end
})


vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only load the session if nvim was started with no args and without reading from stdin
    if vim.fn.argc(-1) == 0 and not vim.g.using_stdin then
      resession.load(vim.fn.getcwd(), { silence_errors = true })
    end
  end,
  nested = true,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    resession.save(vim.fn.getcwd(), { notify = false })
  end,
})
vim.api.nvim_create_autocmd('StdinReadPre', {
  callback = function()
    -- Store this for later
    vim.g.using_stdin = true
  end,
})
