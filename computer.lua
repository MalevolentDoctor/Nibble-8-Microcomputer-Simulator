Computer = {}
Computer.__index = Computer

function Computer.new(parent_workbench)
	local self = {}
	setmetatable(self, Computer)

	self.objConsole = Console.new(self, 0, 0, App.window_width - 400, App.window_height - 80, true)
	self.canvas_screen = love.graphics.newCanvas(self.objConsole.w + 2, self.objConsole.h + 2)
	self.thisWorkbench = parent_workbench
	-- self.canvas_screen:setFilter("linear", "linear", 1)

	self.crt = love.graphics.newShader("shaders/fragment/frag_crt.glsl", "shaders/vertex/vert_passthrough.glsl")

	return self
end


function Computer:update()
	self.objConsole:update()
end

function Computer:draw()
	love.graphics.setCanvas(self.canvas_screen)
	self.objConsole:draw()
	love.graphics.reset()

	love.graphics.setShader(self.crt)
	self.crt:send("window_width", App.window_width)
	self.crt:send("window_scale", App.scale)
	love.graphics.draw(self.canvas_screen, 100, 20, 0, App.scale, App.scale)

	love.graphics.reset()
end