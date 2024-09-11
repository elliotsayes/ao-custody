---@diagnostic disable: duplicate-set-field
require("test.setup")()

_G.VerboseTests = 0                    -- how much logging to see (0 - none at all, 1 - important ones, 2 - everything)
_G.VirtualTime = _G.VirtualTime or nil -- use for time travel
-- optional logging function that allows for different verbosity levels
_G.printVerb = function(level)
  level = level or 2
  return function(...) -- define here as global so we can use it in application code too
    if _G.VerboseTests >= level then print(table.unpack({ ... })) end
  end
end

_G.Owner = '123MyOwner321'
_G.MainProcessId = '123xyzMySelfabc321'
_G.AoCredProcessId = 'AoCred-123xyz'

_G.Processes = {
  [_G.AoCredProcessId] = require 'mocked-env.processes.token' (_G.AoCredProcessId),
  ["<Index>"] = require 'mocked-env.processes.dummy' ("<Index>"),
  ["<Beneficiary>"] = require 'mocked-env.processes.dummy' ("<Beneficiary>"),
  ["<Dummy>"] = require 'mocked-env.processes.dummy' ("<Dummy>")
}

_G.Handlers = require "handlers"

_G.ao = require "ao" (_G.MainProcessId) -- make global so that the main process and its non-mocked modules can use it
-- => every ao.send({}) in this test file effectively appears as if the message comes the main process

_G.ao.env = {
  Process = {
    Tags = {
      ["Name"] = "GreeterProcess",
      -- ... add other tags that would be passed in when the process is spawned
    }
  }
}

_G.INDEX_PROCESS = "<Index>"
_G.BENEFICIARY_ADDRESS = "<Beneficiary>"
local custody = require "custody.main" -- require so that process handlers are loaded


local resetGlobals = function()
end

describe("greetings", function()
  setup(function()
    -- to execute before this describe
  end)

  teardown(function()
    -- to execute after this describe
  end)

  it("should send AckSrc", function()
    assert.equal("AckSrc", _G.LastMessage.Tags["Action"])
  end)

  it("should send", function()
    ao.send({
      Target = ao.id,
      From = "<Dummy>",
      Tags = {
        Action = "Info"
      }
    })
    assert.equal("0", _G.LastMessage.Tags["Stake-Count"])
  end)
end)
