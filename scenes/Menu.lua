local Menu = {}

require("GLOBALS")
local Scene = require("engine.Scene")
local Input = require("engine.Input")

function Menu.load()
    
end

function Menu.update(dt)
    if Input.wasPressed("space") then
        CurrentScene="Tutorial"
        Scene.change(CurrentScene)
    end
end

function Menu.draw()
    love.graphics.setNewFont("assets/fonts/PressStart2P-Regular.ttf",12)
    love.graphics.print("Pressione SPACE para iniciar", 1024/2-160, 768/2)
end

return Menu