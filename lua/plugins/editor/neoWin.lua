local util = require('util')
local toggleColor = require('toggleColor')

return {
  {
    "hjfeldy/neoWin",
    -- dir = '/home/harry/Repos/neowin',
    branch="feature/tpad",
    keys = {
      -- LSP 
      {"<leader>g", "", desc="+LSP"},
      {
        '<leader>gt',
        function() 
          require('lspHelpers').toggleHints() 
          require('telescopeHelpers').toggleHints()
        end,
        desc='Toggle LSP Diagnostic Level'
      },
      {
        "<leader>go",
        function()
          vim.lsp.buf.hover({border='rounded'})
        end,
        desc="Hover"
      },
      {
        "<leader>gr",
        '<cmd>Trouble lsp_references focus=true<CR>',
        --[[ function()
          vim.cmd('Trouble references focus=true')
        end, ]]
        desc="References"
      },
      {
        "<leader>gd",
        function()
          vim.lsp.buf.definition()
        end,
        desc="Goto Definition"
      },
      {
        "<leader>gi",
        function()
          vim.lsp.buf.implementation()
        end,
        desc="Goto Implementation"
      },
      {
        "<leader>gD",
        function()
          vim.diagnostic.open_float()
        end,
        desc="Open Diagnostics"
      },

      -- Terminal commands
      {"<leader>t", "", mode="n", desc="+Terminals"},
      {"<leader>tt", "<cmd>NewTerm<CR>", mode="n", desc="New Terminal"},
      {"<leader>tT", "<cmd>Terminals<CR>", mode="n", desc="Telescope Terminal Picker"},
      {"<leader>tn", "<cmd>NextTerm<CR>", mode="n", desc="Next Terminal"},
      {"<leader>tp", "<cmd>PrevTerm<CR>", mode="n", desc="Previous Terminal"},
      {"<leader>tr", "<cmd>RenameTerm<CR>", mode="n", desc="Rename Terminal"},
      {"<C-t>", "<cmd>ToggleTerm<CR>", mode={"n", "t"}, desc="Toggle Terminal(s)"},

      -- Window jumping/resizing
      {"-", "<cmd>resize -1<cr>", mode="n"},
      {"+", "<cmd>resize +1<cr>", mode="n"},
      {"<C-s>", "<cmd>vertical resize -1<cr>", mode="n"},
      {"<C-b>", "<cmd>vertical resize +1<cr>", mode="n"},
      {"<C-w>", "<C-\\><C-n>", mode="t"},
      {"<C-j>", "<C-w>j", mode="n"},
      {"<C-k>", "<C-w>k", mode="n"},
      {"<C-h>", "<C-w>h", mode="n"},
      {"<C-l>", "<C-w>l", mode="n"},
      {"<C-j>", "<C-\\><C-n><C-w>j", mode="t"},
      {"<C-k>", "<C-\\><C-n><C-w>k", mode="t"},
      {"<C-h>", "<C-\\><C-n><C-w>h", mode="t"},
      {"<C-l>", "<C-\\><C-n><C-w>l", mode="t"},
      {"<leader>v", "<cmd>vsplit<CR><C-w>l", mode="n", desc="Vertical Split"},

      -- Sane text-editing defaults
      {"J", "}", mode={"n", "x"}, desc="Jump Down"},
      {"K", "{", mode={"n", "x"}, desc="Jump Up"},
      {"<leader>j", "<cmd>cnext<CR>", mode="n", desc="Qfix next"},
      {"<leader>k", "<cmd>cprev<CR>", mode="n", desc="Qfix prev"},
      {"vv", "gv", mode="n", "Rehighlight"},
      {"<leader>J", "J", mode="n", desc="Merge Lines"},
      {"<leader>N", function() vim.o.hlsearch = not vim.o.hlsearch end, mode="n", desc="Toggle Highlight"},

      -- Quitting
      {"q", "", mode="n", desc="+Quitting"},
      {"qw", "<cmd>q<cr>", mode="n", desc="Close Window"},
      {"qq", function() require('neoWin.smartDelete').smartDelete() end, mode="n", desc="Quit Buffer"},
      {"qf", function() require('neoWin.smartDelete').smartDelete(true) end, mode="n", desc="Force-Quit Buffer"},
      
      {
        "<C-p>",
        function() 
          vim.cmd('Lazy reload NeoSolarized.nvim')
          require('highlights').setColors()
          require('lualine').refresh()
        end,
        mode="n" 
      }
    }
  }
}
