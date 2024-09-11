require('stake.const')

-- Returns the process ID of the spawned process
local function spawnProcess(walletId: string): string
  local req = ao.spawn(ao.env.Module.Id, {
    Name = "Custody-" .. walletId,
    Authority = CUSTODY_AUTHORITY,
  })
  local res = req.receive()
  
  return res.Tags['Process']
end

local function configureProcess(processId: string, walletId: string)
  local req = ao.send({
    Target = processId,
    Action = "EvalAck",
    Data = [[
BENEFICIARY_ADDRESS = "]] .. walletId .. [["
ALLOW_THIRD_PARTY_STAKE = true
WITHDRAW_TO_THIRD_PARTY = true
ao.addAssignable("CUSTODY_SRC_MSG", {
  Id = "]] .. CUSTODY_SRC_MSG .. [["
})
]]
  })
  local res = req.receive()
  if res == nil then
    error("Failed to configure process")
  end
end

local function loadSource(processId: string)
  ao.assign({
    Processes = { processId },
    Message = CUSTODY_SRC_MSG
  })
end

return {
  SpawnProcess = spawnProcess,
  ConfigureProcess = configureProcess,
  LoadSource = loadSource
}