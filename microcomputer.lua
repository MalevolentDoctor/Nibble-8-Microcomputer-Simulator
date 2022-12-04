require("fonts.fonts")

Microcomputer = {};
Microcomputer.__index = Microcomputer;

function Microcomputer.new()
    local self = {}
    setmetatable(self, Microcomputer);

    self.active = true

    self.obj_microprocessor = Microprocessor.new(self,8);
    self.address_bus = 0x0000
    self.data_bus = 0x00

    self.ram_size = 0x0100 -- 4kb ram
    self.rom_size = 0x0100 -- 4kb rom

    self.obj_ram = Ram.new(self, 0, self.ram_size)
    self.obj_rom = Rom.new(self, 0xFFFF - self.rom_size + 1, self.rom_size)

    -- AESTHETIC PARAMETERS
    local _, window_height = App.getWindowSize()
    do -- registers window
        self.reg_win = Window.new(self.obj_microprocessor, 0, 0, 0, 0, 3, 3, 3, 2, 
            {"pxl_5x7_thin", "pxl_5x7_bold", "pxl_5x7_thin"},
            {{'4B051F', '380317', '000'}, {'000'}, {'000'}}
        )

        self.reg_win.reg_rows = math.ceil(self.obj_microprocessor.reg_size/2)

        -- translation layer
        self.reg_win.trans_reg_alpha = {"B", "C", "D", "E", "G", "H", "X", "Y"}
        self.reg_win.trans_xreg_alpha = {"BX", "DX", "GX", " Z"}

        function self.reg_win:draw()
            self:resetCurrentY()
            self:drawBackground()
            self:drawTitle({self.col_txt[1], "REGISTERS"}, true)
        
            self:hline(2, self.col_bdr[1])
            self:printText({self.col_txt[1], " ACCUMULATOR " .. numbers.toBin(self.other.accumulator, 8)}, self.fnt_txt1)
            self:vspace(self.int_buffer)
            self:hline(1, self.col_bdr[1])
        
            self:drawBorder(2)
        
            -- general purpose registers
            for i = 1,self.reg_rows do
                local reg_v1 = numbers.toBin(self.other.gp_registers[2*i - 1], 8)
                local reg_v2 = numbers.toBin(self.other.gp_registers[2*i], 8)
                local reg_a1 = self.trans_reg_alpha[2*i - 1]
                local text
        
                if reg_v2 ~= nil then
                    local reg_a2 = self.trans_reg_alpha[2*i]
                    local xreg = self.trans_xreg_alpha[i]
                    text = xreg .. " ".. reg_a1  .. reg_v1 .. " " .. reg_a2 .. reg_v2
                else
                    text = "   "..reg_a1..reg_v1
                end
                self:printText({self.col_txt[1], text}, self.fnt_txt2)
            end
            self:vspace(self.int_buffer - 1)
            self:hline(1, self.col_bdr[1])
        
            -- -- stack pointer and instruction pointer
            self:printText({self.col_txt[1], "STACK " .. numbers.toBin(self.other.stack_pointer, 16)}, self.fnt_txt2)
            self:printText({self.col_txt[1], "INSTR " .. numbers.toBin(self.other.instruction_pointer, 16)}, self.fnt_txt2)
        end
        
        self.reg_win.h = self.reg_win:getHeight(self.obj_microprocessor)
        self.reg_win.y = App.window_height - self.reg_win.h
        self.reg_win.w = self.reg_win.fnt_txt1_w * 23 + 2*self.reg_win.int_buffer -- check

        self.reg_win:init()
    end

    do -- RAM window
        self.ram_win = Window.new(self.obj_ram, 0, 0, 0, 0, 3, 3, 3, 2,
        {"pxl_5x7_thin", "pxl_5x7_bold", "pxl_5x7_thin"},
        {{'4B051F', '380317'}, {'000'}, {'000'}}
        )
        
        self.ram_win.vals_in_row = 8

        -- window size
        self.ram_win.h = window_height - self.reg_win.h + self.ram_win.ext_buffer

        self.ram_win.body_char_width = self.ram_win.vals_in_row * 3 + 6
        self.ram_win.w = self.ram_win.fnt_txt2_w * (self.ram_win.body_char_width + 1) + 2*self.ram_win.int_buffer
        self.ram_win:init()

        self.ram_win.window_rows = math.floor((self.ram_win.h_int - self.ram_win.hdr_h)/(self.ram_win.fnt_txt2_h + self.ram_win.line_spacing))
        self.ram_win.row_offset = 0;

        function self.ram_win:draw()
            self:resetCurrentY()
            self:drawBackground()
            self:drawTitle({self.col_txt[1], "RAM"}, true)
            self:hline(2)

            -- ram
            local vals, val_str
            for i = 1,self.window_rows do
                vals = {}
                local row_index = (i - 1 + self.row_offset)*self.vals_in_row
                local row_hex_index = bit.tohex(row_index, 4):upper()
                for j = 1,self.vals_in_row do
                    local ind = row_index + j - 1;
                    vals[j] = numbers.byteToHex(self.other.ram[ind])
                end
                val_str = table.concat(vals, " ")
                self:printText({self.col_txt[1], "0x" .. row_hex_index .. " " .. val_str}, self.fnt_txt2)
            end
            self:drawBorder(2)
        end

        self.ram_win:init()
    end

    -- sprites
    self.spr_microprocessor = Sprite.new(
        -1, 10, 1, 1, 
        {"assets/png/microcontroller_chip.png"}, "nearest",
        {hover = false, visible = false}
    )
    self.spr_microprocessor.x = math.floor(App.window_width/2) - math.floor(self.spr_microprocessor.w/2)

    return self
end

function Microcomputer:update(dt)
    if self.active then
        local nav_key = keyboard:getNavKey()
        local edit_key = keyboard:getEditKey()

        if nav_key == "pagedown" then
            self.ram_win.row_offset = math.min(math.ceil(self.obj_ram.size/self.ram_win.vals_in_row) - self.ram_win.window_rows, self.ram_win.row_offset + self.ram_win.window_rows - 1);
            self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;
        elseif nav_key == "pageup" then
            self.ram_win.row_offset = math.max(0, self.ram_win.row_offset - self.ram_win.window_rows + 1);
            self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;
        end

        if edit_key == "backspace" then
            self.active = false
        end

        if nav_key == "home" then
            self.obj_microprocessor:start()
            self.obj_microprocessor.active = true
        end

        self.obj_microprocessor:update(dt)

        keyboard:reset()
    end
end

function Microcomputer:draw()
    if self.active then

        -- windows
        self.reg_win:draw()
        self.ram_win:draw()
        self:drawMicroprocessor()
    end
end

function Microcomputer:drawMC()
end

function Microcomputer:drawRAMTooltip()
end

function Microcomputer:drawMicroprocessor()
    love.graphics.setColor(1,1,1)
    self.spr_microprocessor:draw()

    local x = self.spr_microprocessor.x
    local y = self.spr_microprocessor.y
    local w = self.spr_microprocessor.w
    local h = self.spr_microprocessor.h

    love.graphics.setColor(0,0,0)
    love.graphics.setFont(Font.fonts["pxl_5x7_bold"])
    love.graphics.print("NIBBLE-8", x + 23, y + 7)
    love.graphics.print("FLAGS", x + 23, y + 65)
    love.graphics.setFont(Font.fonts["pxl_5x7_thin"])
    love.graphics.print("GP REGISTERS:" .. tostring(self.obj_microprocessor.reg_size), x + 23, y + 20)
    love.graphics.print("RAM:" .. tostring(self.obj_ram.size) .. " Bytes", x + 23, y + 30)
    love.graphics.print("ROM:" .. tostring(self.obj_rom.size) .. " Bytes", x + 23, y + 40)
    love.graphics.print("IO:" .. tostring("NaN") .. " Ports", x + 23, y + 50)

    love.graphics.print("SIGN:      " .. tostring(self.obj_microprocessor:getSign()), x + 23, y + 75)
    love.graphics.print("ZERO:      " .. tostring(self.obj_microprocessor:getZero()), x + 23, y + 85)
    love.graphics.print("PARITY:    " .. tostring(self.obj_microprocessor:getParity()), x + 23, y + 95)
    love.graphics.print("CARRY:     " .. tostring(self.obj_microprocessor:getCarry()), x + 23, y + 105)
    love.graphics.print("INTRPT:    " .. tostring(self.obj_microprocessor:getInterruptDisable()), x + 23, y + 115)
end

function Microcomputer:drawROM()
end

function Microcomputer:drawIO()
end

function Microcomputer:readAddressPins()
    self.address_bus = self.obj_microprocessor.address_bus
end

function Microcomputer:readMemory()
    self:readAddressPins()
    self.data_bus = self.obj_ram.ram[self.address_bus] or self.obj_rom.rom[self.address_bus]
end

function Microcomputer:writeMemory()
    if self.obj_ram.ram[self.address_bus] ~= nil then
        self.obj_ram.ram[self.address_bus] = self.data_bus
    end
end