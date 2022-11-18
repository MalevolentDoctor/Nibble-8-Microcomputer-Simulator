Computer = {}
Computer.__index = Computer

function Computer.new()
	local self = {}
	setmetatable(self, Computer)

	return self
end


function Computer:update()
end

function Computer:draw()
end