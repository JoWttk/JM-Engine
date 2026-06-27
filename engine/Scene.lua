local Scene = {}
local current = nil
local scenes = {}

local activeFade = nil

local function smoothstep(t)
    return t * t * (3 - 2 * t)
end

local function fadeOut(TIME, onComplete)
    local timer = 0
    local done = false

    return {
        update = function(dt)
            if done then return end
            timer = timer + dt
            if timer >= TIME then
                timer = TIME
                done = true
                if onComplete then onComplete() end
            end
        end,

        draw = function()
            if done then return end
            local t = smoothstep(timer / TIME)
            love.graphics.setColor(0, 0, 0, t)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1, 1)
        end,

        isDone = function() return done end
    }
end

local function fadeIn(TIME, onComplete)
    local timer = 0
    local done = false

    return {
        update = function(dt)
            if done then return end
            timer = timer + dt
            if timer >= TIME then
                timer = TIME
                done = true
                if onComplete then onComplete() end
            end
        end,

        draw = function()
            if done then return end
            local t = smoothstep(timer / TIME)
            local alpha = 1 - t
            love.graphics.setColor(0, 0, 0, alpha)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1, 1)
        end,

        isDone = function() return done end
    }
end

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

function Scene.transition(outTime, midFn, inTime, endFn)
    outTime = outTime or 0.35
    inTime  = inTime or 0.35

    activeFade = fadeOut(outTime, function()
        if midFn then midFn() end

        activeFade = fadeIn(inTime, function()
            activeFade = nil
            if endFn then endFn() end
        end)
    end)
end

function Scene.change(name, doFade)
    local scene = scenes[name]
    if not scene then return end

    local Player = require("entities.Player")
    Player.currentCollision = nil

    local function changeNow()
        current = scene
        OLD_SCENE = CURRENT_SCENE
        CURRENT_SCENE = name

        if CURRENT_SCENE_MODULE then 
            package.loaded[CURRENT_SCENE_MODULE] = nil
        end
        CURRENT_SCENE_MODULE = require("scenes." .. CURRENT_SCENE)

        if current.load then current.load() end
    end

    if doFade then
        Scene.transition(0.35, function()
            changeNow()
        end, 0.35)
    else
        changeNow()
    end
end

function Scene.update(dt)
    if current and current.update then
        current.update(dt)
    end

    if activeFade then
        activeFade.update(dt)
    end
end

function Scene.draw()
    if current and current.draw then
        current.draw()
    end

    if activeFade then
        activeFade.draw()
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
