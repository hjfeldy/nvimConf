local map = vim.keymap.set

-- LSP

map("n", "<leader>g", "", {desc="+LSP"})

map("n",
  "<leader>gt",
  function() 
    require("helpers.lsp").toggleHints() 
    require("helpers.telescope.utils").toggleHints()
  end,
  {desc="Toggle LSP Diagnostic Level"}
)

map(
  "n",
  "<leader>go",
  function()
    vim.lsp.buf.hover({border="rounded"})
  end,
  {desc="Hover"}
)

map(
  "n",
  "<leader>gr",
  "<cmd>Trouble lsp_references focus=true<CR>",
  --[[ function()
    vim.cmd("Trouble references focus=true")
  end, ]]
  {desc="References"}
)

map(
  "n",
  "<leader>gd",
  function()
    vim.lsp.buf.definition({
      on_list = require("helpers.lsp").listHandler
    })
  end,
  {desc="Goto Definition"}
)

map(
  "n",
  "<leader>gi",
  function()
    vim.lsp.buf.implementation()
  end,
  {desc="Goto Implementation"}
)

map(
  "n",
  "<leader>gD",
  function()
    vim.diagnostic.open_float()
  end,
  {desc="Open Diagnostics"}
)


-- Window jumping/resizing
map("n", "-", "<cmd>resize -1<cr>")
map("n", "+", "<cmd>resize +1<cr>")
map("n", "<C-s>", "<cmd>vertical resize -1<cr>")
map("n", "<C-b>", "<cmd>vertical resize +1<cr>")
map("t", "<C-w>", "<C-\\><C-n>")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("t", "<C-j>", "<C-\\><C-n><C-w>j")
map("t", "<C-k>", "<C-\\><C-n><C-w>k")
map("t", "<C-h>", "<C-\\><C-n><C-w>h")
map("t", "<C-l>", "<C-\\><C-n><C-w>l")
map("n", "<leader>v", "<cmd>vsplit<CR><C-w>l", {desc="Vertical Split"})

-- Sane text-editing defaults
map({"n", "x"}, "J", "}", {desc="Jump Down"})
map({"n", "x"}, "K", "{", {desc="Jump Up"})
map("n", "<leader>j", "<cmd>cnext<CR>", {desc="Qfix next"})
map("n", "<leader>k", "<cmd>cprev<CR>", {desc="Qfix prev"})
map("n", "vv", "gv", {desc="Rehighlight"})
map("n", "<leader>J", "J", {desc="Merge Lines"})
map("n", "<leader>N", function() vim.o.hlsearch = not vim.o.hlsearch end, {desc="Toggle Highlight"})

map(
  "n",
  "<C-p>",
  function() 
    require('highlights').toggleColor()
    require('lualine').refresh()
  end
)

vim.o.shiftwidth=2
vim.o.tabstop=2
vim.o.expandtab=true

vim.o.hlsearch=true
vim.o.smartcase=true
vim.o.ignorecase=true

vim.o.clipboard='unnamedplus'
-- vim.g.clipboard='xclip'

vim.o.number=true
vim.o.relativenumber=true

vim.o.winborder='rounded'

vim.o.undodir='/home/harry/.local/state/nvim/undo'
vim.o.undofile=true

vim.o.mouse=''

vim.o.fillchars='foldsep:│'
vim.o.signcolumn='auto:2'
vim.o.foldcolumn='auto:2'
vim.o.wrap=false

vim.o.scrolloff = 4

vim.o.sessionoptions='buffers,tabpages,globals'
