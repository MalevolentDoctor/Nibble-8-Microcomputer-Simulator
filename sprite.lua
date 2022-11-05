---@diagnostic disable: lowercase-global

Sprite = {
    sprites = {},
    flags = {hover = false, visible = true}
}
Sprite.__index = Sprite

function Sprite.new(x, y, sx, sy, images, flags)
    obj = {};
    setmetatable(obj, Sprite)

    obj.x = x;          -- x position of the sprite
    obj.y = y;          -- y position of the sprite
    obj.sx = sx;        -- x scale of the sprite
    obj.sy = sy;        -- y scale of the sprite
    obj.i = 1;          -- sprite index

    obj.images = {}     -- sprite images
    for i,v in ipairs(images) do
        obj.images[i] = love.graphics.newImage(v)
    end
    
    obj.w = obj.images[obj.i]:getWidth();
    obj.h = obj.images[obj.i]:getHeight();

    obj.flags = {}                      -- setting the sprite flags
    for k,v in pairs(Sprite.flags) do
        if flags == nil then
            obj.flags[k] = v;
        elseif flags[k] == nil then
            obj.flags[k] = v;
        else
            obj.flags[k] = flags[k];
        end
    end

    table.insert(Sprite.sprites, obj);

    return obj
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