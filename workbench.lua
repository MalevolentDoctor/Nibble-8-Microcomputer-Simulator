Workbench = {}
Workbench.__index = Workbench

function Workbench.new()
	local self = {}
	setmetatable(self, Workbench)

	self.objComputer = Computer.new(self) -- object of the desktop (your PC) screen
	self.objMicrocomputer = Microcomputer.new(self) -- object containing the microcomputer

	self.page = 0

	self.spr_workbench_pg1_bg = Sprite.new(0, 0, 1/3, 1/3, {"assets/png/workbench_pg1_hires.png"}, "linear")
	self.temp_canvas = love.graphics.newCanvas(App.window_width, App.window_height)

	return self
end

function Workbench:update(dt)
	local fun_key = keyboard:getFunKey();

	-- switch between the pages using function keys
	if fun_key == "f1" then self.page = 0 end
	if fun_key == "f2" then self.page = 1 end

	if self.page == 0 then
		-- if on the first page we update the desktop screen on the computer
		self.objComputer:update()
	elseif self.page == 1 then
		self.objMicrocomputer:update(dt)
	end
end

function Workbench:draw()
	if self.page == 0 then
		-- if on the first page we draw the desktop screen on the computer
		self.objComputer:draw()
		self.spr_workbench_pg1_bg:draw()
	elseif self.page == 1 then
		love.graphics.setCanvas(self.temp_canvas)
		self.objMicrocomputer:draw()
		love.graphics.reset()
		love.graphics.draw(self.temp_canvas, 0, 0, 0, App.scale, App.scale)
	end
end