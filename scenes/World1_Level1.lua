local Level = {}

Level.World = 1
Level.Level = 1

local Player = require("entities.Player")
local Platform = require("entities.Platform")
local Enemy = require("entities.Enemy")
local PowerUps = require("entities.PowerUps")

local Save = require("engine.Save")

local Camera
local Textures
local Background

Level.recentlyJoined = false

Level.PlayerX = 100
Level.PlayerY = 100

local MapEnemies = {}

function Level.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    if Save.read("player.txt") then
        local data = Save.read("player.txt")
        local recentlyJoined = data.recentlyJoined
        Level.recentlyJoined = recentlyJoined
    end

    Textures = {

    }
    
    Background = love.graphics.newImage("assets/background/World1.png")

    Platform.clear()
    Enemy.clear()
    MapEnemies = {}
    
    Platform.new(0, 550, 800, 32, nil, love.graphics.newImage("assets/entities/textures/tile1.png"))
    
    Platform.new(150, 450, 100, 20, {0.8, 0.4, 0.2})
    Platform.new(350, 350, 120, 20, {0.8, 0.4, 0.2})
    Platform.new(50, 250, 80, 20, {0.8, 0.4, 0.2})
    Platform.new(500, 400, 140, 20, {0.8, 0.4, 0.2}, nil, nil, true, 1, true, true, "bottom", function(p)
        PowerUps.spawnRandom((p.x + p.w / 2) + 28, p.y)
    end)
    
    Platform.new(650, 300, 30, 250, {0.5, 0.5, 0.8})

    Platform.new(1860, 400, 64, 128, {0.8, 0.4, 0.2}, nil, "ExitW1L1", false, 0, false)

    MapEnemies[#MapEnemies + 1] = Enemy:new("stomper", 400, 500, { patrolDist = 200, speed = 120 })
    
    Player.load()
    Player.setMap("Tutorial")

    Camera = Player.getCamera()
    Camera.smoothness = 5
    Camera.scale = CAMERA_SCALE

    if not Level.recentlyJoined then
        Player.moveTo(100, 100)
    end
    
    Level.recentlyJoined = true
end

function Level.update(dt)
    local Components = require("engine.EntitySystem.Components")
    local entity = Player.getEntity()
    local pos = Components.Position[entity]
    local col = Components.Collider[entity]
    local vel = Components.Velocity[entity]

    local prevY = pos.y

    Player.update(dt)

    local playerProxy = {
        x = pos.x,
        y = pos.y,
        width = col.w,
        height = col.h,
        vy = vel.y,
        lastY = prevY,
        baseSpeed = Player.baseSpeed,
        speed = Player.speed,
        jumpBoost = Player.jumpBoost or 1,
        invincible = Player.invincible or false,
        takeDamage = function(_, amount)
            Player.takeDamage(amount)
        end,
        bounceJump = function(_)
            vel.y = -400
        end,
    }

    Enemy.updateAll(dt, playerProxy)
    PowerUps.update(dt, playerProxy)

    Player.speed = playerProxy.speed
    Player.jumpBoost = playerProxy.jumpBoost
    Player.invincible = playerProxy.invincible
end

function Level.draw()
    love.graphics.draw(Background, -300, -400)

    if Camera then
        Camera.set()
    end
    
    Platform.draw()
    Enemy.drawAll()
    PowerUps.draw()
    Player.draw()
    
    if Camera then
        Camera.unset()
    end
end

return Level