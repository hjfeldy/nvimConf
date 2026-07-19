local function setupNeowin() 
  -- print('SETTING UP NEOWIN')
  local neoConf = require('neoconf')
  -- print('NEOCONF: ' .. vim.inspect(neoConf.get()))
  local neoConfig = require('neoconf').get('neoWin')
  require('neoWin.settings').setup(neoConfig)
  -- require('neoWin.logger').refreshAll()
end

return {
  "folke/neoconf.nvim",
  config=function() 
    require('neoconf').setup({})
    require('neoconf.plugins').register({
      name='neoWin',
      setup = setupNeowin,
      -- on_schema = setupNeowin,
      on_update=setupNeowin
    })
  end
  -- opts = function() 
  --   require('neoconf.plugins').register({
  --     name='neoWin',
  --     setup = setupNeowin,
  --     on_schema = setupNeowin,
  --     on_update=setupNeowin
  --   })
  -- end
  }
