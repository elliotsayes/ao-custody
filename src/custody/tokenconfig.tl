local bint = require('utils.bint')()
local utils = require('utils.tl-utils')

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
      Min = bint(10):ipow(bint(9)), -- 0.001 wAR
      Max = bint(10):ipow(bint(15)), -- 1000 wAR
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

global record BoundsStr
  Min: string
  Max: string
end

global record StakingTokenConfigExport
  Enabled: boolean
  QuantityBounds: BoundsStr
  DurationBounds: Bounds
end

local type StakingTokensExport = { string: StakingTokenConfigExport }

local function getStakingTokens(): StakingTokensExport
  local stakingTokensExport: StakingTokensExport = {}
  for tokenId, tokenConfig in pairs(stakingTokens) do
    stakingTokensExport[tokenId] = {
      Enabled = tokenConfig.Enabled,
      QuantityBounds = {
        Min = tostring(tokenConfig.QuantityBounds.Min),
        Max = tostring(tokenConfig.QuantityBounds.Max),
      },
      DurationBounds = tokenConfig.DurationBounds,
    }
  end
  return stakingTokensExport
end

local function getRewardTokens(): RewardTokens
  return utils.deepcopy(rewardTokens) as RewardTokens
end

return {
  GetStakingTokens = getStakingTokens,
  GetRewardTokens = getRewardTokens,
  RewardTokens = rewardTokens,
  IsStakingEnabled = isStakingEnabled,
  GetStakingTokenConfig = getStakingTokenConfig,
  IsRewardEnabled = isRewardEnabled
}