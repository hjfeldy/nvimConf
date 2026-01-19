return {
  "hedyhli/outline.nvim",
  lazy=true,
  keys = {
    {"<leader>o", "<cmd>Outline<cr>", desc="Symbols Outline"}
  },
  cmd = { "Outline", "OutlineOpen" },
  opts = {
    symbol_folding = {
      autofold_depth=1,
    },
    show_cursorline=true,
    keymaps = {
      peek_location={'g'},
      toggle_preview = 'p',
      close = {'q'},
      fold_toggle_all={'o'},
    }
  }
}
