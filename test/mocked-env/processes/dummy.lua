local function newmodule(selfId)
  local dummy = {}

  function dummy.handle(msg)
    print(msg.From .. " => " .. selfId)
    -- Print out tags table
    for k, v in pairs(msg.Tags) do
      print("  " .. k .. " = " .. v)
    end

    _G.LastMessage[selfId] = msg
  end

  return dummy
end
return newmodule
