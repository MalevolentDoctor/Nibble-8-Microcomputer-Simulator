require("init")

function love.load()
	App.init()
	Font.init()

	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setLineStyle("rough")

	love.keyboard.setKeyRepeat(true);
	GLOBAL_obj_workbench = Workbench.new();

	love.graphics.default_font = love.graphics.getFont();
end

function love.update(dt)
	-- ObjEditor:update();
	
	GLOBAL_obj_workbench:update()
end

function love.draw()
	local window_width, window_height = love.window.getMode()

	GLOBAL_obj_workbench:draw();
	-- Font:demo()

	love.graphics.setColor(1,1,1)
	love.graphics.draw(App.canvas, 0, 0, 0, App.scale, App.scale)

	-- debug stuff
	love.graphics.setFont(love.graphics.default_font)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), window_width - 110, window_height - 20)
end

function love.keypressed(key)
	if key == "capslock" then
		keyboard.capslock = not keyboard.capslock
	end
	keyboard.current_key = key;
end

function love.mousepressed(x, y, button)
	Mouse.current_key = button;
	Mouse.x = x;
	Mouse.y = y;
end
