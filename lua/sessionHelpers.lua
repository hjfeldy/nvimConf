local M = {}
local util = require('util')

function M.getFinder(results)
  local finders = require('telescope.finders')
  local resession = require('resession')
  local sessions = resession.list({dir='explicit'})

  return finders.new_table {
    results = sessions,
    entry_maker = function(entry)
      print('Making entry: ' .. vim.inspect(entry))
      return {
        value=entry,
        display=entry,
        ordinal=entry
      }
    end
  }
end


function M.wipeout()
  local tabs = vim.api.nvim_list_tabpages()
  local bufs = vim.api.nvim_list_bufs()
  local currTab = vim.api.nvim_get_current_tabpage()
  local newBuf = vim.api.nvim_create_buf(true, false)
  util.debug('Created new dummy buffer: ' .. newBuf)
  vim.api.nvim_win_set_buf(0, newBuf)
  local currBuf = vim.api.nvim_get_current_buf()
  util.debug('Current tab: ' .. currTab)
  util.debug('Current buf: ' .. currBuf)
  util.debug('Old tabs: ' .. vim.inspect(tabs))
  util.debug('Old bufs: ' .. vim.inspect(bufs))

  for _, tab in ipairs(tabs) do
    if tab ~= currTab then
      local tabIndex = vim.api.nvim_tabpage_get_number(tab)
      util.debug('Deleting tab ' .. tab .. '(tabIndex ' .. tabIndex .. ')')
      vim.cmd('tabclose ' .. tabIndex)
    end
  end
  for _, buf in ipairs(bufs) do
    if buf ~= currBuf then
      util.debug('Deleting buf ' .. buf)
      vim.api.nvim_buf_delete(buf, {force=true})
    end
  end
  vim.cmd('Lazy reload bufferline.nvim')
end

function M.pickSession(opts)
  local pickers = require('telescope.pickers')
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  opts = opts or {}

  opts.dynamic_preview_title = true
  local resession = require('resession')
  pickers.new(opts, {
    selection_strategy='reset',
    prompt_title = "Sessions",
    sorter = conf.generic_sorter(opts),
    finder = M.getFinder(),
    -- luacheck: push no unused args
    attach_mappings = function(prompt_bufnr, map)
      -- map('<C-e>',
      actions.select_default:replace(
        function()
          local actions = require "telescope.actions"
          local action_state = require "telescope.actions.state"
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          -- M.wipeout()
          resession.load(entry.value, {dir='explicit'})
        end
      )
      return true
    end,
    -- luacheck: pop
  }):find()
end


function M.saveSesh()
  local seshName = vim.fn.input({prompt='Session Name'})
  require('resession').save(seshName, {dir='explicit'}) 
end

vim.api.nvim_create_user_command('SaveSession', M.saveSesh, {nargs=0})
vim.api.nvim_create_user_command('LoadSession', M.pickSession, {nargs=0})

return M
