  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific location.

return {
  "folke/flash.nvim",
  lazy=false,
  -- event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    label = {
      format = function(opts)
        return { { opts.match.label, opts.hl_group } }
      end,
    },
    modes = {
      char = { enabled = false }
    }
  },
  -- stylua: ignore
  keys = {
    {"<leader>s", "", desc="+Flash Search"},
    { 
      "<leader>ss",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
      desc = "Flash"
    },
    {
      "<leader>st",
      mode = { "n", "o", "x" },
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter"
    },
  },
}

