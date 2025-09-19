local api = vim.api
local util = require('util')

-- go to last known cursor position when opening a file
api.nvim_create_autocmd('BufReadPost', {
  pattern = { '*' },
  callback = function()
    vim.cmd("normal! '\"");
  end
})

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
      local name = api.nvim_buf_get_name(buf)
      if string.len(name) == 0 and listed then
        api.nvim_buf_delete(buf, {})
        return
      end
    end
  end
})

-- quit when deleting the last buffer
-- api.nvim_create_autocmd('BufDelete', {
--   pattern = { '*' },
--   callback = function(event)
--     util.debug('Event:', event)
--     local bufs = api.nvim_list_bufs()
--     local namedBufs = 0
--     for i, buf in ipairs(bufs) do
--       local bufName = api.nvim_buf_get_name(buf)
--       local bufListed = api.nvim_get_option_value('buflisted', {buf=buf})
--       local ft = api.nvim_get_option_value('filetype', {buf=buf})
--       if buf ~= event.buf 
--       and bufName ~= '[No Name]'
--       and #bufName > 0 
--       and (bufListed or ft == 'Terminal')
--       then
--         namedBufs = namedBufs+1
--       end
--     end
--     if namedBufs == 0 then
--       print('Quitting!')
--       vim.cmd('qa')
--     end
--     print(vim.inspect(namedBufs))
--   end
-- })
