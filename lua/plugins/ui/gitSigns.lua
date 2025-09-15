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
      -- { "<leader>Gu", function() require('gitsigns').undo_stage_hunk() end, mode="n", desc="Undo Stage Hunk"},
      -- map({ "n", "v" }, "<leader>Ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      {"<leader>GS", function() require('gitsigns').stage_buffer() end, mode="n", desc="Stage Buffer"},
      -- {"<leader>ghR", gs.reset_buffer, mode="n", desc="Reset Buffer"},
      {"<leader>Gb", function() require('gitsigns').blame_line({ full = true }) end, mode="n", desc="Blame Line"},
      {"<leader>GB", function() require('gitsigns').blame() end, mode="n", desc="Blame Buffer"},
      {"<leader>Gd", function() require('gitsigns').diffthis() end, mode="n", desc="Diff This"},
      -- {"<leader>GD", function() gs.diffthis("~") end, mode="n", desc="Diff This ~"},
      -- { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode={ "o", "x" }, desc="Select Hunk")
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
