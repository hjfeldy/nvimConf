return {
  "Tsuzat/NeoSolarized.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local solarized = require('NeoSolarized')
      local hl = require('highlights')
      local style = hl.DARK and 'dark' or 'light'

      vim.o.background = style
      solarized.setup({
        style=style,
        -- style='dark',
        transparent=hl.DARK,
      })
      vim.cmd [[ colorscheme NeoSolarized ]]
      hl.setColors()
    end
}
