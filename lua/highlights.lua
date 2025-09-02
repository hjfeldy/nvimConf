local util = require('util')
local setHL = vim.api.nvim_set_hl

local function getHL(hl)
  return vim.api.nvim_get_hl(0, {name=hl})
end

local function copyHL(fromHL, toHL)
  local copied = getHL(fromHL)
  setHL(0, toHL, {fg=copied.fg, bg=copied.bg, link=copied.link})
end

local lspKinds = {
  '@lsp.type.enum',
  '@lsp.type.type',
  '@lsp.type.class',
  '@lsp.type.event',
  '@lsp.type.macro',
  '@lsp.type.method',
  '@lsp.type.number',
  '@lsp.type.regexp',
  '@lsp.type.string',
  '@lsp.type.struct',
  '@lsp.type.comment',
  '@lsp.type.keyword',
  '@lsp.type.function',
  '@lsp.type.modifier',
  '@lsp.type.operator',
  '@lsp.type.property',
  '@lsp.type.variable',
  '@lsp.type.decorator',
  '@lsp.type.interface',
  '@lsp.type.namespace',
  '@lsp.type.parameter',
  '@lsp.type.enumMember',
  '@lsp.type.typeParameter'
}

-- BlinkCmpKindField = @lsp.type.number,
-- BlinkCmpKindVariable = @lsp.type.number,
-- etc.
local overrides = {
  field = 'number',
  variable = 'number',
  snippet = 'property',
  text = 'comment'
}


local M = {}

--- Invoke custom highlighting logic
function M.setColors()
  -- Set the foldColumn color based on whether we currently are in dark mode
  local dark = require('toggleColor').DARK
  local color
  if dark then color = '#ffffff' else color = '#000000' end
  setHL(0, 'FoldColumn', {fg=color})

  -- Hack statusline so we don't get weird conflicts with the trouble.statusline component
  copyHL('lualine_c_normal', 'StatusLine')

  -- Override Blink lsp highlights (which NeoSolarized does not define) with builtin lsp highlights
  -- This adds color/style to the LSP completion menu
  for _, lspKind in pairs(lspKinds) do
    local kind = util.split(lspKind, '.')[3]
    local cmpKind = 'BlinkCmpKind' .. util.capitalize(kind)
    copyHL(lspKind, cmpKind)
  end

  -- Override Blink lsp highlights with custom highlights defined in the "overrides" table
  for cmpKind, lspKind in pairs(overrides) do
    local fullLspKind = '@lsp.type.' .. lspKind
    local fullCmpKind = 'BlinkCmpKind' .. util.capitalize(cmpKind)
    copyHL(fullLspKind, fullCmpKind)
  end
end

-- Expose as a module so that we can refresh colors ad-hoc (ie. after toggling dark-mode)
M.setColors()
return M
