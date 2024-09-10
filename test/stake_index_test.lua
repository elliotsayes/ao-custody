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
    assert(res == 0, "Failed to initialize the database")
  end)

  it("should not get nonexistant wallet", function()
    local res = stake_index.GetWalletProcess("0x1234")
    assert(res.WalletId == nil, "Should have failed get wallet")
    assert(res.ProcessId == nil, "Should have failed get process")
  end)

  it("should add a wallet", function()
    local res = stake_index.InsertWallet("0x1234", 100)
    assert(res == 0, "Failed to insert wallet")
  end)

  it("should fail to insert the duplicate wallet", function()
    local res = stake_index.InsertWallet("0x1234", 100)
    assert(res ~= 0, "Should have failed to insert wallet")
  end)

  it("should only get wallet for unset process", function()
    local res = stake_index.GetWalletProcess("0x1234")
    assert(res.WalletId == "0x1234", "Should have got wallet Id")
    assert(res.ProcessId == nil, "Should have failed get process")
  end)

  it("should not get the wallet's process", function()
    local res = stake_index.GetWalletProcess("0x5678")
    assert(res.WalletId == nil, "Should have failed get wallet")
    assert(res.ProcessId == nil, "Should have failed get process")
  end)

  it("should set process for wallet", function()
    local res = stake_index.SetWalletProcess("0x1234", 100, "0x5678")
    assert(res == 0, "Should have failed to get process")
  end)

  it("should now get the wallet's process", function()
    local res = stake_index.GetWalletProcess("0x1234")
    assert(res.WalletId == "0x1234", "Failed to get wallet process")
    assert(res.ProcessId == "0x5678", "Failed to get wallet process")
  end)

  it("should now get the process's wallet", function()
    local res = stake_index.GetProcessWallet("0x5678")
    assert(res.WalletId == "0x1234", "Failed to get process wallet")
    assert(res.ProcessId == "0x5678", "Failed to get process wallet")
  end)
end)
