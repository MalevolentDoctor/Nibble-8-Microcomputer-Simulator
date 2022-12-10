-- strips leading and trailing whitespace
function string:strip()
	return self:gsub("^%s+", ""):gsub("%s+$", "")
end

-- split string where the sep character appears
function string:split(sep)
	if sep == nil then
		sep = "%s" -- default to white space seperator
	end
	local t = {n = 0}
	for str in self:gmatch("([^".. sep .. "]+)") do
		table.insert(t, str)
		t.n = t.n + 1
	end
	return t
end

-- inserts the character at the index (such that it takes that index)
function string:insert(char, pos)
	local n = self:len()
	pos = pos%(n + 1)

	if pos == 1 then
		return char .. self;
	elseif pos == 0 then
		return self .. char;
	else
		return self:sub(1, pos - 1) .. char .. self:sub(pos, -1);
	end
end

function string:remove(start, fin)
	return self:sub(1, start - 1) .. self:sub(fin + 1, -1)
end

-- string includes character
function string:includes(char)
	return self:find(char, 1) ~= nil
end

-- true if string includes illegal file characters
function string:includesIllegal()
	return (self:includes("<") or self:includes(">") or self:includes(":")
		or self:includes("\"") or self:includes("\\")
		or self:includes("|") or self:includes("%?") or self:includes("%*"))
end