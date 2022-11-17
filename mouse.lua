Mouse = {
	current_key = nil,
	x = 0,
	y = 0,
}

function Mouse.reset()
	Mouse.current_key = nil;
end

function Mouse.getKey()
	return Mouse.x, Mouse.y, Mouse.current_key
end

-- gets the position of the mouse scaled to glob_scale
function Mouse.getPosition()
	local mx, my = love.mouse.getPosition()
	mx = math.floor(mx/App.scale);
    my = math.floor(my/App.scale);
	return mx, my
end