local api = vim.api

local M = {}

--- Reverse a table k:v to v:k
--- @param d table
--- @return table
function M.reverse(d)
  local out = {}
  for k, v in pairs(d) do
    out[v] = k
  end
  return out
end

--- Merge two tables
--- @param d1 table
--- @param d2 table
--- @return table
function M.merge(d1, d2)
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

--- Merge an array of tables
function M.mergeArrays(...)
  local arrays = { ... }
  local out = {}
  for _, array in pairs(arrays) do
    for _, v in ipairs(array) do
      out[#out+1] = v
    end
  end
  return out
end

--- Copy a table
--- @param d table
--- @return table
function M.copy(d)
  local out = {}
  for k, v in pairs(d) do
    out[k] = v
  end
  return out
end

-- local map = api.nvim_set_keymap
-- local opts = { noremap = true }
-- function M.mapKey(key, mapTo, mode, desc)
--   local _opts = M.copy(opts)
--   if desc ~= nil
--     then _opts.desc = desc
--   end
--   map(mode, key, mapTo, _opts)
-- end

--- Capitalize the first letter of a string
--- @param str string
function M.capitalize(str)
  local first = str:sub(1, 1)
  local rest = str:sub(2, #str)
  return first:upper() .. rest
end

--- Split a string by a delimiter
--- @param str string
--- @return string[]
function M.split(str, delim)
  local out = {}
  local s = ''
  for i = 1,#str do
    local chunk = str:sub(i, i+#delim-1)
    if chunk == delim then
      out[#out+1] = s
      s = ''
    else
      s = s .. str:sub(i, i)
    end
  end
  if #s > 0 then
    out[#out+1] = s
  end
  return out
end

--- Join an array of strings with a delimiter
--- @param strings string[]
--- @param delim string
function M.join(strings, delim)
  local out = ''
  for _, str in pairs(strings) do
    out = out .. str .. delim
  end
  return out:sub(1, #out-#delim)
end

--- Generate a shortened version of a path,
--- specifying a fixed number of path components
---@param path string
---@param maxComponents integer?
function M.shortenPath(path, maxComponents)
  maxComponents = maxComponents or 0

  local home = os.getenv('HOME') or "__notfound__"
  path = path:gsub(home, '~')

  local pathSep = package.config:sub(1,1)
  if vim.o.shellslash then
    pathSep = '/'
  end
  local components = M.split(path, pathSep)
  if maxComponents > 0 and maxComponents < #components then
    local lastComponents = {}
    for i = #components-maxComponents+1,#components do
      lastComponents[#lastComponents+1] = components[i]
    end
    components = lastComponents
  end
  return M.join(components, pathSep)

end

--- Generate a wrapped version of shortenPath() for the current buffer
---@param maxComponents integer? Maximum number of path components
---@param skipReplaceCwd boolean? Should the vim working directory be replaced with "."?
function M.shortenPathFunc(maxComponents, skipReplaceCwd)
  return function()
    local path = api.nvim_buf_get_name(api.nvim_get_current_buf())
    -- Keep the configured depth immutable. These closures are shared by the
    -- long-lived lualine component graph, so changing the captured value while
    -- rendering a terminal would otherwise shorten every later buffer too.
    local effectiveMaxComponents = vim.bo.filetype == 'Terminal' and 1 or maxComponents
    if effectiveMaxComponents == nil or effectiveMaxComponents < 1 then
      effectiveMaxComponents = 999
    end

    if not skipReplaceCwd then
      local cwd = vim.uv.cwd() or '__ERR__'
      path = path:gsub(cwd, '.')
    end

    return M.shortenPath(path, effectiveMaxComponents)
  end
end

--- Emit a debug log
function M.debug(...)
  if not vim.g.NOICE_DEBUG then return end
  local args = { ... }
  local s = ''
  for _, msg in pairs(args) do
    if type(msg) == 'table' then
      msg = vim.inspect(msg)
    end
    s = s .. msg .. ' '
  end
  -- will be filtered by NOICE_DEBUG
  vim.notify(s, vim.log.levels.DEBUG)
end


--- Toggle debug logs
function M.toggleDebug()
  vim.g.NOICE_DEBUG = not vim.g.NOICE_DEBUG
  local tf = vim.g.NOICE_DEBUG and 'true' or 'false'
  -- vim.cmd('Lazy reload noice.nvim')
  vim.notify('Toggled debug logs to ' .. tf, vim.log.levels.INFO)
end


--- Render a user-friendly string for the current PWD (with a nerd-font icon)
--- @param skipSub boolean? Skip the string substitution of "~" for the HOME environment var
function M.renderHome(skipSub)
  local cwd = vim.uv.cwd() or '__notfound__'
  local home = os.getenv('HOME') or '__notfound__'
  return " " .. (skipSub == true and cwd or string.gsub(cwd, home, '~'))
end

-- function M.listedBufs()
--   local out = {}
--   for _, buf in ipairs(api.nvim_list_bufs()) do
--     local listed = vim.bo[buf].buflisted
--     local name = api.nvim_buf_get_name(buf)
--     if listed then
--       out[#out+1] = name
--     end
--   end
--   return out
-- end

--- Merge the values of a table into another table, doing so recursively for table values
--- When both tables define a key with a primitive value, the source table's value is overridden by the addTable
--- @param sourceTable table table whose values are overridden 
--- @param addTable table table with overriding values
--- @return table
function M.recursiveMerge(sourceTable, addTable)
  local merged = {}
  local keys = {}
  for _, tbl in ipairs({sourceTable, addTable}) do
    for k, _ in pairs(tbl) do
      keys[#keys+1] = k
    end
  end

  for _, key in ipairs(keys) do
    if type(addTable[key]) == 'table' and type(sourceTable[key]) == 'table' then
      merged[key] = M.recursiveMerge(sourceTable[key], addTable[key])
    else
      merged[key] = addTable[key] or sourceTable[key]
    end
  end
  return merged
end


--- Extract the values of a table into an array
--- If the values contain an "index" field, sort the array by it
--- @param tbl table
--- @return table
function M.tblToArray(tbl)
  local out = {}
  for _, v in pairs(tbl) do
    if v.index ~= nil then
      out[v.index] = v
    else
      out[#out+1] = v
    end
  end
  return out
end

return M
