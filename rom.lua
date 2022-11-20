Rom = {}
Rom.__index = Rom

function Rom.new(microcomputer, size)
	local self = {}
	setmetatable(self, Rom)

	self.thisMicrocomputer = microcomputer
	self.size = size

	-- create and initialise rom table
	self.rom = {}
	for i = 1,size do
		self.rom[i] = 0
	end

	return self
end

function Rom:update(dt)
end


function Rom:draw()
end