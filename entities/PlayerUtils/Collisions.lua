require("GLOBALS")

local Scene = require("engine.Scene")
local Input = require("engine.Input")

local SimpleD = require("engine.DialogTypes.SimpleDialogue")
local Window = require("engine.Interface.window")

local collisions = {
    ["JoinParkour"] = {
        jumpable = false,

        load = function(Player)
            if Window.isActive() then return end 
            Window.config({
                offsetX = 25,
                offsetY = -50,
                maxWidth = 300
            })

            Window.show("Press {SPACE} to join parkour!")
        end,

        run = function(Player, skipped)
            if not skipped then skipped = false end

            local function leave()
                SimpleD.close()
                
                Scene.change("MapSelector", true, function()
                    Window.close()
                end)
            end
            
            if skipped then
                leave()
                return
            end

            if Input.wasPressed("space") then
                leave()
            end
        end,

        update = function(dt)
            Window.update(dt)
        end,

        draw = function()
            Window.draw()
        end
    },

    ["StomperExplain"] = {
        jumpable = false,

        load = function(Player)
            if CURRENT_SCENE ~= "Tutorial" then return end

            if CURRENT_SCENE_MODULE and CURRENT_SCENE_MODULE.haveSeenWhatsStomper == true then
                return 
            end

            SimpleD.config({
                x = 300,
                y = love.graphics.getHeight() - 180,
                width = 400
            })
            SimpleD.showSequence(CurrentLanguageModule.Tutorial.StomperExplain, function()
                CURRENT_SCENE_MODULE.haveSeenWhatsStomper = true
                print(tostring(CURRENT_SCENE_MODULE.haveSeenWhatsStomper))
            end)
        end,

        unload = function(Player)
            SimpleD.close()
        end,
    }
}

local Save = require("engine.Save")

collisions["DoorWorld1"] = {
    jumpable = false,

    load = function(Player)
        if Window.isActive() then return end
        Window.config({
            offsetX = 25,
            offsetY = -50,
            maxWidth = 300
        })
        Window.show("Press {SPACE} to enter World 1!")
    end,

    run = function(Player, skipped)
        if not skipped then skipped = false end

        local function enter()
            Window.close()
            Scene.change("World1Level1", true)
        end

        if skipped then
            enter()
            return
        end

        if Input.wasPressed("space") then
            enter()
        end
    end,

    update = function(dt)
        Window.update(dt)
    end,

    draw = function()
        Window.draw()
    end
}

local function makeLockedDoor(worldNumber, sceneName)
    return {
        jumpable = false,

        load = function(Player)
            local save = Save.read("progress.txt") or {}
            if save["world" .. worldNumber .. "Unlocked"] then
                if Window.isActive() then return end
                Window.config({
                    offsetX = 25,
                    offsetY = -50,
                    maxWidth = 300
                })
                Window.show("Press {SPACE} to enter World " .. worldNumber .. "!")
            else
                if Window.isActive() then return end
                Window.config({
                    offsetX = 25,
                    offsetY = -50,
                    maxWidth = 300
                })
                Window.show("Locked!")
            end
        end,

        run = function(Player, skipped)
            local save = Save.read("progress.txt") or {}
            if not save["world" .. worldNumber .. "Unlocked"] then return end

            if not skipped then skipped = false end

            local function enter()
                Window.close()
                Scene.change(sceneName, true)
            end

            if skipped then
                enter()
                return
            end

            if Input.wasPressed("space") then
                enter()
            end
        end,

        update = function(dt)
            Window.update(dt)
        end,

        draw = function()
            Window.draw()
        end
    }
end

collisions["ExitW1L1"] = {
    jumpable = false,

    load = function(Player)
        if Window.isActive() then return end
        Window.config({
            offsetX = 25,
            offsetY = -50,
            maxWidth = 300
        })
        Window.show("Press {SPACE} to return!")
    end,

    run = function(Player, skipped)
        if not skipped then skipped = false end

        local function leave()
            Window.close()

            local save = Save.read("progress.txt") or {}
            save["world2Unlocked"] = true
            Save.write("progress.txt", save)

            Scene.change("MapSelector", true)
        end

        if skipped then
            leave()
            return
        end

        if Input.wasPressed("space") then
            leave()
        end
    end,

    update = function(dt)
        Window.update(dt)
    end,

    draw = function()
        Window.draw()
    end
}

-- collisions["DoorWorld2"] = makeLockedDoor(2, "World2Level1")
-- collisions["DoorWorld3"] = makeLockedDoor(3, "World3Level1")

return collisions