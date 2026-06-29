require("GLOBALS")

local Scene = require("engine.Scene")
local Input = require("engine.Input")

local SimpleD = require("engine.DialogTypes.SimpleDialogue")
local Window = require("engine.Interface.window")

local collisions = {
    ["JoinParkour"] = {
        jumpable = false,

        load = function(Player)
            if Window.isActive() then return end 
            Window.config({
                offsetX = 25,
                offsetY = -50,
                maxWidth = 300
            })

            Window.show("Press {SPACE} to join parkour!")
        end,

        run = function(Player, skipped)
            if not skipped then skipped = false end

            local function leave()
                Scene.change("Parkour", true, function()
                    Window.close()
                end)
            end
            
            if skipped then
                leave()
                return
            end

            if Input.wasPressed("space") then
                leave()
            end
        end,

        update = function(dt)
            Window.update(dt)
        end,

        draw = function()
            Window.draw()
        end
    },

    ["StomperExplain"] = {
        jumpable = false,

        load = function(Player)
            SimpleD.config({
                x = 300,
                y = love.graphics.getHeight() - 180,
                width = 400
            })
            SimpleD.showSequence(CurrentLanguageModule.Tutorial.StomperExplain)
        end,

        unload = function(Player)
            SimpleD.close()
        end,
    }
}

return collisions