Console = {}
Console.__index = Console

function Console.new()
	local self = {}
	setmetatable(self, Console)

	self.active = true

	self.x = 0;
    self.y = 0;
    self.w = App.window_width;
    self.h = App.window_height;

	self.win = Window.new(self.x, self.y, self.w, self.h, 0, 0, 5, 0,
	{"dos16", "pxl_5x7_bold", "pxl_5x7_thin"}, -- fonts
	{{"202020", "101010"}, {"000"}, {"ccc", "ddd"}} -- colours
	)
	self.win:init()

	-- Other
    self.current_key = nil;         -- the current key that is pressed
    self.active = true;             -- whether or not the console is active (visible)

	-- Console
    self.text = {n = 1, ""};                    -- table of text in the console
    self.top_line = 1;                          -- top line visible in the console
    self.command_buffer = {n = 0, i = 0};       -- table containing previously entered commands
    self.command_buffer[0] = "";

	self.vert_cursor = 1;   -- vertical position of the cursor in the console
    self.horz_cursor = 1;   -- horizontal position of the cursor in the console

    self.lines = math.floor(self.win.h/self.win.fnt_txt2_h)
    self.bottom_line = math.min(self.text.n, self.top_line + self.lines)

	function self.win:draw(console)
		self:resetCurrentY()
		self:drawBackground()
		self:drawTitle({self.col_txt[1], "CONSOLE"}, true)
		self:hline(2)

		-- draw console text
		for i = console.top_line, console.bottom_line do
			if console.text[i] ~= nil then
				if console.text[i]:sub(1,2) == "<<" then 
					self:printText("      " .. console.text[i]:sub(3,-1), self.fnt_txt2)
				else
					self:printText(">>  " .. console.text[i], self.fnt_txt2)
				end
				self:vspace(1)
			end
		end
	end

	self.win:init()

	print("Created console successfully")
	return self
end

function Console:update()
	local char_key = keyboard:getCharKey();
	local nav_key = keyboard:getNavKey();
	local edit_key = keyboard:getEditKey();
	local fun_key = keyboard:getFunKey();
	local misc_key = keyboard:getMiscKey();

	-- when in console mode

	if char_key ~= nil then self:charInput(char_key) end
	-- if edit_key == "enter" then self:consoleEnter() end
	if edit_key == "backspace" then self:backspace() end
	if edit_key == "delete" then self:del() end

	if nav_key == "left" then self:cursorLeft() end
	if nav_key == "right" then self:cursorRight() end

	-- if nav_key == "up" then self:consoleUpArrow() end
	-- if nav_key == "down" then self:consoleDownArrow() end


	if misc_key == "escape" then
		self.active = false
	end

	keyboard:reset();
end

function Console:draw()
	self.win:draw(self)

	-- draw cursor
	local cursor_x = self.win.x_int + (self.horz_cursor + 3)*self.win.fnt_txt2_w;
	local cursor_y = self.win.hdr_h + self.win.y_int + (self.vert_cursor - self.top_line)*(self.win.fnt_txt2_h + 1);

	love.graphics.setColor(1,1,1,0.5);
	love.graphics.rectangle("fill", cursor_x, cursor_y, self.win.fnt_txt2_w, self.win.fnt_txt2_h + 2)
end

function Console:charInput(char)
	self.text[self.vert_cursor] = self.text[self.vert_cursor]:insert(char, self.horz_cursor)
	self.horz_cursor = self.horz_cursor + char:len();
	self:updateScrollPosition();
end

function Console:backspace()
	if self.horz_cursor ~= 1 then -- if at the beginning of a line, the backspace will remove a line
		self.text[self.vert_cursor] = self.text[self.vert_cursor]:remove(self.horz_cursor - 1, self.horz_cursor - 1)
		self.horz_cursor = self.horz_cursor - 1;
	end
end

function Console:del()
	self.text[self.vert_cursor] = self.text[self.vert_cursor]:remove(self.horz_cursor, self.horz_cursor)
end

function Console:cursorLeft()
	if self.horz_cursor ~= 1 then
		self.horz_cursor = self.horz_cursor - 1;
	end
end

function Console:cursorRight()
	if self.horz_cursor ~= string.len(self.text[self.vert_cursor]) + 1 then
		self.horz_cursor = self.horz_cursor + 1
	end
end

function Console:upArrow()
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

function Console:downArrow()
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

function Console:updateScrollPosition()
	-- self.bottom_line = math.min(self.text.n, self.top_line + self.lines - 1)

	-- if (self.vert_cursor > self.bottom_line) then
	-- 	self.top_line = self.vert_cursor - self.lines;
	-- 	self.bottom_line = math.min(self.text.n, self.top_line + self.lines)
	-- end

	-- if (self.vert_cursor < self.top_line) then
	-- 	self.top_line = self.vert_cursor;
	-- 	self.bottom_line = math.min(self.text.n, self.top_line + self.lines - 1)
	-- end
end

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

	tab, state = table.text_load("editor/saves/" .. fname)
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