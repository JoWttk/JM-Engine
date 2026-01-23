local Platform = {}
local Entity = require("engine.EntitySystem.Entity")
local Components = require("engine.EntitySystem.Components")

Platform.list = {}

function Platform.new(x, y, w, h, color)
    local platform = {
        x = x,
        y = y,
        w = w,
        h = h,
        color = color or { 0.3, 0.3, 0.3 }
    }
    
    table.insert(Platform.list, platform)
    return platform
end

function Platform.draw()
    for _, platform in ipairs(Platform.list) do
        love.graphics.setColor(platform.color)
        love.graphics.rectangle("fill", platform.x, platform.y, platform.w, platform.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", platform.x, platform.y, platform.w, platform.h)
    end
end

function Platform.clear()
    Platform.list = {}
end

return Platform