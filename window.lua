-- A generic window that can be used for ideally anything
Window = {}
Window.__index = Window

-- set the parameters for the window (semi-constant)
function Window.new(x, y, w, h, r, exbuff, inbuff, bdr, fonts, colours)
    local self = {}
    setmetatable(self, Window)

    self.active = true

    -- window size and shape
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.r = r or 0

    self.ext_buffer = exbuff or 0
    self.int_buffer = inbuff or 0

    self.border = bdr or 0
    self.line_spacing = 1;

    -- fonts {1: header, 2: text 1, 3 text 2, ...}
    self.fnt_hdr, self.fnt_hdr_w, self.fnt_hdr_h = Font.getFont(fonts[1])
    self.fnt_txt1, self.fnt_txt1_w, self.fnt_txt1_h = Font.getFont(fonts[2])
    self.fnt_txt2, self.fnt_txt2_w, self.fnt_txt2_h = Font.getFont(fonts[3])

    -- colours {{background}, {border}, {text}}
    self.col_bg = {}
    self.col_bdr = {}
    self.col_txt = {}
    if colours ~= nil then
        if colours[1] ~= nil then
            for i,v in ipairs(colours[1]) do
                self.col_bg[i] = Colour.hex(v)
            end
        end
        if colours[2] ~= nil then
            for i,v in ipairs(colours[2]) do
                self.col_bdr[i] = Colour.hex(v)
            end
        end
        if colours[3] ~= nil then
            for i,v in ipairs(colours[3]) do
                self.col_txt[i] = Colour.hex(v)
            end
        end
    end
    

    return self
end

-- calculate once anything that relies on the initial parameters (can be called again to update)
function Window:init()
    self.x_ext = self.x + self.ext_buffer
    self.y_ext = self.y + self.ext_buffer
    self.w_ext = self.w - 2 * self.ext_buffer
    self.h_ext = self.h - 2 * self.ext_buffer

    self.x_int = self.x_ext + self.int_buffer
    self.y_int = self.y_ext + self.int_buffer
    self.w_int = self.w_ext - 2 * self.int_buffer
    self.h_int = self.h_ext - 2 * self.int_buffer

    self.current_y = self.y_int
    self.reset_y = self.y_int

    -- precalculate to optimise
    self.hdr_h = self.int_buffer * 2 + self.fnt_hdr_h + self.border
    self.hdr_y_offset = self.int_buffer + self.fnt_hdr_h + self.border

    
end

-- draws a horizontal line of specified width and colour at the current y value
function Window:hline(width, colour)
	local col = colour or self.col_bdr[1]
    self.current_y = self.current_y - math.ceil(width/2)
    love.graphics.setLineWidth(0)
    love.graphics.setColor(col)
    love.graphics.rectangle("fill", self.x_ext, self.current_y, self.w_ext, width)
    self.current_y = self.current_y + width + self.int_buffer + 1
end

-- prints text, either table or string, of specified colour at current y and x
function Window:printText(text, font, x)
    love.graphics.setFont(font)
    x = x or self.x_int
    love.graphics.setColor(1,1,1,1) -- set colour to white to avoid tinting
    love.graphics.print(text, x, self.current_y)
    self.current_y = self.current_y + font:getHeight() + self.line_spacing
end

-- adds a vertical space
function Window:vspace(px)
    self.current_y = self.current_y + px
end

function Window:drawBackground()
    love.graphics.setColor(self.col_bg[1])
    love.graphics.rectangle("fill", self.x_ext, self.y_ext, self.w_ext, self.h_ext, self.r)
end

function Window:drawBorder(width)
    love.graphics.setColor(self.col_bdr[1])
    love.graphics.setLineWidth(width)
    love.graphics.rectangle("line", self.x_ext, self.y_ext, self.w_ext, self.h_ext, self.r)
end

function Window:drawTitle(text, background)
    if background then
        love.graphics.setColor(self.col_bg[2])
        love.graphics.rectangle("fill", self.x_ext, self.y_ext, self.w_ext, self.hdr_h)
    end
    love.graphics.setFont(self.fnt_hdr)
    love.graphics.setColor(1,1,1,1) -- reset colour to white to avoid tinting
    love.graphics.print(text, self.x_int, self.current_y + self.border)
    self.current_y = self.current_y + self.hdr_y_offset
end

function Window:resetCurrentY()
    self.current_y = self.reset_y
end

function Window:getHeight()
    local parent_canvas = love.graphics.getCanvas()
    local temp_canvas = love.graphics.newCanvas(1,1)
    love.graphics.setCanvas(temp_canvas)
    self:init()
    self:draw()
    love.graphics.setCanvas(parent_canvas)

    return self.current_y + self.ext_buffer + self.int_buffer
end