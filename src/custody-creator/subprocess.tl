require('custody-creator.const')

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
  ao.send({
    Target = processId,
    Action = "Eval",
    Data = [[
CREATOR_PROCESS = "]] .. ao.id .. [["
BENEFICIARY_ADDRESS = "]] .. walletId .. [["

ao.addAssignable("CUSTODY_SRC_MSG", {
  Id = "]] .. CUSTODY_SRC_MSG .. [["
})

local eval = require('.eval')(ao)
EvalOnceHistory = EvalOnceHistory or {}
Handlers.add(
  'EvalOnce',
  Handlers.utils.hasMatchingTag('Action', 'EvalOnce'),
  function(msg)
    if msg.From == Owner and not EvalOnceHistory[msg.Id] then
      EvalOnceHistory[msg.Id] = true
      eval(msg)
    end
  end
)

ao.send({
  Target = CREATOR_PROCESS,
  Action = "AckCfg"
})
]]
  })

  Handlers.receive({
    From = processId,
    Action = "AckCfg"
  })
end

local function loadSource(processId: string)
  ao.assign({
    Processes = { processId },
    Message = CUSTODY_SRC_MSG
  })

  Handlers.receive({
    From = processId,
    Action = "AckSrc"
  })
end

return {
  SpawnProcess = spawnProcess,
  ConfigureProcess = configureProcess,
  LoadSource = loadSource
}