local srcFile = io.open("custody.lua", "r")
if not srcFile then
  error("Could not open file")
end
local src = srcFile:read "*a"
srcFile:close()

local evalSrc = [==[
Send({
  Target = 'fcoN_xJeisVsPXA-trzVAuIiqO3ydLQxM-L4XbrQKzY',
  Tags = {
    Action = 'Eval',
  },
  Data = [=[
]==] .. src .. [==[
]=]
})
]==]

local writeFile = io.open("./send_custody_src_msg.lua", "w")
if not writeFile then
  error("Could not open file")
end
writeFile:write(evalSrc)
writeFile:close()
