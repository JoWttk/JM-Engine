local Parkour = {}

local Player = require("entities.Player")
local Platform = require("entities.Platform")
local Enemy = require("entities.Enemy")

local Save = require("engine.Save")

local Camera

Parkour.recentlyJoined = false

Parkour.PlayerX = 100
Parkour.PlayerY = 100

local MapEnemies = {}

function Parkour.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    if Save.read("player.txt") then
        local data = Save.read("player.txt")
        local recentlyJoined = data.recentlyJoined
        Parkour.recentlyJoined = recentlyJoined
    end

    Platform.clear()
    -- Clear existing enemies to avoid duplicates when reloading the scene
    Enemy.clear()
    MapEnemies = {}
    
    Platform.new(0, 550, 800, 32, nil, love.graphics.newImage("assets/entities/platformsTextures/tile1.png"))
    
    Platform.new(150, 450, 100, 20, {0.8, 0.4, 0.2})
    Platform.new(350, 350, 120, 20, {0.8, 0.4, 0.2})
    Platform.new(50, 250, 80, 20, {0.8, 0.4, 0.2})
    Platform.new(500, 400, 140, 20, {0.8, 0.4, 0.2})
    
    Platform.new(650, 300, 30, 250, {0.5, 0.5, 0.8})

    MapEnemies[#MapEnemies + 1] = Enemy:new("stomper", 400, 500, { patrolDist = 200, speed = 120 })

    for i, enemy in ipairs(MapEnemies) do
        enemy.onDied:connect(function()
            print("ng i died " .. enemy.name)
        end)
    end
    
    Player.load()
    Player.setMap("Tutorial")

    Camera = Player.getCamera()
    Camera.smoothness = 6
    Camera.scale = 1.8

    if not Parkour.recentlyJoined then
        Player.moveTo(100, 100)
    end
    
    Parkour.recentlyJoined = true
end

function Parkour.update(dt)
    local Components = require("engine.EntitySystem.Components")
    local entity = Player.getEntity()
    local pos = Components.Position[entity]
    local col = Components.Collider[entity]
    local vel = Components.Velocity[entity]

    local prevY = pos.y

    Player.update(dt)

    local playerProxy = {
        x      = pos.x,
        y      = pos.y,
        width  = col.w,
        height = col.h,
        vy     = vel.y,
        lastY  = prevY,  
        takeDamage = function(_, amount)
            Player.takeDamage(amount)
        end,
        bounceJump = function(_)
            vel.y = -400
        end,
    }

    Enemy.updateAll(dt, playerProxy)
end

function Parkour.draw()
    if Camera then
        Camera.set()
    end
    
    Platform.draw()
    Enemy.drawAll()
    Player.draw()
    
    if Camera then
        Camera.unset()
    end
end

return Parkour