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
            fnt_txt = Font.fonts["nokia_mod"],
            fnt_acc = Font.fonts["dos14"]
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
        self.reg_win.h = 2*self.reg_win.out_buffer + 5*self.reg_win.in_buffer + math.floor(6.5*self.reg_win.fnt_text_yspacing) + 2*self.reg_win.fnt_hdr_h

        self.reg_win.y = window_height - self.reg_win.h
        self.reg_win.hdr_h = self.reg_win.fnt_hdr_h + 2*self.reg_win.in_buffer
        self.reg_win.w = self.reg_win.fnt_txt_w * 23 + self.reg_win.in_buffer

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
        self.reg_win.y_subacc_out = self.reg_win.y_body_out + self.reg_win.fnt_hdr_h + self.reg_win.in_buffer + 1

        -- other values
        --self.wr.second_reg_offset = self.wr.fnt_txt_w * 12

        self.reg_win.y_sub_genreg = self.reg_win.y_subacc_out + self.reg_win.fnt_text_yspacing * self.reg_win.reg_rows + self.reg_win.fnt_text_hh

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
            fnt_txt = Font.fonts["nokia_mod"]
        }
        
        -- fonts
        self.ram_win.fnt_hdr_w = self.ram_win.fnt_hdr:getWidth("A")
        self.ram_win.fnt_hdr_h = self.ram_win.fnt_hdr:getHeight()
        self.ram_win.fnt_txt_w = self.ram_win.fnt_txt:getWidth("A")
        self.ram_win.fnt_txt_h = self.ram_win.fnt_txt:getHeight()

        self.ram_win.fnt_text_yspacing = self.ram_win.fnt_txt_h + 1

        self.ram_win.reg_rows = math.floor(self.obj_mc.reg_size/2)

        -- window size
        self.ram_win.h = window_height - self.reg_win.h
        self.ram_win.body_char_width = 30

        self.ram_win.hdr_h = self.ram_win.fnt_hdr_h + 2*self.ram_win.in_buffer
        self.ram_win.w = self.ram_win.fnt_txt_w * (self.ram_win.body_char_width + 1) + self.ram_win.in_buffer

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

        self.ram_win.trans_byte_to_hex = {
            ['00000000'] = '00',
            ['00000001'] = '01',
            ['00000010'] = '02',
            ['00000011'] = '03',
            ['00000100'] = '04',
            ['00000101'] = '05',
            ['00000110'] = '06',
            ['00000111'] = '07',
            ['00001000'] = '08',
            ['00001001'] = '09',
            ['00001010'] = '0A',
            ['00001011'] = '0B',
            ['00001100'] = '0C',
            ['00001101'] = '0D',
            ['00001110'] = '0E',
            ['00001111'] = '0F',
            ['00010000'] = '10',
            ['00010001'] = '11',
            ['00010010'] = '12',
            ['00010011'] = '13',
            ['00010100'] = '14',
            ['00010101'] = '15',
            ['00010110'] = '16',
            ['00010111'] = '17',
            ['00011000'] = '18',
            ['00011001'] = '19',
            ['00011010'] = '1A',
            ['00011011'] = '1B',
            ['00011100'] = '1C',
            ['00011101'] = '1D',
            ['00011110'] = '1E',
            ['00011111'] = '1F',
            ['00100000'] = '20',
            ['00100001'] = '21',
            ['00100010'] = '22',
            ['00100011'] = '23',
            ['00100100'] = '24',
            ['00100101'] = '25',
            ['00100110'] = '26',
            ['00100111'] = '27',
            ['00101000'] = '28',
            ['00101001'] = '29',
            ['00101010'] = '2A',
            ['00101011'] = '2B',
            ['00101100'] = '2C',
            ['00101101'] = '2D',
            ['00101110'] = '2E',
            ['00101111'] = '2F',
            ['00110000'] = '30',
            ['00110001'] = '31',
            ['00110010'] = '32',
            ['00110011'] = '33',
            ['00110100'] = '34',
            ['00110101'] = '35',
            ['00110110'] = '36',
            ['00110111'] = '37',
            ['00111000'] = '38',
            ['00111001'] = '39',
            ['00111010'] = '3A',
            ['00111011'] = '3B',
            ['00111100'] = '3C',
            ['00111101'] = '3D',
            ['00111110'] = '3E',
            ['00111111'] = '3F',
            ['01000000'] = '40',
            ['01000001'] = '41',
            ['01000010'] = '42',
            ['01000011'] = '43',
            ['01000100'] = '44',
            ['01000101'] = '45',
            ['01000110'] = '46',
            ['01000111'] = '47',
            ['01001000'] = '48',
            ['01001001'] = '49',
            ['01001010'] = '4A',
            ['01001011'] = '4B',
            ['01001100'] = '4C',
            ['01001101'] = '4D',
            ['01001110'] = '4E',
            ['01001111'] = '4F',
            ['01010000'] = '50',
            ['01010001'] = '51',
            ['01010010'] = '52',
            ['01010011'] = '53',
            ['01010100'] = '54',
            ['01010101'] = '55',
            ['01010110'] = '56',
            ['01010111'] = '57',
            ['01011000'] = '58',
            ['01011001'] = '59',
            ['01011010'] = '5A',
            ['01011011'] = '5B',
            ['01011100'] = '5C',
            ['01011101'] = '5D',
            ['01011110'] = '5E',
            ['01011111'] = '5F',
            ['01100000'] = '60',
            ['01100001'] = '61',
            ['01100010'] = '62',
            ['01100011'] = '63',
            ['01100100'] = '64',
            ['01100101'] = '65',
            ['01100110'] = '66',
            ['01100111'] = '67',
            ['01101000'] = '68',
            ['01101001'] = '69',
            ['01101010'] = '6A',
            ['01101011'] = '6B',
            ['01101100'] = '6C',
            ['01101101'] = '6D',
            ['01101110'] = '6E',
            ['01101111'] = '6F',
            ['01110000'] = '70',
            ['01110001'] = '71',
            ['01110010'] = '72',
            ['01110011'] = '73',
            ['01110100'] = '74',
            ['01110101'] = '75',
            ['01110110'] = '76',
            ['01110111'] = '77',
            ['01111000'] = '78',
            ['01111001'] = '79',
            ['01111010'] = '7A',
            ['01111011'] = '7B',
            ['01111100'] = '7C',
            ['01111101'] = '7D',
            ['01111110'] = '7E',
            ['01111111'] = '7F',
            ['10000000'] = '80',
            ['10000001'] = '81',
            ['10000010'] = '82',
            ['10000011'] = '83',
            ['10000100'] = '84',
            ['10000101'] = '85',
            ['10000110'] = '86',
            ['10000111'] = '87',
            ['10001000'] = '88',
            ['10001001'] = '89',
            ['10001010'] = '8A',
            ['10001011'] = '8B',
            ['10001100'] = '8C',
            ['10001101'] = '8D',
            ['10001110'] = '8E',
            ['10001111'] = '8F',
            ['10010000'] = '90',
            ['10010001'] = '91',
            ['10010010'] = '92',
            ['10010011'] = '93',
            ['10010100'] = '94',
            ['10010101'] = '95',
            ['10010110'] = '96',
            ['10010111'] = '97',
            ['10011000'] = '98',
            ['10011001'] = '99',
            ['10011010'] = '9A',
            ['10011011'] = '9B',
            ['10011100'] = '9C',
            ['10011101'] = '9D',
            ['10011110'] = '9E',
            ['10011111'] = '9F',
            ['10100000'] = 'A0',
            ['10100001'] = 'A1',
            ['10100010'] = 'A2',
            ['10100011'] = 'A3',
            ['10100100'] = 'A4',
            ['10100101'] = 'A5',
            ['10100110'] = 'A6',
            ['10100111'] = 'A7',
            ['10101000'] = 'A8',
            ['10101001'] = 'A9',
            ['10101010'] = 'AA',
            ['10101011'] = 'AB',
            ['10101100'] = 'AC',
            ['10101101'] = 'AD',
            ['10101110'] = 'AE',
            ['10101111'] = 'AF',
            ['10110000'] = 'B0',
            ['10110001'] = 'B1',
            ['10110010'] = 'B2',
            ['10110011'] = 'B3',
            ['10110100'] = 'B4',
            ['10110101'] = 'B5',
            ['10110110'] = 'B6',
            ['10110111'] = 'B7',
            ['10111000'] = 'B8',
            ['10111001'] = 'B9',
            ['10111010'] = 'BA',
            ['10111011'] = 'BB',
            ['10111100'] = 'BC',
            ['10111101'] = 'BD',
            ['10111110'] = 'BE',
            ['10111111'] = 'BF',
            ['11000000'] = 'C0',
            ['11000001'] = 'C1',
            ['11000010'] = 'C2',
            ['11000011'] = 'C3',
            ['11000100'] = 'C4',
            ['11000101'] = 'C5',
            ['11000110'] = 'C6',
            ['11000111'] = 'C7',
            ['11001000'] = 'C8',
            ['11001001'] = 'C9',
            ['11001010'] = 'CA',
            ['11001011'] = 'CB',
            ['11001100'] = 'CC',
            ['11001101'] = 'CD',
            ['11001110'] = 'CE',
            ['11001111'] = 'CF',
            ['11010000'] = 'D0',
            ['11010001'] = 'D1',
            ['11010010'] = 'D2',
            ['11010011'] = 'D3',
            ['11010100'] = 'D4',
            ['11010101'] = 'D5',
            ['11010110'] = 'D6',
            ['11010111'] = 'D7',
            ['11011000'] = 'D8',
            ['11011001'] = 'D9',
            ['11011010'] = 'DA',
            ['11011011'] = 'DB',
            ['11011100'] = 'DC',
            ['11011101'] = 'DD',
            ['11011110'] = 'DE',
            ['11011111'] = 'DF',
            ['11100000'] = 'E0',
            ['11100001'] = 'E1',
            ['11100010'] = 'E2',
            ['11100011'] = 'E3',
            ['11100100'] = 'E4',
            ['11100101'] = 'E5',
            ['11100110'] = 'E6',
            ['11100111'] = 'E7',
            ['11101000'] = 'E8',
            ['11101001'] = 'E9',
            ['11101010'] = 'EA',
            ['11101011'] = 'EB',
            ['11101100'] = 'EC',
            ['11101101'] = 'ED',
            ['11101110'] = 'EE',
            ['11101111'] = 'EF',
            ['11110000'] = 'F0',
            ['11110001'] = 'F1',
            ['11110010'] = 'F2',
            ['11110011'] = 'F3',
            ['11110100'] = 'F4',
            ['11110101'] = 'F5',
            ['11110110'] = 'F6',
            ['11110111'] = 'F7',
            ['11111000'] = 'F8',
            ['11111001'] = 'F9',
            ['11111010'] = 'FA',
            ['11111011'] = 'FB',
            ['11111100'] = 'FC',
            ['11111101'] = 'FD',
            ['11111110'] = 'FE',
            ['11111111'] = 'FF'
        }

    end

    return self
end

function Microcomputer:update()
end

function Microcomputer:draw()
    local window_width, window_height = App.getWindowSize()
    love.graphics.setFont(self.fnt_text)

    -- background
    love.graphics.setColor(self.col_bg);
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)

    -- registers
    self:drawRegisters()

    -- ram
    self:drawRAM()

    -- stack pointer


    -- instuction pointer


    -- draw all canvases
    --love.graphics.setColor(1,1,1)
    --love.graphics.draw(self.wr.canvas)
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
        local yy = self.reg_win.y_subacc_out + self.reg_win.fnt_text_yspacing * (i - 1) + self.reg_win.in_buffer
        love.graphics.print(text, self.reg_win.x_body_in, yy)
    end

    -- stack pointer and instruction pointer
    love.graphics.print("STACK " .. self.obj_mc.stack_pointer, self.reg_win.x_body_in, self.reg_win.y_sub_genreg + self.reg_win.in_buffer)
    love.graphics.print("INSTR " .. self.obj_mc.instruction_pointer, self.reg_win.x_body_in, self.reg_win.y_sub_genreg + self.reg_win.fnt_text_yspacing + self.reg_win.in_buffer)

    -- border
    love.graphics.setColor(self.reg_win.col_bdr)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.reg_win.x_out, self.reg_win.y_out, self.reg_win.w_out, self.reg_win.h_out, self.reg_win.r)
    love.graphics.line(self.reg_win.x_out, self.reg_win.y_body_out, self.reg_win.x_out + self.reg_win.w_out, self.reg_win.y_body_out)
    love.graphics.setLineWidth(1)
    love.graphics.line(self.reg_win.x_out, self.reg_win.y_subacc_out, self.reg_win.x_out + self.reg_win.w_out, self.reg_win.y_subacc_out)
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


    -- 6 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |

    -- ram
    love.graphics.setFont(self.ram_win.fnt_txt)

    local vals, val_str, yy
    local vals_in_row = 8
    local rows = math.ceil(self.obj_mc.sram_size/vals_in_row)
    for i = 1,rows do
        vals = {}
        for j = 1,vals_in_row do
            local ind = (i-1)*vals_in_row + j - 1
            vals[j] = self.ram_win.trans_byte_to_hex[self.obj_mc.sram[ind]]
        end
        val_str = table.join(vals, " ")
        yy = self.ram_win.y_body_in + self.ram_win.fnt_text_yspacing * (i - 1)
        love.graphics.print("0x0000 " .. val_str, self.ram_win.x_body_in, yy)
    end


    -- border
    love.graphics.setColor(self.ram_win.col_bdr)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.ram_win.x_out, self.ram_win.y_out, self.ram_win.w_out, self.ram_win.h_out, self.ram_win.r)
    love.graphics.line(self.ram_win.x_out, self.ram_win.y_body_out, self.ram_win.x_out + self.ram_win.w_out, self.ram_win.y_body_out)
end

function Microcomputer:drawROM()
end

function Microcomputer:drawIO()
end