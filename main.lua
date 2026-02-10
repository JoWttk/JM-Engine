local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Player = require("entities.Player")
require("GLOBALS")

lick = require("libs.lick")
lick.reset = true 

CurrentLanguageModule = require("translation." ..CurrentLanguage)

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    
    Scene.register("Menu", require("scenes.Menu"))
    Scene.register("UserCreator", require("scenes.UserCreator"))
    Scene.register("Tutorial", require("scenes.Tutorial"))
    Scene.register("Parkour", require("scenes.Parkour"))
    Scene.register("Dead", require("scenes.Dead"))
    
    Scene.change("Menu")
end

function love.update(dt)
    if dt > 0.05 then dt = 0.05 end
    
    Scene.update(dt)
    Input.update()
end

function love.draw()
    Scene.draw()
end

function love.keypressed(key)
    Input.keypressed(key)

    if Scene.keypressed then
        Scene.keypressed(key)
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