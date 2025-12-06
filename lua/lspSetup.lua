local helpers = require('lspHelpers')
local util = require('lspconfig.util')

-- https://docs.basedpyright.com/v1.21.0/configuration/language-server-settings/
vim.lsp.config.basedpyright = {
  -- We override this because the default root_dir resolution will include fugitive buffers ("fugitive:///")
  -- which triggers some bug that causes the workspace to be interpreted as the root of the filesystem "/"
  -- completely freezing neovim entirely, such that you need to kill the process externally :/
  root_dir = function(fname, on_dir)
    local util = require("lspconfig.util")
    local root = util.root_pattern("pyproject.toml", "setup.py", ".git")(fname)
    if root == nil or root == "/" then
      return nil  -- don't attach at all
    end
    on_dir(root)
    return root
  end,
  -- root_dir = util.root_pattern("pyproject.toml", "setup.py", ".git"),
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        diagnosticMode = 'openFilesOnly'
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


vim.lsp.config.ts_ls = {
  settings = {
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
  -- 'jdtls',
  'basedpyright',
  'csharp_ls',
  'ts_ls'
})
