local function validateArweaveAddress(address: string): boolean
  return string.match(address, "^[%w_-]{43}$") ~= nil
end

return {
  ValidateArweaveAddress = validateArweaveAddress
}