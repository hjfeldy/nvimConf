local M = {}

M.DARK = false
function M.toggle() 
  M.DARK = not M.DARK
  local tf
  if M.DARK then tf = 'true' else tf = 'false' end
  if M.DARK then return 'dark' else return 'light' end
end

return M
