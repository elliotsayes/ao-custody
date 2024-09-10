require('stake.const')
local index = require('stake.index')
local parse = require('stake.parse')

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
  local existingEntry = index.GetWalletProcess(msg.From)
  if existingEntry.WalletId ~= nil then
    return msg.reply({
      Error = "Already Created",
    })
  end

  index.InsertWallet(msg.From)

  local req = ao.spawn(ao.env.Module.Id, {
    Authority = CUSTODY_AUTHORITY,
  })

  -- TODO: complete
end

return {
  GetWallet = getWallet,
  CreateCustody = createCustody
}