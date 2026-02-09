local Menu = {}

require("GLOBALS")
local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local Text = require("engine.Interface.text")

local ChangeLanguage = require("engine.Events.ChangedLanguage").ChangeLanguage

local GameNameText
local PlayButton

function Menu.load()
    PlayButton = Button:new(
        1024/2-100, 768/2, 200, 50,
        {0.2, 0.6, 0.8}, "Play",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 24,
        2, {1,1,1},
        function()
            Scene.change("Tutorial")
        end
    )

    GameNameText = Text:new(1024/4.7, 768/4, "assets/fonts/PressStart2P-Regular.ttf", 48, "JM Engine Demo", {0,0,0}, 2.4, {1,1,1})
end

function Menu.update(dt)
    local mouseX, mouseY = Input.getMousePosition()

    PlayButton:update(mouseX, mouseY, Input.wasMousePressed(1))

    if Input.wasPressed("g") then
        ChangeLanguage("en")
    end
end

function Menu.draw()
    PlayButton:draw()
    GameNameText:draw()
end

return Menu