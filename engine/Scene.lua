local Scene = {}
local current = nil
local scenes = {}

function Scene.register(name, scene)
    scenes[name] = scene
end

function Scene.getCurrentModule()
    return require("scenes." .. CURRENT_SCENE)
end

function Scene.load(scene)
    if type(scene) == "string" then
        scene = scenes[scene]
    end
    
    current = scene
    if current and current.load then 
        current.load() 
    end
end

function Scene.change(name)
    local scene = scenes[name]
    current = scene
    if current and current.load then
        OLD_SCENE = CURRENT_SCENE
        CURRENT_SCENE = name
        current.load()
    end
end

function Scene.update(dt)
    if current and current.update then
        current.update(dt)
    end
end

function Scene.draw()
    if current and current.draw then
        current.draw()
    end
end

function Scene.keypressed(key)
    if current and current.keypressed then
        current.keypressed(key)
    end
end

function Scene.keyreleased(key)
    if current and current.keyreleased then
        current.keyreleased(key)
    end
end

return Scene