-- Load native implementation on PUC, pure on LuaJIT.
if jit == nil then
  return require('mtype.native')
else
  return require('mtype.pure')
end
