return {
  "hedyhli/outline.nvim",
  lazy=true,
  keys = {
    {"<leader>o", "<cmd>Outline<cr>", desc="Symbols Outline"}
  },
  cmd = { "Outline", "OutlineOpen" },
  opts = {}
}

-- return {
--   "hedyhli/outline.nvim",
--   config = function()
--     -- Example mapping to toggle outline
--     vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>",
--       { desc = "Toggle Outline" })
--
--     require("outline").setup {
--       -- Your setup opts here (leave empty to use defaults)
--     }
--   end,
-- }
