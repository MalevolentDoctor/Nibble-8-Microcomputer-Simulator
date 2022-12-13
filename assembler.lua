local utf8 = require("utf8")
local opcodes = require("opcodes")

Assembler = {}
Assembler.__index = Assembler

function Assembler.new()
    local self = {}
    setmetatable(self, Assembler)

    self.short_mnemonic_table = {
        adc = -1, sbc = -1, ini = "inip", dci = "dcip", ins = "insp", dcs = "dcsp", clc = "clrc", cli = "clri", 
        cls = "clrs", clv = "clrv", clz = "clrz", stc = "setc", sti = "seti", sts = "sets", stv = "setv", stz = "setz", 
        ["and"] = "ana", ora = -1, xor = -1, ["not"] = "nota", cmp = -1, rar = "rort", ral = "rolt"
    }

    self.oc55 = {noop=0, halt=0, rstt=0, brek=0, mvrr=0, stma=0, staz=0, ldma=0, ldaz=0, psha=0, plla=0, acra=0, acia=0,
            scra=0, scia=0, inip=0, dcip=0, insp=0, dcsp=0, anra=0, ania=0, orra=0, oria=0, xora=0, xoia=0, nota=0,
            rort=0, rolt=0, jump=0, jpsn=0, jpsp=0, jpez=0, jpnz=0, jpic=0, jpnc=0, jpiv=0, jpnv=0, call=0, retn=0,
            clrz=0, clrs=0, clrc=0, clri=0, clrv=0, setz=0, sets=0, setc=0, seti=0, setv=0, tfzi=0, tfiz=0, tfas=0,
            tfsa=0, tffa=0, tfaf=0}

    self.reg_alpha = {A = 0x0, B = 0x1, C = 0x2, D = 0x3, E = 0x4, H = 0x5, L = 0x6, X = 0x7, Y = 0x8}
    self.machine_code = ""
    self.program_index = 1
    self.start_index = 0xfffc
    self.assembler_report = {n = 0}
    self.labels = {}
    self.limitation = "oc55"

    return self
end

function Assembler:assemble(code, filename)
    -- debug code input
    print("\ncode input: ")
    for k,v in pairs(code) do
        print(k, v)
    end

    for line = 1,code.n do -- assemble the rest of the lines
        print("\ncode at line " .. tostring(line) .. ": " .. code[line])


        local inputs = code[line]:strip():split();

        -- skip if the line is blank
        if table.getLength(inputs) == 0 then
            print("blank line, jumping to the end of the loop")
            goto next_line
        end

        -- Assembler parameters
        if (string.sub(inputs[1], 1, 1) == ".") then
            self:handleAssemblerParams(line, inputs)
        end

        -- skip over argument if it is a label
        if string.sub(inputs[1], 1, 1) == ":" then
            if string.sub(inputs[1], -1, -1) == ":" then
                local label_name = string.sub(inputs[1], 2, -2)
                print("saving label: " .. label_name)
                if self.labels[label_name] ~= nil then
                    self:assembleMsg("Error [line " .. line .. "]: This label has already been defined")
                end

                if (label_name:includes("%.")) then
                    self:assembleMsg("Error [line " .. line .. "]: Label cannot contain '.' character")
                else
                    self.labels[label_name] = self.program_index
                end

                -- remove label from the table
                table.remove(inputs, 1)
                if table.getLength(inputs) == 0 then
                    print("line only contained a label, jumping to end of loop")
                    goto next_line
                end

            end
        end

        for k,v in pairs(inputs) do
            print(k, v)
        end

        -- check if the line is a comment
        if inputs[1]:sub(1,1) == ";" then
            print("this line is a comment: skipping")
            goto next_line 
        end

        -- if the first argument is a mnemonic
        if (opcodes.opcode_table[inputs[1]] ~= nil or self.short_mnemonic_table[inputs[1]] ~= nil) then
            -- clean up the arguments to be passed
            local mnemonic = table.remove(inputs, 1)
            if (self.short_mnemonic_table[mnemonic] ~= -1 and self.short_mnemonic_table[mnemonic] ~= nil) then
                mnemonic = self.short_mnemonic_table[mnemonic]
            end

            for i,v in pairs(inputs) do
                print(i,v)
            end

            inputs = self:trimArguments(inputs)

            -- call the funciton named by the mnemonic
            if string.len(mnemonic) == 3 then
                self[mnemonic:lower()](self, line, inputs)
            else
                self:assembleOperation(mnemonic, line, inputs)
            end
        else
            -- if the first argmuent is not a mnemonic, check if it is an immediate
            -- if it is, write the value directly to the output
            for i = 1,table.getLength(inputs) do
                local arg_vals, arg_types = self:handleArguments(line, {inputs[i]}, {immediate = -1}, {})

                if (arg_types[1] == "immediate") then
                    local arg_bytes = math.ceil(string.len(arg_vals[1])/8)
                    self:append(arg_vals[i])
                    self.program_index = self.program_index + arg_bytes;
                else
                    self:assembleMsg("Error [line " .. line .. "]: Unidentified value")
                end
            end
        end

        ::next_line::
        print("done line")
    end

    self:addProgramIndex(-1)
    if (self.program_index <= 0) then
        self:assembleMsg("Error: there is nothing to assemble")
    end

    self.start_index = self.start_index - self.program_index
    self:resolveLabels()

    self.machine_code = numbers.toBin(self.program_index, 16) .. numbers.toBin(self.start_index, 16) .. self.machine_code

    print("start index: " .. tostring(self.start_index))
    print("program index: " .. tostring(self.program_index))

    -- check for errors, whether or not to compile
    local num_errors = 0;
    local num_warnings = 0;
    for _,v in ipairs(self.assembler_report) do
        if v:sub(1, 5) == "Error" then num_errors = num_errors + 1 end
        if v:sub(1, 7) == "Warning" then num_warnings = num_warnings + 1 end
    end

    if num_errors > 0 then
        self:assembleMsg("Fatal errors occured during assembly")
        return self.assembler_report
    end

    if num_warnings > 0 then
        self:assembleMsg("file assembled with " .. tostring(num_warnings) .. " warnings")
        table.text_save({n = 1, self.machine_code}, filename)
        return self.assembler_report
    end

    self:assembleMsg("file assembled with no errors or warnings")
    table.text_save({n = 1, self.machine_code}, filename)
    return self.assembler_report
end

do -- Arithmetic Functions
    -- adds two numbers together with a carry
    function Assembler:adc(line, args)

        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {immediate = 8, register = 4}, {none = 0})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[2] == "none") then
            self:assembleOperation("acra", line, args)
        elseif (arg_types[1] == "immediate" and arg_types[2] == "none") then
            self:assembleOperation("acia", line, args)
        end
    end

    -- subtracts two numbers together with a carry
    function Assembler:sbc(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {immediate = 8, register = 4}, {none = 0})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[2] == "none") then
            self:assembleOperation("scra", line, args)
        elseif (arg_types[1] == "immediate" and arg_types[1] == "none") then
            self:assembleOperation("scia", line, args)
        end
    end
end -- Arithmetic Functions

do -- Incrementing and Decrementing
end -- Incrementing and Decrementing

do -- Setting and Clearing Flags
end -- Setting and Clearing Flags

do -- Logic
    function Assembler:ana(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {immediate = 8, register = 4}, {none = 0})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[2] == "none") then
            self:assembleOperation("anra", line, args)
        elseif (arg_types[1] == "immediate" and arg_types[2] == "none") then
            self:assembleOperation("ania", line, args)
        end
    end

    function Assembler:ora(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {immediate = 8, register = 4}, {none = 0})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[2] == "none") then
            self:assembleOperation("orra", line, args)
        elseif (arg_types[1] == "immediate" and arg_types[2] == "none") then
            self:assembleOperation("oria", line, args)
        end
    end

    function Assembler:xor(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {immediate = 8, register = 4}, {none = 0})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[2] == "none") then
            self:assembleOperation("xora", line, args)
        elseif (arg_types[1] == "immediate" and arg_types[2] == "none") then
            self:assembleOperation("xoia", line, args)
        end
    end

    function Assembler:cmp(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {immediate = 8, register = 4}, {none = 0})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[2] == "none") then
            self:assembleOperation("cpra", line, args)
        elseif (arg_types[1] == "immediate" and arg_types[2] == "none") then
            self:assembleOperation("cpia", line, args)
        end
    end
end -- Logic

do -- Data Manipulation
end -- Data Manipulation

do -- Moving Data

    function Assembler:mov(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {register = 4}, {register = 4})

        -- call the appropriate function
        if (arg_types[1] == "register" and arg_types[1] == "register") then
            self:assembleOperation("mvrr", line, args)
        end
    end

    function Assembler:str(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {address = 16, none = 0}, {})

        -- call the appropriate function
        if (arg_types[1] == "address" and arg_types[2] == "none") then
            self:assembleOperation("stma", line, args)
        elseif (arg_types[1] == "none" and arg_types[2] == "none") then
            self:assembleOperation("staz", line, args)
        end
    end

    function Assembler:lod(line, args)
        -- check the arguments
        local _, arg_types = self:handleArguments(line, args, {address = 16, none = 0}, {})

        -- call the appropriate function
        if (arg_types[1] == "address" and arg_types[2] == "none") then
            self:assembleOperation("ldma", line, args)
        elseif (arg_types[1] == "none" and arg_types[2] == "none") then
            self:assembleOperation("ldaz", line, args)
        end
    end

    function Assembler:psh(line, args)
        self:assembleOperation("psha", line, args)
    end

    function Assembler:pll(line, args)
        self:assembleOperation("plla", line, args)
    end

end -- Moving Data

-- adds a value to the program index, this should be a number of bytes
function Assembler:addProgramIndex(num)
    self.program_index = self.program_index + num
end

-- append a compile message to be returned once compilation is complete
function Assembler:assembleMsg(str)
    table.insert(self.assembler_report, self.assembler_report.n + 1, str);
    self.assembler_report.n = self.assembler_report.n + 1;
end

function Assembler:append(str)
    self.machine_code = self.machine_code .. str
end

-- 
function Assembler:trimArguments(args)
    local args_end = table.getLength(args)

    for i = args_end,1,-1 do
        if (string.sub(args[i], 1, 1) == ";") then
            args_end = i - 1
        end
    end

    return table.subtable(args, 1, args_end)
end

-- return the correct form from the arg handler
function Assembler:assembleOperation(mnemonic, line, args)
    if self[self.limitation][mnemonic] == nil then
        self:assembleMsg("Error [line " .. line .. "]: This mnemonic is not supported by this processor")
    else
        local args_lookup_table = {n = "none", r = "register", i = "immediate", z = "zero", a = "address"}

        local arg_indices = {string.sub(opcodes.opcode_table[mnemonic].args, 1,1), string.sub(opcodes.opcode_table[mnemonic].args, 4,4)}
        local req_arg_sizes = {tonumber(string.sub(opcodes.opcode_table[mnemonic].args, 2,3)), tonumber(string.sub(opcodes.opcode_table[mnemonic].args, 5,6))}

        local req_arg_types = {args_lookup_table[arg_indices[1]], args_lookup_table[arg_indices[2]]}

        local arg_vals, arg_types = self:handleArguments(line, args, {[req_arg_types[1]] = req_arg_sizes[1]}, {[req_arg_types[2]] = req_arg_sizes[2]})
        
        if (arg_types[1] == req_arg_types[1] and arg_types[2] == req_arg_types[2]) then
            print("\narg types entered")
            for k,v in pairs(arg_types) do
                print(k, v)
            end

            print("\narg vals entered")
            for k,v in pairs(arg_vals) do
                print(k, v)
            end

            local opcode = numbers.toBin(opcodes.opcode_table[mnemonic].opcode, 8)
            local command_size = 8 + req_arg_sizes[1] + req_arg_sizes[2]
            self:append(opcode .. arg_vals[1] .. arg_vals[2])
            self:addProgramIndex(math.ceil(command_size/8))
        end
    end
end

function Assembler:handleAssemblerParams(line, inputs)
    local arg = string.lower(string.sub(table.remove(inputs, 1), 2, -1))
    inputs = self:trimArguments(inputs)
    
    if arg == "start" then
    else
        self:assembleMsg("Error [line " .. line .. "]: Assembler command `" .. arg .. "' not recognised")
    end
end

function Assembler:handleArguments(line, args, allowed_arg_1, allowed_arg_2)
    local arg_place = {"first", "second"}
    local allowed_args = {allowed_arg_1, allowed_arg_2}

    print("Allowed arguments in the first place")
    for k,v in pairs(allowed_args[1]) do
        print(k,v)
    end

    print("Allowed arguments in the second place")
    for k,v in pairs(allowed_args[2]) do
        print(k,v)
    end

    local arg_vals = {}
    local arg_types = {}

    for i = 1,2 do
        if (args[i] == nil and (allowed_args[i].none ~= nil or table.getLength(allowed_args[i]) == 0)) then -- no argument and none desired
            print("No argument provided, and none was desired")
            arg_vals[i] = ""
            arg_types[i] = "none"

        elseif (args[i] == nil and table.getLength(allowed_args[i]) > 0) then -- no argument provided, one desired
            print("no argument was proveded, but one was expected")
            self:assembleMsg("Error [line " .. line .. "]: Expected " .. arg_place[i] .. " argument, none provided")

        elseif (string.sub(args[i], 1, 1) == "#") then -- immediate value
            arg_vals[i], arg_types[i] = self:handleImmediateArgs(line, i, args, allowed_args)

        elseif (string.sub(args[i], 1, 1) == "@") then -- address value
            arg_vals[i], arg_types[i] = self:handleAddressArgs(line, i, args, allowed_args)

        elseif (self.reg_alpha[args[i]] ~= nil) then -- register
            arg_vals[i], arg_types[i] = self:handleRegisterArgs(line, i, args, allowed_args)

        elseif (args[i] ~= nil) then -- label
            arg_vals[i], arg_types[i] = self:handleLabelArgs(line, i, args, allowed_args)
        end
    end

    return arg_vals, arg_types
end

function Assembler:handleImmediateArgs(line, i, args, allowed_args)
    local arg_val, arg_type
    local places = {"first", "second"}

    print("recieved an immediate value")
    local bit_count = allowed_args[i].immediate

    if bit_count ~= nil then
        print("value given was an immediate that can have " .. tostring(bit_count) .. " bits")

        -- check if the provided argument is in the form of a string
        local is_string = false
        if (string.sub(args[i], 1, 1) == '"' and string.sub(args[i], -1, -1) == '"') then
            is_string = true
        elseif (string.sub(args[i], 1, 1) == "'" and string.sub(args[i], -1, -1) == "'") then
            is_string = true
        end

        local val = nil

        -- if the argument is a string, then we handle it a little differently than a number
        if (is_string) then
            print("value given was a string")
            local str = string.sub(args[i], 2, -2)      -- extract the string
            local str_len = string.len(str)             -- get the length of the string
            local str_bits = str_len*8                  -- get the number of bits occupied by the string (each character takes 1 byte)

            -- check if the number of bits is within the allowed amount
            if (str_bits > bit_count) then
                self:assembleMsg("Warning [line " .. line .. "]: Value in the " .. places[i] .. 
                                    " argument exceeds the maximum number of bytes, it will be truncated")
            end

            local bin_val = ""                          -- initialise the string to store the binary representation of the string

            -- loop through each character, check that it is valid and append the binary representation to bin_val
            for i = str_len,1,-1 do
                local char = string.sub(str, i, i)
                local byte = utf8.to_byte(char)
                if byte ~= nil then
                    bin_val = bin_val .. numbers.toBin(byte, 8)
                else
                    self:assembleMsg("Error [line " .. line .. "]: Undefined unicode character used")
                end

                -- if there was something in the string, then we set arg_vals equal to said value
                if string.len(bin_val) > 0 then
                    if (bit_count ~= -1) then
                        local str_end_index = math.floor(bit_count/8)
                        bin_val = string.sub(bin_val, 1, str_end_index)
                    end
                    arg_val = bin_val
                    arg_type = "immediate"
                end
            end

        else -- if the value is not a string, then we assume it to be a number
            val = numbers.tonumber(string.sub(args[i], 2, -1))
            print("value given was an immediate number: " .. tostring(val))
        
            if (val ~= nil) then
                if (bit_count == -1) then
                    -- needs to be in little endian
                    local num_bits = math.floor(math.log(val, 2)) + 1
                    num_bits = num_bits + math.fmod(8 - math.fmod(num_bits, 8), 8)
                    arg_val = numbers.toBin(val, num_bits)
                    arg_type = "immediate"
                elseif (val < math.pow(2,bit_count)) then
                    arg_val = numbers.toBin(val, bit_count)
                    arg_type = "immediate"
                else
                    self:assembleMsg("Warning [line " .. line .. "]: Value in the " .. places[i] .. 
                                    " argument exceeds the maximum number of bytes, it will be truncated")
                    arg_val = numbers.toBin(val, bit_count)
                    arg_type = "immediate"
                end
            else
                self:assembleMsg("Error [line " .. line .. "]: The numeric expression in the " .. places[i] .. " argument is malformed")
            end
        end
    else
        self:assembleMsg("Error [line " .. line .. "]: Operator does not support an immediate value for the " .. places[i] .. " argument")
    end

    return arg_val, arg_type
end

function Assembler:handleAddressArgs(line, i, args, allowed_args)
    local arg_val, arg_type
    local places = {"first", "second"}

    print("provided an address value")
    local bit_count = allowed_args[i].address

    if bit_count ~= nil then
        local val = numbers.tonumber(string.sub(args[i], 2, -1))

        if (val ~= nil) then
            if (val >= math.pow(2,bit_count)) then
                self:assembleMsg("Warning [line " .. line .. "]: Value in the " .. places[i] .. 
                                    " argument exceeds the maximum number of bytes, it will be truncated")
            end
            
            local bin = numbers.toBin(val, 16)
            local address_bin = string.sub(bin, -8, -1) .. string.sub(bin, 1, 8)
            arg_val = address_bin
            arg_type = "address"

        else
            self:assembleMsg("Error [line " .. line .. "]: The numeric expression in the " .. places[i] .. " argument is malformed")
        end
    else
        self:assembleMsg("Error [line " .. line .. "]: Operator does not support an address value for the " .. places[i] .. " argument")
    end

    return arg_val, arg_type
end

function Assembler:handleRegisterArgs(line, i, args, allowed_args)
    local arg_val, arg_type
    local places = {"first", "second"}

    print("provided a register value")
    if allowed_args[i].register ~= nil then
        arg_val = numbers.toBin(self.reg_alpha[args[i]], 4)

        -- buffer to make the register take up 8 bytes
        if allowed_args[i].register == 8 then
            arg_val = arg_val .. "0000"
        end
        arg_type = "register"
    else
        self:assembleMsg("Error [line " .. line .. "]: Operator does not support a register value for the " .. places[i] .. " argument")
    end

    return arg_val, arg_type
end

function Assembler:handleLabelArgs(line, i, args, allowed_args)
    local arg_val, arg_type
    local places = {"first", "second"}

    print("provided a label")

    if (allowed_args[i].address == 16) then
        arg_val = "[" .. tostring(line) .. "." .. args[i] .. "]"
        arg_type = "address"
    else
        self:assembleMsg("Error [line " .. line .. "]: The " .. places[i] .. " argument cannot be a label (16-bit address)")
    end

    return arg_val, arg_type
end

function Assembler:resolveLabels()
    local i, label_data, line, label_name, label_val, address, address_bin
    local j = 1

    print("\nResolving Labels")
    for k,v in pairs(self.labels) do
        print(k, v)
    end

    while (string.find(self.machine_code, "%[", j) ~= nil) do
        i = string.find(self.machine_code, "%[", j)
        j = string.find(self.machine_code, "%]", i)
        label_data = string.sub(self.machine_code, i + 1, j - 1):split(".")
        line = label_data[1]
        label_name = label_data[2]

        print("line: " .. line)
        print("label name: " .. label_name)

        label_val = self.labels[label_name]
        if (label_val == nil) then
            self:assembleMsg("Error [line " .. line .. "]: Label not defined")
            return nil, nil
        else
            address = self.start_index + label_val - 1
            address_bin = numbers.toBin(address, 16)
            if address_bin ~= nil then
                self.machine_code = string.sub(self.machine_code, 1, i-1) .. string.sub(address_bin, -8, -1) .. string.sub(address_bin, 1, 8) .. string.sub(self.machine_code, j + 1, -1)
                j = i + 16
            end
        end
    end
end