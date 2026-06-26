local UI = require("engine.Interface.UI")

local InterfaceButton = {}

function InterfaceButton:new(x, y, width, height, bgColor, text, textColor, font, fontSize, strokeWidth, strokeColor, onClick)
    local button = {}
    button.x = x
    button.y = y
    button.width = width
    button.minWidth = width
    button.height = height
    button.bgColor = bgColor or {1, 1, 1}
    button.textColor = textColor or {0, 0, 0}
    button.text = text
    button.strokeWidth = strokeWidth or 0
    button.strokeColor = strokeColor or {0, 0, 0}
    button.onClick = onClick
    button.isHovered = false
    button.fontPath = font
    button.fontSize = fontSize or 16

    function button:draw()
        local sw = self.strokeWidth or 0
        local cornerRadius = 8

        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("fill", self.x + 4, self.y + 4, self.width, self.height, cornerRadius)

        if sw > 0 then
            love.graphics.setColor(self.strokeColor[1], self.strokeColor[2], self.strokeColor[3], self.strokeColor[4] or 1)
            love.graphics.rectangle("fill", self.x - sw, self.y - sw, self.width + sw * 2, self.height + sw * 2, cornerRadius)
        end

        local r, g, b, a = self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4] or 1
        if self.isHovered then
            r, g, b = math.min(1, r * 1.1), math.min(1, g * 1.1), math.min(1, b * 1.1)
        end
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius)

        if self.text and self.text ~= "" then
            love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4] or 1)
            local font = UI.getFont(self.fontPath, self.fontSize)
            love.graphics.setFont(font)
            local textY = self.y + self.height/2 - (font:getHeight() / 2)
            love.graphics.printf(self.text, self.x, textY, self.width, "center")
        end
    end

    function button:update(mx, my, isPressed)
        self.isHovered = mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
        if self.isHovered and isPressed and self.onClick then
            self.onClick()
        end
    end

    function button:setText(newText)
        self.text = newText
    end

    function button:fitToText(padding)
        padding = padding or 16
        local font = UI.getFont(self.fontPath, self.fontSize)
        local textWidth = font:getWidth(self.text or "")
        local newWidth = textWidth + padding * 2
        if self.minWidth then
            self.width = math.max(self.minWidth, newWidth)
        else
            self.width = newWidth
        end
    end

    function button:setPosition(x, y)
        self.x = x or self.x
        self.y = y or self.y
    end

    function button:centerHorizontally(cx)
        cx = cx or (1024/2)
        self.x = cx - (self.width / 2)
    end

    return button
end

return InterfaceButton