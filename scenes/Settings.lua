local Settings = {
    Language = "en",
    Controller = "Keyboard",
    Volume = 100,
    VSync = "ON",
    Fullscreen = "OFF"
}

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local task = require("engine.Utils.task")
local Save = require("engine.Save")
local Text = require("engine.Interface.text")
local Camera = require("engine.EntitySystem.Camera")
local signal = require("engine.Utils.signal")

Settings.addQuit = signal:new()

local BG = require("scenes.utils.Background")

local Languages = {
    en = require("translation.en"),
    pt = require("translation.pt")
}

local changeLanguage = require("translation.change")

local ST
local LabelGameplay
local LabelGraphics

local ChangeLanguageButton
local ChangeControllerButton
local ChangeVolumeButton

local VSyncButton
local FullscreenButton

local BackButton
local buttons = {}

local COL_LEFT  = BASE_WIDTH / 4      -- centro da coluna esquerda
local COL_RIGHT = BASE_WIDTH * 3 / 4  -- centro da coluna direita
local BTN_W = 260
local BTN_H = 50
local BTN_START_Y = BASE_HEIGHT / 2 - 120
local BTN_GAP = 70

function Make(key, value)
    Settings[key] = value
end

function Settings.load()
    BG.load()
    buttons = {}

    if Save.read("settings.txt") then
        local data = Save.read("settings.txt")
        Settings.Language   = data.Language   or "en"
        Settings.Controller = data.Controller or "Keyboard"
        Settings.Volume     = data.Volume     or 100
        Settings.VSync      = data.VSync      or "ON"
        Settings.Fullscreen = data.Fullscreen or "OFF"
    end

    local T = Languages[Settings.Language] or Languages["pt"]

    -- Título
    ST = Text:new(0, 30, "assets/fonts/PressStart2P-Regular.ttf", 28, T.Settings[1], {1,1,1}, 2, {0.2, 0.6, 0.8})
    if ST.centerAt then ST:centerAt(BASE_WIDTH/2) end

    LabelGameplay = Text:new(0, BTN_START_Y - 50, "assets/fonts/PressStart2P-Regular.ttf", 14, "Gameplay", {0.6, 0.88, 1.0}, 1.5, {0.1, 0.3, 0.5})
    LabelGraphics = Text:new(0, BTN_START_Y - 50, "assets/fonts/PressStart2P-Regular.ttf", 14, "Graphics", {0.6, 0.88, 1.0}, 1.5, {0.1, 0.3, 0.5})
    if LabelGameplay.centerAt then LabelGameplay:centerAt(COL_LEFT) end
    if LabelGraphics.centerAt then LabelGraphics:centerAt(COL_RIGHT) end

    ChangeLanguageButton = Button:new(
        0, BTN_START_Y, BTN_W, BTN_H,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[2] .. Settings.Language:upper(),
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 13,
        2, {1,1,1},
        function()
            Settings.Language = Settings.Language == "en" and "pt" or "en"
            Settings.save()
            if ChangeLanguage then ChangeLanguage:fire(Settings.Language) end
            local newT = Languages[Settings.Language] or Languages["pt"]
            ChangeLanguageButton:setText(newT.Settings[2] .. Settings.Language:upper())
            ChangeControllerButton:setText(newT.Settings[3] .. Settings.Controller)
            ChangeVolumeButton:setText(newT.Settings[4] .. Settings.Volume)
            VSyncButton:setText(newT.Settings[5] .. Settings.VSync)
            BackButton:setText(newT.Settings[6])
            ST:setText(newT.Settings[1])
            if ST.centerAt then ST:centerAt(BASE_WIDTH/2) end
        end,
        "scale"
    )

    ChangeControllerButton = Button:new(
        0, BTN_START_Y + BTN_GAP, BTN_W, BTN_H,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[3] .. Settings.Controller,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 12,
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
                ChangeControllerButton:setText(CurrentLanguageModule.Settings[3] .. CurrentLanguageModule.Settings.ControlTypes[2])
            else
                ChangeControllerButton:setText(CurrentLanguageModule.Settings[3] .. CurrentLanguageModule.Settings.ControlTypes[1])
            end
        end,
        "scale"
    )

    ChangeVolumeButton = Button:new(
        0, BTN_START_Y + BTN_GAP * 2, BTN_W, BTN_H,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[4] .. Settings.Volume,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 12,
        2, {1,1,1},
        function()
            Settings.Volume = Settings.Volume == 100 and 0 or math.min(100, Settings.Volume + 10)
            ChangeVolumeButton:setText((Languages[Settings.Language] or Languages["pt"]).Settings[4] .. Settings.Volume)
            Settings.save()
        end,
        "scale"
    )

    -- Coluna direita: Graphics
    VSyncButton = Button:new(
        0, BTN_START_Y, BTN_W, BTN_H,
        {0.2, 0.6, 0.8}, CurrentLanguageModule.Settings[5] .. Settings.VSync,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 12,
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

    FullscreenButton = Button:new(
        0, BTN_START_Y + BTN_GAP, BTN_W, BTN_H,
        {0.2, 0.6, 0.8}, "Fullscreen: " .. Settings.Fullscreen,
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 12,
        2, {1,1,1},
        function()
            if Settings.Fullscreen == "OFF" then
                Settings.Fullscreen = "ON"
                love.window.setFullscreen(true)
            else
                Settings.Fullscreen = "OFF"
                love.window.setFullscreen(false)
            end

            Camera.onResize()

            FullscreenButton:setText("Fullscreen: " .. Settings.Fullscreen)
            Settings.save()
        end,
        "scale"
    )

    BackButton = Button:new(
        0, BASE_HEIGHT / 1.2, 250, 50,
        {1, 0, 0}, CurrentLanguageModule.Settings[6] or "Back",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 24,
        2, {1,1,1},
        function()
            Settings.save()
            Scene.change(OLD_SCENE)
        end,
        "shake"
    )

    for _, b in ipairs({ChangeLanguageButton, ChangeControllerButton, ChangeVolumeButton}) do
        if b.centerHorizontally then b:centerHorizontally(COL_LEFT) end
    end

    for _, b in ipairs({VSyncButton, FullscreenButton}) do
        if b.centerHorizontally then b:centerHorizontally(COL_RIGHT) end
    end

    if BackButton.centerHorizontally then BackButton:centerHorizontally(BASE_WIDTH/2) end

    table.insert(buttons, ChangeLanguageButton)
    table.insert(buttons, ChangeControllerButton)
    table.insert(buttons, ChangeVolumeButton)
    table.insert(buttons, VSyncButton)
    table.insert(buttons, FullscreenButton)
    table.insert(buttons, BackButton)

    if ChangeLanguage then
        ChangeLanguage:connect(function(newLang)
            local T = Languages[newLang] or Languages["pt"]
            ChangeLanguageButton:setText(T.Settings[2] .. (newLang:upper()))
            ChangeControllerButton:setText(T.Settings[3] .. Settings.Controller)
            ChangeVolumeButton:setText(T.Settings[4] .. Settings.Volume)
            VSyncButton:setText(T.Settings[5] .. Settings.VSync)
            BackButton:setText(T.Settings[6])
            ST:setText(T.Settings[1])
            if ST.centerAt then ST:centerAt(BASE_WIDTH/2) end
        end)
    end
end

function Settings.save()
    Save.write("settings.txt", {
        Language   = Settings.Language,
        Controller = Settings.Controller,
        Volume     = Settings.Volume,
        VSync      = Settings.VSync,
        Fullscreen = Settings.Fullscreen
    })
end

function Settings.update(dt)
    task.step(dt)
    
    local mouseX, mouseY = Input.getCanvasMousePosition()
    for _, button in ipairs(buttons) do
        button:update(mouseX, mouseY, Input.wasMousePressed(1))
    end

    BG.update(dt)
end

local function drawDivider()
    local x = BASE_WIDTH / 2
    local y1 = BTN_START_Y - 60
    local y2 = BTN_START_Y + BTN_GAP * 2 + BTN_H + 10

    love.graphics.setColor(0.4, 0.75, 1.0, 0.25)
    love.graphics.setLineWidth(1)
    love.graphics.line(x, y1, x, y2)
    love.graphics.setLineWidth(1)
end

function Settings.draw()
    BG.draw()
    drawDivider()

    LabelGameplay:draw()
    LabelGraphics:draw()

    for _, button in ipairs(buttons) do
        button:draw()
    end

    ST:draw()
end

Settings.addQuit:connect(function()
    BackButton.width = BackButton.width / 2
    BackButton:updateFont(18)

    local QuitButton = Button:new(
        BackButton.x + (BackButton.width + 15), BackButton.y, BackButton.width, BackButton.height,
        {0.45, 0.15, 0.6}, "Quit",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 18,
        2, {1,1,1},
        function()
            love.event.quit()
        end,
        "shake"
    )
    table.insert(buttons, QuitButton)
end)

return Settings