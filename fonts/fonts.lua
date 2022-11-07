
Font = {
	fonts = {
		["dos8"] = love.graphics.newFont("fonts/fnt_ModernDOS8x8.ttf", 16, "mono"),
		["dos14"] = love.graphics.newFont("fonts/fnt_ModernDOS8x14.ttf", 16, "mono"),
		["dos16"] = love.graphics.newFont("fonts/fnt_ModernDOS8x16.ttf", 16, "mono"),
		["nokia_mod"] = love.graphics.newFont("fonts/8x8pixelFont.ttf", 8, "mono"),
		["start"] = love.graphics.newFont("fonts/fnt_pressStart.ttf", 8, "mono"),
		["retro"] = love.graphics.newFont("fonts/fnt_retroGaming.ttf", 11, "mono"),
	}
}

function Font.init()
	for _,v in pairs(Font.fonts) do
		v:setFilter("nearest", "nearest", 1)
	end
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