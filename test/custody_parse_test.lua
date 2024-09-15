---@diagnostic disable: duplicate-set-field
require("test.setup")()

_G.IsInUnitTest = true -- set this per test file to keep ao.send() from doing anything
_G.VerboseTests = 0    -- how much logging to see (0 - none at all, 1 - important ones, 2 - everything)
-- optional logging function that allows for different verbosity levels
_G.printVerb = function(level)
  level = level or 2
  return function(...) -- define here as global so we can use it in application code too
    if _G.VerboseTests >= level then print(table.unpack({ ... })) end
  end
end

local custody_parse = require "custody.parse"

describe("custody.parse", function()
  setup(function()
  end)

  teardown(function()
  end)

  it("should fail", function()
    local res = custody_parse.validateArweaveAddress("0x1234")
    assert.is_false(res)
  end)

  it("should pass on real address", function()
    local res = custody_parse.validateArweaveAddress("0cQJ5Hd4oCaL57CWP-Pqe5_e0D4_ZDWuxKBgR9ke1SI")
    assert.is_true(res)
  end)
end)
