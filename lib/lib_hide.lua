-- Credit jan1i3 @ factorio discord

-- very start of the file
local __original_global_values -- double __ to be sure-er it doesn't conflict
local __original_loaded_packages
do
  -- copy from util, in case it somehow got overwritten
  local function __deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
      if type(object) ~= "table" then
        return object
      -- don't copy factorio rich objects
      elseif object.__self then
        return object
      elseif lookup_table[object] then
        return lookup_table[object]
      end
      local new_table = {}
      lookup_table[object] = new_table
      for index, value in pairs(object) do
        new_table[_copy(index)] = _copy(value)
      end
      return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
  end
 
  __original_global_values = __deepcopy(_G)
  __original_loaded_packages = __deepcopy(package.loaded)
end
 
 
-- your file, just like you had it previously
 
 
 
-- very end of the file
 
-- using this too maintain table references.
local function __recursive_assign(source, target) -- double __ to be sure-er it doesn't conflict
  local to_remove = {}
  for k, _ in pairs(target) do
    to_remove[k] = true
  end
 
  for k, v in pairs(source) do
    local t = target[k]
    if t then
      __recursive_assign(v, t)
    else
      target[k] = v
    end
    to_remove[k] = nil
  end
 
  for k, _ in ipairs(to_remove) do
    target[k] = nil
  end
end

return {__recursive_assign,__original_global_values, _G,__original_loaded_packages, package.loaded}