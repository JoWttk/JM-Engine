local Menu = {}

require("GLOBALS")
local Scene = require("engine.Scene")
local Input = require("engine.Input")

local ChangeLanguage = require("engine.Events.ChangedLanguage").ChangeLanguage

function Menu.load()
    
end

function Menu.update(dt)
    if Input.wasPressed("space") then
        CurrentScene="Tutorial"
        Scene.change(CurrentScene)
    end

    if Input.wasPressed("g") then
        ChangeLanguage("en")
    end
end

function Menu.draw()
    love.graphics.setNewFont("assets/fonts/PressStart2P-Regular.ttf",12)
    love.graphics.print(CurrentLanguageModule.Menu[1], 1024/2-160, 768/2)
end

return Menu