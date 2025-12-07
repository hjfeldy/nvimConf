local helpers = require('helpers.resession')

return {
  "stevearc/resession.nvim",
  dependencies = {dir="/home/harry/Repos/neowin"},
  -- lazy=false,
  keys = {
    {
      '<C-s>',
      helpers.saveSesh,
      desc='Save Session'
    },
    {
      '<C-^>',
      helpers.pickSession,
      desc='Load Session'
    },
  },
  opts = {
    -- override default filter
    buf_filter = function(bufnr)
      local exclude = {
        ['Terminal'] = true,
        ['fugitive'] = true,
        ['help'] = true
      }
      local filetype = vim.bo[bufnr].filetype
      -- if filetype == 'Terminal' or filetype == 'fugitive' then
      if exclude[filetype] then
        return false
      end

      local buftype = vim.bo[bufnr].buftype
      if buftype ~= "" and buftype ~= "acwrite" then
        return false
      end
      if vim.api.nvim_buf_get_name(bufnr) == "" then
        return false
      end

      -- this is required for scope.nvim, since the default filter skips nobuflisted buffers
      return true
    end,
    extensions = {
      -- orderedTabBuffersPlugin = {},
      neoWin = {},
      bufferline = {},
      scope = {}
    } 
  }
}
