require("custody.parse")

local depositHistory: { StakeDeposit }
local withdrawalHistory: { StakeWithdrawal }
local activeStakes: { StakeDeposit }

depositHistory = depositHistory or {}
withdrawalHistory = withdrawalHistory or {}
activeStakes = activeStakes or {}

local function recordDeposit(stakeDeposit: StakeDeposit)
  print("Recording deposit of " .. stakeDeposit.TokenId .. " from " .. stakeDeposit.Sender .. ": " .. tostring(stakeDeposit.Quantity))
  table.insert(depositHistory, stakeDeposit)
  table.insert(activeStakes, stakeDeposit)
end

local function recordWithdrawal(stakeWithdrawal: StakeWithdrawal)
  for i, stake in ipairs(activeStakes) do
    if stake.Id == stakeWithdrawal.Id then
      table.remove(activeStakes, i)
      table.insert(withdrawalHistory, stakeWithdrawal)
      break
    end
  end
end

local function getActiveStakes(): { StakeDeposit }
  return activeStakes
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

local function getActiveStakeById(stakeId: string): StakeDeposit | nil
  for _, stake in ipairs(activeStakes) do
    if stake.Id == stakeId then
      return stake
    end
  end
end

return {
  RecordDeposit = recordDeposit,
  RecordWithdrawal = recordWithdrawal,
  GetActiveStakes = getActiveStakes,
  GetActiveStakesBySender = getActiveStakesBySender,
  GetActiveStakeById = getActiveStakeById
}
