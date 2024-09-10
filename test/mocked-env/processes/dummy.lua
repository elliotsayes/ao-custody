local json = require "json"

local function newmodule(selfId)
  local dummy = {}

  function dummy.handle(msg)
    print(selfId .. ": " .. msg.From .. " says " .. (msg.Data or "<nil>"))
    -- Print out tags table
    print(json.encode(msg.Tags))

    _G.LastMessage = msg
  end

  return dummy
end
return newmodule
