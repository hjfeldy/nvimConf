---Global quality-of-life print utilities
---(accessible via the nvim cmdline)

function NvimDebug(...)
  local args = { ... }
  local s = ''
  for i, msg in ipairs(args) do
    if type(msg) == 'table' then 
      msg = '\n' .. vim.inspect(msg) .. '\n'
    else
      msg = tostring(msg)
    end
    s = s .. msg 
    if i ~= #args then
      s = s .. ' '
    end
  end
  vim.notify(s, vim.log.levels.DEBUG)
end
