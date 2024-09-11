require("custody.const")
require("custody.parse")

local function refundCreditNotice(creditNotice: CreditNotice)
  local quantityStr = tostring(creditNotice.Quantity)
  print("Refunding " .. quantityStr .. " of " .. creditNotice.TokenId .. " tokens to " .. creditNotice.Sender)
  ao.send({
    Target = creditNotice.TokenId,
    Action = "Transfer",
    Quantity = quantityStr,
    Recipient = creditNotice.Sender,
  })
end

local function distributeCreditNotice(creditNotice: CreditNotice)
  local quantityStr = tostring(creditNotice.Quantity)
  print("Distributing " .. quantityStr .. " of " .. creditNotice.TokenId .. " tokens to " .. BENEFICARY_ADDRESS)
  ao.send({
    Target = creditNotice.TokenId,
    Action = "Transfer",
    Quantity = quantityStr,
    Recipient = BENEFICARY_ADDRESS,
  })
end

local function withdrawFullStakeDeposit(stakeDeposit: StakeDeposit)
  local quantityStr = tostring(stakeDeposit.Quantity)
  print("Withdrawing " .. quantityStr .. " of " .. stakeDeposit.TokenId .. " tokens to " .. stakeDeposit.Sender)
  ao.send({
    Target = stakeDeposit.TokenId,
    Action = "Transfer",
    Quantity = quantityStr,
    Recipient = stakeDeposit.Sender,
  })
end

return {
  RefundCreditNotice = refundCreditNotice,
  DistributeCreditNotice = distributeCreditNotice,
  WithdrawFullStakeDeposit = withdrawFullStakeDeposit,
}