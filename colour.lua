---@diagnostic disable: lowercase-global

require("numbers")

Colour = {}

function Colour.hex(hex_string)
	local r, g, b, a;
	if hex_string:len() == 6 then
		r = numbers.hexToDec(hex_string:sub(1,2))/255;
		g = numbers.hexToDec(hex_string:sub(3,4))/255;
		b = numbers.hexToDec(hex_string:sub(5,6))/255;
		a = 1.0;
	elseif hex_string:len() == 8 then
		r = numbers.hexToDec(hex_string:sub(1,2))/255;
		g = numbers.hexToDec(hex_string:sub(3,4))/255;
		b = numbers.hexToDec(hex_string:sub(5,6))/255;
		a = numbers.hexToDec(hex_string:sub(7,8))/255;
	elseif hex_string:len() == 3 then
		r = numbers.hexToDec(hex_string:sub(1,1) .. hex_string:sub(1,1))/255;
		g = numbers.hexToDec(hex_string:sub(2,2) .. hex_string:sub(2,2))/255;
		b = numbers.hexToDec(hex_string:sub(3,3) .. hex_string:sub(3,3))/255;
		a = 1.0;
	else
		error("bad hex string provided to colour.hex()")
	end

	return {r, g, b, a}
end
