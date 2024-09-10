local index = require('stake.index')

local function getWallet(msg: Message): any
  local walletId = msg.Tags['Wallet-Id'] or msg.From
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

return {
  GetWallet = getWallet
}