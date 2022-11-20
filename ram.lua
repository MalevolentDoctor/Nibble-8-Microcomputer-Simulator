Ram = {}
Ram.__index = Ram

function Ram.new(microcomputer, size)
	local self = {}
	setmetatable(self, Ram)

	self.thisMicrocomputer = microcomputer
	self.size = size

	-- create and initialise ram table
	self.ram = {}
	for i = 1,size do
		self.ram[i] = 0
	end

	return self
end

function Ram:update(dt)
end


function Ram:draw()
end