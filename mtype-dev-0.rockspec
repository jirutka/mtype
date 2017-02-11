-- vim: set ft=lua:

package = 'mtype'
version = 'dev-0'

source = {
  url = 'git://github.com/jirutka/mtype.git',
  branch = 'master',
}

description = {
  summary = 'TODO',
  detailed = [[
TODO]],
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
  },
}
