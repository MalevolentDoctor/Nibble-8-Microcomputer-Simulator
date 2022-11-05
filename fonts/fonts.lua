
Font = {
	fonts = {
		["dos8_1"] = love.graphics.newFont("fonts/fnt_ModernDOS8x8.ttf", 16),
		["dos8_2"] = love.graphics.newFont("fonts/fnt_ModernDOS8x8.ttf", 32),
		["dos8_3"] = love.graphics.newFont("fonts/fnt_ModernDOS8x8.ttf", 48),

		["dos14_1"] = love.graphics.newFont("fonts/fnt_ModernDOS8x14.ttf", 16),
		["dos14_2"] = love.graphics.newFont("fonts/fnt_ModernDOS8x14.ttf", 32),
		["dos14_3"] = love.graphics.newFont("fonts/fnt_ModernDOS8x14.ttf", 48),

		["dos16_1"] = love.graphics.newFont("fonts/fnt_ModernDOS8x16.ttf", 16),
		["dos16_2"] = love.graphics.newFont("fonts/fnt_ModernDOS8x16.ttf", 32),
		["dos16_3"] = love.graphics.newFont("fonts/fnt_ModernDOS8x16.ttf", 48),

		["nokia_1"] = love.graphics.newFont("fonts/fnt_nokia.ttf", 8),
		["nokia_2"] = love.graphics.newFont("fonts/fnt_nokia.ttf", 16),
		["nokia_3"] = love.graphics.newFont("fonts/fnt_nokia.ttf", 24),

		["start_1"] = love.graphics.newFont("fonts/fnt_pressStart.ttf", 8),
		["start_2"] = love.graphics.newFont("fonts/fnt_pressStart.ttf", 16),
		["start_3"] = love.graphics.newFont("fonts/fnt_pressStart.ttf", 24),

		["retro_1"] = love.graphics.newFont("fonts/fnt_retroGaming.ttf", 11),
		["retro_2"] = love.graphics.newFont("fonts/fnt_retroGaming.ttf", 22),
		["retro_3"] = love.graphics.newFont("fonts/fnt_retroGaming.ttf", 33),
	}
}


function Font:demo()
	local y = 5;
	local x = 5;
	for k,v in pairs(self.fonts) do
		love.graphics.print(k, v, x, y)
		y = y + v:getHeight() + 2;
	end
end