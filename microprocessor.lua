Microprocessor = {}
Microprocessor.__index = Microprocessor
-- 8 bit opcode, 4-16 bit args (up to a total of 16 bits)
-- 16 bit opcodes
-- 1 working register, 1 instruction pointer, 1 flag register
-- flag [sign, zero, carry/borrow, parity]

-- have some way to characterise compute time
-- byte addressable (not individual bits)

function Microprocessor.new(microcomputer, reg_size)
    local self = {}
    setmetatable(self, Microprocessor)

    self.opcode_table = {
        [0x00] = "noop", [0x01] = "halt", [0x02] = "rstt", [0x03] = "brek", [0x04] = "clrz", [0x05] = "clrs", [0x06] = "clrp", [0x07] = "clrc",
        [0x08] = "clri", [0x09] = "clrv", [0x0A] = "setz", [0x0B] = "sets", [0x0C] = "setp", [0x0D] = "setc", [0x0E] = "seti", [0x0F] = "setv",
        [0x10] = "anra", [0x11] = "anrr", [0x12] = "ania", [0x13] = "anir", [0x14] = "anma", [0x15] = "anaz", [0x16] = "anrz", [0x17] = "null",
        [0x18] = "null", [0x19] = "null", [0x1A] = "null", [0x1B] = "null", [0x1C] = "null", [0x1D] = "null", [0x1E] = "null", [0x1F] = "nota",
        [0x20] = "orra", [0x21] = "orrr", [0x22] = "oria", [0x23] = "orir", [0x24] = "orma", [0x25] = "oraz", [0x26] = "orrz", [0x27] = "null",
        [0x28] = "xora", [0x29] = "xorr", [0x2A] = "xoia", [0x2B] = "xoir", [0x2C] = "xoma", [0x2D] = "xoaz", [0x2E] = "xorz", [0x2F] = "null",
        [0x30] = "lsra", [0x31] = "lsrc", [0x32] = "null", [0x33] = "lsla", [0x34] = "lslc", [0x35] = "null", [0x36] = "asra", [0x37] = "asla",
        [0x38] = "null", [0x39] = "rora", [0x3A] = "rorc", [0x3B] = "rort", [0x3C] = "null", [0x3D] = "rola", [0x3E] = "rolc", [0x3F] = "rolt",
        [0x40] = "null", [0x41] = "mvrr", [0x42] = "mvia", [0x43] = "mvir", [0x44] = "null", [0x45] = "null", [0x46] = "null", [0x47] = "mviz",
        [0x48] = "tfzi", [0x49] = "tfiz", [0x4A] = "tfzs", [0x4B] = "tfsz", [0x4C] = "tffa", [0x4D] = "tffr", [0x4E] = "tfaf", [0x4F] = "tfef",
        [0x50] = "stza", [0x51] = "stzr", [0x52] = "null", [0x53] = "null", [0x54] = "stma", [0x55] = "staz", [0x56] = "strz", [0x57] = "null",
        [0x58] = "ldza", [0x59] = "ldzr", [0x5A] = "null", [0x5B] = "null", [0x5C] = "ldma", [0x5D] = "ldaz", [0x5E] = "ldrz", [0x5F] = "null",
        [0x60] = "jump", [0x61] = "null", [0x62] = "jpsn", [0x63] = "jpsp", [0x64] = "null", [0x65] = "jpez", [0x66] = "jpnz", [0x67] = "null",
        [0x68] = "jppo", [0x69] = "jppe", [0x6A] = "null", [0x6B] = "jpic", [0x6C] = "jpnc", [0x6D] = "null", [0x6E] = "jpiv", [0x6F] = "jpnv",
        [0x70] = "call", [0x71] = "null", [0x72] = "clsn", [0x73] = "clsp", [0x74] = "null", [0x75] = "clez", [0x76] = "clnz", [0x77] = "null",
        [0x78] = "clpo", [0x79] = "clpe", [0x7A] = "null", [0x7B] = "clic", [0x7C] = "clnc", [0x7D] = "null", [0x7E] = "cliv", [0x7F] = "clnv",
        [0x80] = "retn", [0x81] = "null", [0x82] = "rtsn", [0x83] = "rtsp", [0x84] = "null", [0x85] = "rtez", [0x86] = "rtnz", [0x87] = "null",
        [0x88] = "rtpo", [0x89] = "rtpe", [0x8A] = "null", [0x8B] = "rtic", [0x8C] = "rtnc", [0x8D] = "null", [0x8E] = "rtiv", [0x8F] = "rtnv",
        [0x90] = "inaa", [0x91] = "inrr", [0x92] = "null", [0x93] = "null", [0x94] = "inmm", [0x95] = "inzz", [0x96] = "inmz", [0x97] = "null",
        [0x98] = "dcaa", [0x99] = "dcrr", [0x9A] = "null", [0x9B] = "null", [0x9C] = "dcmm", [0x9D] = "dczz", [0x9E] = "dcmz", [0x9F] = "null",
        [0xA0] = "adra", [0xA1] = "adrr", [0xA2] = "adia", [0xA3] = "adir", [0xA4] = "adma", [0xA5] = "adaz", [0xA6] = "adrz", [0xA7] = "null",
        [0xA8] = "acra", [0xA9] = "acrr", [0xAA] = "acia", [0xAB] = "acir", [0xAC] = "acma", [0xAD] = "acaz", [0xAE] = "acrz", [0xAF] = "null",
        [0xB0] = "sbra", [0xB1] = "sbrr", [0xB2] = "sbia", [0xB3] = "sbir", [0xB4] = "sbma", [0xB5] = "sbaz", [0xB6] = "sbrz", [0xB7] = "null",
        [0xB8] = "scra", [0xB9] = "scrr", [0xBA] = "scia", [0xBB] = "scir", [0xBC] = "scma", [0xBD] = "scaz", [0xBE] = "scrz", [0xBF] = "null",
        [0xC0] = "cpra", [0xC1] = "cprr", [0xC2] = "cpia", [0xC3] = "cpir", [0xC4] = "cpma", [0xC5] = "cpaz", [0xC6] = "cprz", [0xC7] = "cpza",
        [0xC8] = "null", [0xC9] = "null", [0xCA] = "null", [0xCB] = "null", [0xCC] = "null", [0xCD] = "null", [0xCE] = "null", [0xCF] = "cpzr",
        [0xD0] = "psha", [0xD1] = "pshr", [0xD2] = "pshf", [0xD3] = "null", [0xD4] = "null", [0xD5] = "null", [0xD6] = "null", [0xD7] = "null",
        [0xD8] = "plla", [0xD9] = "pllr", [0xDA] = "pllf", [0xDB] = "null", [0xDC] = "null", [0xDD] = "null", [0xDE] = "null", [0xDF] = "popd",
        [0xE0] = "adza", [0xE1] = "adzr", [0xE2] = "acza", [0xE3] = "aczr", [0xE4] = "sbza", [0xE5] = "sbzr", [0xE6] = "scza", [0xE7] = "sczr",
        [0xE8] = "inzm", [0xE9] = "dczm", [0xEA] = "anza", [0xEB] = "anzr", [0xEC] = "orza", [0xED] = "orzr", [0xEE] = "xoza", [0xEF] = "xozr",
        [0xF0] = "null", [0xF1] = "null", [0xF2] = "null", [0xF3] = "null", [0xF4] = "null", [0xF5] = "null", [0xF6] = "null", [0xF7] = "null",
        [0xF8] = "null", [0xF9] = "null", [0xFA] = "null", [0xFB] = "null", [0xFC] = "null", [0xFD] = "null", [0xFE] = "null", [0xFF] = "null",
    }

    self.thisMicrocomputer = microcomputer
    self.active = false
    self.cycles = 0;

    self.data_bus = 0x00
    self.address_bus = 0x0000

    -- ## Registers ## --
    self.reg_size = reg_size;
    self.accumulator = 0x00
    
    self.gp_registers = {}                 -- general purpose registers                    (8x(0-8) bits)
    for i = 1,reg_size do
        self.gp_registers[i] = 0x00
    end

    --initialise flag register
    self.flags = 0x00                   -- register to store flags                      (8 bits)

    self.alu_temp_register = 0x00       -- temporary register in the ALU                (8 bits)
    self.instruction_register = 0x00    -- register to store the current instruction    (8 bits)
    self.instruction_pointer = 0x0000   -- register to store the instrunction pointer   (16 bits)
    self.stack_pointer = 0x00           -- register to store the stack pointer          (8 bits)


    return self
end

-- start address at fffc/fffd
-- cannot differentiate between RAM and ROM

-- 0x0000 - 0x00ff: zero page
-- 0x0100 - 0x01ff: stack
-- 0x0200 - 0x0?ff: program
-- 0x0(?+1)00 - 0xefff: general purpose memory
-- 0xff00 - 0xffff: system params, dedication io stuff etc

-- store in little endian

-- ## Instruction
-- fetch takes one cycle
-- decode takes 1 cycle


function Microprocessor:update(dt)
    if self.active then
        self:fetch()
        self:decodeOpcode()
        -- love.timer.sleep(0.2)
    end
end

do -- ## Operations ## --

do -- Arithmetic

    -- adds the value stored in a register to the value stored in the accumulator, storing the result in the accumulator
    function Microprocessor:acra()
        self:meta_writeRegisterToTemp()
        self:aluAdd()
    end

    -- adds an immediate value to the value stored in the accumulator, storing the result in the accumulator
    function Microprocessor:acia()
        self:meta_writeImmediateToTemp()
        self:aluAdd()
    end

    function Microprocessor:scra()
        self:meta_writeRegisterToTemp()
        self:aluSub()
    end

    function Microprocessor:scia()
        self:meta_writeImmediateToTemp()
        self:aluSub()
    end

end -- Arithmetic

do -- Incrementing/Decrementing

    function Microprocessor:inip()
        self:incInstructionPointer()
    end

    function Microprocessor:dcip()
        self:decInstructionPointer()
    end

    function Microprocessor:insp()
        self:incStackPointer()
    end

    function Microprocessor:dcsp()
        self:decStackPointer()
    end

end -- incrementing/Decrementing

do -- Set/Clear flags (should take 2 cycles each)

    -- clears the carry flag
    function Microprocessor:clrc()
        self:clearCarry()
    end

    -- clears the interrupt disable flag
    function Microprocessor:clri()
        self:clearInterruptDisable()
    end

    -- clears the parity flag
    function Microprocessor:clrp()
        self:clearParity()
    end

    -- clears the sign flag
    function Microprocessor:clrs()
        self:clearSign()
    end

    -- clears the overflow flag
    function Microprocessor:clrv()
        self:clearOverflow()
    end

    -- clears the zero flag
    function Microprocessor:clrz()
        self:clearZero()
    end

    -- sets the carry flag
    function Microprocessor:setc()
        self:setCarry()
    end

    -- sets the interrupt disable flag
    function Microprocessor:seti()
        self:setInterruptDisable()
    end

    -- sets the parity flag
    function Microprocessor:setp()
        self:setParity()
    end

    -- sets the sign flag
    function Microprocessor:sets()
        self:setSign()
    end

    -- sets the overflow flag
    function Microprocessor:setv()
        self:setOverflow()
    end

    -- sets the zero flag
    function Microprocessor:setz()
        self:setZero()
    end

end -- Set/Clear flags

do -- Logic

    -- ands the accumulator with the contents of the specified register
    function Microprocessor:anra()
        self:meta_writeRegisterToTemp()
        self:aluAnd()
    end

    function Microprocessor:ania()
        self:meta_writeImmediateToTemp()
        self:aluAnd()
        print("accumualator after ania: 0x" .. bit.tohex(self.accumulator, 2) .. "\n")
    end

    function Microprocessor:orra()
        self:meta_writeRegisterToTemp()
        self:aluOr()
    end

    function Microprocessor:oria()
        self:meta_writeImmediateToTemp()
        self:aluOr()
    end

    function Microprocessor:xora()
        self:meta_writeRegisterToTemp()
        self:aluXor()
    end

    function Microprocessor:xoia()
        self:meta_writeImmediateToTemp()
        self:aluXor()
    end

    function Microprocessor:nota()
        self:aluNotA()
    end

    function Microprocessor:cpra()
        self:meta_writeRegisterToTemp()
        self:aluCompare()
    end

    function Microprocessor:cpia()
        self:meta_writeImmediateToTemp()
        self:aluCompare()
    end


end -- Logic

do -- Data Manipulation

    function Microprocessor:rort()
        self:rotateRightThroughCarry()
    end

    function Microprocessor:rolt()
        self:rotateLeftThroughCarry()
    end

end -- Data Manipulation

do -- Moving Data

    -- copy the contents of one register to another
    function Microprocessor:mvrr()
        self:meta_getMemByte()
        local lo_reg, hi_reg = self:decodeRegister()
        self:readRegister(lo_reg)
        self:writeRegister(hi_reg)

        print("accumualator after mvrr: 0x" .. bit.tohex(self.accumulator, 2))
        print("gp_registers after mvrr:")
        for k,v in pairs(self.gp_registers) do
            print(k,v)
        end
        print("")
    end

    -- copy the contents of one register to another
    function Microprocessor:mvia()
        self:meta_getMemByte()
        self:readRegister(0x0)
    end

    -- stores the accumulator at the specified address in memory
    function Microprocessor:stma()
        self:meta_writeMemBytePairToXY()
        self:meta_writeAddressBusFromXY()
        self:readRegister(0x0)
        self.thisMicrocomputer:writeMemory()
    end

    -- stores the accumulator at the address specified by the Z register in memory
    function Microprocessor:staz()
        self:meta_writeAddressBusFromXY()
        self:readRegister(0x0)
        self.thisMicrocomputer:writeMemory()
    end

    -- loads the data stored at the specified address in memory to the accumulator
    function Microprocessor:ldma()
        self:meta_writeMemBytePairToXY()
        self:meta_writeAddressBusFromXY()
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self:writeRegister(0x0)
    end

    -- loads the data stored at the address specified by the Z register in memory to the accumulator
    function Microprocessor:ldaz()
        self:meta_writeAddressBusFromXY()
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self:writeRegister(0x0)
    end

    -- push the value in the accumulator to the stack
    function Microprocessor:psha()
        self:incStackPointer()
        self:readStackPointer()
        self.address_bus = 0x0100 + self:getDataBus()
        self:readRegister(0x0)
        self.thisMicrocomputer:writeMemory()
    end

    -- pops the top of the stack to the accumulator
    function Microprocessor:plla()
        self:readStackPointer()
        self.address_bus = 0x0100 + self:getDataBus()
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self:writeRegister(0x0)
        self:decStackPointer()
    end

    function Microprocessor:tfzi()
        self:readRegister(0x7)
        self:writeInstructionPointerLowByte()
        self:readRegister(0x8)
        self:writeInstructionPointerHighByte()
    end

    function Microprocessor:tfiz()
        self:readInstructionPointerLowByte()
        self:writeRegister(0x7)
        self:readInstructionPointerHighByte()
        self:writeRegister(0x8)
    end

    function Microprocessor:tfas()
        self:readRegister(0x0)
        self:writeStackPointer()
    end

    function Microprocessor:tfsa()
        self:readStackPointer()
        self:writeRegister(0x0)
    end

    function Microprocessor:tffa()
        self:readFlagsRegister()
        self:writeRegister(0x0)
    end

    function Microprocessor:tfaf()
        self:readRegister(0x0)
        self:writeFlagsRegister()
    end

end -- Moving Data

do -- Branching

    -- unconditional jump
    function Microprocessor:jump()
        self:meta_writeMemBytePairToXY()
        print("X register: 0x" .. bit.tohex(self.gp_registers[7], 2))
        print("Y register: 0x" .. bit.tohex(self.gp_registers[8], 2))
        self:tfzi()
    end

    -- jump if the sign is negative
    function Microprocessor:jpsn()
        if (self:getSign() == 1) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if the sign is positive
    function Microprocessor:jpsp()
        if (self:getSign() == 0) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if is zero
    function Microprocessor:jpez()
        if (self:getZero() == 1) then
            self:meta_writeMemBytePairToXY()
            print("X register: 0x" .. bit.tohex(self.gp_registers[7]))
            print("Y register: 0x" .. bit.tohex(self.gp_registers[8]))
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if not zero
    function Microprocessor:jpnz()
        if (self:getZero() == 0) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if carry
    function Microprocessor:jpic()
        if (self:getCarry() == 1) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if not carry
    function Microprocessor:jpnc()
        if (self:getCarry() == 0) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if overflow
    function Microprocessor:jpiv()
        if (self:getOverflow() == 1) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    -- jump if not overflow
    function Microprocessor:jpnv()
        if (self:getOverflow() == 0) then
            self:meta_writeMemBytePairToXY()
            self:tfzi()
        else
            self:incInstructionPointer()
            self:incInstructionPointer()
        end
    end

    function Microprocessor:call()
        self:meta_writeMemBytePairToXY()

        self:incStackPointer()
        self:readStackPointer()
        self.address_bus = 0x0100 + self:getDataBus()
        self:readInstructionPointerHighByte()
        self.thisMicrocomputer:writeMemory()
        
        self:incStackPointer()
        self:readStackPointer()
        self.address_bus = 0x0100 + self:getDataBus()
        self:readInstructionPointerLowByte()
        self.thisMicrocomputer:writeMemory()

        self:tfzi()
    end

    function Microprocessor:retn()
        self:readStackPointer()
        self.address_bus = 0x0100 + self:getDataBus()
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self:writeInstructionPointerLowByte()
        self:decStackPointer()

        self:readStackPointer()
        self.address_bus = 0x0100 + self:getDataBus()
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self:writeInstructionPointerHighByte()
        self:decStackPointer()
    end

end -- Branching

do -- Microprocessor Stuff

    -- trigger an interrupt
    function Microprocessor:brek()
        -- break
    end

    -- stops the microprocessor from executing any further code
    function Microprocessor:halt()
        -- [ find out exactly how this works ] --
        self.active = false
    end

    -- performs no operation, takes 2 cycles
    function Microprocessor:noop()
    end

    -- restart the microprocessor
    function Microprocessor:rstt()
        Microprocessor:start()
    end

end -- Microprocessor Stuff

end -- operations

do -- ## ALU Operations ## --

    -- adds the values in the alu_a_register and alu_b_register, and sends the result back to the accumulator
    function Microprocessor:aluAdd()
        local carry = self:getCarry()
        local result = self.accumulator + self.alu_temp_register + carry
        self.accumulator = bit.band(result, 0xff)

        -- set the carry flag
        if (bit.band(result, 0x100) == 1) then self:setCarry() else self:clearCarry() end

        self:setSFlagFor(self.accumulator)
        self:setVFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

    function Microprocessor:aluSub()
        local carry = self:getCarry()
        local result = self.accumulator - self.alu_temp_register + 0x100
        self.accumulator = bit.band(result, 0xff)

        -- set the carry flag
        if (bit.band(result, 0x100) == 0) then self:setCarry() else self:clearCarry() end

        self:setSFlagFor(self.accumulator)
        self:setVFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
        print("Z flag after subtraction: " .. self:getZero())
    end

    function Microprocessor:aluAnd()
        self.accumulator = bit.band(self.accumulator, self.alu_temp_register)

        self:setSFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

    function Microprocessor:aluOr()
        self.accumulator = bit.bor(self.accumulator, self.alu_temp_register)

        self:setSFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

    function Microprocessor:aluXor()
        self.accumulator = bit.bxor(self.accumulator, self.alu_temp_register)

        self:setSFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

    function Microprocessor:aluNotA()
        self.accumulator = bit.bnot(self.accumulator)

        self:setSFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

    function Microprocessor:rotateRightThroughCarry()
        local first_bit = bit.band(self.accumulator, 0x1)
        self.accumulator = bit.bor(bit.rshift(self.accumulator, 1), self:getCarry() * 0x80)
        if (first_bit == 1) then self:setCarry() else self:clearCarry() end

        self:setSFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

    function Microprocessor:rotateLeftThroughCarry()
        local first_bit = bit.band(self.accumulator, 0x80)
        self.accumulator = bit.bor(bit.rshift(self.accumulator, 1), self:getCarry() * 0x1)
        if (first_bit > 0) then self:setCarry() else self:clearCarry() end

        self:setSFlagFor(self.accumulator)
        self:setZFlagFor(self.accumulator)
    end

end -- alu operations

do -- ## Micro Instructions ## -- Manipulating data_bus, flags, fetching data, etc

    -- called when the microprocessor is powered on 
    function Microprocessor:start()
        --## Reads the initial instruction pointer from memory
        -- read least significant byte from memory 0xfffc
        self.address_bus = 0xfffc
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        -- set least significant byte without altering most significant byte
        self.instruction_pointer = bit.band(self.instruction_pointer, 0xff00) + self:getDataBus()

        -- push 0xfffc to the address bus
        self.address_bus = 0xfffd
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        -- set most significant byte without altering least significant byte
        self.instruction_pointer = bit.lshift(self:getDataBus(), 8) + bit.band(self.instruction_pointer, 0x00ff)
        print("initial instruction pointer: 0x" .. bit.tohex(self.instruction_pointer, 4):upper())
    end

    -- fecthes the instruction from memory
    function Microprocessor:fetch()
        --## fetches the instruction from the location specified by the instruction pointer and saves it to the instruction register
        self.address_bus = self.instruction_pointer
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self.instruction_register = self:getDataBus()

        -- increment the instruction pointer after it has finished fetching
        self:incInstructionPointer()
    end

    -- decodes the instruction stored in the instruction register
    function Microprocessor:decodeOpcode()
        -- determine the opcode 
        print("instruction: 0x" .. bit.tohex(self.instruction_register, 2):upper() .. " = " .. self.opcode_table[self.instruction_register])
        self[self.opcode_table[self.instruction_register]](self)
    end

    -- increments the instruction pointer
    function Microprocessor:incInstructionPointer()
        self.instruction_pointer = self.instruction_pointer + 1
        self.instruction_pointer = bit.band(self.instruction_pointer, 0xffff)
    end

    -- increments the instruction pointer
    function Microprocessor:decInstructionPointer()
        self.instruction_pointer = self.instruction_pointer - 1
        self.instruction_pointer = bit.band(self.instruction_pointer, 0xffff)
    end

    -- increments the stack pointer
    function Microprocessor:incStackPointer()
        self.stack_pointer = self.stack_pointer + 1
        self.stack_pointer = bit.band(self.stack_pointer, 0xff)
    end

    -- decrements the stack pointer
    function Microprocessor:decStackPointer()
        self.stack_pointer = self.stack_pointer - 1
        self.stack_pointer = bit.band(self.stack_pointer, 0xff)
    end

    -- increments the number of cycles the program has taken by a specified amount
    function Microprocessor:incCycles(cycles)
        self.cycle = self.cycle + cycles
    end

    -- returns the data stored in the specified register5q
    function Microprocessor:readRegister(index)
        if index == 0 then
            self.data_bus = self.accumulator
        else
            self.data_bus = self.gp_registers[index]
        end
    end

    -- sets the data in the specified register
    function Microprocessor:writeRegister(index)
        if index == 0 then
            self.accumulator = self:getDataBus()
        else
            self.gp_registers[index] = self:getDataBus()
        end
    end

    function Microprocessor:writeTempRegister()
        self.alu_temp_register = self:getDataBus()
    end

    function Microprocessor:readDataPins()
        self.data_bus = self.thisMicrocomputer.data_bus;
    end

    function Microprocessor:decodeRegister()
        local lo_reg = bit.rshift(bit.band(self:getDataBus(), 0xf0), 4)
        local hi_reg = bit.band(self:getDataBus(), 0x0f)

        return lo_reg, hi_reg
    end

    function Microprocessor:writeAddressBusLowByte()
        self.address_bus = self.data_bus + bit.band(self.address_bus, 0xff00)
    end

    function Microprocessor:writeAddressBusHighByte()
        self.address_bus = bit.lshift(self.data_bus,8) + bit.band(self.address_bus, 0x00ff)
    end

    function Microprocessor:writeInstructionPointerLowByte()
        self.instruction_pointer = self.data_bus + bit.band(self.instruction_pointer, 0xff00)
    end

    function Microprocessor:writeInstructionPointerHighByte()
        self.instruction_pointer = bit.band(self.instruction_pointer, 0x00ff) + self.data_bus * 0x0100
    end

    function Microprocessor:readInstructionPointerLowByte()
        self.data_bus = bit.band(self.instruction_pointer, 0x00ff)
    end

    function Microprocessor:readInstructionPointerHighByte()
        self.data_bus = bit.rshift(bit.band(self.instruction_pointer, 0xff00), 8)
    end

    function Microprocessor:writeStackPointer()
        self.stack_pointer = self.data_bus
    end

    function Microprocessor:readStackPointer()
        self.data_bus = self.stack_pointer
    end

    function Microprocessor:writeFlagsRegister()
        self.flags = self.data_bus
    end

    function Microprocessor:readFlagsRegister()
        self.data_bus = self.flags
    end


    do -- ## Set/Clear/Get Flags ##-- 

        -- determines what the carry flag should given an, at least, 9-bit value
        function Microprocessor:setCFlagFor(val)
            if (bit.band(val, 0x100) == 1) then self:setCarry() else self:clearCarry() end
        end

        -- determines what the parity flag should be given some data
        function Microprocessor:setPFlagFor(val)
            if (bit.band(val, 0x1) == 0x0) then self:setParity() else self:clearParity() end
        end

        -- determines what the sign flag should be given some data
        function Microprocessor:setSFlagFor(val)
            if (bit.band(val, 0x80) > 0) then self:setSign() else self:clearSign() end
        end

        -- determines what the overflow flag should be given some data
        function Microprocessor:setVFlagFor(val)
            -- not the actual way the processor would evaluate this but I cant think of how to
            if (val < -128 or val > 127) then self:setOverflow() else self:clearOverflow() end
        end

        -- determines what the zero flag should be given some data
        function Microprocessor:setZFlagFor(val)
            print("setting zero flag with val = " .. val)
            if (val == 0) then self:setZero() else self:clearZero() end
        end


        function Microprocessor:getZero()       return (bit.band(self.flags, 0x01) > 0) and 1 or 0  end
        function Microprocessor:setZero()       self.flags = bit.bor(self.flags, 0x01)              end
        function Microprocessor:clearZero()     self.flags = bit.band(self.flags, 0xFE)             end

        function Microprocessor:getSign()       return (bit.band(self.flags, 0x02) > 0) and 1 or 0  end
        function Microprocessor:setSign()       self.flags = bit.bor(self.flags, 0x02)              end
        function Microprocessor:clearSign()     self.flags = bit.band(self.flags, 0xFD)             end

        function Microprocessor:getParity()     return (bit.band(self.flags, 0x04) > 0) and 1 or 0  end
        function Microprocessor:setParity()     self.flags = bit.bor(self.flags, 0x04)              end
        function Microprocessor:clearParity()   self.flags = bit.band(self.flags, 0xFB)             end

        function Microprocessor:getCarry()      return (bit.band(self.flags, 0x08) > 0) and 1 or 0  end
        function Microprocessor:setCarry()      self.flags = bit.bor(self.flags, 0x08)              end
        function Microprocessor:clearCarry()    self.flags = bit.band(self.flags, 0xF7)             end

        function Microprocessor:getInterruptDisable()      return (bit.band(self.flags, 0x10) > 0) and 1 or 0  end
        function Microprocessor:setInterruptDisable()      self.flags = bit.bor(self.flags, 0x10)              end
        function Microprocessor:clearInterruptDisable()    self.flags = bit.band(self.flags, 0xEF)             end

        function Microprocessor:getOverflow()   return (bit.band(self.flags, 0x20) > 0) and 1 or 0  end
        function Microprocessor:setOverflow()   self.flags = bit.bor(self.flags, 0x20)              end
        function Microprocessor:clearOverflow() self.flags = bit.band(self.flags, 0xDF)             end

    end -- flags

end -- Micro Instructions

do --## Meta functions ##-- groups of operations that are performed regularly

    -- gets the byte in memory stored at the location specified by the instruction pointer
    -- and reads it to the internal data bus, and increments the instruction pointer
    function Microprocessor:meta_getMemByte()
        self.address_bus = self.instruction_pointer
        self.thisMicrocomputer:readMemory()
        self:readDataPins()
        self:incInstructionPointer()
    end

    -- writes the value in the register indexed by the byte in memory pointed to by the
    -- instruction pointer to the temporary register in the ALU
    function Microprocessor:meta_writeRegisterToTemp()
        self:meta_getMemByte()
        local reg = self:decodeRegister()
        self:readRegister(reg)
        self:writeTempRegister()
    end

    -- writes the immediate value given in the byte of memory pointed to by the
    -- instruction pointer to the temporary register in the ALU
    function Microprocessor:meta_writeImmediateToTemp()
        self:meta_getMemByte()
        self:writeTempRegister()
    end

    -- gets a pair of bytes from memory in little endian format and stores them in the Z register
    function Microprocessor:meta_writeMemBytePairToXY()
        self:meta_getMemByte()
        self:writeRegister(0x7)
        self:meta_getMemByte()
        self:writeRegister(0x8)
    end

    function Microprocessor:meta_writeAddressBusFromXY()
        self:readRegister(0x7)
        self:writeAddressBusLowByte()
        self:readRegister(0x8)
        self:writeAddressBusHighByte()
    end

    -- pushes a 16 bit value to the address bus given by a low and high byte
    function Microprocessor:pushAddressBus(lo_byte, hi_byte)
        self.address_bus = lo_byte + bit.lshift(hi_byte, 8)
    end

end -- metafunctions

-- pushes an 8 bit value to the data bus
function Microprocessor:writeDataBus(data)
    self.data_bus = data
end

-- returns the value currently on the data bus
function Microprocessor:getDataBus()
    return self.data_bus
end