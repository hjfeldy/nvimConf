return {
   "tpope/vim-fugitive",
   lazy=false,
   config = function()
     local map = vim.api.nvim_set_keymap
     map('n', '<leader>Gl', '<cmd>G log --decorate<cr>', {desc='Git Log'})
   end
}
