Microcontroller = {
	opcode = {mov = "000000", add = "000001", adi = "000010", clr = "000011"},
	reg_alpha = {A = "0000", B = "0001", C = "0010", D = "0011", E = "0100", G = "0101", H = "0110", X = "0111", Y = "1000"}
}
-- 8 bit opcode, 4-16 bit args (up to a total of 16 bits)
-- 16 bit opcodes
-- 1 working register, 1 instruction pointer, 1 flag register
-- flag [sign, zero, carry/borrow, parity]

-- have some way to characterise compute time
-- byte addressable (not individual bits)

function Microcontroller.new(reg_size, sram_size, flash_size, io_size)
	-- obj = {};
	obj = table.copy(Microcontroller) -- get the fixed values
	setmetatable(obj, Microcontroller)

	-- checking provided params
	if (reg_size > 16) then
		reg_size = 16;
	elseif reg_size < 1 then
		reg_size = 1;
	end

	obj.reg_size = reg_size;
	obj.sram_size = sram_size;
	obj.flash_size = flash_size;

	--initialise general registers (8 bit chucks)
	obj.registers = {}
	for i = 0,(reg_size - 1) do
		local reg_label = numbers.toBin(i, 4)
		if reg_label ~= nil then obj.registers[reg_label] = "00000000"; end
	end

	--initialise sram (8 bit chunks)
	obj.sram = {};
	for i = 0,(sram_size - 1) do
		obj.sram[i] = "00000000";
	end

	--initialise flash (8 bit chunks)
	obj.flash = {};
	for i = 0,(flash_size - 1) do
		obj.flash[i] = "00000000";
	end

	obj.io = {}
	for i = 0,(io_size - 1) do
		obj.io[i] = "00000000";
	end

	--initialise flag register
	obj.flag = {};
	for i = 0,7 do
		obj.flag[i] = "0";
	end

	-- initialise intruction pointer register
	obj.instruction = {};
	for i = 1,8 do
		obj.instruction[i] = "0";
	end

	obj.instruction_pointer = "0000000000000000";
	obj.stack_pointer = "0000000000000000";

	return obj
end

function Microcontroller:loadProgram()
	-- take the string and make a table each element containing 8 bits
	-- [start program, end program]
	-- part to tell the micro-controller where to load the program
	-- part to tell the micro-controller where to start reading
	-- generate [start free memory, end free memory]
	-- [start stack, end stack]
	-- ?should I have an inbuilt stack, or stick it in the memory
end

function Microcontroller:startProgram()
end

function Microcontroller:cycle(dt)
	-- read the instruction in the flash at the pointer

	-- interpret the instruction

	-- do the instruction
end

-- Operations
function Microcontroller:mov(reg_adr1, reg_adr2) -- copy the contents of address1 to address2
	self:setReg(reg_adr2, self:loadReg(reg_adr1));
end

function Microcontroller:add(reg_adr) -- add the contents of adr to the working directory
	self:setReg("0000", self:binAddition(self:loadReg("0000"), self:loadReg(reg_adr)))
end

function Microcontroller:adi(immediate) -- add the constant immediate to the value in the working directory
	self:setReg("0000", self:binAddition(self:loadReg("0000"), immediate))
end

function Microcontroller:clr(reg_adr) -- clear the specified register (set all to zero)
	self:setReg(reg_adr, "00000000");
end

function Microcontroller:jmp(mem_adr) -- jump to the specified location in the program
	self:setIP(mem_adr)
end

-- Maths Functions
function Microcontroller:binAddition(bin1, bin2)
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

function Microcontroller:binSubtraction(bin1, bin2)
end

-- Internal Operations
function Microcontroller:loadReg(adr)
	return self.registerss(adr)
end

function Microcontroller:setReg(adr, bin)
	self.registers[adr] = bin;
end

function Microcontroller:setCarry(val)
	self.flag[3] = val;
end

function Microcontroller:setIP(mem_adr)
	self.instruction_pointer = mem_adr;
end


function Microcontroller:writeFlash(address, code)
	-- ask about this
	local loc = numbers.binToDec(address)
	for i = 1,string.len(code) do
		self.flash[(loc + i - 1)%self.flash_size + 1] = string.sub(code, i, i)
	end
end