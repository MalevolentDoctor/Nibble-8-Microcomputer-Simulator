Workbench = {}
Workbench.__index = Workbench

function Workbench.new()
	local self = {}
	setmetatable(self, Workbench)

	self.obj_computer = Computer.new() -- object of the desktop (your PC) screen
	self.obj_microcomputer = Microcomputer.new() -- object containing the microcomputer

	self.page = 0

	self.crt = love.graphics.newShader("shaders/fragment/frag_crt.glsl", "shaders/vertex/vert_passthrough.glsl")
	self.spr_workbench_pg1_bg = Sprite.new(0, 0, App.scale, App.scale, {"assets/png/workbench_pg1.png"})

	return self
end

function Workbench:update()
	local fun_key = keyboard:getFunKey();

	-- switch between the pages using function keys
	if fun_key == "f1" then self.page = 0 end
	if fun_key == "f2" then self.page = 1 end

	if self.page == 0 then
		-- if on the first page we update the desktop screen on the computer
		self.obj_computer:update()
	end
end

function Workbench:draw()
	if self.page == 0 then
		-- if on the first page we draw the desktop screen on the computer
		self.obj_computer:draw()
		self.spr_workbench_pg1_bg:draw()
	end
end