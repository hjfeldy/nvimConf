
---Global quality-of-life print utilities
---(accessible via the nvim cmdline)
function NvimDebug(...)
  local logger = require('neoWin.logger'):new('vimConf.debugger')
  return logger:debug(...)
end
