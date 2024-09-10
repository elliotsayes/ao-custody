local index = require('stake.index')

global IsInitialized: boolean;
IsInitialized = IsInitialized or false;

if not IsInitialized then
  index.InitializeDb()
end
