local helpers = require('lspHelpers')

-- https://docs.basedpyright.com/v1.21.0/configuration/language-server-settings/
vim.lsp.config.basedpyright = {
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        diagnosticMode = 'workspace'
      }
    }
  }
}


-- https://luals.github.io/wiki/configuration/
vim.lsp.config.lua_ls = {
  
  settings = {
    Lua = {
      diagnostics = {
        enable = true
      }
    }
  }
}

vim.lsp.config.jdtls = {
  settings = {
    java = {
    }
  }
}

vim.lsp.enable({
  'lua_ls',
  'jdtls',
  'basedpyright',
  'csharp_ls'
})
