---------
-- Pure-Lua implementation of the mtype functions.

local getmetatable = getmetatable
local io_type = io.type
local rawtype = type


--- Returns type of the given `value`.
--
-- @param value
-- @treturn string A type of the value.
local function type (value)
  local rtype = rawtype(value)

  if rtype ~= 'table' and rtype ~= 'userdata' then
    return rtype
  end

  local mt = getmetatable(value)
  if mt then
    local mttype = mt.__type

    if mttype and rawtype(mttype) == 'function' then
      mttype = mttype(value)
    end

    if mttype then
      return mttype
    end
  end

  if rtype == 'userdata' then
    local itype = io_type(value)
    if itype then
      return itype
    end
  end

  return rtype
end

--- Returns true if the given *value* is of the specified (enhanced) *type*.
-- When called with only one argument, partially applied function is returned.
--
-- @tparam string typename
-- @param ?value
-- @treturn boolean|function
-- @raise If *typename* is not a string or *value* is a table with metafield
--   `__istype` that is not a function or table.
local function istype (...)
  local typename, value = ...

  if select('#', ...) == 1 then
    -- Return partially applied function.
    return function(val)
      return istype(typename, val)
    end
  end

  if rawtype(typename) ~= 'string' then
    error('bad argument #1 to "istype" (string expected, got '
          ..rawtype(value)..')', 2)
  end

  local rtype = rawtype(value)
  local rtype_equals = rtype == typename

  if rtype_equals or rtype ~= 'table' and rtype ~= 'userdata' then
    return rtype_equals
  end

  local mt = getmetatable(value)
  if mt then
    local istype_f = mt.__istype
    if istype_f ~= nil then
      local istype_t = rawtype(istype_f)

      if istype_t == 'function' then
        return istype_f(value, typename)
      elseif istype_t == 'table' then
        return not not istype_f[typename]
      else
        error('invalid metafield "__istype" (function or table expected, got '
              ..istype_t..')')
      end
    end
  end

  return type(value) == typename
end

return {
  type = type,
  istype = istype,
}
