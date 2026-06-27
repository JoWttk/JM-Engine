require("GLOBALS")

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Components = require("engine.EntitySystem.Components")
local RichText = require("engine.Interface.RichText")

local SimpleD = require("engine.DialogTypes.SimpleDialogue")
local Window = require("engine.Interface.window")

local AllImages = {
    Spacebar = icons.SPACE
}

local currentShowingWindow = nil

local collisions = {
    ["JoinParkour"] = {
        jumpable = false,

        load = function(player)
            Window.config({
                offsetX = 25,
                offsetY = -50,
                maxWidth = 300
            })
        end,

        run = function(player)
            if Input.wasPressed("space") then
                Scene.change("Parkour", true)
            end
        end,

        update = function(dt)
            Window.update(dt)
        end,

        draw = function(player, currentCollision)
            if currentCollision ~= "JoinParkour" then 
                if currentShowingWindow == "JoinParkour" then
                    Window.close()
                    currentShowingWindow = nil
                end

                return 
            end

            if currentShowingWindow ~= "JoinParkour" then
                Window.show("Press {SPACE} to join parkour!")
                currentShowingWindow = "JoinParkour"
            end
            Window.draw()
        end
    },
    ["StomperExplain"] = {
        jumpable = false,

        load = function(player)
            SimpleD.config({
                x = 300,
                y = love.graphics.getHeight() - 180,
                width = 400
            })
        end,

        draw = function(player, currentCollision)
            if currentCollision ~= "StomperExplain" then
                if currentShowingWindow == "StomperExplain" then
                    SimpleD.close()
                    currentShowingWindow = nil
                end
                
                return
            end

            if currentShowingWindow ~= "StomperExplain" then
                SimpleD.showSequence(CurrentLanguageModule.Tutorial.StomperExplain)
                currentShowingWindow = "StomperExplain"
            end
        end
    }
}

return collisions