require("init")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.keyboard.setKeyRepeat(true);

	--print("Program loaded");

	ObjDesktop = Desktop:new();
	--ObjPIC8 = Micro:new(4, 1, 8, 32);
	--ObjEditor = TextEditor:new(0, 0, 1280, 720, 20, "edit");
	love.graphics.default_font = love.graphics.getFont();
end


function love.update(dt)
	-- ObjEditor:update();
	Desktop:update()
end


function love.draw()
	local window_width, window_height = love.window.getMode()
	-- ObjEditor:draw();
	ObjDesktop:draw();
	-- Font:demo()

	-- debug stuff
	love.graphics.setFont(love.graphics.default_font)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), window_width - 110, window_height - 20)
end

function love.keypressed(key)
	if key == "capslock" then
		keyboard.capslock = not keyboard.capslock
	end
	keyboard.current_key = key;
end

function love.mousepressed(x, y, button)
	mouse.current_key = button;
	mouse.x = x;
	mouse.y = y;
end
