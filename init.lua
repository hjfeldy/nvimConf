-- Send the unnamed/system registers through the client terminal when editing
-- remotely. This must be set before anything initializes the clipboard provider.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  vim.g.clipboard = 'osc52'
end

require('config.lazy')
require('config.lsp')
require('highlights')
require('nvimDebugger')
require('saneDefaults')
require('autocommands')
