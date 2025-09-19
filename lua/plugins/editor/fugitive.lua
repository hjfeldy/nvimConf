return {
   "tpope/vim-fugitive",
   config = function()
     local map = vim.api.nvim_set_keymap
     map('n', '<leader>Gl', '<cmd>G log --decorate<cr>', {desc='Git Log'})
   end
   -- keys = {
   --   {'<leader>Gl', '<cmd>Git log --decorate', desc='Git Log'}
   -- }
}
