
require('custody.const')
local createSubscribable = require('subscribable.subscribable')

global Subscribable: TSubscribable
Subscribable = createSubscribable({
  useDB = false
})

Subscribable.configTopicsAndChecks({
  ['stake-deposit'] = {
    description = 'Stake Deposit',
    returns = '',
    subscriptionBasis = '',
  },
  ['stake-withdrawal'] = {
    description = 'Stake Withdrawal',
    returns = '',
    subscriptionBasis = '',
  },
  ['distribute'] = {
    description = 'Distribute',
    returns = '',
    subscriptionBasis = '',
  },
})

Subscribable.registerSubscriber(BENEFICARY_ADDRESS, true)

local enum SubscriptionTopic
  'stake-deposit'
  'stake-withdrawal'
  'distribute'
end

local function notifyTopic(topic: SubscriptionTopic, data: any)
  Subscribable.notifyTopic(topic, data, os.time())
end

return {
  NotifyTopic = notifyTopic
}