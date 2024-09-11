local parse = require('custody.parse')
local tokenconfig = require('custody.tokenconfig')
local ledger = require('custody.ledger')
local transfer = require('custody.transfer')

local function handleStakeDeposit(msg: Message, creditNotice: CreditNotice)
  local _, stakeDeposit = parse.parseStakeDeposit(msg, creditNotice)
  if stakeDeposit is string then
    print("Failed to parse stake deposit: " .. stakeDeposit)
    transfer.RefundCreditNotice(creditNotice)
    return
  end

  ledger.RecordDeposit(stakeDeposit)
end

local function handleCreditNotice(msg: Message)
  local _, creditNotice = parse.parseCreditNotice(msg)
  if creditNotice is string then
    print("Failed to parse credit notice: " .. creditNotice)
    return
  end

  if tokenconfig.IsStakingEnabled(creditNotice.TokenId) then
    handleStakeDeposit(msg, creditNotice)
  elseif tokenconfig.IsRewardEnabled(creditNotice.TokenId) then
    transfer.DistributeCreditNotice(creditNotice)
  else
    print("Unknown token id:" .. creditNotice.TokenId)
    print("Refunding " .. tostring(creditNotice.Quantity) .. " of " .. creditNotice.TokenId .. " tokens to " .. creditNotice.Sender)
    transfer.RefundCreditNotice(creditNotice)
  end
end

local function handleWithdraw(msg: Message): any
  local _, stakeWithdrawl = parse.parseStakeWithdrawl(msg)
  if stakeWithdrawl is string then
    return msg.reply({
      Error = "Invalid stake withdrawl request",
    })
  end

  local activeStake = ledger.GetActiveStakeById(stakeWithdrawl.Id)
  if activeStake is nil then
    return msg.reply({
      Error = "No active stake found for withdrawl: " .. stakeWithdrawl.Id,
    })
  end

  if activeStake.Sender ~= stakeWithdrawl.Sender then
    return msg.reply({
      Error = "Withdrawl of " .. activeStake.Id .. " stake can only be made by " .. activeStake.Sender,
    })
  end

  if os.time() < activeStake.WithdrawTimeMs then
    return msg.reply({
      Error = "Stake " .. activeStake.Id .. " cannot be withdrawn until " .. tostring(activeStake.WithdrawTimeMs),
    })
  end

  ledger.RecordWithdrawl(stakeWithdrawl)
  transfer.WithdrawFullStakeDeposit(activeStake)

  return msg.reply({
    Status = "Complete",
    StakeId = activeStake.Id,
  })
end

local function handleInfo(msg: Message): any
  local walletId = msg.From
  local activeStakes = ledger.GetActiveStakes()

  return msg.reply({
    WalletId = walletId,
    ['Stake-Count'] = tostring(#activeStakes),
  })
end

return {
  Info = handleInfo,
  CreditNotice = handleCreditNotice,
  Withdraw = handleWithdraw
}