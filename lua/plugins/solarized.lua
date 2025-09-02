return {
  "Tsuzat/NeoSolarized.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local solarized = require('NeoSolarized')
      local toggler = require('toggleColor')
      local style = toggler.toggle()
      vim.o.background = style
      solarized.setup({
        style=style,
        -- style='dark',
        transparent=toggler.DARK,
      })
      vim.cmd [[ colorscheme NeoSolarized ]]
    end
}
