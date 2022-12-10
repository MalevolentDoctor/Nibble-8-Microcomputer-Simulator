
Font = {
	fonts = {
		["dos8"] = love.graphics.newFont("fonts/fnt_ModernDOS8x8.ttf", 16, "mono"),
		["dos14"] = love.graphics.newFont("fonts/fnt_ModernDOS8x14.ttf", 16, "mono"),
		["dos16"] = love.graphics.newFont("fonts/fnt_ModernDOS8x16.ttf", 16, "mono"),
		["nokia_mod"] = love.graphics.newFont("fonts/8x8pixelFont.ttf", 8, "mono"),
		["start"] = love.graphics.newFont("fonts/fnt_pressStart.ttf", 8, "mono"),
		["retro"] = love.graphics.newFont("fonts/fnt_retroGaming.ttf", 11, "mono"),
		["pxl_5x7_thin"] = love.graphics.newFont("fonts/fnt_pixel_5x7_thin.ttf", 14, "mono"),
		["pxl_5x7_bold"] = love.graphics.newFont("fonts/fnt_pixel_5x7_bold.ttf", 14, "mono"),
		["pxl_3x5_thin"] = love.graphics.newFont("fonts/fnt_pixel_3x5_thin_allcaps.ttf", 14, "mono"),
	}
}

function Font.init()
	for _,v in pairs(Font.fonts) do
		v:setFilter("nearest", "nearest", 1)
	end
end

-- returns the font, its width and its height
function Font.getFont(name)
	local fnt = Font.fonts[name]
	local w = fnt:getWidth("A")
	local h = fnt:getHeight()
	return fnt, w, h
end

function Font:demo()
	local y = 5;
	local x = 5;
	for k,v in pairs(self.fonts) do
		love.graphics.setFont(v)
		love.graphics.print(k, x, y)
		y = y + v:getHeight() + 2;
	end
end