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
    vim.treesitter.language.register("c_sharp", "cs")

    -- The main-branch rewrite no longer consumes the old `ensure_installed`
    -- option. `install()` is asynchronous and a no-op for installed parsers.
    require("nvim-treesitter").install(parsers)
  end,
}
