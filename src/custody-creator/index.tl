local sqlite = require("lsqlite3")
global IndexDb: DB
IndexDb = IndexDb or sqlite.open_memory()

local function initializeDb(): number
  return IndexDb:exec[[
CREATE TABLE IF NOT EXISTS Wallet(
  WalletId TEXT PRIMARY KEY NOT NULL,
  TimestampCreated INTEGER NOT NULL,
  TimestampModified INTEGER NOT NULL,
  ProcessId TEXT UNIQUE
);
]]
end

local function insertWallet(walletId: string): number
  local stmt = IndexDb:prepare[[
INSERT INTO Wallet(WalletId, TimestampCreated, TimestampModified)
VALUES(?, ?, ?);
]]
  if stmt == nil then
    error("Failed to prepare statement")
  end

  local timestamp = os.time()
  stmt:bind_values(walletId, timestamp, timestamp)
  local result = stmt:step()
  if result ~= sqlite.DONE then
    return result
  end
  return stmt:finalize()
end

local function setWalletProcess(walletId: string, processId: string): number
  local stmt = IndexDb:prepare[[
UPDATE Wallet SET TimestampModified = ?, ProcessId = ?
WHERE WalletId = ?;
]]
  if stmt == nil then
    error("Failed to prepare statement")
  end
  
  local timestamp = os.time()
  stmt:bind_values(timestamp, processId, walletId)
  stmt:step()
  return stmt:finalize()
end

local record WalletEntry
  WalletId: string | nil
  ProcessId: string | nil
end

local function getWalletProcess(walletId: string): WalletEntry
  local stmt = IndexDb:prepare[[
SELECT ProcessId FROM Wallet WHERE WalletId = ?;
]]
  stmt:bind_values(walletId)
  if stmt:step() == sqlite.ROW then
    local value = stmt:get_value(0)
    stmt:finalize()
    if value is string then
      return {
        WalletId = walletId,
        ProcessId = value
      }
    end
    return {
      WalletId = walletId,
      ProcessId = nil
    }
  end
  stmt:finalize()
  return {
    WalletId = nil,
    ProcessId = nil
  }
end

local function getProcessWallet(processId: string): WalletEntry
  local stmt = IndexDb:prepare[[
SELECT WalletId FROM Wallet WHERE ProcessId = ?;
]]
  stmt:bind_values(processId)
  if stmt:step() == sqlite.ROW then
    local value = stmt:get_value(0)
    stmt:finalize()
    return {
      WalletId = value as string,
      ProcessId = processId
    }
  end
  stmt:finalize()
  return {
    WalletId = nil,
    ProcessId = nil
  }
end

local record WalletStats
  Total: number
  Active: number
  Pending: number
end

local function getWalletStats(): WalletStats
  -- Query both rows, and rows with process Id set
  local stmt = IndexDb:prepare[[
SELECT COUNT(*) FROM Wallet;
]]
  stmt:step()
  local total = stmt:get_value(0) as number
  stmt:finalize()

  stmt = IndexDb:prepare[[
SELECT COUNT(*) FROM Wallet WHERE ProcessId IS NOT NULL;
]]
  stmt:step()
  local active = stmt:get_value(0) as number
  stmt:finalize()

  local pending = total - active

  return {
    Total = total as number,
    Active = active as number,
    Pending = pending as number
  }
end

return {
  InitializeDb = initializeDb,
  InsertWallet = insertWallet,
  SetWalletProcess = setWalletProcess,
  GetWalletProcess = getWalletProcess,
  GetProcessWallet = getProcessWallet,
  GetWalletStats = getWalletStats
}