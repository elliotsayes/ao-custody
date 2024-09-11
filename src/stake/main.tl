local index = require('stake.index')
local handlers = require('stake.handlers')

global IsInitialized: boolean;
IsInitialized = IsInitialized or false;

if not IsInitialized then
  index.InitializeDb()
end

Handlers.add(
  "Custody-Index.Get-Wallet",
  Handlers.utils.hasMatchingTag("Action", "Custody-Index.Get-Wallet"),
  handlers.GetWallet
)

Handlers.add(
  'Custody-Index.Create-Custody',
  Handlers.utils.hasMatchingTag("Action", "Custody-Index.Create-Custody"),
  handlers.CreateCustody
)
