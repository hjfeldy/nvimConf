local function getFinder(results)
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


local function pickSession(opts)
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
    finder = getFinder(),
    -- luacheck: push no unused args
    attach_mappings = function(prompt_bufnr, map)
      -- map('<C-e>',
      actions.select_default:replace(
        function()
          local action_state = require "telescope.actions.state"
          local entry = action_state.get_selected_entry()
          resession.load(entry.value, {dir='explicit'})
        end
      )
      return true
    end,
    -- luacheck: pop
  }):find()
end


local function saveSesh()
  local seshName = vim.fn.input({prompt='Session Name'})
  require('resession').save(seshName, {dir='explicit'}) 
end

vim.api.nvim_create_user_command('SaveSession', saveSesh, {nargs=0})
vim.api.nvim_create_user_command('LoadSession', pickSession, {nargs=0})

return {
  "stevearc/resession.nvim",
  keys = {
    {
      '<C-s>',
      saveSesh,
      desc='Save Session'
    },
    {
      '<C-^>',
      pickSession,
      desc='Load Session'
    },
  },
  opts = {
    -- override default filter
    buf_filter = function(bufnr)
      local filetype = vim.api.nvim_get_option_value('filetype', {buf=bufnr})
      if filetype == 'Terminal' or filetype == 'fugitive' then
        return false
      end

      local buftype = vim.bo[bufnr].buftype
      if buftype == 'help' then
        return true
      end
      if buftype ~= "" and buftype ~= "acwrite" then
        return false
      end
      if vim.api.nvim_buf_get_name(bufnr) == "" then
        return false
      end

      -- this is required for scope.nvim, since the default filter skips nobuflisted buffers
      return true
    end,
    extensions = {
      bufferline = {},
      scope = {}
    } 
  }
}
