local json = require('json')
local parse = require('custody.parse')
local tokenconfig = require('custody.tokenconfig')
local ledger = require('custody.ledger')
local transfer = require('custody.transfer')
local subscription = require('custody.subscription')

local function handleStakeDeposit(msg: Message, creditNotice: CreditNotice)
  local _, stakeDeposit = parse.parseStakeDeposit(msg, creditNotice)
  if stakeDeposit is string then
    print("Failed to parse stake deposit: " .. stakeDeposit)
    transfer.RefundCreditNotice(creditNotice)
    return
  end

  ledger.RecordDeposit(stakeDeposit)
  subscription.NotifyTopic("stake-deposit", stakeDeposit)
end

local function handleDistributeReward(creditNotice: CreditNotice)
  transfer.DistributeCreditNotice(creditNotice)
  subscription.NotifyTopic("distribute", creditNotice)
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
    handleDistributeReward(creditNotice)
  else
    print("Unknown token id:" .. creditNotice.TokenId)
    print("Refunding " .. tostring(creditNotice.Quantity) .. " of " .. creditNotice.TokenId .. " tokens to " .. creditNotice.Sender)
    transfer.RefundCreditNotice(creditNotice)
  end
end

local function handleWithdraw(msg: Message): any
  local _, stakeWithdrawal = parse.parseStakeWithdrawal(msg)
  if stakeWithdrawal is string then
    return msg.reply({
      Error = "Invalid stake withdrawal request",
    })
  end

  local activeStake = ledger.GetActiveStakeById(stakeWithdrawal.Id)
  if activeStake is nil then
    return msg.reply({
      Error = "No active stake found for withdrawal: " .. stakeWithdrawal.Id,
    })
  end

  if activeStake.Sender ~= stakeWithdrawal.Sender then
    return msg.reply({
      Error = "Withdrawal of " .. activeStake.Id .. " stake can only be made by " .. activeStake.Sender,
    })
  end

  if os.time() < activeStake.WithdrawTimeMs then
    return msg.reply({
      Error = "Stake " .. activeStake.Id .. " cannot be withdrawn until " .. tostring(activeStake.WithdrawTimeMs),
    })
  end

  ledger.RecordWithdrawal(stakeWithdrawal)
  transfer.WithdrawFullStakeDeposit(activeStake)
  subscription.NotifyTopic("stake-withdrawal", stakeWithdrawal)

  return msg.reply({
    Status = "Complete",
    StakeId = activeStake.Id,
  })
end

local function handleInfo(msg: Message): any
  local activeStakes = ledger.GetActiveStakes()
  local data = json.encode({
    StakingTokens = tokenconfig.GetStakingTokens(),
    RewardTokens = tokenconfig.GetRewardTokens(),
  })

  return msg.reply({
    Protocol = "Custody",
    ['Stake-Count'] = tostring(#activeStakes),
    Data = data,
  })
end

return {
  Info = handleInfo,
  CreditNotice = handleCreditNotice,
  Withdraw = handleWithdraw
}