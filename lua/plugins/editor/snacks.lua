  -- quality-of-life

return {
  "folke/snacks.nvim",
  opts = {
    animate = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    words = { enabled = true },
    statuscolumn = {
      enabled = false,
      left = { "mark", "fold" }, -- priority of signs on the left (high to low)
      right = { "git" }, -- priority of signs on the right (high to low)
      folds = {
        open = true, -- show open fold icons
        git_hl = true, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { "GitSign", "MiniDiffSign" },
      },
      refresh = 50, -- refresh at most every 50ms
    }
  }
}
