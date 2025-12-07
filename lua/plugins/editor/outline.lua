return {
  "hedyhli/outline.nvim",
  lazy=true,
  keys = {
    {"<leader>o", "<cmd>Outline<cr>", desc="Symbols Outline"}
  },
  cmd = { "Outline", "OutlineOpen" },
  opts = {
    keymaps = {
      toggle_preview = 'p',
      close = {'q'}
    }
  }
}
