-- Terminal-Window / editor enhancements
local COLORSCHEME_PLUGIN = 'NeoSolarized.nvim'

--- Source project-local environment files in a newly opened neoWin terminal.
--- @param bufnr integer
local function sourceTerminalEnvironment(bufnr)
  local api = vim.api
  local terminal

  for _, candidate in ipairs(require('neoWin.terminals').getTerminalBufs(false)) do
    if candidate.bufNr == bufnr then
      terminal = candidate
      break
    end
  end

  if terminal == nil or not api.nvim_tabpage_is_valid(terminal.tabNum) then
    return
  end

  local tabnr = api.nvim_tabpage_get_number(terminal.tabNum)
  local win = api.nvim_tabpage_get_win(terminal.tabNum)
  local cwd = vim.fn.getcwd(api.nvim_win_get_number(win), tabnr)
  local paths = {
    vim.fs.joinpath(cwd, '.env'),
    vim.fs.joinpath(cwd, '.venv', 'bin', 'activate'),
  }
  local commands = {}

  for _, path in ipairs(paths) do
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == 'file' then
      commands[#commands + 1] = 'source ' .. vim.fn.shellescape(path)
    end
  end

  if #commands > 0 then
    api.nvim_chan_send(terminal.channel, table.concat(commands, ' && ') .. '\r')
  end
end

--- Return a wrapped function which calls lualine.refresh() after its execution
local function lualineWrapped(innerFunc)
  local wrapped = function(...)
    local out = innerFunc(...)
    require('lualine').refresh()
    return out
  end
  return wrapped
end


return {
  {
    "hjfeldy/neoWin",
    -- dir = "/home/harry/Repos/neowin",
    branch="feature/work",
    -- lazy=false,
    init = function()
      local group = vim.api.nvim_create_augroup('VimConfNeoWinTerminalEnvironment', { clear = true })
      vim.api.nvim_create_autocmd('TermOpen', {
        group = group,
        callback = function(ev)
          -- TermOpen fires from inside neoWin's jobstart(), before createTerm()
          -- has recorded the new terminal. Defer lookup until that call returns.
          vim.schedule(function()
            sourceTerminalEnvironment(ev.buf)
          end)
        end,
      })
    end,
    keys = {

      -- Directory navigation commands
      -- Wrap these in lualine.refresh() calls, because we display current-directory info with lualine
      -- If we wait for the periodic lualine refresh, there is a noticeable delay
      {"<leader>c", "", desc="+CD"},
      {
        "<leader>cc",
        lualineWrapped(function() require('neoWin.smartCD').smartCD(false) end),
        mode="n",
        desc="Change Directory to Current Buffer's"
      },
      {
        "<leader>cl",
        lualineWrapped(function() require('neoWin.smartCD').smartCD(true) end),
        mode="n",
        desc="Change Local-Window Directory to Current Buffer's"
      },
      {
        "<leader>cO", lualineWrapped(function() require('neoWin.smartCD').jumpBack(false) end),
        mode="n",
        desc="Change Local-Window to Previous Directory"
      },
      {
        "<leader>co", lualineWrapped(function() require('neoWin.smartCD').jumpBack(true) end),
        mode="n",
        desc="Change Local-Window to Previous Directory"
      },
      {
        "<leader>cI",
        lualineWrapped(function() require('neoWin.smartCD').jumpForwards(false) end),
        mode="n",
        desc="Change to Next Directory"
      },
      {
        "<leader>ci",
        lualineWrapped(function() require('neoWin.smartCD').jumpForwards(true) end),
        mode="n",
        desc="Change to Next Directory"
      },

      -- Terminal commands
      {"<leader>t", "", mode="n", desc="+Terminals"},
      {"<leader>tt", function() require('neoWin.terminals').newTerm() end, mode="n", desc="New Terminal"},
      {"<leader>tT", function() require('neoWin.customPicker').termPick() end, mode="n", desc="Telescope Terminal Picker"},
      {"<leader>tn", function() require('neoWin.terminals').nextTerm() end, mode="n", desc="Next Terminal"},
      {"<leader>tp", function() require('neoWin.terminals').prevTerm() end, mode="n", desc="Previous Terminal"},
      {"<leader>tr", function() require('neoWin.terminals').renameTerm() end, mode="n", desc="Rename Terminal"},
      {"<C-t>", function() require('neoWin.terminals').toggle() end, mode={"n", "t"}, desc="Toggle Terminal(s)"},

      -- Quitting
      {"q", "", mode="n", desc="+Quitting"},
      {"qw", function() require('neoWin.smartDelete').smartCloseWin() end, mode="n", desc="Close Window"},
      {"qW", function() require('neoWin.smartDelete').smartCloseWin(true) end, mode="n", desc="Force-Close Window"},
      {"qq", function() require('neoWin.smartDelete').smartDelete() end, mode="n", desc="Quit Buffer"},
      {"qf", function() require('neoWin.smartDelete').smartDelete(true) end, mode="n", desc="Force-Quit Buffer"},
      {"qr", function() require('neoWin.smartDelete').resetLastBufs() end, mode='n', desc='Force-Reset Buffer History'},

      {
        "<C-p>",
        function()
          require('highlights').toggleColor()
          require('lualine').refresh()
          vim.cmd('Lazy reload ' .. COLORSCHEME_PLUGIN)
        end,
        mode="n"
      }
    },
  }
}
