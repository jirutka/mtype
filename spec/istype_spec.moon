lpeg = require 'lpeg'

userdata = lpeg.P('')
file = io.open('/dev/null')

values = { true, false, 42, 'aloha!', userdata, -> 'hi!', {} }
stdtypes = { 'nil', 'boolean', 'number', 'string', 'userdata', 'function', 'thread', 'table' }


for impl in *{'pure', 'native'} do
  { type: mtype, istype: istype } = require 'mtype.'..impl

  describe "#{impl}.istype", ->

    for ttype in *stdtypes do
      context "('#{ttype}', nil)", ->
        expected = ttype == 'nil'

        it "returns #{expected}", ->
          assert.equals expected, istype(ttype, nil)
          assert.equals expected, istype(ttype)(nil)

      context "('#{ttype}', <file>)", ->
        expected = ttype == 'userdata'

        it "returns #{expected}", ->
          assert.equals expected, istype(ttype, file)
          assert.equals expected, istype(ttype)(file)

      for value in *values do
        context "('#{ttype}', <#{mtype(value)}>)", ->
          expected = mtype(value) == ttype

          it "returns #{expected}", ->
            assert.equals expected, istype(ttype, value)
            assert.equals expected, istype(ttype)(value)

    context "('file', <file>)", ->
      it 'returns true', ->
        assert.is_true istype('file', file)


    context 'given table with __istype', ->

      context 'function', ->
        it 'calls it and returns return value', ->
          for expected in *{true, false} do
            value = setmetatable({}, { __istype: -> expected })
            assert.same expected, istype('foo', value)

        it 'calls it with (table, type)', ->
          ttype, value = 'foo', {}
          setmetatable(value, { __istype: (t, v) ->
            assert t == value
            assert v == ttype
            true
          })
          assert.is_true istype(ttype, value)

      context 'table', ->
        table = { Truthy: true, Falsy: false, Number: 1 }
        value = setmetatable({}, { __istype: table })

        context 'when contains given type as key', ->
          it 'returns false when its value is false', ->
            assert.is_false istype('Falsy', value)

          it 'returns true when its value is true', ->
            assert.is_true istype('Truthy', value)

          it 'returns true when its value is not nil or false', ->
            assert.is_true istype('Number', value)

        context 'when does not contain given type as key', ->
          it 'returns false', ->
            assert.is_false istype('NoHere', value)

      context 'of incorrect type', ->
        for field in *values unless contains type(field), {'function', 'table'} do
          value = setmetatable({}, { __istype: field })

          it 'raises error', ->
            assert.has_error -> istype('foo', value)
            assert.has_error -> istype('foo')(value)


    context 'given table with __type and w/o __istype', ->
      metatype = 'Metal'
      value = setmetatable({}, { __type: metatype })

      it 'returns true when given type is same as metatype', ->
        assert.is_true istype(metatype, value)

      it 'returns true for type "table" (supertype)', ->
        assert.is_true istype('table', value)


    context 'given 1 argument', ->
      subject = istype('string')

      it 'returns partially applied function', ->
        assert.is_same 'function', type(subject)
        assert.is_true subject('aloha!')
        assert.is_false subject(66)


    context 'when 1st arg is not string', ->

      for value in *values if type(value) != 'string' do
        it 'raises error', ->
          assert.has_error -> istype(value, 'foo')
          assert.has_error -> istype(value)('foo')
