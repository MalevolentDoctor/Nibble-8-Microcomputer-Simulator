---@diagnostic disable: lowercase-global


numbers = {
    oct_to_bin_lookup = {
        ['0'] = '000',
        ['1'] = '001',
        ['2'] = '010',
        ['3'] = '011',
        ['4'] = '100',
        ['5'] = '101',
        ['6'] = '110',
        ['7'] = '111'
    },

    hex_to_bin_lookup = {
        ['0'] = '0000',
        ['1'] = '0001',
        ['2'] = '0010',
        ['3'] = '0011',
        ['4'] = '0100',
        ['5'] = '0101',
        ['6'] = '0110',
        ['7'] = '0111',
        ['8'] = '1000',
        ['9'] = '1001',
        ['A'] = '1010', ['a'] = '1010',
        ['B'] = '1011', ['b'] = '1011',
        ['C'] = '1100', ['c'] = '1100',
        ['D'] = '1101', ['d'] = '1101',
        ['E'] = '1110', ['e'] = '1110',
        ['F'] = '1111', ['f'] = '1111'
    },

    hex_to_dec_lookup = {
        ['0'] = 0, ['1'] = 1, ['2'] = 2, ['3'] = 3, 
        ['4'] = 4, ['5'] = 5, ['6'] = 6, ['7'] = 7,
        ['8'] = 8, ['9'] = 9, ['a'] =10, ['A'] =10,
        ['b'] =11, ['B'] =11, ['c'] =12, ['C'] =12,
        ['d'] =13, ['D'] =13, ['e'] =14, ['E'] =14,
        ['f'] =15, ['F'] =15
    }
}

function numbers.decToBin(num)
    local bin = "";
    while num >= 1 do
        bin = tostring(num%2) .. bin;
        num = math.floor(num/2);
    end
    return bin
end

function numbers.octToBin(num)
    local bin = "";

    for i = 1,num:len() do
        bin = bin .. numbers.oct_to_bin_lookup[string.sub(num, i, i)]
    end

    return bin
end

function numbers.hexToBin(num)
    local bin = "";
    for i = 1,num:len() do
        bin = bin .. numbers.hex_to_bin_lookup[string.sub(num, i, i)]
    end

    return bin
end

function numbers.hexToDec(num)
    local dec = 0;
    local length = num:len();
    for i = length,1,-1 do
        dec = dec + numbers.hex_to_dec_lookup[num:sub(i,i)] * math.pow(16, length - i)
    end
    return dec
end

-- forces the binary value to contain a certaing number of bits by trimming
-- or appending zeros, oversize set to 'true' if trimming down required
function numbers.setBits(num, bits)
    if num == nil then return nil, nil end

    local oversize = false;
    if string.len(num) > bits then
        oversize = true;
        while string.len(num) > bits do
            num = string.sub(num, 2, -1)
        end
    elseif string.len(num) < bits then
        while string.len(num) < bits do
            num = "0" .. num
        end
    end
    return num, oversize
end

-- number is in the format "0f4h" (binary (b), octonal (o), decimal (d) or hexadecimal (h))
-- binary value returned with the specified number of bits and no suffix 
function numbers.toBin(num, bits)
    local outnum, oversize;
    if type(num) == "number" then
        outnum, oversize = numbers.setBits(numbers.decToBin(num), bits)
    elseif type(num) == string then

        local num_type = string.sub(num, -1, -1);
        local num_val = string.sub(num, 1, -2);
        
        if num_type == "b" then 
            -- binary to binary (just change number of bits)
            outnum, oversize = numbers.setBits(num_val, bits)
        elseif num_type == "o" then
            -- octal to binary and changing number of bits
            outnum, oversize = numbers.setBits(numbers.octToBin(num_val), bits)
        elseif num_type == "d" then
            -- decimal to binary and changing number of bits
            outnum, oversize = numbers.setBits(numbers.decToBin(tonumber(num_val)), bits)
        elseif num_type == "h" then
            -- hexadecimal to binary and changing number of bits
            outnum, oversize = numbers.setBits(numbers.hexToBin(num_val), bits)
        else 
            -- if bad, return nil, nil
            return nil, nil
        end
    else
        return nil, nil
    end

    -- outnum: binary value e.g. "010011"
    -- oversize: bool true if removed significant bits while trimming
    return outnum, oversize
end

-- converts a binary value (no suffix) to decimal (as a number)
function numbers.binToDec(bin)
    local num = 0;
    local mul = 1;
    local digits = string.len(bin);
    for i = digits,1,-1 do
        num = num + tonumber(string.sub(bin, i, i))*mul;
        mul = mul + mul;
    end
    return num
end