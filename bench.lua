#!/usr/bin/env lua

local benchmark = require 'benchmark'
local native = require 'mtype.native'
local pure = require 'mtype.pure'

-- unpack is not global since Lua 5.3
local unpack = table.unpack or unpack  --luacheck: std lua51

local type_raw = type
local type_native = native.type
local type_pure = pure.type

-- Number of iterations.
local N = 5000000

-- disable JIT when running on LuaJIT
if jit then jit.off() end


local reporter = benchmark.bm(20, nil, true)

local function measure (label, func)
  -- warm up
  for i=1, N / 100 do
    func()
  end

  reporter:report(function()
    for i=1, N do
      func()
    end
  end, label)
end


local meta_str = setmetatable({}, {
  __type = 'meta'
})

local meta_fun = setmetatable({
  tag = 'meta'
}, {
  __type = function(self)
    return self.tag
  end
})


for _, desc in ipairs {
  { 'number'                  , 42                   },
  { 'string'                  , 'allons-y!'          },
  { 'table without __type'    , setmetatable({}, {}) },
  { 'table with string __type', meta_str             },
  { 'table with func __type'  , meta_fun             },
} do
  local label, value = unpack(desc)

  print('-- '..label)

  measure('type', function()
    type_raw(value)
  end)

  measure('mtype (pure)', function()
    type_pure(value)
  end)

  measure('mtype (native)', function()
    type_native(value)
  end)

  print('')
end
