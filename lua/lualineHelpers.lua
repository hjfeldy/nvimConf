-- Idea for dynamically shortening components (specifying a "shortVersion" in each component) 
-- not currently working with the trouble.statusline component, which is the most killer feature...

local util = require('util')
local telescopeHelpers = require('telescopeHelpers')
local icons = require('icons')
local Snacks = require('snacks')
local trouble = require('trouble')
local api = vim.api
local lualine = require('lualine')

local M = {}


function M.getStatus()
  local stat = vim.o.statusline
  return string.gsub(stat, '%%#%S*#', ''):gsub('%%<', ''):gsub('%%%*', ''):gsub('%%%%', '%')
end

vim.api.nvim_create_autocmd('WinEnter', {
  pattern = {'*'},
  callback = function(ev)
    local stat = M.getStatus()
  end
});

-- local _refresh = lualine.refresh
-- lualine.refresh = function() 
--   _refresh()
--   local stat = M.getStatus()
--   if #stat > vim.api.nvim_win_get_width(0) then
--     -- util.debug('too long!')
--     -- require('lualine.dynamicMode').setGlobal('short', true)
--   else
--     -- util.debug('not too long')
--     -- require('lualine.dynamicMode').setGlobal('short', false)
--   end
--   -- util.debug('Refreshed - status length =', #stat, 'status =', stat)
-- end

return M
