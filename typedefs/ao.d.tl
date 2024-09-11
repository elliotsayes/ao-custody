global record ao
  id: string
  send: function(message: {string: string}): Message
  record env
    record Module
      Id: string
    end
    record Process
      Tags: { string: string }
      Owner: string
    end
  end
  spawn: function(module: string, tags: {string: string}): Message
  assign: function(AssignArgs)
end

global type MatchedHandler = function(msg: Message): boolean

global record Handlers
  add: function
  receive: function
  record utils
    hasMatchingTag: function(tag: string, value: string): MatchedHandler
    hasMatchingTagOf: function(tag: string, values: {string}): MatchedHandler
    hasMatchingData: function(value: string): MatchedHandler
    reply: function(input: string | {string: string}): function (msg: Message): nil
    continue: function<F>(fn: F): F
  end
end

global record Message
  Id: string
  From: string
  Target: string
  Timestamp: number
  Tags: { string: string }
  Data: string
  Owner: string
  reply: function({string: string}): nil
  receive: function(): Message
end

local record AssignArgs
  Processes: {string}
  Message: string
end

global record TokenNotice
  Id: string
  From: string
  Tags: { string: string }
  Data: string
  Owner: string
  Target: string
  Action: string
  Sender: string
  Recipient: string
  Quantity: string
end

global record Colors
  red: string
  green: string
  blue: string
  reset: string
  gray: string
end