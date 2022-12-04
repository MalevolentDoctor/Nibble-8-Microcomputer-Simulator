Ram = {}
Ram.__index = Ram

function Ram.new(microcomputer, start, size)
	local self = {}
	setmetatable(self, Ram)

	self.thisMicrocomputer = microcomputer
	self.size = size

	-- create and initialise ram table
	self.ram = {}
	for i = start,(start + size - 1) do
		self.ram[i] = math.random(0,255)
	end

	return self
end

function Ram:update(dt)
end


function Ram:draw()
end