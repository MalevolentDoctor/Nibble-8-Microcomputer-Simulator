function love.conf(t)
	t.window.title = "8-bit Microcontroller"
	t.window.height = 720; -- 360, 720, 1080, 1440, 1800, 2160
	t.window.width = 1280; -- 640, 1280, 1920, 2560, 3200, 3840
	t.console = false;
	t.window.msaa = 0;
	t.window.vsync = false;
end