local json = require "json"

local function newmodule(selfId)
  local token = {}

  local ao = require "ao" (selfId)

  token.mockBalance = "100"

  function token.handle(msg)
    if msg.Tags.Action == "Balance" then
      ao.send({ Target = msg.From, Balance = token.mockBalance })
    end
  end

  return token
end
return newmodule
