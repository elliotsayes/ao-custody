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

_G.LastMessage = {}
_G.Processes = {
  [_G.AoCredProcessId] = require 'mocked-env.processes.token' (_G.AoCredProcessId),
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

local stake = require "stake.main" -- require so that process handlers are loaded


local resetGlobals = function()
end


describe("greetings", function()
  setup(function()
    -- to execute before this describe
  end)

  teardown(function()
    -- to execute after this describe
  end)

  it("should send", function()
    ao.send({
      Target = ao.id,
      From = "<Dummy>",
      Tags = {
        Action = "Custody-Index.Get-Wallet"
      }
    })
    assert.equal("Not Found", _G.LastMessage["<Dummy>"].Tags["Status"])
  end)
end)
