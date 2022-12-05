-- CHANGES: checkForceBits should never get a non numeric value, make forceBits return nil
--			for the number if it contains non-numeric characters

Assembler = {
    opcode_table = {
        noop = 0x00, halt = 0x01, rstt = 0x02, brek = 0x03, clrz = 0x04, clrs = 0x05, clrp = 0x06, clrc = 0x07,
        clri = 0x08, clrv = 0x09, setz = 0x0A, sets = 0x0B, setp = 0x0C, setc = 0x0D, seti = 0x0E, setv = 0x0F,
        anra = 0x10, anrr = 0x11, ania = 0x12, anir = 0x13, anma = 0x14, anaz = 0x15, anrz = 0x16,
                                                                                                   nota = 0x1F,
        orra = 0x20, orrr = 0x21, oria = 0x22, orir = 0x23, orma = 0x24, oraz = 0x25, orrz = 0x26,
        xora = 0x28, xorr = 0x29, xoia = 0x2A, xoir = 0x2B, xoma = 0x2C, xoaz = 0x2D, xorz = 0x2E,
        lsra = 0x30, lsrc = 0x31,              lsla = 0x33, lslc = 0x34,              asra = 0x36, asla = 0x37,
                     rora = 0x39, rorc = 0x3A, rort = 0x3B,              rola = 0x3D, rolc = 0x3E, rolt = 0x3F,
        mvrr = 0x41, mvia = 0x42, mvir = 0x43,                                                     mviz = 0x47,
        tfzi = 0x48, tfiz = 0x49, tfzs = 0x4A, tfsz = 0x4B, tffa = 0x4C, tffr = 0x4D, tfaf = 0x4E, tfef = 0x4F,
        stza = 0x50, stzr = 0x51,                           stma = 0x54, staz = 0x55, strz = 0x56,
        ldza = 0x58, ldzr = 0x59,                           ldma = 0x5C, ldaz = 0x5D, ldrz = 0x5E,
        jump = 0x60,              jpsn = 0x62, jpsp = 0x63,              jpez = 0x65, jpnz = 0x66,
        jppo = 0x68, jppe = 0x69,              jpic = 0x6B, jpnc = 0x6C,              jpiv = 0x6E, jpnv = 0x6F,
        call = 0x70,              clsn = 0x72, clsp = 0x73,              clez = 0x75, clnz = 0x76,
        clpo = 0x78, clpe = 0x79,              clic = 0x7B, clnc = 0x7C,              cliv = 0x7E, clnv = 0x7F,
        retn = 0x80,              rtsn = 0x82, rtsp = 0x83,              rtez = 0x85, rtnz = 0x86,
        rtpo = 0x88, rtpe = 0x89,              rtic = 0x8B, rtnc = 0x8C,              rtiv = 0x8E, rtnv = 0x8F,
        inaa = 0x90, inrr = 0x91,                           inmm = 0x94, inzz = 0x95, inmz = 0x96,
        dcaa = 0x98, dcrr = 0x99,                           dcmm = 0x9C, dczz = 0x9D, dcmz = 0x9E,
        adra = 0xA0, adrr = 0xA1, adia = 0xA2, adir = 0xA3, adma = 0xA4, adaz = 0xA5, adrz = 0xA6,
        acra = 0xA8, acrr = 0xA9, acia = 0xAA, acir = 0xAB, acma = 0xAC, acaz = 0xAD, acrz = 0xAE,
        sbra = 0xB0, sbrr = 0xB1, sbia = 0xB2, sbir = 0xB3, sbma = 0xB4, sbaz = 0xB5, sbrz = 0xB6,
        scra = 0xB8, scrr = 0xB9, scia = 0xBA, scir = 0xBB, scma = 0xBC, scaz = 0xBD, scrz = 0xBE,
        cpra = 0xC0, cprr = 0xC1, cpia = 0xC2, cpir = 0xC3, cpma = 0xC4, cpaz = 0xC5, cprz = 0xC6, cpza = 0xC7,
                                                                                                   cpzr = 0xCF,
        psha = 0xD0, pshr = 0xD1, pshf = 0xD2,
        plla = 0xD8, pllr = 0xD9, pllf = 0xDA,                                                     popd = 0xDF,
        adza = 0xE0, adzr = 0xE1, acza = 0xE2, aczr = 0xE3, sbza = 0xE4, sbzr = 0xE5, scza = 0xE6, sczr = 0xE7,
        inzm = 0xE8, dczm = 0xE9, anza = 0xEA, anzr = 0xEB, orza = 0xEC, orzr = 0xED, xoza = 0xEE, xozr = 0xEF
    },

    reg_alpha = {A = 0x0, B = 0x1, C = 0x2, D = 0x3, E = 0x4, G = 0x5, H = 0x6, X = 0x7, Y = 0x8},
    machine_code = "",
    program_line = 1,
    assembler_report = {n = 0},
    labels = {};
}

function Assembler:assemble(code, filename)

    for line = 1, code.n do -- get all labels
        -- clean up white space
        local args = code[line]:strip():split();

        -- skip if the line is blank
        if args.n == 0 then goto next_line end

        -- check if the line is a label
        if args[1]:sub(1,1) == ":" then
            local label_name = string.upper(args[1]:sub(2,-1)); -- force upper case for label			
            if self.labels[label_name] == nil then
                -- get the position in the program as a 16bit binary number
                 local pline, plineerr = numbers.setBits(numbers.decToBin(self.program_line), 16);

                -- error checking (this may change)
                if not self:checkForceBits(line, pline, plineerr) then 
                    return self.assembler_report
                else
                    -- save the label name (key) and the program_line (value)
                     self.labels[label_name] = pline
                    goto next_line -- jump to the next line in the code
                end
            else
                -- if the label_name ~= nil then there exists a label with this name 
                -- and there will be undeterministic behaviour so throw an error
                local err_msg = "Fatal [line " .. line .. "]: Label ':" .. label_name .. "' defined multiple times"
                self:assembleMsg(err_msg);
                return self.assembler_report;
            end
        else
            -- if not a label then just jump to the next line
            goto next_line
        end

        self.program_line = self.program_line + 1;
        ::next_line::
    end

    print("got labels")

    for line = 1,code.n do -- assemble the rest of the lines
        -- clean up white space
        -- print(code[line])
        local args = code[line]:strip():split();

        -- skip if the line is blank
        if args.n == 0 then goto next_line end

        -- check if the line is a comment or label
        if args[1]:sub(1,1) == ";" then goto next_line end
        if args[1]:sub(1,1) == ":" then goto next_line end

        -- call a function of the argument provided
        if args[1] ~= nil then
            if (self[args[1]] ~= nil) then
                self[args[1]:lower()](self, line, args)
            else
                local err_msg = "Fatal [line " .. line .. "]: Mnemonic `" .. args[1]:upper() .. "' not recognised"
                self:assembleMsg(err_msg);
                return self.assembler_report;
            end
        else
            goto next_line
        end

        self.program_line = self.program_line + 1;
        print(self.machine_code)

        ::next_line::
    end

    table.text_save({n = 1, self.machine_code}, filename)
    self:assembleMsg("Build completed without critical failure")
    return self.assembler_report
end

-- for the four character functions, we are sure that the expected input is given, to some degree
-- Immediate values are denoted by #, labels are denoted by $, otherwise if A, B, C, D, H, L, X, Y are given they are assumed to be registers
-- @ denotes a memory address e.g. @#100110b
-- arguments are seperated by a space
-- ; denotes a comment
-- :label: assigns a label
-- .option defines an assembler option
-- number formats binary (b), octal (c), decimal (d) and hexadecimal (h) are supported, written in the format e.g. #1fh (immediate hexadecimal value 1f)

-- some examples
-- :var: #10d ; this essentially is a variable named "var" with the value 10

do -- Arithmetic Functions

    -- adds two numbers together with a carry
    function Assembler:adc(line, args)
        -- check the arguments
        local arg_vals, arg_types = self:checkArguments(line, args, {immediate = 8, register = 4}, {})

        -- call the appropriate function
        if arg_types[1] == "register" then
            self:acra(line, arg_vals)
        elseif arg_types[1] == "immediate" then
            self:acia(line, arg_vals)
        end

    end

    -- adds the value stored in a register to the value stored in the accumulator,
    -- storing the result in the accumulator
    function Assembler:acra(line, args)
        local opcode = numbers.toBin()
    end

    -- adds an immediate value to the value stored in the accumulator,
    -- storing the result in the accumulator
    function Assembler:acia(line, args)
        
    end

end -- Arithmetic Functions


function Assembler:mov(line, args)
    -- check the number of arguments provided
    if not self:checkNumArgs(line, args, 3) then return self.assembler_report end

    -- try to perform operations using those 
    local opcode =  numbers.toBin(self.op.mov, 8);

    -- Read register inputs as A, B, C, etc
    local arg1 = numbers.toBin(self.reg_alpha[args[2]:upper()], 8);
    local arg2 = numbers.toBin(self.reg_alpha[args[3]:upper()], 8);
    
    if self:checkRegister(line, arg1) and self:checkRegister(line, arg2) then
        self:append(opcode .. arg1 .. arg2)
    end
end

function Assembler:add(line, args)
    if not self:checkNumArgs(line, args, 2) then return self.assembler_report end

    local arg1 = self.reg_alpha[args[2]:upper()];

    print(self:checkRegister(line, arg1))

    if self:checkRegister(line, arg1) then
        self:append(self.op.add .. arg1 .. "0000")
    end
end

function Assembler:adi(line, args)
end

function Assembler:jmp(line, args)
    if not self:checkNumArgs(line, args, 2) then return self.assembler_report end
    
    local arg1 = self.labels[args[2]:upper()] -- argument given as a label
    if arg1 == nil then -- argument not given as a label
        local overflow;
        arg1, overflow = numbers.setBits(numbers.toBin(arg[1]), 16)
        if self:checkForceBits(arg1, overflow) then
            self:append(self.op.jmp .. arg1)
        end
    else
        self:append(self.op.jmp .. arg1)
    end
end

function Assembler:checkNumArgs(line, args, n)
    for i = 2,n do
        if args[i] == nil then
            local err_msg = "Fatal [line " .. line .. "]: Not enough arguments provided"
            self:assembleMsg(err_msg);
            return false
        end
    end
    if args[n + 1] ~= nil and args[n + 1]:sub(1,1) ~= ";" then
        local err_msg = "Error [line " .. line .. "]: Too many arguments provided"
        self:assembleMsg(err_msg);
        return false;
    end
    return true;
end

function Assembler:checkForceBits(line, num, err)
    if tonumber(num) == nil then
        local err_msg = "Error [line " .. line .. "]: non numeric value(s) provided"
        self:assembleMsg(err_msg);
        return false;
    end

    -- check if the numbers provided were oversized
    if err then
        local err_msg = "Error [line " .. line .. "]: argmument exceed maximum value"
        self:assembleMsg(err_msg);
        return false
    end

    return true
end

function Assembler:checkRegister(line, reg)
    if reg == nil then
        local err_msg = "Fatal [line " .. line .. "]: Invalid definition of registers"
        self:assembleMsg(err_msg);
        return false;
    else
        return true
    end
end

function Assembler:append(str)
    self.machine_code = self.machine_code .. str
end

-- append a compile message to be returned once compilation is complete
function Assembler:assembleMsg(str)
    table.insert(self.assembler_report, self.assembler_report.n + 1, str);
    self.assembler_report.n = self.assembler_report.n + 1;
end


function Assembler:checkArguments(line, args, allowed_arg_1, allowed_arg_2)
    -- argument types: "register", "immediate", "address"
    -- allowed_arg = {"immediate" = 8} (allowed an 8 bit immediate value)
    -- return the types and sizes of the two arguments
    -- {arg1 = 8, arg2 = 4} or something like that
    -- # denotes immediate
    -- @ denotes address
    -- A, B, C etc denote registers
    -- args is just the table of arguments not the opcode
    -- label, if defined, should always be safe to use
    -- if not typed, the value is assumed to be a label, this is equivelant to an address

    local arg_place = {"first", "second"}
    local allowed_arg = {allowed_arg_1, allowed_arg_2}

    local arg_vals = {}
    local arg_types = {}

    for i = 1,2 do
        if (#allowed_arg[i] > 0 and args[i] == nil) then -- no argument provided, one desired
            self:assembleMsg("Error [line " .. line .. "]: Expected " .. arg_place[i] .. " argument, none provided")

        elseif (#allowed_arg[i] == 0) then -- argument provided, none desired
            self:assembleMsg("Warning [line " .. line .. "]: No " .. arg_place[i] .. " argument expected, it will be ignored")

        elseif (string.sub(arg[i], 1, 1) == "#") then -- immediate value
            local bit_count = allowed_arg[i].immediate
            if bit_count ~= nil then
                local val = numbers.tonumber()
                if (val ~= nil) then
                    if (val < math.pow(2,bit_count)) then
                        arg_vals[i] = val
                        arg_types[i] = "immediate"
                    else
                        self:assembleMsg("Warning [line " .. line .. "]: Value in the " .. arg_place[i] .. 
                                         " argument exceeds the maximum number of bytes, it will be truncated")
                        arg_vals[i] = val
                        arg_types[i] = "immediate"
                    end
                else
                    self:assembleMsg("Error [line " .. line .. "]: The numeric expression in the " .. arg_place[i] .. " argument is malformed")

                end
            else
                self:assembleMsg("Error [line " .. line .. "]: Operator does not support an immediate value for the " .. arg_place[i] .. " argument")
            end

        elseif (string.sub(arg[i], 1, 1) == "@") then -- address value
            local bit_count = allowed_arg[i].address
            if bit_count ~= nil then
                local val = numbers.tonumber()
                if (val ~= nil) then
                    if (val < math.pow(2,bit_count)) then
                        arg_vals[i] = val
                        arg_types[i] = "address"
                    else
                        self:assembleMsg("Warning [line " .. line .. "]: Value in the " .. arg_place[i] .. 
                                         " argument exceeds the maximum number of bytes, it will be truncated")
                        arg_vals[i] = val
                        arg_types[i] = "address"
                    end
                else
                    self:assembleMsg("Error [line " .. line .. "]: The numeric expression in the " .. arg_place[i] .. " argument is malformed")
                end
            else
                self:assembleMsg("Error [line " .. line .. "]: Operator does not support an address value for the " .. arg_place[i] .. " argument")
            end

        elseif (self.reg_alpha[arg[i]] ~= nil) then -- register
            if allowed_arg[i].register ~= nil then
                arg_vals[i] = self.reg_alpha[arg[i]]
                arg_types[i] = "register"
            else
                self:assembleMsg("Error [line " .. line .. "]: Operator does not support a register value for the " .. arg_place[i] .. " argument")
            end

        else -- label
            if allowed_arg[i].address ~= nil then
                local label_val = self.labels[arg[i]]
                if label_val ~= nil then
                    arg_vals[i] = label_val
                    arg_types[i] = "address"
                else
                    self:assembleMsg("Error [line " .. line .. "]: Label " .. arg[i] .. " is not defined anywhere in the program")
                end
            end
        end
    end

    return arg_vals, arg_types


end