local Menu = {}

require("GLOBALS")
local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local Save = require("engine.Save")
local Text = require("engine.Interface.text")

require("translation.change")

local GameNameText
local PlayButton
local SettingsButton

Menu.recentlyJoined = false

function Menu.load()
    PlayButton = Button:new(
        1024/2-150, 768/2, 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Menu[1] or "Play",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 21,
        2, {1,1,1},
        function()
            if Save.read("player.txt") then
                local data = Save.read("player.txt")
                Scene.change(data.scene)
            else
                Scene.change("UserCreator")
            end
        end
    )

    SettingsButton = Button:new(
        1024/2-150, 768/2 + 70, 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Menu[2] or "Settings",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 18,
        2, {1,1,1},
        function()
            Scene.change("Settings")
        end
    )

    GameNameText = Text:new(1024/4.7, 768/4, "assets/fonts/PressStart2P-Regular.ttf", 48, "JM Engine Demo", {0,0,0}, 2.4, {1,1,1})
    if PlayButton.centerHorizontally then PlayButton:centerHorizontally(1024/2) end
    if SettingsButton.centerHorizontally then SettingsButton:centerHorizontally(1024/2) end
    if GameNameText and GameNameText.centerAt then GameNameText:centerAt(1024/2) end
end

if ChangeLanguage then
    ChangeLanguage:connect(function(newLang)
        CurrentLanguageModule = require("translation." .. newLang)
        if PlayButton and PlayButton.setText then
            PlayButton:setText(CurrentLanguageModule.Menu[1])
        end
        if SettingsButton and SettingsButton.setText then
            SettingsButton:setText(CurrentLanguageModule.Menu[2])
        end
        
        if PlayButton and PlayButton.centerHorizontally then PlayButton:centerHorizontally(1024/2) end
        if SettingsButton and SettingsButton.centerHorizontally then SettingsButton:centerHorizontally(1024/2) end
        if GameNameText and GameNameText.centerAt then GameNameText:centerAt(1024/2) end
    end)
end

function Menu.update(dt)
    local mouseX, mouseY = Input.getCanvasMousePosition()

    PlayButton:update(mouseX, mouseY, Input.wasMousePressed(1))
    SettingsButton:update(mouseX, mouseY, Input.wasMousePressed(1))

    -- if Input.wasPressed("g") then
    --     ChangeLanguage("en")
    -- end
end

function Menu.draw()
    PlayButton:draw()
    GameNameText:draw()
    SettingsButton:draw()
end

return Menu