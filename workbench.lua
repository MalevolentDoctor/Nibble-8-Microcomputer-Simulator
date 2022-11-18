Workbench = {}
Workbench.__index = Workbench

function Workbench.new()
	self = {}
	setmetatable(self, Workbench)
	return self
end

function Workbench:update()
end

function Workbench:draw()
end