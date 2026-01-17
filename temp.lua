local function externalFunctionality()
  print('external!')
end

local function f(a, b) 
  return a+b
end

local function wrap(innerFunc)
  local wrapped = function(...)
    externalFunctionality()
    return innerFunc(...)
  end
  return wrapped
end

local wrapped = wrap(f)

print('return value is: ' .. wrapped(1, 2))
