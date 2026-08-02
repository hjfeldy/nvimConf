
return {
  "sindrets/diffview.nvim",
  keys = {
    {"<leader>Gl", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history (current file)"},
    {"<leader>GL", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview file history (all files)"},
    {"<leader>GD", "<cmd>DiffviewOpen<cr>", desc = "Diffview (all files)"},
  },
  opts = {
    hooks = {
      view_opened = function(view) 
        local tabNum = vim.api.nvim_tabpage_get_number(view.tabpage)
        local prevTab = vim.api.nvim_list_tabpages()[tabNum-1]
        local tabName = vim.api.nvim_tabpage_get_var(prevTab, 'name')
        vim.api.nvim_tabpage_set_var(view.tabpage, 'name', tabName .. ' (diff-view)')
        vim.cmd('tabmove -1')
      end
    },
    keymaps = {
      view = {
        {'n', 'J', ']c', desc = 'Next Hunk' },
        {'n', 'K', '[c', desc = 'Previous Hunk' },
      }
    }
  }
}
