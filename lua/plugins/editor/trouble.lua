--- @require('trouble')

-- diagnostics
return {
  "folke/trouble.nvim",
  lazy=false,

  --- @type trouble.Config
  opts = {
    focus=true,
    follow = true,
    auto_preview = true,
    preview = {
      type = 'float',
      relative = 'editor',
      border = 'rounded',
      title = 'Preview',
      title_pos = 'center'
    }
  },
  cmd = "Trouble",
  keys = {
    {
      "<leader>x",
      "",
      desc = "+Trouble Diagnostics",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Global Diagnostics",
    },
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics",
    },
    {
      "<leader>xf",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List",
    },
    --[[ {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    }, ]]
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
  }
}

