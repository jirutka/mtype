---------
-- @module mtype

local getmetatable = getmetatable
local io_type = io.type
local rawtype = type


--- Returns (enhanced) type name of the given *value*.
--
-- * If the *value* is a table or an userdata with a metatable, then it looks
--   for a metafield `__type`.
--
--    * If the metafield is a string, then it returns it as a type name.
--
--    * If it's a function, then it calls it with the *value* as an argument.
--      If the result is not nil, then it returns it as a type name;
--      otherwise continues.
--
-- * If the *value* is an IO userdata (file), then it calls `io.type` and
--   returns result as a type name.
--
-- * If nothing above applies, then it returns a raw type of the *value*,
--   i.e. the same as built-in type function.
--
-- @param value
-- @treturn string A type name of the value.
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

--- Returns true if (enhanced) type of the given *value* meets the specified
-- *typename*. When called with only one argument, partially applied function
-- is returned.
--
-- * If raw type of the *value* equals the *typename*, then it returns true.
--
-- * If the *value* is a table or an userdata with a metatable, then it looks
--   for a metafield `__istype`.
--
--    * If the metafield is a function, then it calls it
--      with arguments *value, typename* and returns the result (the return
--      type **should** be boolean, but it's not checked!).
--
--    * If a table, then it looks for a key that equals the *typename*. If
--      there's no such key or its value is false (or nil), then it returns
--      false. Otherwise returns true.
--
--    * Otherwise raises error.
--
-- * If nothing above applies, then it calls `type` with the *value*, compares
--   the result with the *typename* and returns true if equals, false otherwise.
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

--- @export
return {
  type = type,
  istype = istype,
}
