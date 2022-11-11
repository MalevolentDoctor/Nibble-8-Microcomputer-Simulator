-- UPDATES TO MAKE
--[[
    Smarter Tab-ing (doesn't just jump 4 spaces)
    Cursor remembers horizontal position
--]]

Editor = {
    help_text = {
        help_list = {"build", "clc", "close", "exit", "help", "load", "new", "save"},
        build = {
            "build  assembles file to Nibble-8 machine code",
            "build <file>:  assembles current file in editor to Nibble-8 machine code",
            "   prefix with `!' to override warnings",
            "parameters:",
            "   <file>  file to save the machine code to, default extension is .bin"
        },
        clc = {
            "clc    clears the console",
            "clc:  clears the console window of all text"
        },
        close = {
            "close  minimizes the editor",
            "close:  minimizes the editor window, all work is persistent",
            "   use `exit' to exit the editor entirely",
        },
        exit = {
            "exit   exits the editor",
            "exit:  exits the editor window, all work is cleared",
            "   use `close' to minimise the window and keep work",
            "   *currently does not work and performs the same operation as `close'"
        },
        help = {
            "help   summary of commands or help for specified command",
            "help:            provides a summary of commands",
            "help <command>:  provides the details for a specific command"
        },
        load = {
            "load   loads a file",
            "load <file>:  loads a file from the specified directory into the editor",
            "   prefix with `!' to override warnings",
            "parameters: ",
            "   <file>  directory from which to laod the file, default extension is .txt"
        },
        new = {
            "new    creates a new file",
            "new:  clears the current file open in the editor to leave a blank page",
            "   prefix with `!' to override warnings",
        },
        save = {
            "save   saves current file",
            "save <file>:  saves the current file in the editor to a file at the specified directory",
            "   prefix with `!' to override warnings",
            "parameters: ",
            "   <file>  directory at which to save the file, default extension is .txt"
        }
    }
};
Editor.__index = Editor

function Editor.new(x, y, width, height, mode)
    local self = {}
    setmetatable(self, Editor)

    -- Configuration
    self.x = x;                     -- x position of the top left of the editor window
    self.y = y;                     -- y position of the top left of the editor window
    self.width = width;             -- width of the window
    self.height = height;           -- height of the window
    self.x_border = 20;       -- size of the vertical borders
    self.y_border = 2;              -- size of the horizontal borders
    self.mode = mode;               -- mode of the editor ("edit"/"console")

    -- Font
    self.text_font = Font.fonts["pxl_5x7_thin"];   -- font (type) used in editor/console
    self.ui_font = Font.fonts["dos16"];         -- font (type) used in editor UI

    -- file
    self.saved = true;              -- whether or not the current file is saved
    self.file_name = "Untitled"     -- name of the current file

    -- Other
    self.current_key = nil;         -- the current key that is pressed
    self.active = true;             -- whether or not the editor is active (visible)
    
    -- Editor
    self.editor_text = {n = 1, ""}; -- table of text in editor
    self.editor_header_buffer = 24  -- height of the header of the editor
    self.editor_top_line = 1;       -- line visible at the top of the editor window (changes when scrolling)
    self.max_line_num_buffer = 2;   -- number of spaces between line number and editor text (not quite?)

    -- Console
    self.console_text = {n = 1, ""};                                -- table of text in the console
    self.console_header_buffer = 24;                                -- height of the header of the console
    self.console_height = 200;                                      -- height of the console (takes away from the editor)
    self.console_top_line = 1;                                      -- top line visible in the console
    self.console_command_buffer = {n = 0, i = 0};                   -- table containing previously entered commands
    self.console_command_buffer[0] = "";

    -- Cursor
    self.editor_vert_cursor = 1;    -- vertical position of the cursor in the editor
    self.editor_horz_cursor = 1;    -- horizontal position of the cursor in the editor
    self.console_vert_cursor = 1;   -- vertical position of the cursor in the console
    self.console_horz_cursor = 1;   -- horizontal position of the cursor in the console

    -- Calculated values
    self.fnt_text_height = self.text_font:getHeight();                       -- height of font used in the editor/console
    self.fnt_text_width = self.text_font:getWidth("a");                      -- width (assuming monospaced) of the font used in editor/console
    self.text_y_spacing = self.fnt_text_height + 2;                          -- vertical spacing between rows of text (font height + 2)

    self.ui_font_height = self.ui_font:getHeight();                     -- height of font used in the editor UI
    self.ui_font_width = self.ui_font:getWidth("a");                    -- width (assuming monospaced) of the font used in the editor UI

    self.editor_header_height = self.ui_font_height + self.editor_header_buffer;
    self.editor_lines = math.floor((self.height - self.y_border - self.editor_header_height - self.console_height)/self.text_y_spacing)
    self.editor_bottom_line = math.min(self.editor_text.n, self.editor_top_line + self.editor_lines - 1)
    self.editor_text_y_offset = self.y + self.y_border + self.editor_header_height - self.text_y_spacing/2;
    self.editor_text_x_offset = self.x + self.x_border;

    self.console_y = self.y + self.height - self.console_height;    -- y position of the top left of the console
    self.console_header_height = self.ui_font_height + self.console_header_buffer;
    self.console_lines = math.floor((self.console_height - self.y_border - self.console_header_height)/self.text_y_spacing)
    self.console_bottom_line = math.min(self.console_text.n, self.console_top_line + self.console_lines)
    self.console_text_y_offset = self.console_y + self.console_header_height - self.text_y_spacing/2;
    self.console_text_x_offset = self.x + self.x_border;

    
    -- Navigation
    self.nav_vert_cursor = {
        ["up"] = -1, ["down"] = 1,
        ["pageup"] = -self.editor_lines, ["pagedown"] = self.editor_lines,
        ["home"] = -math.huge, ["end"] = math.huge
    }

    return self
end

function Editor:update()
    if self.active then
        local char_key = keyboard:getCharKey();
        local nav_key = keyboard:getNavKey();
        local edit_key = keyboard:getEditKey();
        -- local misc_key = Keyboard:getMiscKey(); -- currently unused
        local fun_key = keyboard:getFunKey();

        -- check if a modifier key is active

        -- swtich modes
        if fun_key == "f1" then self:setMode("edit") end
        if fun_key == "f2" then self:setMode("console") end

        -- input a character at the cursor
        

        -- when in edit mode
        if self.mode == "edit" then
            if char_key ~= nil then self:editorCharInput(char_key) end
            if edit_key == "enter" then self:editEnter() end
            if edit_key == "backspace" then self:editorBackspace() end
            if edit_key == "delete" then self:editorDel() end

            if nav_key == "left" then self:editorCursorLeft() end
            if nav_key == "right" then self:editorCursorRight() end

            if (nav_key == "up" or nav_key == "down" or nav_key == "pageup" or nav_key == "pagedown" or nav_key == "home" or nav_key == "end") then
                self:shiftVertCursor(self.nav_vert_cursor[nav_key])
            end
        end

        -- when in console mode
        if self.mode == "console" then
            if char_key ~= nil then self:consoleCharInput(char_key) end
            if edit_key == "enter" then self:consoleEnter() end
            if edit_key == "backspace" then self:consoleBackspace() end
            if edit_key == "delete" then self:consoleDel() end

            if nav_key == "left" then self:consoleCursorLeft() end
            if nav_key == "right" then self:consoleCursorRight() end

            if nav_key == "up" then self:consoleUpArrow() end
            if nav_key == "down" then self:consoleDownArrow() end

        end
        keyboard:reset();
    end
end

-- draw funciton
function Editor:draw()
    if self.active then
        local inner_x = self.x + self.x_border;
        local inner_y = self.y + self.y_border;

        -- text editor background
        love.graphics.setColor(0.1,0.1,0.1,1);
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        love.graphics.setColor(1,1,1,1);

        local editor_cursor_x = self.editor_text_x_offset + (self.editor_horz_cursor + self.max_line_num_buffer)*self.fnt_text_width;
        local editor_cursor_y = self.editor_text_y_offset + (self.editor_vert_cursor - self.editor_top_line)*self.text_y_spacing;
        local console_cursor_x = self.console_text_x_offset + (self.console_horz_cursor + 3)*self.fnt_text_width;
        local console_cursor_y = self.console_text_y_offset + (self.console_vert_cursor - self.console_top_line)*self.text_y_spacing;

        -- draw editor text
        love.graphics.setFont(self.text_font)

        if self.mode == "edit" then love.graphics.setColor(1, 1, 1, 1) else love.graphics.setColor(0.5, 0.5, 0.5, 1) end
        for i = self.editor_top_line, self.editor_bottom_line + 1 do
            if self.editor_text[i] ~= nil then
                local line_num_buffer = string.rep(" ", self.max_line_num_buffer - string.len(tostring(i)) - 1)
                love.graphics.print(line_num_buffer .. tostring(i) .. "  " .. self.editor_text[i], self.editor_text_x_offset, self.editor_text_y_offset + self.text_y_spacing*(i - self.editor_top_line))
            end
        end

        -- draw console text
        if self.mode == "edit" then love.graphics.setColor(0.5, 0.5, 0.5, 1) else love.graphics.setColor(1, 1, 1, 1) end
        for i = self.console_top_line, self.console_bottom_line do
            if self.console_text[i] ~= nil then
                if self.console_text[i]:sub(1,2) == "<<" then 
                    love.graphics.print("      " .. self.console_text[i]:sub(3,-1), self.console_text_x_offset, self.console_text_y_offset + self.text_y_spacing*(i - self.console_top_line))
                else
                    love.graphics.print(">>  " .. self.console_text[i], self.console_text_x_offset, self.console_text_y_offset + self.text_y_spacing*(i - self.console_top_line))
                end
            end
        end

        -- draw cursor
        love.graphics.setColor(1,1,1,0.5);
        if self.mode == "edit" then
            love.graphics.rectangle("fill", editor_cursor_x, editor_cursor_y, self.fnt_text_width, self.fnt_text_height)
        elseif self.mode == "console" and self.console_vert_cursor <= self.console_bottom_line then
            love.graphics.rectangle("fill", console_cursor_x, console_cursor_y, self.fnt_text_width, self.fnt_text_height)
        end

        -- draw headers
        love.graphics.setColor(0.7,0.7,0.7,1);
        love.graphics.setFont(self.ui_font)
        local name_offset = self.ui_font_width * 6 + 32;
        love.graphics.print("EDITOR", inner_x, inner_y + self.editor_header_buffer/2 - self.ui_font_height/2)
        love.graphics.print("CONSOLE", inner_x, self.console_y + self.console_header_buffer/2 - self.ui_font_height/2 + 1)

        -- file name
        if self.saved then
            love.graphics.print(self.file_name, inner_x + name_offset, inner_y + self.editor_header_buffer/2 - self.ui_font_height/2)
        else
            love.graphics.print("*" .. self.file_name, inner_x + name_offset, inner_y + self.editor_header_buffer/2 - self.ui_font_height/2)
        end

        -- header divider    
        love.graphics.setColor(0,0,0,1); love.graphics.line(self.x, inner_y + self.editor_header_buffer, self.x + self.width, inner_y + self.editor_header_buffer);
        love.graphics.setColor(0,0,0,1); love.graphics.line(self.x, self.console_y, self.x + self.width, self.console_y);
        love.graphics.setColor(0,0,0,1); love.graphics.line(self.x, self.console_y + self.console_header_buffer, self.x + self.width, self.console_y + self.console_header_buffer);

        -- reset colour
        love.graphics.setColor(1,1,1,1);
    end
end

do -- CONSOLE COMMANDS
    function Editor:consoleEnter()
        self.console_command_buffer.i = 0;
    
        local command = self.console_text[self.console_vert_cursor]:strip()
    
        if command ~= "" then
            if self.console_command_buffer[self.console_command_buffer.n] ~= command then
                self.console_command_buffer[self.console_command_buffer.n + 1] = command;
                self.console_command_buffer.n = self.console_command_buffer.n + 1
            end
            self:consoleInterpreter(command);
        end
        -- these will print lines
        table.insert(self.console_text, "");
        self.console_text.n = self.console_text.n + 1;
        self.console_vert_cursor = self.console_vert_cursor + 1;
        self.console_horz_cursor = 1;
        self:updateConsoleScrollPosition()
    end

    function Editor:consoleInterpreter(command_string)
        -- execute the command entered
        local command = (command_string:strip()):split("%s")
    
        -- reset input if previous resulted in an error or notice
        if command[1] == "Error:" or command[1] == "Notice:" then
            self.editor_text[self.editor_vert_cursor] = "";
            self.editor_horz_cursor = 1;
        -- switch back into edit mode on the currently loaded file
        elseif command[1] == "save"  or command[1] == "!save"  then self:saveFile(command)
        elseif command[1] == "load"  or command[1] == "!load"  then self:loadFile(command)
        elseif command[1] == "new"   or command[1] == "!new"   then self:newFile(command)
        elseif command[1] == "exit"  or command[1] == "!exit"  then self:closeEditor(command)
        elseif command[1] == "close" or command[1] == "!exit"  then self:closeEditor(command)
        elseif command[1] == "build" or command[1] == "!build" then self:buildFile(command)
        elseif command[1] == "clc" then self:clearConsole()
        elseif command[1] == "help" then self:consoleHelp(command)
        else -- Error failed to find command
            self:consoleError("No command \"" .. command[1] .. "\" found")
        end
    end

    function Editor:saveFile(command)
        local fname = command[2];

        if command[3] ~= nil then -- too many arguments provided
            self:consoleError("Too many arguments"); return;
        end
        if command[2] == nil then -- no name provided
            if self.file_name ~= "Untitled" then
                command[2] = self.file_name;
            else
                self:consoleError("No file name provided") return;
            end
        end
        if command[2]:includesIllegal() then -- check for illegal characters
            self:consoleError("Illegal characters in file name"); return;
        else -- we have checked everything and we should be good to go
            if not command[2]:includes("%.") then fname = fname .. ".txt" end -- append extension if none provided

            local f_info = {};
            f_info = love.filesystem.getInfo("editor/saves/" .. fname, f_info);
            if f_info == nil or command[1] == "!save" then -- if file does not exist or we are overwriting it
                local state = table.text_save(self.editor_text, "editor/saves/" .. fname) -- save file
                
                -- check if there where any errors when saving
                if state ~= nil then                    -- error occured while saving
                    self:consoleError(state) return;
                else                                    -- file saved successfully
                    self:consoleNotice("File saved successfully")
                    self.file_name = fname;
                    self.saved = true;
                end
            else -- if file exists and we are not overwriting it
                self:consoleError("File '" .. fname .. "' already exists, use !save to overwrite")
            end
        end
    end

    function Editor:loadFile(command)
        local fname = command[2]
        local state, tab, extension;
        if command[1] == "load" and self.saved == false then -- warn not saved
            self:consoleError("File not saved, use '!load' to override");
            return;
        end
        if command[3] ~= nil then -- too many arguments provided
            self:consoleError("Too many arguments");
            return;
        end
        if command[2] == nil then -- no name provided
            self:consoleError("No file name provided");
            return;
        end

        if not command[2]:includes("%.") then fname = fname .. ".txt" end -- append extension if none provided

        tab, state = table.textLoad("editor/saves/" .. fname)
        if state ~= nil then
            self:consoleError(state)
        else
            self.editor_text = tab;
            self.saved = true;
            self.editor_vert_cursor = 1;
            self.editor_horz_cursor = 1;
            self.editor_top_line = 1;
            self.max_line_num_buffer = string.len(tostring(self.editor_text.n)) + 1;
            self:updateEditorScrollPosition();
            self.file_name = fname
            self:consoleNotice(self.file_name .. " loaded successfully")
        end
    end

    function Editor:newFile(command)
        local state, tab, extension;
        if command[1] == "new" and self.saved == false then -- warn not saved
            self:consoleError("File not saved, use '!new' to override");
            return;
        end

        if command[2] ~= nil then -- too many arguments provided
            self:consoleError("Too many arguments provided");
            return;
        end

        self.editor_text = {n = 1, ""};
        self.saved = true;
        self.editor_vert_cursor = 1;
        self.editor_horz_cursor = 1;
        self.editor_top_line = 1;
        self:updateEditorScrollPosition();
        self.file_name = "Untitled"
    end

    function Editor:closeEditor(command)
        local state, tab, extension;
        if command[1] == "exit" and self.saved == false then -- warn not saved
            self:consoleError("File not saved, use '!exit' to override");
            return;
        end
        if command[2] ~= nil then -- too many arguments provided
            self:consoleError("Too many arguments provided");
            return;
        end

        -- reset everything then deactivate
        -- self.editor_text = {lines = 1, ""};
        -- self.saved = true;
        -- self.editor_vert_cursor = 1;
        -- self.editor_horz_cursor = 1;
        -- self.editor_top_line = 1;
        -- self:updateEditorScrollPosition();
        -- self.file_name = "Untitled"
        -- self:setMode("edit")
        self.active = false
    end

    function Editor:buildFile(command)
        local compile_message;
        if command[1] == "build" and self.saved == false then -- warn not saved
            self:consoleError("File not saved, use '!build' to override");
            return;
        end
        if command[3] ~= nil then -- too many arguments provided
            self:consoleError("Too many arguments");
            return;
        end
        if command[2] == nil then -- no name provided
            self:consoleError("No file name provided");
            return;
        end

        if command[2]:sub(-4,-1) == ".bin" then -- if file extension was provided
            compile_message = Assembler:assemble(self.editor_text, "editor/saves/" .. command[2])
        else -- if file extension was not provided
            compile_message = Assembler:assemble(self.editor_text, "editor/saves/" .. command[2] .. ".bin")
        end

        for k,v in pairs(compile_message) do
            print(k,v);
        end

        if compile_message ~= nil then
            print("compile message not nil")
            print(compile_message.n)
            for i = 1,compile_message.n do
                self.console_text.n = self.console_text.n + 1;
                table.insert(self.console_text, self.console_text.n, "<<" .. compile_message[i])
            end
            self.console_vert_cursor = self.console_vert_cursor + compile_message.n;

            self:updateConsoleScrollPosition();
        end

    end

    function Editor:clearConsole()
        self.console_text = {n = 0, ""}
        self.console_vert_cursor = 0;
        self.console_horz_cursor = 0;
    end

    function Editor:consoleHelp(command)
        if command[2] == nil then -- print summary of commands
            self:consolePrint("     -- Summary of Commands --")
            for _,v in ipairs(Editor.help_text.help_list) do
                self:consolePrint(Editor.help_text[v][1])
            end
            self:consolePrint("")
            self:consolePrint("     -- Controls --")
            self:consolePrint("F1                   editor")
            self:consolePrint("F2                   console")
            self:consolePrint("ctrl + arrow keys    scroll console")
            self:consolePrint("")
            self:consolePrint("use `help <command>' to see more details")
        elseif Editor.help_text[command[2]] ~= nil and command[2] ~= "help_list" then
            self:consolePrint(table.subtable(Editor.help_text[command[2]], 2, -1))
        else
        end
    end

    function Editor:consolePrint(text) -- prints a string to the console
        if type(text) == "string" then
            self.console_vert_cursor = self.console_vert_cursor + 1;
            self.console_text[self.console_vert_cursor] = "<<" .. text;
            self.console_text.n = self.console_text.n + 1;
        elseif type(text) == "table" then
            for _,v in pairs(text) do
                self:consolePrint(v)
            end
        end
    end

    function Editor:consoleError(text) -- will probably be depreciated
        self:consolePrint("Error: " .. text)
    end

    function Editor:consoleNotice(text) -- will probably be depreciated
        self:consolePrint("Notice: " .. text)
    end
end

do -- TEXT MODIFICATION [backspace, delete, enter character]
    -- input a character at the cursor
    function Editor:editorCharInput(char)
        self.editor_text[self.editor_vert_cursor] = self.editor_text[self.editor_vert_cursor]:insert(char, self.editor_horz_cursor)
        self.editor_horz_cursor = self.editor_horz_cursor + char:len();
        self.saved = false;
    end
    function Editor:consoleCharInput(char)
        --self.console_text[self.console_vert_cursor] = self.console_text[self.console_vert_cursor]:insert(char, self.console_horz_cursor)
        self.console_text[self.console_vert_cursor] = self.console_text[self.console_vert_cursor]:insert(char, self.console_horz_cursor)
        self.console_horz_cursor = self.console_horz_cursor + char:len();
        self:updateConsoleScrollPosition();
    end

    -- backspace
    function Editor:editorBackspace()
        if self.editor_horz_cursor == 1 then -- if at the beginning of a line, the backspace will remove a line
            if self.editor_vert_cursor ~= 1 then
                local new_horz_cursor = string.len(self.editor_text[self.editor_vert_cursor - 1]) + 1; 
                self.editor_text[self.editor_vert_cursor - 1] = self.editor_text[self.editor_vert_cursor - 1] .. self.editor_text[self.editor_vert_cursor];
                table.remove(self.editor_text, self.editor_vert_cursor)
                self.editor_vert_cursor = self.editor_vert_cursor - 1;
                self.editor_horz_cursor = new_horz_cursor;
                self.editor_text.n = self.editor_text.n - 1;
                self.max_line_num_buffer = string.len(tostring(self.editor_text.n)) + 1;
                self:updateEditorScrollPosition();
            end
        else
            self.editor_text[self.editor_vert_cursor] = self.editor_text[self.editor_vert_cursor]:remove(self.editor_horz_cursor - 1, self.editor_horz_cursor - 1)
            self.editor_horz_cursor = self.editor_horz_cursor - 1;
        end
        self.saved = false;
    end
    function Editor:consoleBackspace()
        if self.console_horz_cursor ~= 1 then -- if at the beginning of a line, the backspace will remove a line
            self.console_text[self.console_vert_cursor] = self.console_text[self.console_vert_cursor]:remove(self.console_horz_cursor - 1, self.console_horz_cursor - 1)
            self.console_horz_cursor = self.console_horz_cursor - 1;
        end
    end

    -- delete (key)
    function Editor:editorDel()
        if self.editor_horz_cursor == self:thisLineLen() + 1 then -- if at the beginning of a line, the backspace will remove a line
            if self.editor_vert_cursor ~= self.editor_text.n then
                self.editor_text[self.editor_vert_cursor] = self.editor_text[self.editor_vert_cursor] .. self.editor_text[self.editor_vert_cursor + 1];
                table.remove(self.editor_text, self.editor_vert_cursor + 1)
                self.editor_text.n = self.editor_text.n - 1;
                self.max_line_num_buffer = string.len(tostring(self.editor_text.n)) + 1;
                self:updateEditorScrollPosition();
            end
        else
            self.editor_text[self.editor_vert_cursor] = self.editor_text[self.editor_vert_cursor]:remove(self.editor_horz_cursor, self.editor_horz_cursor)
        end
        self.saved = false;
    end
    function Editor:consoleDel()
        self.editor_text[self.editor_vert_cursor] = self.editor_text[self.editor_vert_cursor]:remove(self.editor_horz_cursor, self.editor_horz_cursor)
    end

end

do -- NAVIGATION [enter, arrow keys, home/end/pg up/pg down]
    -- enter in editor
    function Editor:editEnter()
        local right_text = "";
        local left_text = self.editor_text[self.editor_vert_cursor]

        if self.editor_horz_cursor == 1 then
            right_text = left_text;
            left_text = "";
        elseif self.editor_horz_cursor <= string.len(left_text) then
            right_text = string.sub(left_text, self.editor_horz_cursor, -1);
            left_text = string.sub(left_text, 1, self.editor_horz_cursor - 1);
        end

        self.editor_text[self.editor_vert_cursor] = left_text;
        table.insert(self.editor_text, self.editor_vert_cursor + 1, right_text)

        self.editor_horz_cursor = 1;
        self.editor_vert_cursor = self.editor_vert_cursor + 1;
        self.editor_text.n = self.editor_text.n + 1;
        
        self:updateEditorScrollPosition();
        
        self.max_line_num_buffer = string.len(tostring(self.editor_text.n)) + 1;
        self.saved = false;
    end

    -- move cursor 1 space to the left or right
    function Editor:editorCursorLeft()
        if self.editor_horz_cursor == 1 then
            if self.editor_vert_cursor > 1 then
                self.editor_vert_cursor = self.editor_vert_cursor - 1;
                self.editor_horz_cursor = string.len(self.editor_text[self.editor_vert_cursor]) + 1;
            else
                self.editor_horz_cursor = 1;
            end
        else
            self.editor_horz_cursor = self.editor_horz_cursor - 1;
        end

        self:updateEditorScrollPosition();
    end
    function Editor:editorCursorRight()
        if self.editor_horz_cursor == string.len(self.editor_text[self.editor_vert_cursor]) + 1 then
            if self.editor_vert_cursor < self.editor_text.n then
                self.editor_vert_cursor = self.editor_vert_cursor + 1;
                self.editor_horz_cursor = 1;
            else
                self.editor_horz_cursor = string.len(self.editor_text[self.editor_vert_cursor]) + 1;
            end
        else 
            self.editor_horz_cursor = self.editor_horz_cursor + 1
        end

        self:updateEditorScrollPosition();
    end
    function Editor:consoleCursorLeft()
        if self.console_horz_cursor ~= 1 then
            self.console_horz_cursor = self.console_horz_cursor - 1;
        end
    end
    function Editor:consoleCursorRight()
        if self.console_horz_cursor ~= string.len(self.console_text[self.console_vert_cursor]) + 1 then
            self.console_horz_cursor = self.console_horz_cursor + 1
        end
    end
    
    -- move the vertical cursor by the amount specified by shift.
    function Editor:shiftVertCursor(shift)
        if shift < 0 then
            self.editor_vert_cursor = math.max(1, self.editor_vert_cursor + shift);
        else
            self.editor_vert_cursor = math.min(self.editor_text.n, self.editor_vert_cursor + shift);
        end

        self.editor_horz_cursor = math.min(self.editor_horz_cursor, string.len(self.editor_text[self.editor_vert_cursor]) + 1);
        self:updateEditorScrollPosition();
    end

    function Editor:consoleUpArrow()
        if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
            self.console_top_line = math.max(1, self.console_top_line - 1);
            self.console_bottom_line = math.min(self.console_text.n, self.console_top_line + self.console_lines);
        else
            self:updateConsoleScrollPosition();
            self.console_command_buffer.i = math.min(self.console_command_buffer.i + 1, self.console_command_buffer.n)
            if self.console_command_buffer.i ~= 0 then
                self.console_text[self.console_vert_cursor] = self.console_command_buffer[self.console_command_buffer.n - self.console_command_buffer.i + 1]
                self.console_horz_cursor = self.console_text[self.console_vert_cursor]:len() + 1;
            end
        end
    end

    function Editor:consoleDownArrow()
        if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
            self.console_top_line = math.min(self.console_text.n, self.console_top_line + 1);
            self.console_bottom_line = math.min(self.console_text.n, self.console_top_line + self.console_lines);
        else
            self:updateConsoleScrollPosition();
            self.console_command_buffer.i = math.max(self.console_command_buffer.i - 1, 0)
            if self.console_command_buffer.i == 0 then
                self.console_text[self.console_vert_cursor] = "";
                self.console_horz_cursor = 1;
            else
                self.console_text[self.console_vert_cursor] = self.console_command_buffer[self.console_command_buffer.n - self.console_command_buffer.i + 1]
                self.console_horz_cursor = self.console_text[self.console_vert_cursor]:len() + 1;
            end
        end
    end

    -- update the region of the screen visible so that the cursor may be seen
    function Editor:updateEditorScrollPosition()
        self.editor_bottom_line = math.min(self.editor_text.n, self.editor_top_line + self.editor_lines - 1)
        if (self.editor_vert_cursor > self.editor_bottom_line) then
            self.editor_top_line = self.editor_vert_cursor - self.editor_lines;
            self.editor_bottom_line = math.min(self.editor_text.n, self.editor_top_line + self.editor_lines - 1)
        end

        if (self.editor_vert_cursor < self.editor_top_line) then
            self.editor_top_line = self.editor_vert_cursor;
            self.editor_bottom_line = math.min(self.editor_text.n, self.editor_top_line + self.editor_lines - 1)
        end
    end

    function Editor:updateConsoleScrollPosition()
        self.console_bottom_line = math.min(self.console_text.n, self.console_top_line + self.console_lines - 1)
        if (self.console_vert_cursor > self.console_bottom_line) then
            self.console_top_line = self.console_vert_cursor - self.console_lines;
            self.console_bottom_line = math.min(self.console_text.n, self.console_top_line + self.console_lines)
        end

        if (self.console_vert_cursor < self.console_top_line) then
            self.console_top_line = self.console_vert_cursor;
            self.console_bottom_line = math.min(self.console_text.n, self.console_top_line + self.console_lines - 1)
        end
    end
end

do -- EDITOR FUNCIONS [setFont, setMode, refresh, thisLineLen]
    -- set the font to be used
    function Editor:setFont(name, size)
        self.text_font = Font[name .. "_" .. size];
    end

    -- set the mode of the editor "edit" or "console"
    function Editor:setMode(mode)
        if self.mode == mode then return end

        if mode == "console" then
            self.mode = "console";
        end
        if mode == "edit" then
            self.mode = "edit";
        end
    end

    --upodate all the calculated parameters with new set values
    function Editor:refresh()
        -- Update font values
        self.fnt_text_height = self.text_font:getHeight();
        self.fnt_text_width = self.text_font:getWidth("a"); -- assume monospaced
        self.text_y_spacing = self.fnt_text_height + 2;

        self.ui_font_height = self.ui_font:getHeight();
        self.ui_font_width = self.ui_font:getWidth("a"); -- assume monospaced

        -- Editor
        self.editor_header_height = self.ui_font_height + self.editor_header_buffer;
        self.editor_lines = math.floor((self.height - 2*self.y_border - self.editor_header_height)/self.text_y_spacing)
        self.editor_top_line = 1;
        self.editor_bottom_line = math.min(self.editor_text.n, self.editor_top_line + self.editor_lines - 1)
        self.editor_text_y_offset = self.y + self.y_border + self.editor_header_height;
        self.editor_text_x_offset = self.x + self.x_border;

        -- Cursor
        self.editor_vert_cursor = 1;
        self.editor_horz_cursor = 1;
    end

    -- returns the length of the current line
    function Editor:thisLineLen()
        return self.editor_text[self.editor_vert_cursor]:len()
    end

    -- Resets the cursor and the scroll position and saved state
    function Editor:reset()
        self.saved = true;
        self.editor_vert_cursor = 1;
        self.editor_horz_cursor = 1;
        self.editor_top_line = 1;
        self.max_line_num_buffer = string.len(tostring(self.editor_text.n)) + 1;
        self:updateEditorScrollPosition();
    end
end