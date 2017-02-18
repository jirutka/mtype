---------
-- Efficient enhanced types for Lua
--
-- There are two equal implementations of this module:
--
-- * `mtype.native` written in C, the most efficient option for PUC Lua
--   (the official Lua interpreter),
-- * `mtype.pure` written in pure Lua, the most efficient option for LuaJIT.
--
-- This module (`mtype`) detects if you run on LuaJIT (by presence of global
-- variable `jit`) or PUC and returns `mtype.pure` or `mtype.native`.
--
-- @module mtype

-- Load "native" implementation on PUC, "pure" on LuaJIT.
if jit == nil then
  return require('mtype.native')
else
  return require('mtype.pure')
end
