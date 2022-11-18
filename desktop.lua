Desktop = {};
Desktop.__index = Desktop

function Desktop.new()
    local self = {}
    setmetatable(self, Desktop)

    self.active = true;

    self.win = Window.new(0, 0, App.window_width, App.window_width, 0, 0, 5, 0,
	{"dos16", "pxl_5x7_bold", "pxl_5x7_thin"}, -- fonts
	{{"1B1026", "1F1B24"}, {"000"}, {"B5A8C6", "ddd"}} -- colours
	)
	self.win:init()

	function self.win:draw(desktop)
        self:resetCurrentY()
        self:drawBackground()
        self:drawTitle("Nibble-8", true)
        self:hline(2)
    end

    do -- Load Sprites
    self.spr_editor_icon = Sprite.new( -- editor icon
        5, self.win.hdr_h + 10, 1, 1, 
        {"assets/png/editor.png", "assets/png/editor_hover.png"},
        {hover = true, visible = false}
    )
    
    self.spr_microcomputer_icon = Sprite.new( -- microcontroller icon
        65, self.win.hdr_h + 10, 1, 1, 
        {"assets/png/microcontroller.png", "assets/png/microcontroller_hover.png"},
        {hover = true, visible = false}
    )
    

    self.spr_file_icon = Sprite.new( -- file icon
        125, self.win.hdr_h + 10, 1, 1,
        {"assets/png/file.png", "assets/png/file_hover.png"},
        {hover = true}
    )

    self.spr_console_icon = Sprite.new( -- file icon
        185, self.win.hdr_h + 10, 1, 1,
        {"assets/png/console.png", "assets/png/console_hover.png"},
        {hover = true, visible = false}
    )
    end

    self.btn_editor = Button.new(self.spr_editor_icon, self.openEditor, self)
    self.btn_mc = Button.new(self.spr_microcomputer_icon, self.openMicrocomputer, self)
    self.btn_console = Button.new(self.spr_console_icon, self.openConsole, self)

    -- table of applications running from the desktop
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

    local apps_active = 0;
    for app,_ in pairs(self.applications) do
        if self.applications[app].active then
            self.applications[app]:update()
            apps_active = apps_active + 1
        end
    end
    if apps_active == 0 then
        self.active = true;
    end

    Mouse.reset();
end

function Desktop:draw()
    self.win:draw(self)

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
    for app,_ in pairs(self.applications) do
        if self.applications[app].active then
            self.applications[app]:draw()
        end
    end
end

function Desktop:openEditor()
    if self.applications.obj_editor.active == nil then
        self.applications.obj_editor = Editor.new(self);
        self.active = false;
        self.spr_editor_icon.i = 1;
    elseif self.applications.obj_editor.active == false then
        self.applications.obj_editor.active = true;
        self.active = false
        self.spr_editor_icon.i = 1;
    end
end

function Desktop:openMicrocomputer()
    if self.applications.obj_mcomputer.active == nil then
        self.applications.obj_mcontroller = Microcontroller.new(9, 65536, 10, 2)
        self.applications.obj_mcomputer = Microcomputer.new(self.applications.obj_mcontroller)
        self.active = false
        self.spr_microcomputer_icon.i = 1
    elseif self.applications.obj_mcomputer.active == false then
        self.applications.obj_mcomputer.active = true
        self.active = false
        self.spr_microcomputer_icon.i = 1
    end
end

function Desktop:openConsole()
    if self.applications.obj_console.active == nil then
        self.applications.obj_console = Console.new(self)
        self.active = false
        self.spr_console_icon.i = 1
    elseif self.applications.obj_console.active == false then
        self.applications.obj_console.active = true
        self.active = false
        self.spr_console_icon.i = 1
    end
end