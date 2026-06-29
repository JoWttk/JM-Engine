local Camera = {}

Camera.x = 0
Camera.y = 0
Camera.targetX = 0
Camera.targetY = 0
Camera.smoothness = 5
Camera.scale = 1.25 
Camera.rotation = 0

Camera.bounds = {
    enabled = false,
    minX = 0,
    minY = 0,
    maxX = 0,
    maxY = 0
}

Camera.deadzone = {
    enabled = false,
    width = 100,
    height = 100
}

function Camera.load()
    local w, h = love.graphics.getDimensions()
    Camera.x = 0
    Camera.y = 0
    Camera.width = w
    Camera.height = h
end

function Camera.update(dt)
    local lerp = math.min(1, Camera.smoothness * dt)
    
    Camera.x = Camera.x + (Camera.targetX - Camera.x) * lerp
    Camera.y = Camera.y + (Camera.targetY - Camera.y) * lerp
    
    if Camera.bounds.enabled then
        Camera.x = math.max(Camera.bounds.minX, math.min(Camera.x, Camera.bounds.maxX))
        Camera.y = math.max(Camera.bounds.minY, math.min(Camera.y, Camera.bounds.maxY))
    end
end

function Camera.follow(x, y)
    local w, h = love.graphics.getDimensions()
    
    if Camera.deadzone.enabled then
        local centerX = Camera.x + w / (2 * Camera.scale)
        local centerY = Camera.y + h / (1.7 * Camera.scale)
        
        local dx = x - centerX
        local dy = y - centerY
        
        if math.abs(dx) > Camera.deadzone.width / 2 then
            Camera.targetX = x - w / (2 * Camera.scale)
        end
        
        if math.abs(dy) > Camera.deadzone.height / 2 then
            Camera.targetY = y - h / (2 * Camera.scale)
        end
    else
        Camera.targetX = x - w / (2 * Camera.scale)
        Camera.targetY = y - h / (1.7 * Camera.scale)
    end
end

function Camera.set()
    love.graphics.push()
    love.graphics.scale(Camera.scale, Camera.scale)
    love.graphics.rotate(Camera.rotation)
    love.graphics.translate(-Camera.x, -Camera.y)
end

function Camera.unset()
    love.graphics.pop()
end

function Camera.setBounds(minX, minY, maxX, maxY)
    Camera.bounds.enabled = true
    Camera.bounds.minX = minX
    Camera.bounds.minY = minY
    Camera.bounds.maxX = maxX - love.graphics.getWidth()
    Camera.bounds.maxY = maxY - love.graphics.getHeight()
end

function Camera.removeBounds()
    Camera.bounds.enabled = false
end

function Camera.setDeadzone(width, height)
    Camera.deadzone.enabled = true
    Camera.deadzone.width = width
    Camera.deadzone.height = height
end

function Camera.removeDeadzone()
    Camera.deadzone.enabled = false
end

Camera.shake = {
    duration = 0,
    intensity = 0
}

function Camera.startShake(duration, intensity)
    Camera.shake.duration = duration
    Camera.shake.intensity = intensity
end

function Camera.updateShake(dt)
    if Camera.shake.duration > 0 then
        Camera.shake.duration = Camera.shake.duration - dt
        
        local shakeX = (math.random() - 0.5) * 2 * Camera.shake.intensity
        local shakeY = (math.random() - 0.5) * 2 * Camera.shake.intensity
        
        Camera.x = Camera.x + shakeX
        Camera.y = Camera.y + shakeY
    end
end

function Camera.toWorld(x, y)
    return x + Camera.x, y + Camera.y
end

function Camera.toScreen(x, y)
    return x - Camera.x, y - Camera.y
end

return Camera