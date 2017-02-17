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

return {
  type = type,
}
