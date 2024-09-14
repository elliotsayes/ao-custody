local parse = require('custody-creator.parse')
local index = require('custody-creator.index')
local subprocess = require('custody-creator.subprocess')

local function getWallet(msg: Message): any
  local otherWalletId = msg.Tags['Wallet-Id']
  if otherWalletId ~= nil and parse.ValidateArweaveAddress(otherWalletId) == false then
    return msg.reply({
      Error = "Invalid Wallet Id",
    })
  end

  local walletId = otherWalletId or msg.From
  local entry = index.GetWalletProcess(walletId)

  if entry.WalletId == nil then
    return msg.reply({
      Status = "Not Found",
      WalletId = walletId,
    })
  end

  if entry.ProcessId == nil then
    return msg.reply({
      Status = "Pending",
      WalletId = entry.WalletId,
    })
  end

  return msg.reply({
    Status = "Success",
    WalletId = entry.WalletId,
    ProcessId = entry.ProcessId,
  })
end

local function createCustody(msg: Message): any
  local walletId = msg.From

  local existingEntry = index.GetWalletProcess(walletId)
  if existingEntry.WalletId ~= nil then
    return msg.reply({
      Error = "Already Created",
    })
  end

  index.InsertWallet(walletId)

  local processId = subprocess.SpawnProcess(walletId)
  subprocess.ConfigureProcess(processId, walletId)
  subprocess.LoadSource(processId)

  index.SetWalletProcess(walletId, processId)

  msg.reply({
    Status = "Complete",
    WalletId = walletId,
    ProcessId = processId,
  })
end

local function info(msg: Message): any
  local stats = index.GetWalletStats()

  msg.reply({
    Protocol = "Custody-Creator",
    Total = tostring(stats.Total),
    Active = tostring(stats.Active),
    Pending = tostring(stats.Pending),
  })
end

return {
  Info = info,
  GetWallet = getWallet,
  CreateCustody = createCustody
}