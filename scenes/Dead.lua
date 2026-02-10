local Dead = {}

require("GLOBALS")

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Text = require("engine.Interface.text")

local Save = require("engine.Save")

local DeathText
local RestartKeyText

Dead.recentlyJoined = false

function Dead.load()
    DeathText = Text:new(1024/2.5, 768/2, "assets/fonts/PressStart2P-Regular.ttf", 48, "You Died", {0,0,0}, 2.4, {1,1,1})
    RestartKeyText = Text:new(1024/2.8, 768/1.5, "assets/fonts/PressStart2P-Regular.ttf", 24, "Press R to Restart", {0,0,0}, 2.4, {1,1,1})
end

function Dead.update(dt)
    if Input.wasPressed("r") then
        Scene.change(OLD_SCENE)
    end
end

function Dead.draw()
    DeathText:draw()
    RestartKeyText:draw()
end

return Dead