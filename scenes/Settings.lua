local Settings = {
    Language = "en", -- en, pt
    Controller = "Keyboard", -- keyboard, gamepad
    Volume = 100, -- 0 to 100
    VSync = "ON" -- on, off
}

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local task = require("engine.Utils.task")
local Save = require("engine.Save")
local Text = require("engine.Interface.text")
local Languages = {
    en = require("translation.en"),
    pt = require("translation.pt")
}

local changeLanguage = require("translation.change")

local ST

local ChangeLanguageButton
local ChangeControllerButton
local ChangeVolumeButton
local VSyncButton

local BackButton

local buttons ={}

function Make(key, value)
    Settings[key] = value
end

function Settings.load()
    if Save.read("settings.txt") then
        local data = Save.read("settings.txt")
        Settings.Language = data.Language or "en"
        Settings.Controller = data.Controller or "keyboard"
        Settings.Volume = data.Volume or 100
        Settings.VSync = data.VSync or "ON"
    end
    local T = Languages[Settings.Language] or Languages["pt"]
    ST = Text:new(BASE_WIDTH/2 - 120, 30, "assets/fonts/PressStart2P-Regular.ttf", 28, T.Settings[1], {1,1,1}, 2, {0.2, 0.6, 0.8})

    ChangeLanguageButton = Button:new(
        BASE_WIDTH/2-150, BASE_HEIGHT/2 - 200, 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[2] .. Settings.Language:upper(),
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 15,
        2, {1,1,1},
        function()
            if Settings.Language == "en" then
                Settings.Language = "pt"
            else
                Settings.Language = "en"
            end

            Settings.save()

            if ChangeLanguage then ChangeLanguage:fire(Settings.Language) end
            local newT = Languages[Settings.Language] or Languages["pt"]
            
            ChangeLanguageButton:setText(newT.Settings[2] .. Settings.Language:upper())
            ChangeControllerButton:setText(newT.Settings[3] .. Settings.Controller)
            ChangeVolumeButton:setText(newT.Settings[4] .. Settings.Volume)
            VSyncButton:setText(newT.Settings[5] .. Settings.VSync)
            BackButton:setText(newT.Settings[6])

            ST:setText(newT.Settings[1])
        end,
        "scale"
    )

    ChangeControllerButton = Button:new(
        BASE_WIDTH/2-150, BASE_HEIGHT/2 - 130, 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[3] .. Settings.Controller,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 14,
        2, {1,1,1},
        function()
            if not love.joystick.getJoysticks()[1] then
                ChangeControllerButton:setText(CurrentLanguageModule.Settings.ControlTypes[3])
                
                task.delay(1.5, function()
                    ChangeControllerButton:setText(CurrentLanguageModule.Settings[3] .. CurrentLanguageModule.Settings.ControlTypes[1])
                end)

                return
            end

            if Settings.Controller == "Keyboard" then
                -- use joystick
                ChangeControllerButton:setText(CurrentLanguageModule.Settings[3] .. CurrentLanguageModule.Settings.ControlTypes[2])
            else
                -- use keyboard
                ChangeControllerButton:setText(CurrentLanguageModule.Settings[3] .. CurrentLanguageModule.Settings.ControlTypes[1])
            end
        end,
        "scale"
    )

    ChangeVolumeButton = Button:new(
        BASE_WIDTH/2-150, BASE_HEIGHT/2 - (130 - 70), 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[4] .. Settings.Volume,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 14,
        2, {1,1,1},
        function()
            if Settings.Volume == 100 then
                Settings.Volume = 0
            else
                Settings.Volume = math.min(100, Settings.Volume + 10)
            end
            ChangeVolumeButton:setText((Languages[Settings.Language] or Languages["pt"]).Settings[4] .. Settings.Volume)
            Settings.save()
        end,
        "scale"
    )

    VSyncButton = Button:new(
        BASE_WIDTH/2-150, BASE_HEIGHT/2 - (130 - 140), 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[5] .. Settings.VSync ,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 14,
        2, {1,1,1},
        function()
            if Settings.VSync == "ON" then
                Settings.VSync = "OFF"
                love.window.setVSync(false)
            else
                Settings.VSync = "ON"
                love.window.setVSync(true)
            end

            VSyncButton:setText((Languages[Settings.Language] or Languages["pt"]).Settings[5] .. Settings.VSync)
            Settings.save()
        end,
        "scale"
    )

    BackButton = Button:new(
        BASE_WIDTH/2-125, BASE_HEIGHT/1.2, 250, 50,
        {0.2, 0.6, 0.8}, "Back",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 24,
        2, {1,1,1},
        function()
            Settings.save()
            Scene.change("Menu")
        end,
        "shake"
    )

    table.insert(buttons, ChangeLanguageButton)
    table.insert(buttons, ChangeControllerButton)
    table.insert(buttons, ChangeVolumeButton)
    table.insert(buttons, VSyncButton)
    table.insert(buttons, BackButton)

    for _, b in ipairs({ChangeLanguageButton, ChangeControllerButton, ChangeVolumeButton, VSyncButton, BackButton}) do
        if b and b.centerHorizontally then b:centerHorizontally(BASE_WIDTH/2) end
    end
    
    if ST and ST.centerAt then ST:centerAt(BASE_WIDTH/2) end

    if ChangeLanguage then
        ChangeLanguage:connect(function(newLang)
            local T = Languages[newLang] or Languages["pt"]
            
            ChangeLanguageButton:setText(T.Settings[2] .. (newLang:upper()))
            ChangeControllerButton:setText(T.Settings[3] .. Settings.Controller)
            ChangeVolumeButton:setText(T.Settings[4] .. Settings.Volume)
            VSyncButton:setText(T.Settings[5] .. Settings.VSync)

            BackButton:setText(T.Settings[6])
            ST:setText(T.Settings[1])

            for _, b in ipairs({ChangeLanguageButton, ChangeControllerButton, ChangeVolumeButton, VSyncButton, BackButton}) do
                if b and b.centerHorizontally then b:centerHorizontally(BASE_WIDTH/2) end
            end
            if ST and ST.centerAt then ST:centerAt(BASE_WIDTH/2) end
        end)
    end
end

function Settings.save()
    Save.write("settings.txt", {
        Language = Settings.Language,
        Controller = Settings.Controller,
        Volume = Settings.Volume,
        VSync = Settings.VSync
    })
end

function Settings.update(dt)
    task.step(dt)
    local mouseX, mouseY = Input.getCanvasMousePosition()

    for _, button in ipairs(buttons) do
        button:update(mouseX, mouseY, Input.wasMousePressed(1))
    end
end

function Settings.draw()
    for _, button in ipairs(buttons) do
        button:draw()
    end
    ST:draw()
end

return Settings