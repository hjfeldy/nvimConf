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


return M
