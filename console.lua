Console = {}
Console.__index = Console

function Console.new(desktop)
	local self = {}
	setmetatable(self, Console)

	self.active = true
	self.desktop = desktop -- desktop that started the console
	self.editor = self.desktop.applications.obj_editor -- should be not nil
	self.editor_is_running = self.editor.active ~= nil

	self.x = 0;
    self.y = 0;
    self.w = App.window_width;
    self.h = App.window_height;

	self.file_text = {} -- locally stored text loaded from a file if editor is not running
	self.local_load = false -- forces files to be loaded locally

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

	-- text to provide for the help command
	self.help_text = {
        help_list = {"build", "clc", "close", "exit", "help", "load", "new", "save"},
        build = {
			"build  assembles assembly code to Nibble-8 machine code",
            "build:  assembles current code opened in editor or loaded into the console,",
			"    or loaded in from a file provided as an optional parameter",
			"",
            "build <out file>:  assembles the code currently loaded in the editor or",
			"    console, and outputs the machine code to `file out'",
			"build <in file, out file>:  assembles the code from `in file' and outputs",
			"    the machine code to `out file'",
			"",
            "parameters:",
			"    <out file> file to save the machine code to, default extension .bin",
            "    <in file>  (optional) file to load assembly code from"
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

	-- window parameters
	self.win = Window.new(self.x, self.y, self.w, self.h, 0, 0, 5, 0,
	{"dos16", "pxl_5x7_bold", "pxl_5x7_thin"}, -- fonts
	{{"202020", "101010"}, {"000"}, {"ccc", "ddd"}} -- colours
	)
	self.win:init()

	self.lines = math.floor((self.win.h_int - self.win.fnt_hdr_h)/(self.win.fnt_txt2_h + self.win.line_spacing)) - 1

	function self.win:draw(console)
		self:resetCurrentY()
		self:drawBackground()
		self:drawTitle({self.col_txt[1], "CONSOLE"}, true)
		self:hline(2)

		-- draw console text
		local bottom_line = console.top_line + console.lines
		for i = console.top_line, bottom_line do
			if console.text[i] ~= nil then
				if console.text[i]:sub(1,2) == "<<" then 
					self:printText("      " .. console.text[i]:sub(3,-1), self.fnt_txt2)
				else
					self:printText(">>  " .. console.text[i], self.fnt_txt2)
				end
			end
		end
	end

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
	if edit_key == "enter" then self:consoleEnter() end
	if edit_key == "backspace" then self:backspace() end
	if edit_key == "delete" then self:del() end

	if nav_key == "left" then self:cursorLeft() end
	if nav_key == "right" then self:cursorRight() end

	if nav_key == "up" then self:upArrow() end
	if nav_key == "down" then self:downArrow() end


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
	self.horz_cursor = self.horz_cursor + char:len()
	self:updateScrollPosition()
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
		self.top_line = math.max(1, self.top_line - 1);
	else
		self:updateScrollPosition();
		self.command_buffer.i = math.min(self.command_buffer.i + 1, self.command_buffer.n)
		if self.command_buffer.i ~= 0 then
			self.text[self.vert_cursor] = self.command_buffer[self.command_buffer.n - self.command_buffer.i + 1]
			self.horz_cursor = self.text[self.vert_cursor]:len() + 1;
		end
	end
end

function Console:downArrow()
	if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
		self.top_line = math.min(self.text.n, self.top_line + 1);
	else
		self:updateScrollPosition();
		self.command_buffer.i = math.max(self.command_buffer.i - 1, 0)
		if self.command_buffer.i == 0 then
			self.text[self.vert_cursor] = "";
			self.horz_cursor = 1;
		else
			self.text[self.vert_cursor] = self.command_buffer[self.command_buffer.n - self.command_buffer.i + 1]
			self.horz_cursor = self.text[self.vert_cursor]:len() + 1;
		end
	end
end

function Console:updateScrollPosition()
	-- cursor cannot be above the top line, only below the bottom
	if self.vert_cursor > self.top_line + self.lines then
		self.top_line = self.vert_cursor - self.lines + 1
	end
end

function Console:consoleEnter()
	self.command_buffer.i = 0;

	local command = self.text[self.vert_cursor]:strip()

	if command ~= "" then
		if self.command_buffer[self.command_buffer.n] ~= command then
			self.command_buffer[self.command_buffer.n + 1] = command;
			self.command_buffer.n = self.command_buffer.n + 1
		end
		self:interpreter(command);
	end
	-- these will print lines
	table.insert(self.text, "");
	self.text.n = self.text.n + 1;
	self.vert_cursor = self.vert_cursor + 1;
	self.horz_cursor = 1;
	self:updateScrollPosition()
end

function Console:interpreter(command_string)
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
	-- elseif command[1] == "exit"  or command[1] == "!exit"  then self:closeEditor(command)
	-- elseif command[1] == "close" or command[1] == "!exit"  then self:closeEditor(command)
	elseif command[1] == "build" then self:buildFile(command)
	elseif command[1] == "clc" then self:clearConsole()
	elseif command[1] == "help" then self:help(command)
	else -- Error failed to find command
		self:consolePrint("Error: No command \"" .. command[1] .. "\" found")
	end
end

-- Save the data currently in the editor to a file
function Console:saveFile(command)
	if self.editor_is_running then
		local fname = command[2]; -- file name
		local overwrite_safe = command[1] == "!save" -- safe to overwrite existing file

		-- check that the expeceted number of arguments were given
		if command[3] ~= nil then
			self:consolePrint("Error: Too many arguments"); return;
		end

		-- check if the name was given
		if command[2] == nil then
			-- if no name was given, but the file is named, then give the file the current name
			if self.editor.file_name ~= "Untitled" then
				fname = self.editor.file_name;
				overwrite_safe = true; -- allow overwrite if using existing file name
			else
				-- if no name provided and the file is unnamed, return error
				self:consolePrint("Error: No file name provided") return;
			end
		end

		-- check if the file name includes any illegal characters
		if command[2]:includesIllegal() then
			self:consolePrint("Error: Illegal characters in file name"); return;
		end

		-- append .txt extension (as default) if none provided
		if not command[2]:includes("%.") then fname = fname .. ".txt" end

		local f_info = {};
		-- get info about the file, if nil then it does not exist
		f_info = love.filesystem.getInfo("editor/saves/" .. fname, f_info);

		-- if the file does not exist or we are ssafe to overwrite it
		if f_info == nil or overwrite_safe then
			-- save file, state contains any errors
			local state = table.text_save(self.editor_text, "editor/saves/" .. fname)
			
			-- check if there where any errors when saving
			if state ~= nil then
				-- return error if it happened
				self:consolePrint(state) return;
			else
				-- if there were no errors, notify user the file saved correctly
				self:consolePrint("Notice: File saved successfully")
				self.file_name = fname;
				self.saved = true;
			end
		else
			-- throw error if the file exists but we are not safe to overwrite
			self:consolePrint("Error: File '" .. fname .. "' already exists, use !save to overwrite")
		end
	else
		-- throw error if trying to call the command without an editor running
		self:consolePrint("Error: No editor running, must be using the editor to call this command")
	end
end

-- Load data from a file into the editor
function Console:loadFile(command)
	local fname = command[2] -- file name
	local state, tab;

	-- Check if there is a file open in the editor or it is safe to overwrite
	if command[1] == "load" and self.saved == false then
		self:consolePrint("Error: File not saved, use '!load' to override"); return false;
	end

	-- check that the function has not recieved too many arguments
	if command[3] ~= nil then
		self:consolePrint("Error: Too many arguments"); return false;
	end

	-- check that a file name was provided
	if command[2] == nil then
		self:consolePrint("Error: No file name provided"); return false;
	end

	-- append extension .txt if none provided
	if not command[2]:includes("%.") then fname = fname .. ".txt" end

	-- load the data from the save file, state contains any errors that occured
	tab, state = table.textLoad("editor/saves/" .. fname)
	if state ~= nil then
		-- if errors occured, print the errors to the console
		self:consolePrint(state)
	else
		-- if no errors occured, we can load in the new data
		if self.editor_is_running and not self.local_load then
			-- if an editor is running then we load the data into the editor
			self.editor.text = tab
			self.editor.file_name = fname
			self.editor:reset()	-- reset the position of the editor
			self:consolePrint(self.file_name .. " loaded successfully")	-- report successfull loading
			return true
		else
			-- if the editor is not running then we load it locally
			self.file_text = tab
			return true
		end
	end
end

-- Load data from a file to be stored locally
function Console:loadFileLocal(file_name)
	self.local_load = true
	local state = self:loadFile({"!load", file_name})
	self.local_load = false
	return state
end

-- create a new file in the editor (replacing the old one)
function Console:newFile(command)
	-- check that an editor is running
	if self.editor_is_running then
		-- throw an error if there is currently an unsaved file in the editor
		if command[1] == "new" and self.saved == false then
			self:consolePrint("Warning: File not saved, use '!new' to override"); return;
		end

		-- check that no additional arguments were provided
		if command[2] ~= nil then
			self:consolePrint("Error: Too many arguments provided"); return;
		end

		-- resetting the editor to a blank slate
		self.editor.text = {n = 1, ""};
		self.editor.file_name = "Untitled"
		self.editor:reset()
	else
		-- if the editor is not running
		self:consolePrint("Error: No editor running, must be using the editor to call this command")
	end
end

-- assembles the code in the editor or loaded from a file
function Console:buildFile(command)
	local ifname = command[2] -- input file
	local ofname = command[3] -- output file

	local compile_message;

	-- check if too many arguments were provided
	if command[4] ~= nil then
		self:consolePrint("Error: Too many arguments provided"); return;
	end

	-- check if any file names were provided
	if command[2] == nil then
		self:consolePrint("Error: No file name(s) provided"); return;
	end

	-- check if one or two file names were provided
	if command[3] == nil then
		-- only one file name provided, assumed to be the output

		ofname = ifname -- rename for clarity
		-- append .bin extension if none provided
		if not ofname:includes("%.") then ofname = ofname .. ".bin" end

		if self.editor_is_running then
			-- if editor running, then get data from editor
			compile_message = Assembler:assemble(self.editor.text, "editor/saves/" .. ofname)
		else
			-- if the editor is not running, get the data from local
			-- check that data has been loaded locally
			if self.file_text.n ~= nil then
				compile_message = Assembler:assemble(self.file_text, "editor/saves/" .. ofname)
			else
				-- no data has been loaded locally, throw an error
				self:consolePrint("Error: no file loaded to be assembled")
			end
		end
	else
		-- if two files are provided then we load locally then build
		-- append .txt/.bin extension if none provided as required
		if not ifname:includes("%.") then ifname = ifname .. ".txt" end
		if not ofname:includes("%.") then ofname = ofname .. ".bin" end
		
		-- load the file locally
		if self:loadFileLocal(ifname) then
			compile_message = Assembler:assemble(self.file_text, "editor/saves/" .. ofname)
		else
			return false
		end
	end

	-- print out any errors returned by the compiler
	if compile_message ~= nil then
		for i = 1,compile_message.n do
			self:consolePrint(compile_message[i])
		end

		self:updateScrollPosition();
	end

end

-- clears all the text from the console
function Console:clearConsole()
	self.text = {n = 0}
	self.vert_cursor = 0;
	self.horz_cursor = 0;
end

-- prints help text for specified commands or a summary of all
function Console:help(command)
	-- if no specific command provided, give a summary of commands
	if command[2] == nil then
		self:consolePrint("     -- Summary of Commands --")
		for _,v in ipairs(self.help_text.help_list) do
			self:consolePrint(self.help_text[v][1])
		end
		-- print a couple of the relevant controls
		self:consolePrint("")
		self:consolePrint("     -- Controls --")
		self:consolePrint("F1                   editor")
		self:consolePrint("F2                   console")
		self:consolePrint("ctrl + arrow keys    scroll console")
		self:consolePrint("")
		self:consolePrint("use `help <command>' to see more details")
	elseif self.help_text[command[2]] ~= nil and command[2] ~= "help_list" then
		-- if the command exists then
		self:consolePrint(table.subtable(self.help_text[command[2]], 2, -1))
	else
		-- if the entered command is not valid
		self:consolePrint("Error: `" .. command[2] .. "' is not a recognised command")
	end
end

-- Prints a string or table of strings to the console
-- TODO: add support for coloured text
function Console:consolePrint(text)
	if type(text) == "string" then
		self.vert_cursor = self.vert_cursor + 1;
		self.text[self.vert_cursor] = "<<" .. text;
		self.text.n = self.text.n + 1;
	elseif type(text) == "table" then
		for _,v in pairs(text) do
			self:consolePrint(v)
		end
	end
end