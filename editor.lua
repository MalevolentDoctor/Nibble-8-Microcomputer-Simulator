Editor = {};
Editor.__index = Editor

function Editor.new(console, x, y, w, h, shader_adjust)
	local self = {}
	setmetatable(self, Editor)

	self.active = true
	self.thisConsole = console -- desktop that started the editor

	self.x = x + (shader_adjust and 1 or 0)
    self.y = y + (shader_adjust and 1 or 0)
    self.w = w
    self.h = h

    -- file
    self.saved = true;              -- whether or not the current file is saved
    self.file_name = "Untitled"     -- name of the current file

    -- Other
    self.current_key = nil;         -- the current key that is pressed
    self.active = true;             -- whether or not the editor is active (visible)

    -- Other
    self.current_key = nil;         -- the current key that is pressed
    self.active = true;             -- whether or not the console is active (visible)

	-- Editor
    self.text = {n = 1, ""};        -- table of text
    self.top_line = 1;              -- top line visible
    self.max_line_num_buffer = 2;   -- number of spaces between line number and editor text (not quite?)

	self.vert_cursor = 1;           -- vertical position of the cursor
    self.horz_cursor = 1;           -- horizontal position of the cursor

	-- window parameters
	self.win = Window.new(self, self.x, self.y, self.w, self.h, 0, 40, 10, 0,
	{"dos16", "pxl_5x7_bold", "pxl_5x7_bold"}, -- fonts
	{{"202020", "101010"}, {"000"}, {"ccc", "ddd"}} -- colours
	)
    self.win.line_spacing = 3;
	self.win:init()

	function self.win:draw(editor)
		self:resetCurrentY()
        self:drawExternBackground()
        self:drawBackground()

        -- draw editor text
        local bottom_line = editor.top_line + editor.lines
        for i = editor.top_line, bottom_line do
            if editor.text[i] ~= nil then
                local line_num_buffer = string.rep(" ", editor.max_line_num_buffer - string.len(tostring(i)) - 1)
                self:printText(line_num_buffer .. tostring(i) .. "  " .. editor.text[i], self.fnt_txt2)
            end
        end
	end

	self.win:init()

	self.lines = math.floor((self.win.h_int - 1)/(self.win.fnt_txt2_h + self.win.line_spacing))

    self.nav_vert_cursor = {
        ["up"] = -1, ["down"] = 1,
        ["pageup"] = -self.lines, ["pagedown"] = self.lines
    }

	print("Created console successfully")
	return self
end

function Editor:update()
    if self.active then
        local char_key = keyboard:getCharKey();
        local nav_key = keyboard:getNavKey();
        local edit_key = keyboard:getEditKey();
        local misc_key = keyboard:getMiscKey();
        local fun_key = keyboard:getFunKey();

        if char_key ~= nil then self:charInput(char_key) end
        if edit_key == "enter" then self:enter() end
        if edit_key == "backspace" then self:backspace() end
        if edit_key == "delete" then self:del() end

        if nav_key == "left" then self:cursorLeft() end
        if nav_key == "right" then self:cursorRight() end

        if nav_key == "home" then self:cursorHome() end
        if nav_key == "end" then self:cursorEnd() end

        if (nav_key == "up" or nav_key == "down" or nav_key == "pageup" or nav_key == "pagedown") then
            self:shiftVertCursor(self.nav_vert_cursor[nav_key])
        end

        if misc_key == "escape" then
			self.active = false
            self.thisConsole.active = true
		end

        keyboard:reset();
    end
end

-- draw funciton
function Editor:draw()
    if self.active == true then
        -- draw window
        self.win:draw(self)

        -- draw cursor
        local editor_cursor_x = self.win.x_int + (self.horz_cursor + self.max_line_num_buffer)*self.win.fnt_txt2_w;
        local editor_cursor_y = self.win.y_int + (self.vert_cursor - self.top_line) * ((self.win.fnt_txt2_h + self.win.line_spacing)) - 1;

        love.graphics.setColor(1,1,1,0.5);
        love.graphics.rectangle("fill", editor_cursor_x, editor_cursor_y, self.win.fnt_txt2_w, self.win.fnt_txt2_h + 2)

        -- reset colour
        love.graphics.setColor(1,1,1,1);
    end
end

do -- TEXT MODIFICATION [backspace, delete, enter character]
--     -- input a character at the cursor
    function Editor:charInput(char)
        self.text[self.vert_cursor] = self.text[self.vert_cursor]:insert(char, self.horz_cursor)
        self.horz_cursor = self.horz_cursor + char:len();
        self.saved = false;
    end

    -- backspace
    function Editor:backspace()
        if self.horz_cursor == 1 then -- if at the beginning of a line, the backspace will remove a line
            if self.vert_cursor ~= 1 then
                local new_horz_cursor = string.len(self.text[self.vert_cursor - 1]) + 1; 
                self.text[self.vert_cursor - 1] = self.text[self.vert_cursor - 1] .. self.text[self.vert_cursor];
                table.remove(self.text, self.vert_cursor)
                self.vert_cursor = self.vert_cursor - 1;
                self.horz_cursor = new_horz_cursor;
                self.text.n = self.text.n - 1;
                self.max_line_num_buffer = string.len(tostring(self.text.n)) + 1;
                self:updateScrollPosition();
            end
        else
            self.text[self.vert_cursor] = self.text[self.vert_cursor]:remove(self.horz_cursor - 1, self.horz_cursor - 1)
            self.horz_cursor = self.horz_cursor - 1;
        end
        self.saved = false;
    end

    -- delete (key)
    function Editor:del()
        if self.horz_cursor == self:thisLineLen() + 1 then -- if at the beginning of a line, the backspace will remove a line
            if self.vert_cursor ~= self.text.n then
                self.text[self.vert_cursor] = self.text[self.vert_cursor] .. self.text[self.vert_cursor + 1];
                table.remove(self.text, self.vert_cursor + 1)
                self.text.n = self.text.n - 1;
                self.max_line_num_buffer = string.len(tostring(self.text.n)) + 1;
                self:updateScrollPosition();
            end
        else
            self.text[self.vert_cursor] = self.text[self.vert_cursor]:remove(self.horz_cursor, self.horz_cursor)
        end
        self.saved = false;
    end

end

do -- NAVIGATION [enter, arrow keys, home/end/pg up/pg down]
    -- enter in editor
    function Editor:enter()
        local right_text = "";
        local left_text = self.text[self.vert_cursor]

        if self.horz_cursor == 1 then
            right_text = left_text;
            left_text = "";
        elseif self.horz_cursor <= string.len(left_text) then
            right_text = string.sub(left_text, self.horz_cursor, -1);
            left_text = string.sub(left_text, 1, self.horz_cursor - 1);
        end

        self.text[self.vert_cursor] = left_text;
        table.insert(self.text, self.vert_cursor + 1, right_text)

        self.horz_cursor = 1;
        self.vert_cursor = self.vert_cursor + 1;
        self.text.n = self.text.n + 1;
        
        self:updateScrollPosition();
        
        self.max_line_num_buffer = string.len(tostring(self.text.n)) + 1;
        self.saved = false;
    end

    -- move cursor 1 space to the left or right
    function Editor:cursorLeft()
        if self.horz_cursor ~= 1 then
            self.horz_cursor = self.horz_cursor - 1;
        end

        self:updateScrollPosition();
    end

    function Editor:cursorRight()
        if self.horz_cursor ~= string.len(self.text[self.vert_cursor]) + 1 then
            self.horz_cursor = self.horz_cursor + 1
        end

        self:updateScrollPosition();
    end
    
    -- move the vertical cursor by the amount specified by shift.
    function Editor:shiftVertCursor(shift)
        if shift < 0 then
            self.vert_cursor = math.max(1, self.vert_cursor + shift)
        else
            self.vert_cursor = math.min(self.text.n, self.vert_cursor + shift)
        end

        self.horz_cursor = math.min(self.horz_cursor, string.len(self.text[self.vert_cursor]) + 1)
        self:updateScrollPosition()
    end

    function Editor:cursorHome()
        self.horz_cursor = 1
    end

    function Editor:cursorEnd()
        self.horz_cursor = self:thisLineLen() + 1
    end

    -- update the region of the screen visible so that the cursor may be seen
    function Editor:updateScrollPosition()
        local bottom_line = self.top_line + self.lines - 1
        if self.vert_cursor > bottom_line then
            self.top_line = self.vert_cursor - self.lines
        end

        if self.vert_cursor < self.top_line then
            self.top_line = self.vert_cursor
        end
    end
end

do -- EDITOR FUNCIONS [setFont, setMode, refresh, thisLineLen]
    -- returns the length of the current line
    function Editor:thisLineLen()
        return self.text[self.vert_cursor]:len()
    end

    -- Resets the cursor and the scroll position and saved state
    function Editor:reset()
        self.saved = true;
        self.vert_cursor = 1;
        self.horz_cursor = 1;
        self.top_line = 1;
        self.max_line_num_buffer = string.len(tostring(self.text.n)) + 1;
        self:updateScrollPosition();
    end
end