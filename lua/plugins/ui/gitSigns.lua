-- git-diff statuscolumn / git-hunk navigation

return {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    -- lazy=false,
    keys = {
      { "<leader>G", "", mode="n", desc="+Git"},
      { "<leader>Gg", function() require('gitsigns').nav_hunk("last") end, mode="n", desc="Last Hunk" },
      { "<leader>GG", function() require('gitsigns').nav_hunk("first") end, mode="n", desc="First Hunk" },
      { "<leader>Gn", function() require('gitsigns').nav_hunk("next") end, mode="n", desc="Next Hunk" },
      { "<leader>GN", function() require('gitsigns').nav_hunk("prev") end, mode="n", desc="Previous Hunk" },
      { "<leader>Gs", "<cmd>Gitsigns stage_hunk<CR>", mode={ "n", "v" }, desc="Stage/Unstage Hunk" },
      {"<leader>GS", function() require('gitsigns').stage_buffer() end, mode="n", desc="Stage Buffer"},
      {"<leader>Gb", function() require('gitsigns').blame_line({ full = true }) end, mode="n", desc="Blame Line"},
      {"<leader>GB", function() require('gitsigns').blame() end, mode="n", desc="Blame Buffer"},
      {"<leader>Gd", function() require('gitsigns').diffthis() end, mode="n", desc="Diff This"},
    },

    opts = {
      signcolumn=true,
      sign_priority=100,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  }
