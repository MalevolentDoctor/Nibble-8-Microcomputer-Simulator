Sprite = {
    sprites = {}
}
Sprite.__index = Sprite

function Sprite.new(x, y, sx, sy, images, filter, flags)
    local self = {}
    self.flags = {hover = false, visible = true}
    setmetatable(self, Sprite)

    self.x = x;          -- x position of the sprite
    self.y = y;          -- y position of the sprite
    self.sx = sx;        -- x scale of the sprite
    self.sy = sy;        -- y scale of the sprite
    self.i = 1;          -- sprite index

    self.images = {}     -- sprite images
    for i,v in ipairs(images) do
        self.images[i] = love.graphics.newImage(v)
        self.images[i]:setFilter(filter, filter, 16)
    end
    
    self.w = self.images[self.i]:getWidth();
    self.h = self.images[self.i]:getHeight();

    if flags ~= nil then
        for k,v in pairs(self.flags) do
            if flags[k] ~= nil then
                self.flags[k] = flags[k];
            end
        end
    end

    table.insert(Sprite.sprites, self);

    return self
end

function Sprite:draw()
    love.graphics.draw(self.images[self.i], self.x, self.y, 0.0, self.sx, self.sy)
end

function Sprite:animate()
end

function Sprite:inBB(x, y)
    if x >= self.x and x <= self.x + self.w*self.sx then
        if y >= self.y and y <= self.y + self.h*self.sy then
            return true
        else
            return false
        end
    end
end