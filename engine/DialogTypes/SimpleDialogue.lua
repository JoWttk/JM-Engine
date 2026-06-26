local RichText = require("engine.Interface.RichText")

local SimpleD = {
    active = false,
    text = "",
    fullText = "",
    displayedText = "",
    x = 50,
    y = 400,
    width = 700,
    height = 150,
    padding = 20,
    dialogues = {},
    index = 1,
    queue = {},
    onComplete = nil,
    
    bgColor = {0, 0, 0, 0.9},
    borderColor = {1, 1, 1},
    textColor = {1, 1, 1},
    borderWidth = 3,
    
    showIndicator = true,
    indicatorText = "▼",
    indicatorBlink = true,
    indicatorTimer = 0,
    
    font = nil,
    iconScale = 1.6,
    
    textSpeed = 0.05,
    textTimer = 0,
    currentChar = 0,
    isTyping = false
}

local function getUTF8Chars(str)
    local chars = {}
    local i = 1
    while i <= #str do
        local byte = string.byte(str, i)
        local charLen = 1
        
        if byte >= 240 then charLen = 4
        elseif byte >= 224 then charLen = 3
        elseif byte >= 192 then charLen = 2
        end
        
        table.insert(chars, string.sub(str, i, i + charLen - 1))
        i = i + charLen
    end
    return chars
end

function SimpleD.loadFont()
    if not SimpleD.font then
        SimpleD.font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 12)
    end
end

function SimpleD.show(text, callback)
    SimpleD.loadFont()
    SimpleD.active = true
    SimpleD.fullText = text
    SimpleD.displayedText = ""
    SimpleD.currentChar = 0
    SimpleD.isTyping = true
    SimpleD.dialogues = {text}
    SimpleD.index = 1
    SimpleD.onComplete = callback
end

function SimpleD.showSequence(dialogueList, callback)
    SimpleD.loadFont()
    SimpleD.active = true
    SimpleD.dialogues = dialogueList
    SimpleD.index = 1
    SimpleD.fullText = dialogueList[1] or ""
    SimpleD.displayedText = ""
    SimpleD.currentChar = 0
    SimpleD.isTyping = true
    SimpleD.onComplete = callback
end

function SimpleD.enqueue(dialogueList, callback)
    table.insert(SimpleD.queue, {
        dialogues = type(dialogueList) == "table" and dialogueList or {dialogueList},
        callback = callback
    })
end

function SimpleD.advance()
    if not SimpleD.active then return end
    
    if SimpleD.isTyping then
        SimpleD.displayedText = SimpleD.fullText
        local chars = getUTF8Chars(SimpleD.fullText)
        SimpleD.currentChar = #chars
        SimpleD.isTyping = false
        return
    end
    
    SimpleD.index = SimpleD.index + 1
    
    if SimpleD.index <= #SimpleD.dialogues then
        SimpleD.fullText = SimpleD.dialogues[SimpleD.index]
        SimpleD.displayedText = ""
        SimpleD.currentChar = 0
        SimpleD.isTyping = true
    else
        SimpleD.finish()
    end
end

function SimpleD.finish()
    if SimpleD.onComplete then
        SimpleD.onComplete()
    end
    
    if #SimpleD.queue > 0 then
        local next = table.remove(SimpleD.queue, 1)
        SimpleD.showSequence(next.dialogues, next.callback)
    else
        SimpleD.close()
    end
end

function SimpleD.close()
    SimpleD.active = false
    SimpleD.dialogues = {}
    SimpleD.index = 1
    SimpleD.onComplete = nil
    SimpleD.displayedText = ""
    SimpleD.fullText = ""
    SimpleD.isTyping = false
end

function SimpleD.isActive()
    return SimpleD.active
end

function SimpleD.skip()
    SimpleD.queue = {}
    SimpleD.finish()
end

function SimpleD.update(dt)
    if not SimpleD.active then return end
    
    if SimpleD.indicatorBlink then
        SimpleD.indicatorTimer = SimpleD.indicatorTimer + dt
    end
    
    if SimpleD.isTyping then
        SimpleD.textTimer = SimpleD.textTimer + dt
        
        if SimpleD.textTimer >= SimpleD.textSpeed then
            SimpleD.textTimer = 0
            SimpleD.currentChar = SimpleD.currentChar + 1
            
            local chars = getUTF8Chars(SimpleD.fullText)
            
            if SimpleD.currentChar <= #chars then
                SimpleD.displayedText = table.concat(chars, "", 1, SimpleD.currentChar)
            else
                SimpleD.isTyping = false
                SimpleD.displayedText = SimpleD.fullText
            end
        end
    end
end

function SimpleD.draw()
    if not SimpleD.active then return end
    
    local previousFont = love.graphics.getFont()
    if SimpleD.font then
        love.graphics.setFont(SimpleD.font)
    end
    
    love.graphics.setColor(SimpleD.bgColor)
    love.graphics.rectangle("fill", SimpleD.x, SimpleD.y, SimpleD.width, SimpleD.height)
    
    love.graphics.setColor(SimpleD.borderColor)
    love.graphics.setLineWidth(SimpleD.borderWidth)
    love.graphics.rectangle("line", SimpleD.x, SimpleD.y, SimpleD.width, SimpleD.height)
    
    love.graphics.setColor(SimpleD.textColor)
    RichText.drawWrapped(
        SimpleD.displayedText,
        SimpleD.x + SimpleD.padding,
        SimpleD.y + SimpleD.padding,
        SimpleD.width - SimpleD.padding * 2,
        SimpleD.font:getHeight() * 1.2,
        1,
        SimpleD.iconScale
    )
    
    if SimpleD.showIndicator and not SimpleD.isTyping then
        local alpha = SimpleD.indicatorBlink and (math.sin(SimpleD.indicatorTimer * 4) * 0.5 + 0.5) or 1
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf(
            SimpleD.indicatorText,
            SimpleD.x,
            SimpleD.y + SimpleD.height - 30,
            SimpleD.width,
            "center"
        )
    end
    
    love.graphics.setFont(previousFont)
end

function SimpleD.config(cfg)
    SimpleD.x = cfg.x or SimpleD.x
    SimpleD.y = cfg.y or SimpleD.y
    SimpleD.width = cfg.width or SimpleD.width
    SimpleD.height = cfg.height or SimpleD.height
    SimpleD.padding = cfg.padding or SimpleD.padding
    
    if cfg.bgColor then SimpleD.bgColor = cfg.bgColor end
    if cfg.borderColor then SimpleD.borderColor = cfg.borderColor end
    if cfg.textColor then SimpleD.textColor = cfg.textColor end
    if cfg.borderWidth then SimpleD.borderWidth = cfg.borderWidth end
    if cfg.showIndicator ~= nil then SimpleD.showIndicator = cfg.showIndicator end
    if cfg.indicatorText then SimpleD.indicatorText = cfg.indicatorText end
    if cfg.indicatorBlink ~= nil then SimpleD.indicatorBlink = cfg.indicatorBlink end
    if cfg.textSpeed then SimpleD.textSpeed = cfg.textSpeed end
    if cfg.iconScale then SimpleD.iconScale = cfg.iconScale end
    
    if cfg.fontSize then
        SimpleD.font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", cfg.fontSize)
    end
end

return SimpleD