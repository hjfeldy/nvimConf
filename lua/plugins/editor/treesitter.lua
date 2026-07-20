local parsers = {
  "c",
  "python",
  "javascript",
  "typescript",
  "java",
  "c_sharp",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- The main-branch rewrite no longer consumes the old `ensure_installed`
    -- option. Avoid scheduling an async install task for every parser on each
    -- startup; `get_installed()` lets us call `install()` only when needed.
    local treesitter = require("nvim-treesitter")
    local installed = {}
    for _, parser in ipairs(treesitter.get_installed()) do
      installed[parser] = true
    end

    local missing = vim.tbl_filter(function(parser)
      return not installed[parser]
    end, parsers)

    if #missing > 0 then
      treesitter.install(missing)
    end
  end,
}
