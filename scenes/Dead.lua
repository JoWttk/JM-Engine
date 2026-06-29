local Dead = {}

require("GLOBALS")

local Input = require("engine.Input")
local Text = require("engine.Interface.text")
local Player=  require("entities.Player")

local Save = require("engine.Save")

local DeathText

Dead.recentlyJoined = false

function Dead.load()
    local T = CurrentLanguageModule and CurrentLanguageModule.Dead or nil
    DeathText = Text:new(BASE_WIDTH/2.5, BASE_HEIGHT/2, "assets/fonts/PressStart2P-Regular.ttf", 48, (T and T[1]) or "You Died", {0,0,0}, 2.4, {1,1,1})
end

function Dead.update(dt)
    if Input.wasPressed("r") then
        Player.respawn(100, 100)
    end
end

function Dead.draw()
    DeathText:draw()
end

return Dead