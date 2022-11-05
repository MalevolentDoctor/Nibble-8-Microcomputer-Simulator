Desktop = {

};

function Desktop:new()
    setmetatable({}, Desktop)
    
    self.header_font_size = 2;             -- size of font in desktop header
    self.header_font_name = "dos16";       -- name of font used in desktop header
    self.header_border = 2;

    self.active = true;

    -- Colours
    self.bg_col = colour.hex("1B1026");
    self.header_col = colour.hex("1F1B24");
    self.header_text_col = colour.hex("B5A8C6");

    -- Calculated values
    self.header_font = Font.fonts[self.header_font_name .. "_" .. self.header_font_size];   -- font (type) used in desktop header
    self.header_font_height = self.header_font:getHeight();                                 -- height of font used in desktop header
    self.header_font_width = self.header_font:getWidth("a");                                -- width (assuming monospaced) of the font used in desktop header
    self.header_height = self.header_font_height + 2*self.header_border;                    -- height of the header bar

    -- images
    self.spr_editor_icon = Sprite.new( -- editor icon
        10, self.header_height + 10, 2, 2, 
        {"assets/png/editor.png", "assets/png/editor_hover.png"},
        {hover = true, visible = false}
    )
    self.btn_editor = Button.new(self.spr_editor_icon, self.openEditor, self)

    self.spr_microcontroller_icon = Sprite.new( -- microcontroller icon
        130, self.header_height + 10, 2, 2, 
        {"assets/png/microcontroller.png", "assets/png/microcontroller_hover.png"},
        {hover = true}
    )
    
    self.spr_file_icon = Sprite.new( -- file icon
        250, self.header_height + 10, 2, 2,
        {"assets/png/file.png", "assets/png/file_hover.png"},
        {hover = true}
    )

    self.cursor = love.mouse.newCursor("assets/png/cursor.png", 10, 10);
    love.mouse.setCursor(self.cursor);

    self.obj_editor = {};

    return self
end

function Desktop:update()
    local window_width, window_height = love.window.getMode()
    local mx, my = love.mouse.getPosition();

    if self.active == true then
        for _,v in ipairs(Sprite.sprites) do
            if v.flags.hover then
                if v:inBB(mx, my) then v.i = 2 else v.i = 1 end
            end
        end

        local _,_,m_btn = mouse.getKey()
        if m_btn == 1 then
            for _,v in ipairs(Button.buttons) do
                if v:inBB(mx, my) then
                    v:pressed()
                end
            end
        end
    end

    if self.obj_editor.active == true then
        self.obj_editor:update();
    else
        self.active = true;
    end

    mouse.reset();
end

function Desktop:draw()
    local window_width, window_height = love.window.getMode()

    -- background
    love.graphics.setColor(self.bg_col);
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)

    -- header
    love.graphics.setColor(self.header_col);
    love.graphics.rectangle("fill", 0, 0, window_width, self.header_height)

    love.graphics.setColor(0,0,0,1); love.graphics.setLineWidth(2)
    love.graphics.line(0, self.header_height, window_width, self.header_height);

    love.graphics.setColor(self.header_text_col)
    love.graphics.print("Nibble-8", self.header_font, 5, self.header_border)

    -- sprites
    for _,v in pairs(Sprite.sprites) do
        if v.flags.visible then
            Sprite.draw(v)
        end
    end

    -- buttons
    for _,v in pairs(Button.buttons) do
        if v.flags.visible then
            Sprite.draw(v.sprite)
        end
    end


    if self.obj_editor.active == true then
        self.obj_editor:draw()
    end

end

function Desktop:openEditor()
    local window_width, window_height = love.window.getMode()

    if self.obj_editor.active == nil then
        self.obj_editor = Editor:new(50, 50, window_width - 100, window_height - 100, "console");
        self.active = false;
        self.spr_editor_icon.i = 1;
    elseif self.obj_editor.active == false then
        self.obj_editor.active = true;
        self.active = false
        self.spr_editor_icon.i = 1;
    end
end