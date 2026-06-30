local Menu = {}

require("GLOBALS")
local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local Save = require("engine.Save")
local Text = require("engine.Interface.text")

local BG

require("translation.change")

local GameNameText
local PlayButton
local SettingsButton

local menuAlpha = 0

Menu.recentlyJoined = false

function Menu.load()
    BG = require("scenes.utils.Background")
    BG.load()

    menuAlpha = 0

    PlayButton = Button:new(
        BASE_WIDTH/2 - 160, BASE_HEIGHT/2 + 20, 320, 56,
        {0.18, 0.52, 0.76}, CurrentLanguageModule.Menu[1] or "Play",
        {1, 1, 1}, "assets/fonts/PressStart2P-Regular.ttf", 20,
        2, {0.4, 0.85, 1.0},
        function()
            if Save.read("player.txt") then
                local data = Save.read("player.txt")
                Scene.change(data.scene, true)
            else
                Scene.change("UserCreator", true)
            end
        end,
        "scale"
    )

    SettingsButton = Button:new(
        BASE_WIDTH/2 - 130, BASE_HEIGHT/2 + 96, 260, 48,
        {0.12, 0.34, 0.52}, CurrentLanguageModule.Menu[2] or "Settings",
        {0.75, 0.92, 1.0}, "assets/fonts/PressStart2P-Regular.ttf", 16,
        2, {0.3, 0.6, 0.8},
        function()
            Scene.change("Settings")
        end,
        "scale"
    )

    GameNameText = Text:new(
        BASE_WIDTH/2, BASE_HEIGHT/4 - 10,
        "assets/fonts/PressStart2P-Regular.ttf", 44,
        "Untitled Game",
        {0.85, 0.97, 1.0},
        3.0, {0.1, 0.35, 0.6}
    )

    if PlayButton.centerHorizontally then PlayButton:centerHorizontally(BASE_WIDTH/2) end
    if SettingsButton.centerHorizontally then SettingsButton:centerHorizontally(BASE_WIDTH/2) end
    if GameNameText and GameNameText.centerAt then GameNameText:centerAt(BASE_WIDTH/2) end
end

if ChangeLanguage then
    ChangeLanguage:connect(function(newLang)
        CurrentLanguageModule = require("translation." .. newLang)
        if PlayButton and PlayButton.setText then PlayButton:setText(CurrentLanguageModule.Menu[1]) end
        if SettingsButton and SettingsButton.setText then SettingsButton:setText(CurrentLanguageModule.Menu[2]) end
        if PlayButton and PlayButton.centerHorizontally then PlayButton:centerHorizontally(BASE_WIDTH/2) end
        if SettingsButton and SettingsButton.centerHorizontally then SettingsButton:centerHorizontally(BASE_WIDTH/2) end
        if GameNameText and GameNameText.centerAt then GameNameText:centerAt(BASE_WIDTH/2) end
    end)
end

function Menu.update(dt)
    local mouseX, mouseY = Input.getCanvasMousePosition()
    PlayButton:update(mouseX, mouseY, Input.wasMousePressed(1))
    SettingsButton:update(mouseX, mouseY, Input.wasMousePressed(1))

    menuAlpha = math.min(1, menuAlpha + dt * 1.5)

    BG.update(dt)
end

local function drawDivider(cx, y, halfW)
    love.graphics.setColor(0.4, 0.75, 1.0, 0.35)
    love.graphics.setLineWidth(1)
    love.graphics.line(cx - halfW, y, cx - 18, y)
    love.graphics.setColor(0.55, 0.85, 1.0, 0.7)
    love.graphics.polygon("fill", cx, y - 4, cx + 5, y, cx, y + 4, cx - 5, y)
    love.graphics.setColor(0.4, 0.75, 1.0, 0.35)
    love.graphics.line(cx + 18, y, cx + halfW, y)
    love.graphics.setLineWidth(1)
end

function Menu.draw()
    BG.draw()

    local t = love.timer.getTime()

    local titleFont = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 44)
    love.graphics.setFont(titleFont)
    local title = "Untitled Game"
    local tw = titleFont:getWidth(title)
    local tx = BASE_WIDTH/2 - tw/2
    local titleY = BASE_HEIGHT/4 - 10

    love.graphics.setColor(0.05, 0.15, 0.35, 0.8 * menuAlpha)
    for i = 1, 3 do
        love.graphics.print(title, tx + i, titleY + i)
    end

    love.graphics.setColor(0.1, 0.35, 0.6, menuAlpha)
    local sr = 3
    for i = 1, 8 do
        local ang = (i/8) * math.pi * 2
        local dx = math.floor(math.cos(ang) * sr + 0.5)
        local dy = math.floor(math.sin(ang) * sr + 0.5)
        love.graphics.print(title, tx + dx, titleY + dy)
    end

    local glowR = 0.85 + BG.titleGlow * 0.15
    local glowG = 0.95 + BG.titleGlow * 0.05
    love.graphics.setColor(glowR, glowG, 1.0, menuAlpha)
    love.graphics.print(title, tx, titleY)

    drawDivider(BASE_WIDTH/2, titleY + 62, 140)

    PlayButton:draw()
    SettingsButton:draw()
end

return Menu