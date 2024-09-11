require("custody.parse")

local depositHistory: { StakeDeposit }
local withdrawlHistory: { StakeWithdrawl }
local activeStakes: { StakeDeposit }

depositHistory = depositHistory or {}
withdrawlHistory = withdrawlHistory or {}
activeStakes = activeStakes or {}

local function recordDeposit(stakeDeposit: StakeDeposit)
  print("Recording deposit of " .. stakeDeposit.TokenId .. " from " .. stakeDeposit.Sender .. ": " .. tostring(stakeDeposit.Quantity))
  table.insert(depositHistory, stakeDeposit)
  table.insert(activeStakes, stakeDeposit)
end

local function recordWithdrawl(stakeWithdrawl: StakeWithdrawl)
  for i, stake in ipairs(activeStakes) do
    if stake.Id == stakeWithdrawl.Id then
      table.remove(activeStakes, i)
      table.insert(withdrawlHistory, stakeWithdrawl)
      break
    end
  end
end

local function getAllActiveStakes(): { StakeDeposit }
  return activeStakes
end

local function getActiveStakeById(stakeId: string): StakeDeposit | nil
  for _, stake in ipairs(activeStakes) do
    if stake.Id == stakeId then
      return stake
    end
  end
end

local function getActiveStakesBySender(sender: string): { StakeDeposit }
  local result = {}
  for _, stake in ipairs(activeStakes) do
    if stake.Sender == sender then
      table.insert(result, stake)
    end
  end
  return result
end

return {
  RecordDeposit = recordDeposit,
  RecardWithdrawl = recordWithdrawl,
  GetAllActiveStakes = getAllActiveStakes,
  GetActiveStakeById = getActiveStakeById,
  GetActiveStakesBySender = getActiveStakesBySender
}
