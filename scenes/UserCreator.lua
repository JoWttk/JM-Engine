local UC = {}

require("GLOBALS")

local task = require("engine.Utils.task")
local Save = require("engine.Save")

local Scene = require("engine.Scene")
local Button = require("engine.Interface.button")
local Text = require("engine.Interface.text")
local Input = require("engine.Input")
local Player = require("entities.Player")
local VirtualKeyboard = require("engine.Interface.virtualKeyboard")

local Buttons = {}
local PlayButton
local vk

local MinText

UC.recentlyJoined = false

function UC.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    MinText = "Min. 1 character"

    vk = VirtualKeyboard.new({
        maxLen = 12,
    })
    vk:open("")

    PlayButton = Button:new(
        1024/2-130, 768/1.5, 260, 50,
        {0.2, 0.6, 0.8}, "Create User",
        {1,1,1}, "assets/fonts/PressStart2P-Regular.ttf", 18,
        2, {1,1,1},
        function()
            if #vk.text < 1 then
                vk.text = MinText

                task.delay(1.25,function()
                    if vk.text == MinText then
                        vk.text = ""
                    end
                end)

                return
            elseif vk.text == MinText then
                return
            end

            package.loaded[CurrentLanguageModule] = nil
            CurrentLanguageModule = require("translation." ..CurrentLanguage)

            Save.write("player.txt", {
                name = text,
                level = 1,
                Attack = 1,
                Defense = 1,
                Power = 1,
                Stamina = 1,
                posX=100,
                posY=100,
                scene="Tutorial",
                recentlyJoined = require("scenes."..CURRENT_SCENE).recentlyJoined
            })

            Scene.change("Tutorial")
        end
    )

    table.insert(Buttons, PlayButton)
end

function UC.update(dt)
    task.step(dt)
    local mouseX, mouseY = love.mouse.getPosition()

    for _, button in ipairs(Buttons) do
        button:update(mouseX, mouseY, Input.wasMousePressed(1))
    end

    vk:mousemoved(mouseX, mouseY)
    if Input.wasMousePressed(1) then
        vk:mousepressed(mouseX, mouseY, 1)
    end

    vk:update(dt)
    Player.setName(vk.text)
end

function UC.draw()
    for _, button in ipairs(Buttons) do
        button:draw()
    end

    vk:draw()
end

function UC.keypressed(key)
    if vk and vk:isOpen() then
        if vk:keypressed(key) then
            return
        end
    end
end

function UC.keyreleased(key)
    if vk and vk:isOpen() then
        vk:keyreleased(key)
    end
end

return UC