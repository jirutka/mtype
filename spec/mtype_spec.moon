
for impl in *{'pure', 'native'} do
  mtype = require('mtype.'..impl).type

  describe "#{impl}:", ->
    for value in *{ true, false, 42, 'aloha!', {}, -> 'hi!' } do
      context type(value), ->
        it 'returns same type as type()', ->
          assert.same type(value), mtype(value)

    context 'nil', ->
      it 'returns "nil"', ->
        assert.same 'nil', mtype(nil)

    context 'file', ->
      it 'returns same type as io.type()', ->
        value = io.open('/dev/null')
        assert.same io.type(value), mtype(value)
        value\close()
        assert.same io.type(value), mtype(value)

    context 'table with metatype', ->

      context 'when __type is string', ->
        value = setmetatable({}, { __type: 'meta' })

        it 'returns __type value', ->
          assert.same 'meta', mtype(value)

      context 'when __type is function', ->

        it 'calls __type and returns return value', ->
          value = setmetatable({}, { __type: -> 'meta' })
          assert.same 'meta', mtype(value)

        it 'calls __type with the value as 1st argument', ->
          value = setmetatable({}, { __type: (t) -> t })
          assert.equals value, mtype(value)

        context 'and returns nil', ->
          it 'returns "table"', ->
            value = setmetatable({}, { __type: -> nil })
            assert.same 'table', mtype(value)
