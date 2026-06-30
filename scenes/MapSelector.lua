local MapSelector = {}

local Scene = require("engine.Scene")
local Input = require("engine.Input")
local Button = require("engine.Interface.button")
local Text = require("engine.Interface.text")
local BG = require("scenes.utils.Background")
local Progress = require("engine.Progress")

MapSelector.CURRENT_WORLD = 1
MapSelector.LEVELS_PER_WORLD = 6

local levelButtons = {}
local titleText

local GRID_COLS = 3
local BTN_SIZE = 90
local BTN_GAP = 30
local GRID_START_Y = 160

local function drawLockIcon(x, y, size)
    local s = size / 8
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.rectangle("fill", x + s*2, y + s*1, s, s*2.5)
    love.graphics.rectangle("fill", x + s*5, y + s*1, s, s*2.5)
    love.graphics.rectangle("fill", x + s*2.5, y + s*0.5, s*3, s)
    love.graphics.setColor(0.9, 0.7, 0.2, 1)
    love.graphics.rectangle("fill", x + s*1.5, y + s*3, s*5, s*4)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", x + s*3.5, y + s*4.5, s, s)
    love.graphics.setColor(1, 1, 1, 1)
end

local function buildButtons()
    levelButtons = {}

    local totalWidth = GRID_COLS * BTN_SIZE + (GRID_COLS - 1) * BTN_GAP
    local startX = BASE_WIDTH/2 - totalWidth/2

    for i = 1, MapSelector.LEVELS_PER_WORLD do
        local locked = Progress.isLocked(MapSelector.CURRENT_WORLD, i)

        local col = (i - 1) % GRID_COLS
        local row = math.floor((i - 1) / GRID_COLS)
        local x = startX + col * (BTN_SIZE + BTN_GAP)
        local y = GRID_START_Y + row * (BTN_SIZE + BTN_GAP)

        local btn = Button:new(
            x, y, BTN_SIZE, BTN_SIZE,
            {0.2, 0.6, 0.8}, tostring(i),
            {1, 1, 1}, "assets/fonts/PressStart2P-Regular.ttf", 18,
            2, {1, 1, 1},
            function()
                if locked then return end
                print("is not locked")
                Scene.change("World" .. MapSelector.CURRENT_WORLD .. "_Level" .. i, true)
            end,
            "scale"
        )

        btn._locked = locked
        table.insert(levelButtons, btn)
    end
end

function MapSelector.load()
    BG.load()
    buildButtons()

    titleText = Text:new(0, 40, "assets/fonts/PressStart2P-Regular.ttf", 26,
        "World " .. MapSelector.CURRENT_WORLD,
        {1,1,1}, 2, {0.2, 0.6, 0.8})
    if titleText.centerAt then titleText:centerAt(BASE_WIDTH/2) end
end

function MapSelector.update(dt)
    BG.update(dt)
    local mouseX, mouseY = Input.getCanvasMousePosition()
    for _, btn in ipairs(levelButtons) do
        if not btn._locked then
            btn:update(mouseX, mouseY, Input.wasMousePressed(1))
        end
    end
end

function MapSelector.draw()
    BG.draw()
    titleText:draw()

    for _, btn in ipairs(levelButtons) do
        btn:draw()
        if btn._locked then
            drawLockIcon(btn.x + btn.width/2 - 20, btn.y + btn.height/2 - 20, 40)
        end
    end
end

return MapSelector