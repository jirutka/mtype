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

local M

-- Load "native" implementation on PUC, "pure" on LuaJIT.
if jit == nil then
  M = require('mtype.native')
else
  M = require('mtype.pure')
end

--- Version of this module in format "x.y.z".
M._VERSION = '0.0.0'

return M
