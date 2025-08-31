local util = require('util')

return {
  {
    "hjfeldy/neoWin",
    branch="feature/tpad",
    keys = {
      -- LSP 
      {
        "<leader>go",
        function()
          vim.lsp.buf.hover({border='rounded'})
        end
      },
      {
        "<leader>gd",
        function()
          vim.lsp.buf.definition()
        end
      },
      {
        "<leader>gi",
        function()
          vim.lsp.buf.implementation()
        end
      },
      {
        "<leader>gD",
        function()
          vim.diagnostic.open_float()
        end
      },

      -- Terminal commands
      {"<leader>tt", "<cmd>NewTerm<CR>", mode="n"},
      {"<leader>tn", "<cmd>NextTerm<CR>", mode="n"},
      {"<leader>tp", "<cmd>PrevTerm<CR>", mode="n"},
      {"<leader>tr", "<cmd>RenameTerm<CR>", mode="n"},
      {"<C-t>", "<cmd>ToggleTerm<CR>", mode={"n", "t"}},

      -- Window-jumping
      {"<C-w>", "<C-\\><C-n>", mode="t"},
      {"<C-j>", "<C-w>j", mode="n"},
      {"<C-k>", "<C-w>k", mode="n"},
      {"<C-h>", "<C-w>h", mode="n"},
      {"<C-l>", "<C-w>l", mode="n"},
      {"<C-j>", "<C-\\><C-n><C-w>j", mode="t"},
      {"<C-k>", "<C-\\><C-n><C-w>k", mode="t"},
      {"<C-h>", "<C-\\><C-n><C-w>h", mode="t"},
      {"<C-l>", "<C-\\><C-n><C-w>l", mode="t"},

      {"<leader>v", "<cmd>vsplit<cr><C-l>", mode="n"},

      -- Sane text-editing defaults
      {"J", "}", mode={"n", "x"}},
      {"K", "{", mode={"n", "x"}},
      {"<leader>J", "J", mode="n"},
      {"<leader>n", function() vim.o.hlsearch = not vim.o.hlsearch end, mode="n"},

      -- Quitting
      {"q", "", mode="n"},
      {"qq", "<cmd>bdelete<cr>", mode="n"},
      {"qq", "<cmd>bdelete<cr>", mode="n"},
      {"qw", "<cmd>q<cr>", mode="n"},
      {"<leader>q", "<cmd>q!<cr>", mode="n"},
    }
  }
}
