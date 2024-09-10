global type SqliteValue = string | number | nil

local record Statement
  bind_values: function(Statement, ...: SqliteValue): number
  step: function(Statement): number
  get_value: function(Statement, number): SqliteValue
  finalize: function(Statement): number
end

local record DB
  exec: function(DB, string): number
  prepare: function(DB, string): Statement
end

local record lsqlite3
  OK: number
  ROW: number
  DONE: number

  open_memory: function(): DB
end

return lsqlite3