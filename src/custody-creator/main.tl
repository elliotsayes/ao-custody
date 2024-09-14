local index = require('custody-creator.index')
local handlers = require('custody-creator.handlers')

global IsInitialized: boolean;
IsInitialized = IsInitialized or false;

if not IsInitialized then
  index.InitializeDb()
end

Handlers.add(
  "Info",
  Handlers.utils.hasMatchingTag("Action", "Info"),
  handlers.Info
)

Handlers.add(
  "Custody-Creator.Get-Wallet",
  Handlers.utils.hasMatchingTag("Action", "Custody-Creator.Get-Wallet"),
  handlers.GetWallet
)

Handlers.add(
  "Custody-Creator.Create-Custody",
  Handlers.utils.hasMatchingTag("Action", "Custody-Creator.Create-Custody"),
  handlers.CreateCustody
)
