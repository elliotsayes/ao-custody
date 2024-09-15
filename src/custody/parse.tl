local tokens = require("custody.tokenconfig")
local bint = require("utils.bint")()

local function validateArweaveId(address: string | nil): boolean
  if not address or type(address) ~= 'string' then
		return false
	end
	return string.match(address, "^[%w%-_]+$") ~= nil and #address == 43
end

local function withinBoundsInclusive(value: number, bounds: Bounds): boolean
  return value >= bounds.Min and value <= bounds.Max
end

local function withinBoundsInclusiveStr(value: string, bounds: BoundsStr): boolean
  local valueBint = bint.fromstring(value)
  return valueBint:ge(bint.fromstring(bounds.Min)) and valueBint:le(bint.fromstring(bounds.Max))
end

local function validateCreditNoticeQuantity(quantity: string | nil): boolean
  local quantityNum = bint.fromstring(quantity)
  if quantityNum == nil or not quantityNum:gt(bint.zero()) then
    return false
  end
  return true
end

local function validateStakeQuantity(config: StakingTokenConfig, quantityStr: string): boolean
  local bounds = config.QuantityBounds
  return withinBoundsInclusiveStr(quantityStr, bounds)
end

local function parseStakeDuration(config: StakingTokenConfig, duration: string | nil): number
  local durationNum = tonumber(duration)
  if durationNum == nil then
    return nil
  end
  local bounds = config.DurationBounds
  if withinBoundsInclusive(durationNum, bounds) then
    return durationNum
  else
    return nil
  end
end

global record CreditNotice
  Id: string
  TokenId: string
  Sender: string
  Quantity: string
end

local function parseCreditNotice(msg: Message): (boolean, CreditNotice | string)
  local tokenId = msg.From

  local sender = msg.Tags.Sender
  if not validateArweaveId(sender) then
    return false, "Invalid sender address for staking"
  end

  local quantity = msg.Tags.Quantity
  if not validateCreditNoticeQuantity(msg.Tags.Quantity) then
    return false, "Invalid quantity for staking from " .. sender
  end

  local creditNotice: CreditNotice = {
    Id = msg.Id,
    TokenId = tokenId,
    Sender = sender,
    Quantity = quantity,
  }
  return true, creditNotice
end

global record StakeDeposit
  Id: string
  TokenId: string
  Sender: string
  Quantity: string
  DepositTimeMs: number
  StakeDurationMs: number
  WithdrawTimeMs: number
end

local function parseStakeDeposit(msg: Message, creditNotice: CreditNotice): (boolean, StakeDeposit | string)
  local tokenConfig = tokens.GetStakingTokenConfig(creditNotice.TokenId)
  if tokenConfig == nil then
    return false, "Could not find token config for " .. creditNotice.TokenId
  end
  
  local isValidQuantity = validateStakeQuantity(tokenConfig, creditNotice.Quantity)
  if not isValidQuantity then
    return false, "Invalid quantity for staking from " .. creditNotice.Sender
  end

  local stakeDurationMs = parseStakeDuration(tokenConfig, msg.Tags['X-Stake-Duration'])
  if stakeDurationMs == nil then
    return false, "Invalid duration for staking from " .. creditNotice.Sender
  end

  local depositTimeMs = msg.Timestamp
  local withdrawTimeMs = depositTimeMs + stakeDurationMs
  local stakeDeposit: StakeDeposit = {
    Id = creditNotice.Id,
    TokenId = creditNotice.TokenId,
    Sender = creditNotice.Sender,
    Quantity = creditNotice.Quantity,
    DepositTimeMs = depositTimeMs,
    StakeDurationMs = stakeDurationMs,
    WithdrawTimeMs = withdrawTimeMs,
  }
  return true, stakeDeposit
end

global record StakeWithdrawal
  Id: string
  Sender: string
end

local function parseStakeWithdrawal(msg: Message): boolean, StakeWithdrawal | string
  local stakeId = msg.Tags['Stake-Id']
  if not validateArweaveId(stakeId) then
    return false, "Invalid Stake-Id"
  end
  local stakeWithdrawal: StakeWithdrawal = {
    Id = stakeId,
    Sender = msg.From,
  }
  return true, stakeWithdrawal
end

return {
  validateArweaveId = validateArweaveId,
  parseCreditNotice = parseCreditNotice,
  parseStakeDeposit = parseStakeDeposit,
  parseStakeWithdrawal = parseStakeWithdrawal
}