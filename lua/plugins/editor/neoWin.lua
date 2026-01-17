-- Terminal-Window / editor enhancements
local COLORSCHEME_PLUGIN = 'NeoSolarized.nvim'

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
    -- dir="/home/harry/Repos/neowin",
    branch="feature/work",
    -- lazy=false,
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
      {"<leader>tr", function() require('neoWin.Terminals').renameTerm() end, mode="n", desc="Rename Terminal"},
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
    }
  }
}
