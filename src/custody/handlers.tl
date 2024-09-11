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

return {
  HandleCreditNotice = handleCreditNotice
}