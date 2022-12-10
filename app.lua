App = {
	scale = 1,
}

function App.init()
	App.update()
	local w, h = love.window.getMode()
	App.canvas = love.graphics.newCanvas(math.floor(w/2), math.floor(h/2))
	App.canvas:setFilter("nearest", "nearest", 1)
end

function App.update()
	local w, h = love.window.getMode()
	App.window_width = math.floor(w / App.scale)
	App.window_height = math.floor(h / App.scale)
end

function App.getWindowSize()
	return App.window_width, App.window_height
end