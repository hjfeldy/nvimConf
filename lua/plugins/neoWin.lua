return {
  {
    "hjfeldy/neoWin",
    branch="feature/tpad",
    keys = {
      {"<leader>tt", "<cmd>NewTerm<CR>", mode="n"},
      {"<leader>tn", "<cmd>NextTerm<CR>", mode="n"},
      {"<leader>tp", "<cmd>PrevTerm<CR>", mode="n"},
      {"<leader>tr", "<cmd>RenameTerm<CR>", mode="n"},

      {"<C-t>", "<cmd>ToggleTerm<CR>", mode={"n", "t"}},
      {"<C-w>", "<C-\\><C-n>", mode="t"},
      {"<C-j>", "<C-w>j", mode="n"},
      {"<C-k>", "<C-w>k", mode="n"},
      {"<C-h>", "<C-w>h", mode="n"},
      {"<C-l>", "<C-w>l", mode="n"},
      {"<C-j>", "<C-\\><C-n><C-w>j", mode="t"},
      {"<C-k>", "<C-\\><C-n><C-w>k", mode="t"},
      {"<C-h>", "<C-\\><C-n><C-w>h", mode="t"},
      {"<C-l>", "<C-\\><C-n><C-w>l", mode="t"},

      {"<leader>v", "<cmd>vsplit<cr>", mode="n"},

      {"qq", "<cmd>bdelete<cr>", mode="n"},
      {"qw", "<cmd>q<cr>", mode="n"},
      {"<leader>q", "<cmd>q!<cr>", mode="n"},
    }
  }
}
