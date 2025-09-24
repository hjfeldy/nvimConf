local util = require('util')

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
local blinkLspOverrides = {
  field = 'number',
  variable = 'number',
  snippet = 'property',
  text = 'comment'
}


local M = {}

M.setHL = vim.api.nvim_set_hl

function M.getHL(hl)
  return vim.api.nvim_get_hl(0, {name=hl})
end

function M.copyHL(fromHL, toHL)
  local copied = M.getHL(fromHL)
  M.setHL(0, toHL, {fg=copied.fg, bg=copied.bg, link=copied.link})
end


--- Invoke custom highlighting logic
function M.setColors()
  -- Set the foldColumn color based on whether we currently are in dark mode
  local dark = require('toggleColor').DARK
  local color
  if dark then color = '#ffffff' else color = '#000000' end
  M.setHL(0, 'FoldColumn', {fg=color})
  M.setHL(0, 'WinSeparator', {fg=color})

  -- Hack statusline so we don't get weird conflicts with the trouble.statusline component
  M.copyHL('lualine_c_normal', 'StatusLine')

  -- Get rid of annoying automatic highlighting of the word under the cursor
  -- M.copyHL('Normal', 'CurrentWord')
  M.setHL(0, 'CurrentWord', {})

  -- Reverse flash label/cursor - more visibly clear
  -- local flashLabel = M.getHL('FlashLabel')
  -- local flashCursor = M.getHL('FlashCursor')
  -- util.debug('Flash Label:', flashLabel)
  -- util.debug('Flash Cursor:', flashCursor)
  -- M.copyHL('FlashLabel', 'FlashCursor')
  -- M.setHL(0, 'FlashCursor', {fg=flashLabel.fg, bg=flashLabel.bg})
  -- flashLabel = M.getHL('FlashLabel')
  -- flashCursor = M.getHL('FlashCursor')
  -- util.debug('Flash Label (post):', flashLabel)
  -- util.debug('Flash Cursor (post):', flashCursor)

  M.setHL(0, 'FlashMatch', {fg='red', bg='black'})
  M.setHL(0, 'FlashLabel', {fg='red', bg='black'})
  M.setHL(0, 'FlashCurrent', {fg='red', bg='black'})

  -- Override Blink lsp highlights (which NeoSolarized does not define) with builtin lsp highlights
  -- This adds color/style to the LSP completion menu
  for _, lspKind in pairs(lspKinds) do
    local kind = util.split(lspKind, '.')[3]
    local cmpKind = 'BlinkCmpKind' .. util.capitalize(kind)
    M.copyHL(lspKind, cmpKind)
  end

  -- Override Blink lsp highlights with custom highlights defined in the "blinkLspOverrides" table
  for cmpKind, lspKind in pairs(blinkLspOverrides) do
    local fullLspKind = '@lsp.type.' .. lspKind
    local fullCmpKind = 'BlinkCmpKind' .. util.capitalize(cmpKind)
    M.copyHL(fullLspKind, fullCmpKind)
  end
end

-- Expose as a module so that we can refresh colors ad-hoc (ie. after toggling dark-mode)
M.setColors()
return M
