-- Terminal-Window / editor enhancements

return {
  {
    -- "hjfeldy/neoWin",
    dir="/home/harry/Repos/neowin",
    branch="feature/work",
    lazy=false,
    keys = {

      -- Directory navigation commands
      {"<leader>c", "", desc="+CD"},
      {"<leader>cc", function() require('neoWin.smartCD').smartCD(false) end, mode="n", desc="Change Directory to Current Buffer's"},
      {"<leader>cl", function() require('neoWin.smartCD').smartCD(true) end, mode="n", desc="Change Local-Window Directory to Current Buffer's"},
      {"<leader>co", function() require('neoWin.smartCD').jumpBack() end, mode="n", desc="Change to Previous Directory"},
      {"<leader>ci", function() require('neoWin.smartCD').jumpForwards() end, mode="n", desc="Change to Next Directory"},

      -- Terminal commands
      {"<leader>t", "", mode="n", desc="+Terminals"},
      {"<leader>tt", function() require('neoWin.terminals').newTerm() end, mode="n", desc="New Terminal"},
      {"<leader>tT", function() require('neoWin.customPicker').termPick() end, mode="n", desc="Telescope Terminal Picker"},
      {"<leader>tn", function() require('neoWin.terminals').nextTerm() end, mode="n", desc="Next Terminal"},
      {"<leader>tp", function() require('neowin.terminals').prevTerm() end, mode="n", desc="Previous Terminal"},
      {"<leader>tr", function() require('neoWin.Terminals').renameTerm() end, mode="n", desc="Rename Terminal"},
      {"<C-t>", function() require('neoWin.terminals').toggle() end, mode={"n", "t"}, desc="Toggle Terminal(s)"},

      -- Quitting
      {"q", "", mode="n", desc="+Quitting"},
      {"qw", function() require('neoWin.smartDelete').smartCloseWin() end, mode="n", desc="Close Window"},
      {"qW", function() require('neoWin.smartDelete').smartCloseWin(true) end, mode="n", desc="Force-Close Window"},
      {"qq", function() require('neoWin.smartDelete').smartDelete() end, mode="n", desc="Quit Buffer"},
      {"qf", function() require('neoWin.smartDelete').smartDelete(true) end, mode="n", desc="Force-Quit Buffer"},
      
      {
        "<C-p>",
        function() 
          require('highlights').toggleColor()
          require('lualine').refresh()
        end,
        mode="n" 
      }
    }
  }
}
