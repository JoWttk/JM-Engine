local InterfaceText = {}

function InterfaceText:new(x, y, font, fontSize, text, textColor, textStroke, textStrokeColor)
    local textObj = {}
    textObj.x = x
    textObj.y = y
    textObj.text = text
    textObj.textColor = textColor or {1, 1, 1}
    textObj.textStroke = textStroke or 0
    textObj.textStrokeColor = textStrokeColor or {1, 1, 1}

    textObj.font = love.graphics.newFont(font, fontSize)
    
    function textObj:draw()
        love.graphics.setFont(self.font)

        if self.textStroke > 0 then
            love.graphics.setColor(self.textStrokeColor)

            local r = self.textStroke
            local steps = math.max(24, r * 10)

            for i = 1, steps do
                local ang = (i / steps) * math.pi * 2
                local dx = math.floor(math.cos(ang) * r + 0.5)
                local dy = math.floor(math.sin(ang) * r + 0.5)
                love.graphics.print(self.text, self.x + dx, self.y + dy)
            end
        end

        love.graphics.setColor(self.textColor)
        love.graphics.print(self.text, self.x, self.y)
    end

    return textObj
end

return InterfaceText