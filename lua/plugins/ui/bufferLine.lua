-- buffer tabs

local util = require('util')
local icons = require('icons')

return {
  "hjfeldy/bufferline.nvim",
  -- dir = "/home/harry/Repos/bufferline.nvim/",
  branch = 'feature/resession',
  lazy = false,
  -- event = "VeryLazy",
  keys = util.mergeArrays({

    { "gi", "gi", noremap=true }, -- not sure why this is necessary, but the builtin gi binding is getting remapped to a no-op at somewhere

    { "g", "", desc = "+BufferLine"},
    { "gh", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "gl", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "gM", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "gm", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    { "gk", "gg", desc = "Top of buffer" },
    { "gj", "GG", desc = "Bottom of buffer" },

    { "<C-a>", "", desc = "+BufferLine Tabs"},
    { "<C-a>n", "<cmd>tabnext<cr>", desc = "Next Tab"},
    { "<C-a>p", "<cmd>tabprevious<cr>", desc = "Previous Tab"},
    { "<C-a>c", "<cmd>tabnew<cr>", desc = "New Tab"},
    { "<C-a>x", "<cmd>tabclose<cr>", desc = "Close Tab"},

    {
      "<C-a>m",
      function()
        local tabIndex = vim.api.nvim_tabpage_get_number(0)
        print('Tab Index: ' .. tabIndex)
        if tabIndex == #vim.api.nvim_list_tabpages() then
          vim.cmd('tabmove 0')
        else
          vim.cmd('tabmove +1')
        end
      end,
      desc = "Move Tab Right"
    },

    { 
      "<C-a>M",
      function()
        local tabIndex = vim.api.nvim_tabpage_get_number(0)
        if tabIndex == 1 then
          vim.cmd('tabmove $')
        else
          vim.cmd('tabmove -1')
        end
      end,
      desc = "Move Tab Left"
    },

    { "<C-a>r", 
      function() 
        local newName = vim.fn.input('New name for tab')
        vim.cmd('BufferLineTabRename ' .. newName)
      end,
      desc = "Rename Tab"
    },

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
      show_close_icon = false,
      show_buffer_close_icon = false,
      move_wraps_at_ends = true,
      close_command = function(n) require('snacks').bufdelete(n) end,
      numbers = 'ordinal',
      -- stylua: ignore
      right_mouse_command = function(n) require('snacks').bufdelete(n) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,

      custom_filter = function(bufnr, bufnrs)
        local bufType = vim.bo[bufnr].filetype
        local blacklist = {
          ['grug-far'] = true,
          ['help'] = true,
          ['Terminal'] = true,
          ['qf'] = true,
          ['fugitive'] = true 
        }
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

