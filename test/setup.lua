local originalRequire = require

local function mockedRequire(moduleName)
  if moduleName == "ao" then
    return originalRequire("test.mocked-env.ao.ao")
  end

  if moduleName == "handlers-utils" then
    return originalRequire("test.mocked-env.ao.handlers-utils")
  end

  if moduleName == "handlers" then
    return originalRequire("test.mocked-env.ao.handlers")
  end

  if moduleName == "aocred" then
    return originalRequire("test.mocked-env.processes.aocred")
  end

  if moduleName == ".bint" then
    return originalRequire("test.mocked-env.lib.bint")
  end

  if moduleName == ".utils" then
    return originalRequire("test.mocked-env.lib.utils")
  end

  if moduleName == "json" then
    return originalRequire("test.mocked-env.lib.json")
  end

  if moduleName == "lsqlite3" then
    return originalRequire("lsqlite3complete")
  end

  -- Subscribable bundled deps
  if moduleName == "storage-vanilla" or moduleName == "pkg-api" then
    return originalRequire(moduleName)
  end

  if moduleName == "luassert.namespaces" then
    return originalRequire(moduleName)
  end

  local mockPrefix = "mocked-env."
  if string.sub(moduleName, 0, string.len(mockPrefix)) == mockPrefix then
    return originalRequire("test." .. moduleName)
  end

  return originalRequire("build-lua." .. moduleName)
end

return function()
  -- Override the require function globally for the tests
  _G.require = mockedRequire

  -- -- Restore the original require function after all tests
  -- teardown(function()
  --   _G.require = originalRequire
  -- end)
end
