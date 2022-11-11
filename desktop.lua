Desktop = {};

function Desktop:new()
    setmetatable({}, Desktop)

    self.header_font = Font.fonts["dos16"];     -- font (type) used in desktop header
    self.header_border = 2;
    
    self.active = true;

    -- Colours
    self.bg_col = Colour.hex("1B1026");
    self.header_col = Colour.hex("1F1B24");
    self.header_text_col = Colour.hex("B5A8C6");

    -- Calculated values
    
    self.header_font_height = self.header_font:getHeight();                 -- height of font used in desktop header
    self.header_font_width = self.header_font:getWidth("a");                -- width (assuming monospaced) of the font used in desktop header
    self.header_height = self.header_font_height + 2*self.header_border;    -- height of the header bar

    -- images
    self.spr_editor_icon = Sprite.new( -- editor icon
        5, self.header_height + 10, 1, 1, 
        {"assets/png/editor.png", "assets/png/editor_hover.png"},
        {hover = true, visible = false}
    )
    self.btn_editor = Button.new(self.spr_editor_icon, self.openEditor, self)

    self.spr_microcomputer_icon = Sprite.new( -- microcontroller icon
        65, self.header_height + 10, 1, 1, 
        {"assets/png/microcontroller.png", "assets/png/microcontroller_hover.png"},
        {hover = true, visible = false}
    )
    self.btn_mc = Button.new(self.spr_microcomputer_icon, self.openMicrocomputer, self)

    self.spr_file_icon = Sprite.new( -- file icon
        125, self.header_height + 10, 1, 1,
        {"assets/png/file.png", "assets/png/file_hover.png"},
        {hover = true}
    )

    self.spr_console_icon = Sprite.new( -- file icon
        185, self.header_height + 10, 1, 1,
        {"assets/png/console.png", "assets/png/console_hover.png"},
        {hover = true, visible = false}
    )
    self.btn_console = Button.new(self.spr_console_icon, self.openConsole, self)

    --self.cursor = love.mouse.newCursor("assets/png/cursor.png", 10, 10);
    --love.mouse.setCursor(self.cursor);

    self.obj_editor = {};
    self.obj_mcomputer = {};
    self.obj_mcontroller = {};
    self.obj_console = {}

    self.applications = {obj_editor = {}, obj_mcomputer = {}, obj_mcontroller = {}, obj_console = {}}

    return self
end

function Desktop:update()
    local mx, my = Mouse.getPosition();

    if self.active == true then
        for _,v in ipairs(Sprite.sprites) do
            if v.flags.hover then
                if v:inBB(mx, my) then v.i = 2 else v.i = 1 end
            end
        end

        local _,_,m_btn = Mouse.getKey()
        if m_btn == 1 then
            for _,v in ipairs(Button.buttons) do
                if v:inBB(mx, my) then
                    v:pressed()
                end
            end
        end
    end

    if self.obj_editor.active then
        self.obj_editor:update();
    elseif self.obj_mcomputer.active then
        self.obj_mcomputer:update();
    elseif self.obj_console.active then
        self.obj_console:update()
    else
        self.active = true;
    end

    Mouse.reset();
end

function Desktop:draw()
    local window_width, window_height = App.getWindowSize()

    -- background
    love.graphics.setColor(self.bg_col);
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)

    -- header
    love.graphics.setColor(self.header_col);
    love.graphics.rectangle("fill", 0, 0, window_width, self.header_height)

    love.graphics.setColor(0,0,0,1); love.graphics.setLineWidth(2)
    love.graphics.line(0, self.header_height, window_width, self.header_height);

    love.graphics.setColor(self.header_text_col)
    love.graphics.setFont(self.header_font)
    love.graphics.print("Nibble-8", 5, self.header_border)

    -- sprites
    love.graphics.setColor(1,1,1)
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

    -- drawing applications
    -- for app,_ in pairs(self.applications) do
    --     if self.applications[app].active then
    --         self.applications[app]:draw()
    --     end
    -- end
    
    if self.obj_editor.active == true then
        self.obj_editor:draw()
    end

    if self.obj_mcomputer.active == true then
        self.obj_mcomputer:draw()
    end

    if self.obj_console.active == true then
        self.obj_console:draw()
    end

end

function Desktop:openEditor()
    local window_width, window_height = App.getWindowSize()

    if self.obj_editor.active == nil then
        self.obj_editor = Editor.new(0, 0, window_width, window_height, "console");
        self.active = false;
        self.spr_editor_icon.i = 1;
    elseif self.obj_editor.active == false then
        self.obj_editor.active = true;
        self.active = false
        self.spr_editor_icon.i = 1;
    end
end

function Desktop:openMicrocomputer()
    if self.obj_mcomputer.active == nil then
        self.obj_mcontroller = Microcontroller.new(9, 65536, 10, 2)
        self.obj_mcomputer = Microcomputer.new(self.obj_mcontroller)
        self.active = false
        self.spr_microcomputer_icon.i = 1
    elseif self.obj_mcomputer.active == false then
        self.obj_mcomputer.active = true
        self.active = false
        self.spr_microcomputer_icon.i = 1
    end
end

function Desktop:openConsole()
    if self.obj_console.active == nil then
        self.obj_console = Console.new(self)
        self.active = false
        self.spr_console_icon.i = 1
    elseif self.obj_console.active == false then
        self.obj_console.active = true
        self.active = false
        self.spr_console_icon.i = 1
    end
end