local Platform = {}
local Entity = require("engine.EntitySystem.Entity")
local Components = require("engine.EntitySystem.Components")

Platform.list = {}

function Platform.new(x, y, w, h, color, texture)
    local platform = {
        x = x,
        y = y,
        w = w,
        h = h,
        color = color or { 0.3, 0.3, 0.3 },
        texture = texture
    }
    
    table.insert(Platform.list, platform)
    return platform
end

function Platform.draw()
    for _, platform in ipairs(Platform.list) do
        if platform.texture then
            love.graphics.setColor(1, 1, 1)
            
            platform.texture:setWrap("repeat", "repeat")
            
            local texW = platform.texture:getWidth()
            local texH = platform.texture:getHeight()
            
            for px = 0, platform.w - 1, texW do
                for py = 0, platform.h - 1, texH do
                    local drawW = math.min(texW, platform.w - px)
                    local drawH = math.min(texH, platform.h - py)
                    
                    local quad = love.graphics.newQuad(0, 0, drawW, drawH, texW, texH)
                    love.graphics.draw(platform.texture, quad, platform.x + px, platform.y + py)
                end
            end
        else
            love.graphics.setColor(platform.color)
            love.graphics.rectangle("fill", platform.x, platform.y, platform.w, platform.h)
        end
        
        love.graphics.setColor(1, 1, 1)
    end
end

function Platform.clear()
    Platform.list = {}
end

return Platform