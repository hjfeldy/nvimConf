local util = require('util')
---Global quality-of-life print utilities
---(accessible via the nvim cmdline)

function NvimDebug(...)
  return util.debug(...)
end
