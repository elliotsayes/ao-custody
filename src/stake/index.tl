local sqlite = require("lsqlite3")
local DB = sqlite.open_memory()

local function initializeDb(): number
  return DB:exec[[
CREATE TABLE IF NOT EXISTS Wallet(
  WalletId TEXT PRIMARY KEY NOT NULL,
  TimestampCreated INTEGER NOT NULL,
  TimestampModified INTEGER NOT NULL,
  ProcessId TEXT UNIQUE,
);
]]
end

local function insertWallet(walletId: string, timestamp: number): number
  local stmt = DB:prepare[[
INSERT into Wallet (WalletId, TimestampCreated, TimestampModified)
VALUES (?, ?, ?);
]]
  stmt:bind_values(walletId, timestamp, timestamp)
  stmt:step()
  return stmt:finalize()
end

local function setWalletProcess(walletId: string, timestamp: number, processId: string): number
  local stmt = DB:prepare[[
UPDATE Wallet SET TimestampModified = ?, ProcessId = ?
WHERE WalletId = ?;
]]
  stmt:bind_values(timestamp, processId, walletId)
  stmt:step()
  return stmt:finalize()
end

local function getWalletProcess(walletId: string): string|nil
  local stmt = DB:prepare[[
SELECT ProcessId FROM Wallet WHERE WalletId = ?;
]]
  stmt:bind_values(walletId)
  if stmt:step() == sqlite.ROW then
    local value = stmt:get_value(0)
    stmt:finalize()
    if type(value) == "string" then
      return value as string
    end
    return nil
  end
  stmt:finalize()
  return nil
end

return {
  InitializeDb = initializeDb,
  InsertWallet = insertWallet,
  SetWalletProcess = setWalletProcess,
  getWalletProcess = getWalletProcess
}