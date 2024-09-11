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

local stake_index = require "stake.index"

describe("stake.index", function()
  setup(function()
  end)

  teardown(function()
  end)

  it("should initialize the DB", function()
    local res = stake_index.InitializeDb()
    assert.equal(0, res)
  end)

  it("should not get nonexistant wallet", function()
    local res = stake_index.GetWalletProcess("0x1234")
    assert.is_nil(res.WalletId)
    assert.is_nil(res.ProcessId)
  end)

  it("should add a wallet", function()
    local res = stake_index.InsertWallet("0x1234")
    assert.equal(0, res, "Failed to insert wallet")
  end)

  it("should fail to insert the duplicate wallet", function()
    local res = stake_index.InsertWallet("0x1234")
    assert.Not.equal(0, res)
  end)

  it("should only get wallet for unset process", function()
    local res = stake_index.GetWalletProcess("0x1234")
    assert.equal("0x1234", res.WalletId)
    assert.is_nil(res.ProcessId)
  end)

  it("should not get the wallet's process", function()
    local res = stake_index.GetWalletProcess("0x5678")
    assert.is_nil(res.WalletId)
    assert.is_nil(res.ProcessId)
  end)

  it("should set process for wallet", function()
    local res = stake_index.SetWalletProcess("0x1234", "0x5678")
    assert.equal(0, res)
  end)

  it("should now get the wallet's process", function()
    local res = stake_index.GetWalletProcess("0x1234")
    assert.equal("0x1234", res.WalletId)
    assert.equal("0x5678", res.ProcessId)
  end)

  it("should now get the process's wallet", function()
    local res = stake_index.GetProcessWallet("0x5678")
    assert.equal("0x1234", res.WalletId)
    assert.equal("0x5678", res.ProcessId)
  end)
end)
