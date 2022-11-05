---@diagnostic disable: lowercase-global

Button = {
	buttons = {},
	flags = {visible = true}
}
Button.__index = Button

function Button.new(sprite, to, parent, pos, size)
	obj = {}
	setmetatable(obj, Button)

	obj.sprite = sprite;
	obj.to = to;
	obj.parent = parent;

	if pos == nil then
		obj.x = sprite.x;
		obj.y = sprite.y;
	else
		obj.x = pos[1];
		obj.y = pos[2];
	end

	if size == nil then
		obj.w = sprite.w*sprite.sx;
		obj.h = sprite.h*sprite.sy;
	else
		obj.w = size[1];
		obj.h = size[2];
	end

	table.insert(Button.buttons, obj);
	
	return obj
end

function Button:pressed()
	self.to(self.parent)
end

function Button:inBB(x, y)
    if x >= self.x and x <= self.x + self.w then
        if y >= self.y and y <= self.y + self.h then
            return true
        else
            return false
        end
    end
end