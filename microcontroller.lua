OP = {MOV = "000000", ADD = "000001", ADI = "000010", CLR = "000011"}

Micro = {}
-- 8 bit opcode, 4-16 bit args (up to a total of 16 bits)
-- 16 bit opcodes
-- 1 working register, 1 instruction pointer, 1 flag register
-- flag [sign, zero, carry/borrow, parity]

-- have some way to characterise compute time
-- byte addressable (not individual bits)

function Micro:new(reg_size, sram_size, flash_size, io_size)
	setmetatable({}, Micro)

	-- checking provided params
	if (reg_size > 16) then
		reg_size = 16;
	elseif reg_size < 1 then
		reg_size = 1;
	end

	self.reg_size = reg_size;
	self.sram_size = sram_size;
	self.flash_size = flash_size;

	--initialise general registers (8 bit chucks)
	self.registers = {}
	for i = 0,(reg_size - 1) do
		local reg_label = numbers.toBin(i, 4)
		if reg_label ~= nil then self.registers[reg_label] = "00000000"; end
	end

	--initialise sram (8 bit chunks)
	self.sram = {};
	for i = 0,(sram_size - 1) do
		self.sram[i] = "00000000";
	end

	--initialise flash (8 bit chunks)
	self.flash = {};
	for i = 0,(flash_size - 1) do
		self.flash[i] = "00000000";
	end

	self.io = {}
	for i = 0,(io_size - 1) do
		self.io[i] = "00000000";
	end

	--initialise flag register
	self.flag = {};
	for i = 0,7 do
		self.flag[i] = "0";
	end

	-- initialise intruction pointer register
	self.instruction = {};
	for i = 1,8 do
		self.instruction[i] = "0";
	end

	self.instruction_pointer = "0000000000000000";
	self.stack_pointer = "0000000000000000";

	return self
end

function Micro:loadProgram()
	-- take the string and make a table each element containing 8 bits
	-- [start program, end program]
	-- part to tell the micro-controller where to load the program
	-- part to tell the micro-controller where to start reading
	-- generate [start free memory, end free memory]
	-- [start stack, end stack]
	-- ?should I have an inbuilt stack, or stick it in the memory
end

function Micro:startProgram()
end

function Micro:cycle(dt)
	-- read the instruction in the flash at the pointer

	-- interpret the instruction

	-- do the instruction
end

-- Operations
function Micro:mov(reg_adr1, reg_adr2) -- copy the contents of address1 to address2
	self:setReg(reg_adr2, self:loadReg(reg_adr1));
end

function Micro:add(reg_adr) -- add the contents of adr to the working directory
	self:setReg("0000", self:binAddition(self:loadReg("0000"), self:loadReg(reg_adr)))
end

function Micro:adi(immediate) -- add the constant immediate to the value in the working directory
	self:setReg("0000", self:binAddition(self:loadReg("0000"), immediate))
end

function Micro:clr(reg_adr) -- clear the specified register (set all to zero)
	self:setReg(reg_adr, "00000000");
end

function Micro:jmp(mem_adr) -- jump to the specified location in the program
	self:setIP(mem_adr)
end

-- Maths Functions
function Micro:binAddition(bin1, bin2)
	local ans, carry, sum
	ans = "";
	carry = 0;
	for i = 8,1,-1 do
		sum = tonumber(string.sub(bin1, i, i)) + tonumber(string.sub(bin2, i, i)) + carry;
		ans = tostring(math.sign((sum%2))) .. ans;
		carry = math.sign((math.max(0, sum - 1)));
	end
	self:setCarry(tostring(math.sign(carry)))
	return ans
end

function Micro:binSubtraction(bin1, bin2)
end

-- Internal Operations
function Micro:loadReg(adr)
	return self.registerss(adr)
end

function Micro:setReg(adr, bin)
	self.registers[adr] = bin;
end

function Micro:setCarry(val)
	self.flag[3] = val;
end

function Micro:setIP(mem_adr)
	self.instruction_pointer = mem_adr;
end


function Micro:writeFlash(address, code)
	-- ask about this
	local loc = numbers.binToDec(address)
	for i = 1,string.len(code) do
		self.flash[(loc + i - 1)%self.flash_size + 1] = string.sub(code, i, i)
	end
end