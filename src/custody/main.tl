local handlers = require('custody.handlers')

Handlers.add(
  'Info',
  Handlers.utils.hasMatchingTag("Action", "Info"),
  handlers.Info
)

Handlers.add(
  'Custody.Credit-Notice',
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  handlers.CreditNotice
)

Handlers.add(
  'Custody.Withdraw',
  Handlers.utils.hasMatchingTag("Action", "Custody.Withdraw"),
  handlers.Withdraw
)
