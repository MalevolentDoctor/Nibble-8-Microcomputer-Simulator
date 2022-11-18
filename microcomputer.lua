require("fonts.fonts")

Microcomputer = {};
Microcomputer.__index = Microcomputer;

function Microcomputer.new()
    local self = {}
    setmetatable(self, Microcomputer);

    self.active = true

    -- colours
    self.col_bg = Colour.hex('113F5E')
    self.col_black = Colour.hex('000')
    self.col_white = Colour.hex('fff')

    -- fonts
    self.fnt_header = Font.fonts["dos14"]
    self.fnt_text = Font.fonts["dos14"]

    local _, window_height = App.getWindowSize()

    self.obj_microcontroller = Microcontroller.new(1,1,1,1);

    -- calculated values
    self.fnt_header_height = self.fnt_header:getHeight();
    self.fnt_header_width = self.fnt_header:getWidth("A");

    self.fnt_text_height = self.fnt_text:getHeight();
    self.fnt_text_width = self.fnt_text:getWidth("A");

    do -- registers window
        self.reg_win = Window.new(0, 0, 0, 0, 3, 3, 3, 2, 
            {"pxl_5x7_thin", "pxl_5x7_bold", "pxl_5x7_thin"},
            {{'4B051F', '380317'}, {'000'}, {'000'}}
        )

        self.reg_win.reg_rows = math.floor(self.obj_microcontroller.reg_size/2)
        self.reg_win.registers = self.obj_microcontroller.registers
        self.reg_win.sp = self.obj_microcontroller.stack_pointer
        self.reg_win.ip = self.obj_microcontroller.instruction_pointer

        -- translation layer
        self.reg_win.trans_reg_ind = {"0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000"}
        self.reg_win.trans_reg_alpha = {"B", "C", "D", "E", "G", "H", "X", "Y"}
        self.reg_win.trans_xreg_alpha = {"XB", "XD", "XG", " Z"}

        function self.reg_win:draw()
            self:resetCurrentY()
            self:drawBackground()
            self:drawTitle({self.col_txt[1], "REGISTERS"}, true)
        
            self:hline(2, self.col_bdr[1])
            self:printText({self.col_txt[1], " ACCUMULATOR " .. self.registers["0000"]}, self.fnt_txt1)
            self:vspace(self.int_buffer)
            self:hline(1, self.col_bdr[1])
        
            self:drawBorder(2)
        
            -- general purpose registers
            for i = 1,self.reg_rows do
                local i2 = 2*i
                local reg_v1 = self.registers[self.trans_reg_ind[i2 - 1]]
                local reg_v2 = self.registers[self.trans_reg_ind[i2]]
                local reg_a1 = self.trans_reg_alpha[i2 - 1]
                local text
        
                if reg_v2 ~= nil then
                    local reg_a2 = self.trans_reg_alpha[i2]
                    local xreg = self.trans_xreg_alpha[i]
                    text = xreg .. " ".. reg_a1  .. reg_v1 .. " " .. reg_a2 .. reg_v1
                else
                    text = "   "..reg_a1..reg_v1
                end
                self:printText({self.col_txt[1], text}, self.fnt_txt2)
                self:vspace(1)
            end
            self:vspace(self.int_buffer - 1)
            self:hline(1, self.col_bdr[1])
        
            -- -- stack pointer and instruction pointer
            self:printText({self.col_txt[1], "STACK " .. self.sp}, self.fnt_txt2)
            self:vspace(1)
            self:printText({self.col_txt[1], "INSTR " .. self.ip}, self.fnt_txt2)
        end
        
        self.reg_win.h = self.reg_win:getHeight()
        self.reg_win.y = App.window_height - self.reg_win.h
        self.reg_win.w = self.reg_win.fnt_txt1_w * 23 + 2*self.reg_win.int_buffer -- check

        self.reg_win:init()
    end

    do -- RAM window
        self.ram_win = Window.new(0, 0, 0, 0, 3, 3, 3, 2,
        {"pxl_5x7_thin", "pxl_5x7_bold", "pxl_5x7_thin"},
        {{'4B051F', '380317'}, {'000'}, {'000'}}
        )
        
        self.ram_win.vals_in_row = 8

        -- window size
        self.ram_win.h = window_height - self.reg_win.h + self.ram_win.ext_buffer

        self.ram_win.body_char_width = self.ram_win.vals_in_row * 3 + 6
        self.ram_win.w = self.ram_win.fnt_txt2_w * (self.ram_win.body_char_width + 1) + 2*self.ram_win.int_buffer
        self.ram_win:init()

        self.ram_win.window_rows = math.floor(self.ram_win.h_int/(self.ram_win.fnt_txt2_h + 1)) - 1
        self.ram_win.row_offset = 0;

        self.ram_win.ram = self.obj_microcontroller.sram

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
                    vals[j] = numbers.byteToHex(self.ram[ind])
                end
                val_str = table.concat(vals, " ")
                self:printText({self.col_txt[1], "0x" .. row_hex_index .. " " .. val_str}, self.fnt_txt2)
                self:vspace(1)
            end
            self:drawBorder(2)
        end

        self.ram_win:init()
    end

    -- sprites
    self.spr_microcontroller = Sprite.new(
        -1, 10, 1, 1, 
        {"assets/png/microcontroller_chip.png"},
        {hover = false, visible = false}
    )
    self.spr_microcontroller.x = math.floor(App.window_width/2) - math.floor(self.spr_microcontroller.w/2)

    return self
end

function Microcomputer:update()
    if self.active then
        local nav_key = keyboard:getNavKey()
        local edit_key = keyboard:getEditKey()

        if nav_key == "pagedown" then
            self.ram_win.row_offset = math.min(math.ceil(self.obj_mc.sram_size/self.ram_win.vals_in_row) - self.ram_win.window_rows, self.ram_win.row_offset + self.ram_win.window_rows - 1);
            self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;
        elseif nav_key == "pageup" then
            self.ram_win.row_offset = math.max(0, self.ram_win.row_offset - self.ram_win.window_rows + 1);
            self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;
        end

        if edit_key == "backspace" then
            self.active = false
        end

        keyboard:reset()
    end
end

function Microcomputer:draw()
    if self.active then
        local window_width, window_height = App.getWindowSize()
        love.graphics.setFont(self.fnt_text)

        -- background
        love.graphics.setColor(self.col_bg);
        love.graphics.rectangle("fill", 0, 0, window_width, window_height)

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
    self.spr_microcontroller:draw()

    local x = self.spr_microcontroller.x
    local y = self.spr_microcontroller.y
    local w = self.spr_microcontroller.w
    local h = self.spr_microcontroller.h

    love.graphics.setColor(0,0,0)
    love.graphics.setFont(Font.fonts["pxl_5x7_bold"])
    love.graphics.print("NIBBLE-8", x + 23, y + 7)
    love.graphics.print("FLAGS", x + 23, y + 65)
    love.graphics.setFont(Font.fonts["pxl_5x7_thin"])
    love.graphics.print("GP REGISTERS:" .. tostring(self.obj_mc.reg_size - 1), x + 23, y + 20)
    love.graphics.print("RAM:" .. tostring(self.obj_mc.sram_size) .. " Bytes", x + 23, y + 30)
    love.graphics.print("ROM:" .. tostring(self.obj_mc.flash_size) .. " Bytes", x + 23, y + 40)
    love.graphics.print("IO:" .. tostring(self.obj_mc.io_size) .. " Ports", x + 23, y + 50)

    love.graphics.print("SIGN:      " .. tostring(self.obj_mc.flag[1]), x + 23, y + 75)
    love.graphics.print("ZERO:      " .. tostring(self.obj_mc.flag[2]), x + 23, y + 85)
    love.graphics.print("PARITY:    " .. tostring(self.obj_mc.flag[3]), x + 23, y + 95)
    love.graphics.print("CARRY:     " .. tostring(self.obj_mc.flag[4]), x + 23, y + 105)
    love.graphics.print("AUX CARRY: " .. tostring(self.obj_mc.flag[5]), x + 23, y + 115)
end

function Microcomputer:drawROM()
end

function Microcomputer:drawIO()
end