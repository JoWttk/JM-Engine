local Tutorial = {}
local Player = require("entities.Player")
local Platform = require("entities.Platform")
local simpleD = require("engine.DialogTypes.SimpleDialogue")

local Save = require("engine.Save")

local Camera
local Background

Tutorial.recentlyJoined = false

Tutorial.PlayerX = 100
Tutorial.PlayerY = 100

function Tutorial.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    if Save.read("player.txt") then
        local data = Save.read("player.txt")
        local recentlyJoined = data.recentlyJoined
        print("Recently Joined:", recentlyJoined)

        Tutorial.recentlyJoined = recentlyJoined
    end

    Background = love.graphics.newImage("assets/background/test.png")

    Platform.clear()
    
    Platform.new(0, 550, 800, 32, nil, love.graphics.newImage("assets/entities/platformsTextures/tile1.png"))
    
    Platform.new(200, 450, 150, 20, {0.8, 0.4, 0.2})
    Platform.new(400, 350, 120, 20, {0.8, 0.4, 0.2},nil, "JoinParkour")
    Platform.new(100, 250, 100, 20, {0.8, 0.4, 0.2})
    Platform.new(550, 400, 140, 20, {0.8, 0.4, 0.2})
    
    Platform.new(700, 300, 30, 250, {0.5, 0.5, 0.8})
    
    Player.load()
    Player.setMap("Tutorial")
    
    Camera = Player.getCamera()
    
    Camera.smoothness = 6
    Camera.scale = 1.8

    if not Tutorial.recentlyJoined then
        Player.moveTo(100, 100)

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
    -- Camera.setBounds(0, 0, 1600, 1200) -- Descomente e ajuste se quiser limite
end

function Tutorial.update(dt)
    simpleD.update(dt)
    Player.update(dt)
end

function Tutorial.draw()
    love.graphics.draw(Background, 0, -200)
    
    simpleD.draw()

    if Camera then
        Camera.set()
    end
    
    Platform.draw()
    Player.draw()
    
    if Camera then
        Camera.unset()
    end
end

return Tutorial