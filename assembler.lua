-- CHANGES: checkForceBits should never get a non numeric value, make forceBits return nil
--			for the number if it contains non-numeric characters

Assembler = {
	op = {mov = "00000000", add = "00000001", addi = "00000010", cli = "00000011", jmp = "00000100"},
	reg_alpha = {A = "0000", B = "0001", C = "0010", D = "0011", E = "0100", G = "0101", H = "0110", X = "0111", Y = "1000"},
	machine_code = "",
	program_line = 1,
	assembler_report = {n = 0},
	labels = {};
}

function Assembler:assemble(code, filename)

	for line = 1, code.n do -- get all labels
		-- clean up white space
		local args = code[line]:strip():split();

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

	for line = 1,code.n do -- assemble the rest of the lines
		-- clean up white space
		-- print(code[line])
		local args = code[line]:strip():split();

		-- check if the line is a comment or label
		if args[1]:sub(1,1) == ";" then goto next_line end
		if args[1]:sub(1,1) == ":" then goto next_line end

		-- call a function of the argument provided
		if args[1] ~= nil then
			if (self[args[1]] ~= nil) then
				self[args[1]:lower()](self, line, args)
			else
				local err_msg = "Fatal [line " .. line .. "]: Mnemonic '" .. args[1]:upper() .. "' not recognised"
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

function Assembler:mov(line, args)
	-- check the number of arguments provided
	if not self:checkNumArgs(line, args, 3) then return self.assembler_report end

	-- try to perform operations using those 
	local opcode =  self.op.mov;

	-- Read register inputs as A, B, C, etc
	local arg1 = self.reg_alpha[args[2]:upper()];
	local arg2 = self.reg_alpha[args[3]:upper()];
	
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