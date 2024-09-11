local tokens = require("custody.tokenconfig")
local bint = require("utils.bint")()

local function validateArweaveAddress(address: string | nil): boolean
  return string.match(address, "^[%w_-]{43}$") ~= nil
end

local function withinBoundsInclusive(value: number, bounds: Bounds): boolean
  return value >= bounds.Min and value <= bounds.Max
end

local function withinBoundsInclusiveBint(value: BigInteger, bounds: BoundsBint): boolean
  return value:ge(bounds.Min) and value:le(bounds.Max)
end

local function parseCreditNoticeQuantity(quantity: string | nil): BigInteger
  local quantityNum = bint.fromstring(quantity)
  if quantityNum == nil or not quantityNum:gt(bint.zero()) then
    return nil
  end
  return quantityNum
end

local function validateStakeQuantity(config: StakingTokenConfig, quantityBint: BigInteger): boolean
  local bounds = config.QuantityBounds
  return withinBoundsInclusiveBint(quantityBint, bounds)
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
  Quantity: BigInteger
end

local function parseCreditNotice(msg: Message): (boolean, CreditNotice | string)
  local tokenId = msg.From

  local sender = msg.Tags.Sender
  if not validateArweaveAddress(sender) then
    return false, "Invalid sender address for staking"
  end

  local quantity = parseCreditNoticeQuantity(msg.Tags.Quantity)
  if quantity == nil then
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
  Quantity: BigInteger
  StakeTimeMs: number
  StakeDurationMs: number
  WithdrawTimeMs: number
end

local function parseStakeDeposit(msg: Message, creditNotice: CreditNotice): (boolean, StakeDeposit | string)
  local tokenConfig = tokens.GetStakingTokenConfig(creditNotice.TokenId)
  if tokenConfig == nil then
    return false, "Could not find token config for " .. creditNotice.TokenId
  end

  local validQuantity = validateStakeQuantity(tokenConfig, creditNotice.Quantity)
  if not validQuantity then
    return false, "Invalid quantity for staking from " .. creditNotice.Sender
  end

  local stakeDurationMs = parseStakeDuration(tokenConfig, msg.Tags['X-Stake-Duration'])
  if stakeDurationMs == nil then
    return false, "Invalid duration for staking from " .. creditNotice.Sender
  end

  local stakeTimeMs = msg.Timestamp
  local withdrawTimeMs = stakeTimeMs + stakeDurationMs
  local stakeDeposit: StakeDeposit = {
    Id = creditNotice.Id,
    TokenId = creditNotice.TokenId,
    Sender = creditNotice.Sender,
    Quantity = creditNotice.Quantity,
    StakeTimeMs = stakeTimeMs,
    StakeDurationMs = stakeDurationMs,
    WithdrawTimeMs = withdrawTimeMs,
  }
  return true, stakeDeposit
end

global record StakeWithdrawl
  Id: string
  Sender: string
end

local function parseStakeWithdrawl(msg: Message): (boolean, StakeWithdrawl | string)
  local sender = msg.From
  local stakeWithdrawl: StakeWithdrawl = {
    Id = msg.Id,
    Sender = sender,
  }
  return true, stakeWithdrawl
end

return {
  parseCreditNotice = parseCreditNotice,
  parseStakeDeposit = parseStakeDeposit,
  parseStakeWithdrawl = parseStakeWithdrawl
}