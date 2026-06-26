local Settings = {
    Language = "pt-br", -- en, pt-br
    Controller = "keyboard", -- keyboard, gamepad
    Volume = 100, -- 0 to 100
    Difficulty = "normal" -- easy, normal, hard
}

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local task = require("engine.Utils.task")
local Save = require("engine.Save")
local Text = require("engine.Interface.text")
local Languages = {
    en = require("translation.en"),
    ["pt-br"] = require("translation.pt-br")
}

local changeLanguage = require("translation.change")

local ST

local ChangeLanguageButton
local ChangeControllerButton
local ChangeVolumeButton
local ChangeDifficultyButton

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
        Settings.Difficulty = data.Difficulty or "normal"
    end
    local T = Languages[Settings.Language] or Languages["pt-br"]
    ST = Text:new(1024/2 - 120, 30, "assets/fonts/PressStart2P-Regular.ttf", 28, T.Settings[1], {1,1,1}, 2, {0.2, 0.6, 0.8})

    ChangeLanguageButton = Button:new(
        1024/2-150, 768/2 - 200, 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[2] .. Settings.Language:upper(),
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 15,
        2, {1,1,1},
        function()
            if Settings.Language == "en" then
                Settings.Language = "pt-br"
            else
                Settings.Language = "en"
            end

            Settings.save()

            if ChangeLanguage then ChangeLanguage:fire(Settings.Language) end
            local newT = Languages[Settings.Language] or Languages["pt-br"]
            
            ChangeLanguageButton:setText(newT.Settings[2] .. Settings.Language:upper())
            ChangeControllerButton:setText(newT.Settings[3] .. Settings.Controller)
            ChangeVolumeButton:setText(newT.Settings[4] .. Settings.Volume)
            ChangeDifficultyButton:setText(newT.Settings[5] .. Settings.Difficulty)
            BackButton:setText(newT.Settings[6])

            ST:setText(newT.Settings[1])
        end
    )

    ChangeControllerButton = Button:new(
        1024/2-150, 768/2 - 130, 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[3] .. Settings.Controller,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 14,
        2, {1,1,1},
        function()
            if not love.joystick.getJoysticks()[1] then
                ChangeControllerButton:setText("(No Gamepad Detected)")
                
                task.delay(1.5, function()
                    ChangeControllerButton:setText("Controller: "..Settings.Controller)
                end)

                return
            end

            if Settings.Controller == "keyboard" then

            else

            end
        end
    )

    ChangeVolumeButton = Button:new(
        1024/2-150, 768/2 - (130 - 70), 300, 50,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[4] .. Settings.Volume,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 14,
        2, {1,1,1},
        function()
            if Settings.Volume == 100 then
                Settings.Volume = 0
            else
                Settings.Volume = math.min(100, Settings.Volume + 10)
            end
            ChangeVolumeButton:setText((Languages[Settings.Language] or Languages["pt-br"]).Settings[4] .. Settings.Volume)
            Settings.save()
        end
    )

    ChangeDifficultyButton = Button:new(
        1024/2-150, 768/2 - (130 - 140), 300, 50,
        {0.2, 0.6, 0.8}, "Difficulty: Normal",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 14,
        2, {1,1,1},
        function()
            if Settings.Difficulty == "easy" then
                Settings.Difficulty = "normal"
            elseif Settings.Difficulty == "normal" then
                Settings.Difficulty = "hard"
            else
                Settings.Difficulty = "easy"
            end
            ChangeDifficultyButton:setText((Languages[Settings.Language] or Languages["pt-br"]).Settings[5] .. Settings.Difficulty)
            Settings.save()
        end
    )

    BackButton = Button:new(
        1024/2-125, 768/1.2, 250, 50,
        {0.2, 0.6, 0.8}, "Back",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 24,
        2, {1,1,1},
        function()
            Settings.save()
            Scene.change("Menu")
        end
    )

    table.insert(buttons, ChangeLanguageButton)
    table.insert(buttons, ChangeControllerButton)
    table.insert(buttons, ChangeVolumeButton)
    table.insert(buttons, ChangeDifficultyButton)
    table.insert(buttons, BackButton)

    for _, b in ipairs({ChangeLanguageButton, ChangeControllerButton, ChangeVolumeButton, ChangeDifficultyButton, BackButton}) do
        if b and b.centerHorizontally then b:centerHorizontally(1024/2) end
    end
    
    if ST and ST.centerAt then ST:centerAt(1024/2) end

    if ChangeLanguage then
        ChangeLanguage:connect(function(newLang)
            local T = Languages[newLang] or Languages["pt-br"]
            
            ChangeLanguageButton:setText(T.Settings[2] .. (newLang:upper()))
            ChangeControllerButton:setText(T.Settings[3] .. Settings.Controller)
            ChangeVolumeButton:setText(T.Settings[4] .. Settings.Volume)
            ChangeDifficultyButton:setText(T.Settings[5] .. Settings.Difficulty)

            BackButton:setText(T.Settings[6])
            ST:setText(T.Settings[1])

            for _, b in ipairs({ChangeLanguageButton, ChangeControllerButton, ChangeVolumeButton, ChangeDifficultyButton, BackButton}) do
                if b and b.centerHorizontally then b:centerHorizontally(1024/2) end
            end
            if ST and ST.centerAt then ST:centerAt(1024/2) end
        end)
    end
end

function Settings.save()
    Save.write("settings.txt", {
        Language = Settings.Language,
        Controller = Settings.Controller,
        Volume = Settings.Volume,
        Difficulty = Settings.Difficulty
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