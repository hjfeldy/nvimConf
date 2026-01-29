-- Individual LSP configurations

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
      verboseOutput=true,
      analysis = {
        autoImportCompletions = true,
        diagnosticMode = 'openFilesOnly',
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

-- Configure per-project with tsconfig.json
vim.lsp.config.ts_ls = {
  settings = {
  }
}

-- use ftplugin, as per the docs - do not use native LSP
-- vim.lsp.config.jdtls = {
--   settings = {
--     java = {
--     }
--   }
-- }


---@type vim.lsp.Config
vim.lsp.config.csharp_ls = {
  settings = {
    ["csharp.applyFormattingOptions"] = true,
    csharp = {
      applyFormattingOptions = true
    }
  }
}

-- vim.lsp.log.set_level(vim.lsp.log.levels.DEBUG)

if vim.g.NO_LSP then
  print('Neglecting to enable LSP - it is disabled globally')
else
  vim.lsp.enable({
    'lua_ls',
    -- 'jdtls', <- see above
    'basedpyright',
    'csharp_ls',
    'ts_ls'
  })
end
