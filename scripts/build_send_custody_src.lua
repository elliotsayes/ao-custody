local srcFile = io.open("custody.lua", "r")
if not srcFile then
  error("Could not open file")
end
local src = srcFile:read "*a"
srcFile:close()

local evalSrc = [==[
Send({
  Target = ao.id,
  Tags = {
    Action = 'EvalOnce',
  },
  Data = [=[
]==] .. src .. [==[

ao.send({
  Target = Owner,
  Action = 'AckSrc'
})

]=]
})
]==]

local writeFile = io.open("./send_custody_src_msg.lua", "w")
if not writeFile then
  error("Could not open file")
end
writeFile:write(evalSrc)
writeFile:close()
