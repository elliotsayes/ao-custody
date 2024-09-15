require('custody.const')
require('custody.subscription')
local handlers = require('custody.handlers')

Handlers.add(
  'Info',
  Handlers.utils.hasMatchingTag("Action", "Info"),
  handlers.Info
)

Handlers.add(
  'Custody.Credit-Notice',
  function(msg: Message): boolean
    return Handlers.utils.hasMatchingTag("Action", "Credit-Notice")(msg)
        and not Handlers.utils.hasMatchingTag("X-Action", "Pay-For-Subscription")(msg)
  end,
  handlers.CreditNotice
)

Handlers.add(
  'Custody.Withdraw',
  Handlers.utils.hasMatchingTag("Action", "Custody.Withdraw"),
  handlers.Withdraw
)

Handlers.add(
  'Custody.Get-Active-Stakes',
  Handlers.utils.hasMatchingTag("Action", "Custody.Get-Active-Stakes"),
  handlers.GetActiveStakes
)
