require("fonts.fonts")

Microcomputer = {};
Microcomputer.__index = Microcomputer;

function Microcomputer.new(microcontroller)
    local self = {}
    setmetatable(self, Microcomputer);

    self.active = true

    -- colours
    self.col_bg = colour.hex('113F5E')
    self.col_black = colour.hex('000')
    self.col_white = colour.hex('fff')

    -- fonts
    self.fnt_header = Font.fonts["dos14"]
    self.fnt_text = Font.fonts["dos14"]

    local _, window_height = App.getWindowSize()

    self.obj_mc = microcontroller;

    -- calculated values
    self.fnt_header_height = self.fnt_header:getHeight();
    self.fnt_header_width = self.fnt_header:getWidth("A");

    self.fnt_text_height = self.fnt_text:getHeight();
    self.fnt_text_width = self.fnt_text:getWidth("A");

    do -- registers window parameters
        self.reg_win = {
            active = true,
            x = 0, y = -1,
            w = -1, h = -1,
            r = 3,
            in_buffer = 3, out_buffer = 3,

            -- colours
            col_bg = colour.hex('4B051F'),
            col_bdr = colour.hex('000'),
            col_hdr_bg = colour.hex('380317'),
            col_hdr_txt = colour.hex('000'),

            -- fonts
            fnt_hdr = Font.fonts["dos14"],
            fnt_txt = Font.fonts["pxl_5x7_thin"],
            fnt_acc = Font.fonts["pxl_5x7_bold"]
        }
        
        -- fonts
        self.reg_win.fnt_hdr_w = self.reg_win.fnt_hdr:getWidth("A")
        self.reg_win.fnt_hdr_h = self.reg_win.fnt_hdr:getHeight()
        self.reg_win.fnt_txt_w = self.reg_win.fnt_txt:getWidth("A")
        self.reg_win.fnt_txt_h = self.reg_win.fnt_txt:getHeight()
        self.reg_win.fnt_acc_w = self.reg_win.fnt_acc:getWidth("A")
        self.reg_win.fnt_acc_h = self.reg_win.fnt_acc:getHeight()

        self.reg_win.fnt_text_yspacing = self.reg_win.fnt_txt_h + 1
        self.reg_win.fnt_text_hh = math.floor(self.reg_win.fnt_txt_h/2)

        self.reg_win.reg_rows = math.floor(self.obj_mc.reg_size/2)

        -- window size
        self.reg_win.h = 2*self.reg_win.out_buffer + 5*self.reg_win.in_buffer + math.floor(6.5*self.reg_win.fnt_text_yspacing) + 2*self.reg_win.fnt_hdr_h - 2

        self.reg_win.y = window_height - self.reg_win.h
        self.reg_win.hdr_h = self.reg_win.fnt_hdr_h + 2*self.reg_win.in_buffer
        self.reg_win.w = self.reg_win.fnt_txt_w * 23 + 2*self.reg_win.in_buffer

        -- accounting for the external buffer
        self.reg_win.x_out = self.reg_win.x + self.reg_win.out_buffer
        self.reg_win.y_out = self.reg_win.y + self.reg_win.out_buffer
        self.reg_win.w_out = self.reg_win.w - 2 * self.reg_win.out_buffer
        self.reg_win.h_out = self.reg_win.h - 2 * self.reg_win.out_buffer

        -- accounting for internal buffer
        self.reg_win.x_in = self.reg_win.x_out + self.reg_win.in_buffer
        self.reg_win.y_in = self.reg_win.y_out + self.reg_win.in_buffer

        -- in the body (accounting for the header)
        self.reg_win.x_body_out = self.reg_win.x_out
        self.reg_win.y_body_out = self.reg_win.y_out + self.reg_win.hdr_h
        self.reg_win.x_body_in = self.reg_win.x_body_out + self.reg_win.in_buffer
        self.reg_win.y_body_in = self.reg_win.y_body_out + self.reg_win.in_buffer

        -- below the accumulator
        self.reg_win.y_subacc = self.reg_win.y_body_out + self.reg_win.fnt_hdr_h + 1
        self.reg_win.y_sub_genreg = self.reg_win.y_subacc + self.reg_win.fnt_text_yspacing * self.reg_win.reg_rows + 2*self.reg_win.in_buffer - 1

        self.reg_win.canvas = love.graphics.newCanvas(App.window_width, App.window_height)

        -- translation layer
        self.reg_win.trans_reg_ind = {"0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000"}
        self.reg_win.trans_reg_alpha = {"B", "C", "D", "E", "G", "H", "X", "Y"}
        self.reg_win.trans_xreg_alpha = {"XB", "XD", "XG", " Z"}

    end

    do -- RAM window parameters
        self.ram_win = {
            active = true,
            x = 0, y = 0,
            w = -1, h = -1,
            r = 3,
            in_buffer = 3, out_buffer = 3,

            -- colours
            col_bg = colour.hex('4B051F'),
            col_bdr = colour.hex('000'),
            col_hdr_bg = colour.hex('380317'),
            col_hdr_txt = colour.hex('000'),

            -- fonts
            fnt_hdr = Font.fonts["dos14"],
            fnt_txt = Font.fonts["pxl_5x7_thin"]
        }
        
        -- fonts
        self.ram_win.fnt_hdr_w = self.ram_win.fnt_hdr:getWidth("A")
        self.ram_win.fnt_hdr_h = self.ram_win.fnt_hdr:getHeight()
        self.ram_win.fnt_txt_w = self.ram_win.fnt_txt:getWidth("A")
        self.ram_win.fnt_txt_h = self.ram_win.fnt_txt:getHeight()

        self.ram_win.vals_in_row = 8

        -- window size
        self.ram_win.h = window_height - self.reg_win.h + self.ram_win.out_buffer
        self.ram_win.hdr_h = self.ram_win.fnt_hdr_h + 2*self.ram_win.in_buffer
        self.ram_win.body_h = self.ram_win.h - self.ram_win.hdr_h
        self.ram_win.window_rows = math.floor(self.ram_win.body_h/self.ram_win.fnt_txt_h) - 1
        self.ram_win.row_offset = 0;
        self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;

        self.ram_win.body_char_width = self.ram_win.vals_in_row * 3 + 6
        self.ram_win.w = self.ram_win.fnt_txt_w * (self.ram_win.body_char_width + 1) + 2*self.ram_win.in_buffer

        -- accounting for the external buffer
        self.ram_win.x_out = self.ram_win.x + self.ram_win.out_buffer
        self.ram_win.y_out = self.ram_win.y + self.ram_win.out_buffer
        self.ram_win.w_out = self.ram_win.w - 2 * self.ram_win.out_buffer
        self.ram_win.h_out = self.ram_win.h - 2 * self.ram_win.out_buffer

        -- accounting for internal buffer
        self.ram_win.x_in = self.ram_win.x_out + self.ram_win.in_buffer
        self.ram_win.y_in = self.ram_win.y_out + self.ram_win.in_buffer

        -- in the body (accounting for the header)
        self.ram_win.x_body_out = self.ram_win.x_out
        self.ram_win.y_body_out = self.ram_win.y_out + self.ram_win.hdr_h
        self.ram_win.x_body_in = self.ram_win.x_body_out + self.ram_win.in_buffer
        self.ram_win.y_body_in = self.ram_win.y_body_out + self.ram_win.in_buffer

        self.ram_win.canvas = love.graphics.newCanvas(App.window_width, App.window_height)
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
    local nav_key = keyboard:getNavKey();

    if nav_key == "pagedown" then
        self.ram_win.row_offset = math.min(math.ceil(self.obj_mc.sram_size/self.ram_win.vals_in_row) - self.ram_win.window_rows, self.ram_win.row_offset + self.ram_win.window_rows - 1);
        self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;
    elseif nav_key == "pageup" then
        self.ram_win.row_offset = math.max(0, self.ram_win.row_offset - self.ram_win.window_rows + 1);
        self.ram_win.char_offset = self.ram_win.row_offset*self.ram_win.vals_in_row;
    end

    keyboard:reset()
end

function Microcomputer:draw()
    local window_width, window_height = App.getWindowSize()
    love.graphics.setFont(self.fnt_text)

    -- background
    love.graphics.setColor(self.col_bg);
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)

    -- windows
    for _ = 1,100 do
        self:drawRegisters()
        self:drawRAM()
        self:drawMicroprocessor()
    end
end

function Microcomputer:drawMC()
end

function Microcomputer:drawRegisters()
    --love.graphics.setCanvas(self.wr.canvas) -- (seems to be very slow)
    -- 47-48 fps no translation, ~55 fps after

    -- background
    love.graphics.setColor(self.reg_win.col_bg)
    love.graphics.rectangle("fill", self.reg_win.x_out, self.reg_win.y_out, self.reg_win.w_out, self.reg_win.h_out, self.reg_win.r)

    -- heading
    love.graphics.setColor(self.reg_win.col_hdr_bg)
    love.graphics.rectangle("fill", self.reg_win.x_out, self.reg_win.y_out, self.reg_win.w_out, self.reg_win.hdr_h, self.reg_win.r)
    love.graphics.setColor(self.reg_win.col_hdr_txt)
    love.graphics.setFont(self.reg_win.fnt_hdr)
    love.graphics.print("REGISTERS", self.reg_win.x_in, self.reg_win.y_in)

    -- accumulator
    local acc_text = " ACCUMULATOR "
    love.graphics.setFont(self.reg_win.fnt_acc)
    love.graphics.print(acc_text .. self.obj_mc.registers["0000"], self.reg_win.x_body_in, self.reg_win.y_body_in)

    -- general purpose registers
    love.graphics.setFont(self.reg_win.fnt_txt)

    for i = 1,self.reg_win.reg_rows do
        local i2 = 2*i
        local reg_v1 = self.obj_mc.registers[self.reg_win.trans_reg_ind[i2 - 1]]
        local reg_v2 = self.obj_mc.registers[self.reg_win.trans_reg_ind[i2]]
        local reg_a1 = self.reg_win.trans_reg_alpha[i2 - 1]
        local text

        if reg_v2 ~= nil then
            local reg_a2 = self.reg_win.trans_reg_alpha[i2]
            local xreg = self.reg_win.trans_xreg_alpha[i]
            text = xreg .. " ".. reg_a1  .. reg_v1 .. " " .. reg_a2 .. reg_v1
        else
            text = "   " .. reg_a1 .. reg_v1
        end
        local yy = self.reg_win.y_subacc + self.reg_win.fnt_text_yspacing * (i - 1) + self.reg_win.in_buffer - 1
        love.graphics.print(text, self.reg_win.x_body_in, yy)
    end

    -- stack pointer and instruction pointer
    love.graphics.print("STACK " .. self.obj_mc.stack_pointer, self.reg_win.x_body_in, self.reg_win.y_sub_genreg + self.reg_win.in_buffer - 1)
    love.graphics.print("INSTR " .. self.obj_mc.instruction_pointer, self.reg_win.x_body_in, self.reg_win.y_sub_genreg + self.reg_win.fnt_text_yspacing + self.reg_win.in_buffer - 1)

    -- border
    love.graphics.setColor(self.reg_win.col_bdr)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.reg_win.x_out, self.reg_win.y_out, self.reg_win.w_out, self.reg_win.h_out, self.reg_win.r)
    love.graphics.line(self.reg_win.x_out, self.reg_win.y_body_out, self.reg_win.x_out + self.reg_win.w_out, self.reg_win.y_body_out)
    love.graphics.setLineWidth(1)
    love.graphics.line(self.reg_win.x_out, self.reg_win.y_subacc, self.reg_win.x_out + self.reg_win.w_out, self.reg_win.y_subacc)
    love.graphics.line(self.reg_win.x_out, self.reg_win.y_sub_genreg, self.reg_win.x_out + self.reg_win.w_out, self.reg_win.y_sub_genreg)
    
    --love.graphics.setCanvas(App.canvas)
end

function Microcomputer:drawRAM()
    -- background
    love.graphics.setColor(self.ram_win.col_bg)
    love.graphics.rectangle("fill", self.ram_win.x_out, self.ram_win.y_out, self.ram_win.w_out, self.ram_win.h_out, self.ram_win.r)

    -- heading
    love.graphics.setColor(self.ram_win.col_hdr_bg)
    love.graphics.rectangle("fill", self.ram_win.x_out, self.ram_win.y_out, self.ram_win.w_out, self.ram_win.hdr_h, self.ram_win.r)
    love.graphics.setColor(self.ram_win.col_hdr_txt)
    love.graphics.setFont(self.ram_win.fnt_hdr)
    love.graphics.print("RAM", self.ram_win.x_in, self.ram_win.y_in)

    -- ram
    love.graphics.setFont(self.ram_win.fnt_txt)

    local vals, val_str, yy
    for i = 1,self.ram_win.window_rows do
        vals = {}
        local row_index = (i - 1 + self.ram_win.row_offset)*self.ram_win.vals_in_row
        local row_hex_index = bit.tohex(row_index, 4):upper()
        for j = 1,self.ram_win.vals_in_row do
            local ind = row_index + j - 1;
            vals[j] = numbers.byteToHex(self.obj_mc.sram[ind])
        end
        val_str = table.concat(vals, " ")
        yy = self.ram_win.y_body_in + self.ram_win.fnt_txt_h * (i - 1)
        love.graphics.print("0x" .. row_hex_index .. " " .. val_str, self.ram_win.x_body_in, yy)
    end


    -- border
    love.graphics.setColor(self.ram_win.col_bdr)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.ram_win.x_out, self.ram_win.y_out, self.ram_win.w_out, self.ram_win.h_out, self.ram_win.r)
    love.graphics.line(self.ram_win.x_out, self.ram_win.y_body_out, self.ram_win.x_out + self.ram_win.w_out, self.ram_win.y_body_out)
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
