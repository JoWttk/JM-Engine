local InterfaceButton = {}

function InterfaceButton:new(x, y, width, height, bgColor, text, textColor, font, fontSize, strokeWidth, strokeColor, onClick)
    local button = {}
    button.x = x
    button.y = y
    button.width = width
    button.height = height
    button.bgColor = bgColor or {1, 1, 1}
    button.textColor = textColor or {0, 0, 0}
    button.text = text
    button.strokeWidth = strokeWidth or 0
    button.strokeColor = strokeColor or {0, 0, 0}
    button.onClick = onClick
    button.isHovered = false

    local fontToUse = love.graphics.setNewFont(font, fontSize) or love.graphics.getFont()
    button.font = fontToUse

    function button:draw()
        local sw = self.strokeWidth or 0

        if sw > 0 then
            love.graphics.setColor(self.strokeColor[1], self.strokeColor[2], self.strokeColor[3], self.strokeColor[4] or 1)
            love.graphics.rectangle("fill",
                self.x - sw, self.y - sw,
                self.width + sw * 2, self.height + sw * 2
            )
        end

        local r, g, b, a = self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4] or 1
        if self.isHovered then
            r, g, b = r * 0.8, g * 0.8, b * 0.8
        end
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        if self.text and self.text ~= "" then
            love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4] or 1)
            love.graphics.setFont(self.font)
            love.graphics.printf(self.text, self.x, self.y + self.height/2 - 6, self.width, "center")
        end
    end

    function button:update(mx, my, isPressed)
        self.isHovered = mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
        if self.isHovered and isPressed then
            self.onClick()
        end
    end

    return button
end

return InterfaceButton