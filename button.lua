Button = {
	buttons = {}
}
Button.__index = Button

function Button.new(sprite, to, parent, pos, size)
	local self = {}
	self.flags = {visible = true}
	setmetatable(self, Button)

	self.sprite = sprite;
	self.to = to;
	self.parent = parent;

	if pos == nil then
		self.x = sprite.x;
		self.y = sprite.y;
	else
		self.x = pos[1];
		self.y = pos[2];
	end

	if size == nil then
		self.w = sprite.w*sprite.sx;
		self.h = sprite.h*sprite.sy;
	else
		self.w = size[1];
		self.h = size[2];
	end

	table.insert(Button.buttons, self);
	
	return self
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