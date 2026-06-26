require("GLOBALS")

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Components = require("engine.EntitySystem.Components")
local RichText = require("engine.Interface.RichText")
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
                offsetX = player.getX() / 3,
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

            -- if icons.SPACE then print("JJ") end
        end
    }
}

return collisions