require("fonts.fonts")

Microcomputer = {
    active = true,

    -- colours
    col_bg = colour.hex('113F5E'),
    col_black = colour.hex('000'),
    col_white = colour.hex('fff'),

    -- fonts
    fnt_header = Font.fonts["dos14_2"],
    fnt_text = Font.fonts["dos14_1"]
};
Microcomputer.__index = Microcomputer;

function Microcomputer.new(microcontroller)
    obj = {};
    setmetatable(obj, Microcomputer);

    local window_width, window_height = love.window.getMode()

    obj.obj_mc = microcontroller;

    -- calculated values
    obj.fnt_header_height = obj.fnt_header:getHeight();
    obj.fnt_header_width = obj.fnt_header:getWidth("A");

    obj.fnt_text_height = obj.fnt_text:getHeight();
    obj.fnt_text_width = obj.fnt_text:getWidth("A");

    do -- registers window parameters
        obj.wr = {
            active = true,
            x = 0, y = math.floor(7/10 * window_height),
            w = 0, h = 0,
            r = 0,
            in_buffer = 5, out_buffer = 5,

            -- colours
            col_bg = colour.hex('4B051F'),
            col_bdr = colour.hex('000'),
            col_hdr_bg = colour.hex('380317'),
            col_hdr_txt = colour.hex('000'),

            -- fonts
            fnt_hdr = Font.fonts["dos14_2"],
            fnt_txt = Font.fonts["nokia_2"],
            fnt_acc = Font.fonts["dos14_2"]
        }
        obj.wr.h = window_height - obj.wr.y
        obj.wr.fnt_hdr_w = obj.wr.fnt_hdr:getWidth("A")
        obj.wr.fnt_hdr_h = obj.wr.fnt_hdr:getHeight()

        obj.wr.fnt_txt_w = obj.wr.fnt_txt:getWidth("A")
        obj.wr.fnt_txt_h = obj.wr.fnt_txt:getHeight()

        obj.wr.fnt_acc_w = obj.wr.fnt_acc:getWidth("A")
        obj.wr.fnt_acc_h = obj.wr.fnt_acc:getHeight()

        obj.wr.hdr_h = obj.wr.fnt_hdr_h + 2*obj.wr.in_buffer
        obj.wr.w = obj.wr.fnt_txt_w * 23 + obj.wr.in_buffer

        -- accounting for the external buffer
        obj.wr.x_out = obj.wr.x + obj.wr.out_buffer
        obj.wr.y_out = obj.wr.y + obj.wr.out_buffer
        obj.wr.w_out = obj.wr.w - 2 * obj.wr.out_buffer
        obj.wr.h_out = obj.wr.h - 2 * obj.wr.out_buffer

        -- accounting for internal buffer
        obj.wr.x_in = obj.wr.x_out + obj.wr.in_buffer
        obj.wr.y_in = obj.wr.y_out + obj.wr.in_buffer

        -- in the body (accounting for the header)
        obj.wr.x_body_out = obj.wr.x_out
        obj.wr.y_body_out = obj.wr.y_out + obj.wr.hdr_h
        obj.wr.x_body_in = obj.wr.x_body_out + obj.wr.in_buffer
        obj.wr.y_body_in = obj.wr.y_body_out + obj.wr.in_buffer

        -- below the accumulator
        obj.wr.y_subbody_out = obj.wr.y_body_out + obj.wr.fnt_hdr_h + obj.wr.in_buffer

        -- other values
        obj.wr.second_reg_offset = obj.wr.fnt_txt_w * 12
        obj.wr.fnt_text_yspacing = obj.wr.fnt_txt_h + 3
        obj.wr.fnt_text_hh = math.floor(obj.wr.fnt_txt_h/2)
        obj.wr.reg_rows = math.floor(obj.obj_mc.reg_size/2)

        obj.wr.y_sub_genreg = obj.wr.y_subbody_out + obj.wr.fnt_text_yspacing * obj.wr.reg_rows + obj.wr.fnt_text_hh
    end

    return obj
end

function Microcomputer:update()
end

function Microcomputer:draw()
    local window_width, window_height = love.window.getMode()
    love.graphics.setFont(self.fnt_text)

    -- background
    love.graphics.setColor(self.col_bg);
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)

    -- registers

    self:drawRegisters()

    -- stack pointer


    -- instuction pointer
end

function Microcomputer:drawMC()
end

function Microcomputer:drawRegisters()
    -- local self.wr.x_body_out, self.wr.y_body_out -- tempory parameters

    -- background
    love.graphics.setColor(self.wr.col_bg)
    love.graphics.rectangle("fill", self.wr.x_out, self.wr.y_out, self.wr.w_out, self.wr.h_out, self.wr.r)

    -- heading
    love.graphics.setColor(self.wr.col_hdr_bg)
    love.graphics.rectangle("fill", self.wr.x_out, self.wr.y_out, self.wr.w_out, self.wr.hdr_h)
    love.graphics.setColor(self.wr.col_hdr_txt)
    love.graphics.setFont(self.wr.fnt_hdr)
    love.graphics.print("REGISTERS", self.wr.x_in, self.wr.y_in)

    -- accumulator
    local acc_text = " ACCUMULATOR "
    love.graphics.setFont(self.wr.fnt_acc)
    love.graphics.print(acc_text .. self.obj_mc.registers["0000"], obj.wr.x_body_in, obj.wr.y_body_in)

    -- general purpose registers
    love.graphics.setFont(self.wr.fnt_txt)
    
    -- loop through the alpha names of the register addresses
    for reg_a, reg_adr in pairs(self.obj_mc.reg_alpha) do
        if reg_adr ~= "0000" then                               -- skip the accumulator
            local reg_v = self.obj_mc.registers[reg_adr]        -- value stored in register at address reg_adr
            if reg_v ~= nil then                                -- if the register contains something
                local reg_ind = numbers.binToDec(reg_adr)       -- index of the register
                local text = reg_a .. " " ..  reg_v
                local xx = self.wr.x_body_out + self.wr.second_reg_offset * ((reg_ind - 1)%2)
                local yy = self.wr.y_subbody_out + self.wr.fnt_text_yspacing * math.floor((reg_ind - 1)/2) + self.wr.fnt_text_hh
                love.graphics.print(text, xx + self.wr.in_buffer, yy)
            end
        end
    end

    -- border
    love.graphics.setColor(self.wr.col_bdr)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", self.wr.x_out, self.wr.y_out, self.wr.w_out, self.wr.h_out, self.wr.r)
    love.graphics.line(self.wr.x_out, self.wr.y_body_out, self.wr.x_out + self.wr.w_out, self.wr.y_body_out)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.wr.x_out, self.wr.y_subbody_out, self.wr.x_out + self.wr.w_out, self.wr.y_subbody_out)
    love.graphics.line(self.wr.x_out, self.wr.y_sub_genreg, self.wr.x_out + self.wr.w_out, self.wr.y_sub_genreg)
end


function Microcomputer:drawRAM()
end

function Microcomputer:drawROM()
end

function Microcomputer:drawIO()
end