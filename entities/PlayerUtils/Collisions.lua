local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Components = require("engine.EntitySystem.Components")

local AllImages = {
    Spacebar = love.graphics.newImage("assets/images/spacebar.png")
}

local collisions = {
    ["JoinParkour"] = {
        jumpable = false,

        run = function(player)
            if Input.wasPressed("space") then
                Scene.change("Parkour", true)
            end
        end,

        draw = function(player, currentCollision)
            if currentCollision ~= "JoinParkour" then return end

            local pos = Components.Position[player]

            love.graphics.setColor(1, 1, 1, 1)
            -- love.graphics.print("Pressione ESPAÇO para entrar no Parkour!", pos.x - 80, pos.y - 50)
            love.graphics.draw(
                AllImages.Spacebar,
                pos.x - 16,
                pos.y - 48,
                0,
                .1,
                .1
            )
        end
    }
}

return collisions