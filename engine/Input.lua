local Input = {
    keysDown = {},
    keysPressed = {}
}

local SimpleD = require("engine.DialogTypes.SimpleDialogue")

function Input.update()
    Input.keysPressed = {}
end

function Input.keypressed(key)
    Input.keysDown[key] = true
    Input.keysPressed[key] = true
    
    if key == "return" and SimpleD.isActive() then
        SimpleD.advance()
    end
end

function Input.keyreleased(key)
    Input.keysDown[key] = false
end

function Input.isDown(key)
    return Input.keysDown[key]
end

function Input.wasPressed(key)
    return Input.keysPressed[key]
end

return Input