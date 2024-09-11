require("custody.const")
require("custody.parse")

local function refundTokens(creditNotice: CreditNotice): any
  local quantityStr = tostring(creditNotice.Quantity)
  print("Refunding " .. quantityStr .. " of " .. creditNotice.TokenId .. " tokens to " .. creditNotice.Sender)
  ao.send({
    Target = creditNotice.TokenId,
    Action = "Transfer",
    Quantity = quantityStr,
    Recipient = creditNotice.Sender,
  })
end

local function distributeCreditNotice(creditNotice: CreditNotice): any
  local quantityStr = tostring(creditNotice.Quantity)
  print("Distributing " .. quantityStr .. " of " .. creditNotice.TokenId .. " tokens to " .. BENEFICARY_ADDRESS)
  ao.send({
    Target = creditNotice.TokenId,
    Action = "Transfer",
    Quantity = quantityStr,
    Recipient = BENEFICARY_ADDRESS,
  })
end

return {
  RefundTokens = refundTokens
}