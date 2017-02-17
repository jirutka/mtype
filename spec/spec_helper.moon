-- Helpers

export contains = (value, table) ->
  for item in *table do
    return true if item == value
  return false
