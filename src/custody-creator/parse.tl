local function validateArweaveId(address: string): boolean
  if not address or type(address) ~= 'string' then
		return false
	end
	return string.match(address, "^[%w%-_]+$") ~= nil and #address == 43
end

return {
  ValidateArweaveId = validateArweaveId
}