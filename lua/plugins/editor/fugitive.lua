return {
   "tpope/vim-fugitive",
   cmd = { "Git", "G", "Gdl", "Gdiffsplit", "Gread", "Gwrite" },
   -- keys = {
   --   { '<leader>Gl', '<cmd>G log --decorate<cr>', desc = 'Git Log' },
   -- },
   config = function()
     vim.api.nvim_create_user_command('Gdl', function(opts)
       if #opts.fargs ~= 2 then
         vim.notify('Usage: Gdl {ref-a} {ref-b}', vim.log.levels.ERROR)
         return
       end

       local ref_a, ref_b = unpack(opts.fargs)
       local result = vim.system(
         { 'git', 'merge-base', ref_a, ref_b },
         { cwd = vim.fn.getcwd(), text = true }
       ):wait()

       local merge_base = vim.trim(result.stdout or '')
       if result.code ~= 0 or merge_base == '' then
         local message = vim.trim(result.stderr or '')
         vim.notify(message ~= '' and message or 'Unable to determine merge base', vim.log.levels.ERROR)
         return
       end

       local args = {
         'log',
         '--decorate',
         '--graph',
         ref_a,
         ref_b,
         '--not',
         merge_base .. '~1',
       }
       local command = table.concat(vim.tbl_map(vim.fn.shellescape, args), ' ')
       vim.api.nvim_cmd({ cmd = 'G', args = { command } }, {})
     end, { nargs = '+' })
   end,
}
