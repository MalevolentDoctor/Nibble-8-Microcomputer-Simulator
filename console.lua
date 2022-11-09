Console = {}
Console.__index = Console

function Console:new()
	self = {}
	setmetatable(self, Console)

	return self
end
