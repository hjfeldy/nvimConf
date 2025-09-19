-- enhanced syntax-highlighting / navigation
return {
  "nvim-treesitter/nvim-treesitter",
  branch = 'master',
  lazy = false,
  build = ":TSUpdate",
  -- dependencies = { "OXY2DEV/markview.nvim" },
  ensure_installed = {
    "c",
    "python",
    "javascript",
    "typescript",
    "java",
    "csharp",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline"
  },
}
