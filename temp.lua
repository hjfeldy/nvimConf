local base = {
  sectionA = {
    field1 = 'val',
    field2 = 'val2'
  }
}

local extend = {
  sectionA = {
    field2 = 'modified',
    field3='added',
  },
  sectionB = 'added'
}

--- Merge the values of a table into another table, doing so recursively for table values
--- When both tables define a key with a primitive value, the source table's value is overridden by the addTable
local function recursiveMerge(sourceTable, addTable)
  local merged = {}
  local keys = {}
  for i, tbl in ipairs({sourceTable, addTable}) do
    for k, _ in pairs(tbl) do
      keys[#keys+1] = k
    end
  end

  for i, key in ipairs(keys) do
    -- local v1 = sourceTable[k1]
    if addTable[key] == nil then
      merged[key] = sourceTable[key]
    elseif type(addTable[key]) == 'table' and type(sourceTable[key]) == 'table' then
      merged[key] = recursiveMerge(sourceTable[key], addTable[key])
    else
      merged[key] = addTable[key]
    end
  end
  return merged
end

local merged = recursiveMerge(base, extend)
local tbl = {[2] = 1}
print(vim.inspect(tbl[2]))

local a = {a = nil}
for k, v in pairs(a) do 
  print('key:' .. k)
  print(v)
end

print(vim.inspect(require('util').tblToArray({a='asdf', b = 'fdsa', c='ffff'})))
