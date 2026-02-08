local Scene = require("engine.Scene")
local Input = require("engine.Input")
require("globals")

lick = require("libs.lick")
lick.reset = true 

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    
    Scene.register("Menu", require("scenes.Menu"))
    Scene.register("Tutorial", require("scenes.Tutorial"))
    
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
end

function love.keyreleased(key)
    Input.keyreleased(key)
end