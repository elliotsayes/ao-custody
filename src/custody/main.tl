local handlers = require('custody.handlers')

Handlers.add(
  'Custody.Credit-Notice',
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  handlers.HandleCreditNotice
)
