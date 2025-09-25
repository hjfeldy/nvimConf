return {
  'stevearc/conform.nvim',
  keys = {
    {'<leader>C', function() require('conform').format({bufnr=0}) end, desc='Format file'}
  },
  opts = {
    formatters_by_ft = {
      -- lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      -- python = { "isort", "black" },
      -- You can customize some of the format options for the filetype (:help conform.format)
      -- Conform will run the first available formatter
      javascript = { "prettier" },
      typescript = { "prettier" },
      json = {'formatJson'},
    },
    formatters = {
      formatJson = {
        command = 'python3',
        args = {'-m', 'json.tool', '--indent', '2'},
        cwd = vim.uv.cwd
      }
    }
  }
}
