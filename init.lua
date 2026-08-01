-- Send the unnamed/system registers through the client terminal when editing
-- remotely. This must be set before anything initializes the clipboard provider.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require('vim.ui.clipboard.osc52')
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = osc52.copy('+'),
      ['*'] = osc52.copy('*'),
    },
    paste = {
      ['+'] = osc52.paste('+'),
      ['*'] = osc52.paste('*'),
    },
  }
end

require('config.lazy')
require('config.lsp')
require('highlights')
require('nvimDebugger')
require('saneDefaults')
require('autocommands')
