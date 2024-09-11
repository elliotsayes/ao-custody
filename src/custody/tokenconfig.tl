local bint = require("utils.bint")()

global record Bounds
  Min: number
  Max: number
end

global record BoundsBint
  Min: BigInteger
  Max: BigInteger
end

global record StakingTokenConfig
  Enabled: boolean
  QuantityBounds: BoundsBint
  DurationBounds: Bounds
end

local type StakingTokens = { string: StakingTokenConfig }

local stakingTokens: StakingTokens = {
  -- Wrapped Arweave (everPay)
  ["xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10"] = {
    Enabled = true,
    QuantityBounds = {
      Min = bint.frominteger(10 ^ 9), -- 0.001 wAR
      Max = bint.frominteger(10 ^ 15), -- 1000 wAR
    },
    DurationBounds = {
      Min = 1 * 24 * 60 * 60 * 1000, -- 1 day
      Max = 365 * 24 * 60 * 60 * 1000, -- 1 year
    },
  },
}

local function isStakingEnabled(tokenId: string): boolean
  return stakingTokens[tokenId] ~= nil and stakingTokens[tokenId].Enabled
end

local function getStakingTokenConfig(tokenId: string): StakingTokenConfig | nil
  local tokenConfig = stakingTokens[tokenId]
  return tokenConfig
end

global record RewardTokenConfig 
  Enabled: boolean
end

local type RewardTokens = { string: RewardTokenConfig }

local rewardTokens: RewardTokens = {
  -- AO token
  ["m3PaWzK4PTG9lAaqYQPaPdOcXdO8hYqi5Fe9NWqXd0w"] = {
    Enabled = true,
  },
}

local function isRewardEnabled(tokenId: string): boolean
  return rewardTokens[tokenId] ~= nil and rewardTokens[tokenId].Enabled
end

return {
  IsStakingEnabled = isStakingEnabled,
  GetStakingTokenConfig = getStakingTokenConfig,
  IsRewardEnabled = isRewardEnabled
}