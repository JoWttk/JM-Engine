require("GLOBALS")

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Player = require("entities.Player")
local UI = require("engine.Interface.UI")
local Table = require("engine.Utils.Table")
local Camera = require("engine.EntitySystem.Camera")
local Settings = require("scenes.Settings")
local Progress = require("engine.Progress")

lick = require("libs.lick")
lick.reset = true 

local Save = require("engine.Save")
local savedSettings = Save.read("settings.txt")
if savedSettings and savedSettings.Language then
    CurrentLanguage = savedSettings.Language
end

CurrentLanguageModule = require("translation." ..CurrentLanguage)

local gameCanvas
local baseWidth, baseHeight = 1031, 580 

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    UI.init(baseWidth, baseHeight)
    gameCanvas = love.graphics.newCanvas(baseWidth, baseHeight)
    
    Scene.register("Menu", require("scenes.Menu"))
    Scene.register("Settings", require("scenes.Settings"))
    Scene.register("UserCreator", require("scenes.UserCreator"))
    Scene.register("Tutorial", require("scenes.Tutorial"))
    Scene.register("Parkour", require("scenes.Parkour"))
    Scene.register("MapSelector", require("scenes.MapSelector"))
    Scene.register("World1_Level1", require("scenes.World1_Level1"))
    
    Scene.change("Menu")
    Progress.load()
    Web.init()
end

function love.update(dt)
    -- love.window.setTitle("Testing | " .. love.timer.getFPS() .. " FPS")
    if dt > 0.05 then dt = 0.05 end
    
    Scene.update(dt)
    Input.update()
end

function love.draw()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    Scene.draw()
    
    love.graphics.setCanvas()
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local scaleX = w / baseWidth
    local scaleY = h / baseHeight
    local scale = math.min(scaleX, scaleY)
    
    local drawWidth = baseWidth * scale
    local drawHeight = baseHeight * scale
    local offsetX = (w - drawWidth) / 2
    local offsetY = (h - drawHeight) / 2
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, offsetX, offsetY, 0, scale, scale)
end

function love.keypressed(key)
    Input.keypressed(key)

    if Scene.keypressed then
        Scene.keypressed(key)
    end

    if key == "escape" then
        if Table.find(NonPausableScenes, CURRENT_SCENE) then
            return
        end

        if CURRENT_SCENE == "Settings" then
            Scene.change(OLD_SCENE)
        else
            Scene.change("Settings")
            -- Settings.addQuit:fire()
        end
    end
end

function love.keyreleased(key)
    Input.keyreleased(key)

    if Scene.keyreleased then
        Scene.keyreleased(key)
    end
end

function love.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    Input.mousereleased(x, y, button)
end

function love.mousemoved(x, y)
    Input.mousemoved(x, y)
end

function love.quit()
    Player.quit()
end

function love.resize(w, h)
    if UI and UI.init then UI.init() end
    Camera.onResize()
end