local logger = require('neoWin.logger'):new('vimConf.debugger')

---Global quality-of-life print utilities
---(accessible via the nvim cmdline)
function NvimDebug(...)
  return logger:debug(...)
end
