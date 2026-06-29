local Tutorial = {}

local Player = require("entities.Player")
local Platform = require("entities.Platform")

local Image = require("engine.EntitySystem.Image")
local Enemy = require("entities.Enemy")

local simpleD = require("engine.DialogTypes.SimpleDialogue")
local Window = require("engine.Interface.window")

local Save = require("engine.Save")
local Text = require("engine.Interface.text")

local Collisions = require("entities.PlayerUtils.Collisions")

local Camera
local Background
local Tile1
local Tile2

local MapEnemies = {}

Tutorial.recentlyJoined = false
Tutorial.alreadyJoined = false

Tutorial.PlayerX = 100
Tutorial.PlayerY = 285

function Tutorial.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    if Save.read("player.txt") then
        local data = Save.read("player.txt")
        local recentlyJoined = data.recentlyJoined
        print("Recently Joined:", recentlyJoined)

        Tutorial.recentlyJoined = recentlyJoined
    end

    Tile1 = love.graphics.newImage("assets/entities/platformsTextures/tile1.png")
    Tile2 = love.graphics.newImage("assets/entities/platformsTextures/tile2.png")

    Background = love.graphics.newImage("assets/background/test.png")

    Platform.clear()
    Enemy.clear()
    Image.clear()

    MapEnemies = {}
    
    -- GROUND
    Platform.new(0, 550, 800, 32, nil, Tile1)
    Platform.new(0, 580, 800, 300, nil, Tile2)

    Platform.new(900, 550, 600, 32, nil, Tile1)
    Platform.new(900, 580, 600, 300, nil, Tile2)

    Platform.new(1650, 450, 321, 32, nil, Tile1)
    Platform.new(1650, 480, 321, 300, nil, Tile2)

    -- DIALOGUE
    Platform.new(1000, 200, 30, 500, nil, nil, "StomperExplain", false, 0, false)

    -- SPAWN 
    Platform.new(100, 400, 100, 20, {0.8, 0.4, 0.2})

    -- FLAG
    Platform.new(1860, 400, 64, 128, {0.8, 0.4, 0.2}, nil, "JoinParkour", false, 0, false) -- FLAG COLLISION
    Image.new("assets/images/utils/flag.png", 1860, 355, 32, 32, .75)

    -- ENEMIES
    MapEnemies[#MapEnemies + 1] = Enemy:new("stomper", 1370 - 46, 515, { patrolDist = 100, speed = 70 })
    MapEnemies[#MapEnemies + 1] = Enemy:new("stomper", 1380 - 16, 515, { patrolDist = 100, speed = 70 })
        
    Player.load()
    Player.setMap("Tutorial")
    
    Camera = Player.getCamera()
    
    Camera.smoothness = 6
    Camera.scale = CAMERA_SCALE

    if not Tutorial.recentlyJoined then
        Player.moveTo(Tutorial.PlayerX, Tutorial.PlayerY)
    end

    if not Tutorial.alreadyJoined then
        simpleD.config({
            x = 300,
            y = 15,
            width = 400
            })

        simpleD.showSequence(
            CurrentLanguageModule.Tutorial
        )
    end

    Tutorial.recentlyJoined = true
    Tutorial.alreadyJoined = true
    -- Camera.setBounds(0, 0, 1600, 1200) -- Descomente e ajuste se quiser limite
end

function Tutorial.update(dt)
    local Components = require("engine.EntitySystem.Components")
    local entity = Player.getEntity()
    local pos = Components.Position[entity]
    local col = Components.Collider[entity]
    local vel = Components.Velocity[entity]

    local prevY = pos.y

    simpleD.update(dt)
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

function Tutorial.draw()
    love.graphics.draw(Background, 0, -200)

    if Camera then
        Camera.set()
    end
    
    Image.draw()
    Platform.draw()

    Enemy.drawAll()

    love.graphics.draw(love.graphics.newImage("assets/images/space-indicator.png"), 785, 360, 0, .25)
    Player.draw()

    if Camera then
        Camera.unset()
    end

    Text:new(
        BASE_WIDTH - (BASE_WIDTH / 1.02),
        BASE_HEIGHT - (BASE_HEIGHT / 12),
        "assets/fonts/PressStart2P-Regular.ttf",
        12,
        "Press ESC to SKIP TUTORIAL",
        {1,1,1},
        2,
        {0,0,0}
    ):draw()

    simpleD.draw()
end

function Tutorial.keypressed(key)
    if key == "escape" then
        Collisions["JoinParkour"].run(Player, true)
    end
end

return Tutorial