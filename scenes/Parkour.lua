local Parkour = {}

local Player = require("entities.Player")
local Platform = require("entities.Platform")
local Save = require("engine.Save")
local Camera

Parkour.recentlyJoined = false

function Parkour.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    if Save.read("player.txt") then
        local data = Save.read("player.txt")
        local recentlyJoined = data.recentlyJoined
        Parkour.recentlyJoined = recentlyJoined
    end

    Platform.clear()
    
    Platform.new(0, 550, 800, 32, nil, love.graphics.newImage("assets/entities/platformsTextures/tile1.png"))
    
    Platform.new(150, 450, 100, 20, {0.8, 0.4, 0.2})
    Platform.new(350, 350, 120, 20, {0.8, 0.4, 0.2})
    Platform.new(50, 250, 80, 20, {0.8, 0.4, 0.2})
    Platform.new(500, 400, 140, 20, {0.8, 0.4, 0.2})
    
    Platform.new(650, 300, 30, 250, {0.5, 0.5, 0.8})
    
    Player.load()
    Camera = Player.getCamera()
    Camera.smoothness = 6
    Camera.scale = 1.8

    if not Parkour.recentlyJoined then
        Player.moveTo(100, 100)
    end
    
    Parkour.recentlyJoined = true
end

function Parkour.update(dt)
    Player.update(dt)
end

function Parkour.draw()
    if Camera then
        Camera.set()
    end
    
    Platform.draw()
    Player.draw()
    
    if Camera then
        Camera.unset()
    end
end

return Parkour