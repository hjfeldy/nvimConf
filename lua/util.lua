local M = {}

M.merge = function(d1, d2) 
  local out = {}
  for _, d in pairs({d1, d2}) do
    if d ~= nil then 
      for k, v in pairs(d) do
        out[k] = v
      end
    end
  end
  return out
end

M.shallowCopy = function(d) 
  local out = {}
  for k, v in pairs(d) do
    out[k] = v
  end
  return out
end

local map = vim.api.nvim_set_keymap
local opts = { noremap = true }
M.mapKey = function(key, mapTo, mode, desc)
  local _opts = M.shallowCopy(opts)
  if desc ~= nil
    then _opts.description = desc
  end
  map(mode, key, mapTo, _opts)
end

return M
