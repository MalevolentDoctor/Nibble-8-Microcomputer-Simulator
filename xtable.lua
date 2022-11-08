do

-- Save in standard text format (will overwrite existing file)
function table.text_save(tbl, fname)
    -- checking the existence of the directory to which we are saving the file
    -- creating it if it does not exist
    local f_info = {};
    local dir = fname:split("/")
    local dir_str = table.concat(dir, "/", 1, dir.n - 1)
    f_info = love.filesystem.getInfo(dir_str, f_info)
    if f_info == nil then
        local ok = love.filesystem.createDirectory(dir_str)
        if ok == false then
            local err_msg = "Failed create folder " .. dir_str
            return err_msg
        end
    end

    -- create a new file (deletes the previous one if it exists)
    f_info = love.filesystem.getInfo(fname, f_info)
    if f_info ~= nil then
        if f_info.type == "file" then -- if the file already exists, delete it
            love.filesystem.remove(fname)
        end
    end

    -- create a new file
    local f, create_err = love.filesystem.newFile(fname)
    if create_err ~= nil then -- check that the file was created
        return create_err
    end
    -- open the file created to be written to
    local ok, open_err = f:open("w");

    if ok then -- if file opened sucessfully, write strings to table
        for i = 1,tbl.n do
            local str = tostring(tbl[i])
            if str ~= nil then
                if i < tbl.n then
                    f:write(str .. "\n")
                else
                    f:write(str)
                end
            else
                local err_msg = "Failed to write line " .. tostring(i) .. " to file (nil value)"
                return err_msg
            end
        end

        f:close()
    else
        return open_err
    end
end

-- Load standard text format
function table.text_load(fname)
    local f_info = {};
    f_info = love.filesystem.getInfo(fname, f_info)

    if f_info.type == "file" then -- file exists, so we can try to read from it
        local tbl = {n = 0}

        for line in love.filesystem.lines(fname) do
            local str = line:gsub("\t", "    ") 	-- replace tab with 4 spaces
            tbl.n = tbl.n + 1;						-- increment table index
            tbl[tbl.n] = tostring(str)				-- add string to table
        end

        return tbl, nil
    else
        local err_msg = "Error: file '" .. fname .. "' does not exist"
        return nil, err_msg
    end
end

function table.subtable(tab, start, fin)
    local new_table = {};
    if fin < 0 then
        fin = #tab + fin + 1;
    end

    for i = start,fin do
        new_table[i] = tab[i];
    end
    return new_table
end

function table.copy(tab)
    local new_table = {}
    for i,v in pairs(tab) do
        if type(v) == "function" then
            -- don't copy functions
        elseif type(v) == "table" then
            new_table[i] = table.copy(v)
        else
            new_table[i] = v
        end
    end
    return new_table
end

end -- end do