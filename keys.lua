---@diagnostic disable: lowercase-global

keyboard = {
	current_key = nil,
	capslock = false,
	shift_modifier = {
		["1"] = "!",
		["2"] = "@",
		["3"] = "#",
		["4"] = "$",
		["5"] = "%",
		["6"] = "^",
		["7"] = "&",
		["8"] = "*",
		["9"] = "(",
		["0"] = ")",
		["-"] = "_",
		["="] = "+",
		["["] = "{",
		["]"] = "}",
		["\\"] = "|",
		[";"] = ":",
		["'"] = "\"",
		[","] = "<",
		["."] = ">",
		["/"] = "?",
		["`"] = "~",
		[" "] = " ",
	},
	
	caps_modifier = {
		["a"] = "A",
		["b"] = "B",
		["c"] = "C",
		["d"] = "D",
		["e"] = "E",
		["f"] = "F",
		["g"] = "G",
		["h"] = "H",
		["i"] = "I",
		["j"] = "J",
		["k"] = "K",
		["l"] = "L",
		["m"] = "M",
		["n"] = "N",
		["o"] = "O",
		["p"] = "P",
		["q"] = "Q",
		["r"] = "R",
		["s"] = "S",
		["t"] = "T",
		["u"] = "U",
		["v"] = "V",
		["w"] = "W",
		["x"] = "X",
		["y"] = "Y",
		["z"] = "Z",
	}
};

function keyboard:reset()
	self.current_key = nil;
end

function keyboard:getCharKey()
	local key;
	local shift = love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift");

	if self.current_key == "a" then key = "a"	
	elseif self.current_key == "b" then key = "b"
	elseif self.current_key == "c" then key = "c"
	elseif self.current_key == "d" then key = "d"
	elseif self.current_key == "e" then key = "e"
	elseif self.current_key == "f" then key = "f"
	elseif self.current_key == "g" then key = "g"
	elseif self.current_key == "h" then key = "h"
	elseif self.current_key == "i" then key = "i"
	elseif self.current_key == "j" then key = "j"
	elseif self.current_key == "k" then key = "k"
	elseif self.current_key == "l" then key = "l"
	elseif self.current_key == "m" then key = "m"
	elseif self.current_key == "n" then key = "n"
	elseif self.current_key == "o" then key = "o"
	elseif self.current_key == "p" then key = "p"
	elseif self.current_key == "q" then key = "q"
	elseif self.current_key == "r" then key = "r"
	elseif self.current_key == "s" then key = "s"
	elseif self.current_key == "t" then key = "t"
	elseif self.current_key == "u" then key = "u"
	elseif self.current_key == "v" then key = "v"
	elseif self.current_key == "w" then key = "w"
	elseif self.current_key == "x" then key = "x"
	elseif self.current_key == "y" then key = "y"
	elseif self.current_key == "z" then key = "z"
	elseif self.current_key == "1" then key = "1"
	elseif self.current_key == "2" then key = "2"
	elseif self.current_key == "3" then key = "3"
	elseif self.current_key == "4" then key = "4"
	elseif self.current_key == "5" then key = "5"
	elseif self.current_key == "6" then key = "6"
	elseif self.current_key == "7" then key = "7"
	elseif self.current_key == "8" then key = "8"
	elseif self.current_key == "9" then key = "9"
	elseif self.current_key == "0" then key = "0"
	elseif self.current_key == "space" then key = " "
	elseif self.current_key == "tab" then key = "    "
	elseif self.current_key == "-" then key = "-"
	elseif self.current_key == "=" then key = "="
	elseif self.current_key == "[" then key = "["
	elseif self.current_key == "]" then key = "]"
	elseif self.current_key == "\\" then key = "\\"
	elseif self.current_key == ";" then key = ";"
	elseif self.current_key == "'" then key = "'"
	elseif self.current_key == "," then key = ","
	elseif self.current_key == "." then key = "."
	elseif self.current_key == "/" then key = "/"
	elseif self.current_key == "`" then key = "`"
	end

	local return_key
	if shift then
		return_key = self.shift_modifier[key];
		if return_key == nil then
			if self.capslock then
				return_key = key
			else
				return_key = self.caps_modifier[key];
			end
		end
	elseif self.capslock then
		return_key = self.caps_modifier[key];
		if return_key == nil then
			return_key = key
		end
	else
		return_key = key
	end

	return return_key
end

function keyboard:getNavKey()
	local key;

	if self.current_key == "up" then key = "up"
	elseif self.current_key == "down" then key = "down"
	elseif self.current_key == "right" then key = "right"
	elseif self.current_key == "left" then key = "left"
	elseif self.current_key == "home" then key = "home"
	elseif self.current_key == "end" then key = "end"
	elseif self.current_key == "pageup" then key = "pageup"
	elseif self.current_key == "pagedown" then key = "pagedown"
	end

	return key
end

function keyboard:getEditKey()
	local key;

	if self.current_key == "insert" then key = "insert"
	elseif self.current_key == "backspace" then key = "backspace"
	elseif self.current_key == "tab" then key = "tab"
	elseif self.current_key == "clear" then key = "clear"
	elseif self.current_key == "return" then key = "enter"
	elseif self.current_key == "delete" then key = "delete"
	end

	return key
end

function keyboard:getModifierKey()
	local key;

	if self.current_key == "numlock" then key = "numlock"
	elseif self.current_key == "capslock" then key = "capslock"
	elseif self.current_key == "scrollock" then key = "scrollock"
	elseif self.current_key == "rshift" then key = "shift"
	elseif self.current_key == "lshift" then key = "shift"
	elseif self.current_key == "rctrl" then key = "ctrl"
	elseif self.current_key == "lctrl" then key = "ctrl"
	elseif self.current_key == "ralt" then key = "alt"
	elseif self.current_key == "lalt" then key = "alt"
	end

	return key
end

function keyboard:getMiscKey()
	local key;

	if self.current_key == "escape" then key = "escape"
	end

	return key
end

function keyboard:getFunKey()
	local key;

	if self.current_key == "f1" then key = "f1"
	elseif self.current_key == "f2" then key = "f2"
	end

	return key
end

mouse = {
	current_key = nil,
	x = 0,
	y = 0,
}

function mouse.reset()
	mouse.current_key = nil;
end

function mouse.getKey()
	return mouse.x, mouse.y, mouse.current_key
end
