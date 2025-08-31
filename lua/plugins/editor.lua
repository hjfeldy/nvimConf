return {
  {
    "numToStr/Comment.nvim",
    opts = function()
      return {
        toggler = {
          line = '<leader>l',
        },
        opleader = {
          block = '<leader>l',
        }
      }
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
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
}



