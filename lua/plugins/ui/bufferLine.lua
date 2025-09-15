-- buffer tabs

local util = require('util')
local icons = require('icons')

return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = util.mergeArrays({
    { "g", "", desc = "+BufferLine"},
    { "gh", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "gl", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "gM", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "gm", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    { "gk", "gg", desc = "Top of buffer" },
    { "gj", "GG", desc = "Bottom of buffer" }
    },
    (function()
      local numBindings = {}
      for i = 1,9 do
        numBindings[i] = {"g" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", desc = "Go to buffer " .. i}
      end
      return numBindings
    end)()
  ),
  opts = {
    options = {
      -- stylua: ignore
      close_command = function(n) require('snacks').bufdelete(n) end,
      numbers = 'ordinal',
      -- stylua: ignore
      right_mouse_command = function(n) require('snacks').bufdelete(n) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      custom_filter = function(bufnr, bufnrs)
        local bufType = vim.api.nvim_get_option_value('filetype', {buf=bufnr})
        local blacklist = { ['grug-far'] = true, ['help'] = true, ['Terminal'] = true }
        return not blacklist[bufType]
      end,
      diagnostics_indicator = function(_, _, diag)
        local ret = (diag.error and icons.diagnostics.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.diagnostics.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
        {
          filetype = "snacks_layout_box",
        },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
}

