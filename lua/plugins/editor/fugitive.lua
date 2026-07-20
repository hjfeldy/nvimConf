return {
   "tpope/vim-fugitive",
   cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite" },
   keys = {
     { '<leader>Gl', '<cmd>G log --decorate<cr>', desc = 'Git Log' },
   },
}
