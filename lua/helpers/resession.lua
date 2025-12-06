local M = {}

--- Get a custom telescope finder for explicitly-saved sessions
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


--- Open a telescope picker with explicitly-saved sessions
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
