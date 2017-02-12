-- vim: set ft=lua:

package = 'mtype'
version = 'dev-0'

source = {
  url = 'git://github.com/jirutka/mtype.git',
  branch = 'master',
}

description = {
  summary = 'An enhanced type() function that looks for __type metafield',
  detailed = [[
mtype is a library that provides an enhanced version of the type function that looks for __type metafield on a table.
For best performance it's implemented both in Lua (for LuaJIT) and C (for Lua/PUC).]],
  homepage = 'https://github.com/jirutka/mtype',
  maintainer = 'Jakub Jirutka <jakub@jirutka.cz>',
  license = 'MIT',
}

dependencies = {
  'lua >= 5.1',
}

build = {
  type = 'builtin',
  modules = {
    ['mtype'] = 'mtype/init.lua',
    ['mtype.pure'] = 'mtype/pure.lua',
    ['mtype.native'] = {
      sources = 'src/native.c',
    },
  },
}
