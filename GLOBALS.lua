GameScene = {}
OLD_SCENE = "Menu"
CURRENT_SCENE="Menu"
CURRENT_SCENE_MODULE = nil

BASE_WIDTH = 1031
BASE_HEIGHT = 580

CAMERA_SCALE = 1.25

CurrentLanguage = "pt"
CurrentLanguageModule = nil

task = require("engine.Utils.task")
WEB_PLATFORM = "Poki"
Web = require("engine.Web."..WEB_PLATFORM)

NonPausableScenes = {"Menu","Tutorial", "UserCreator"}
GameplayScenes = {"Parkour"}

-- key - especial - pixel size: 32x16
-- key - default - pixel size: 16x16

padlock = love.graphics.newImage("assets/images/pixellock.png")

key_icons = love.graphics.newImage("assets/images/key-icons.png")
key_icons_extra = love.graphics.newImage("assets/images/key-icons-extra.png")
key_icons_extra2 = love.graphics.newImage("assets/images/key-icons-extra.png")

key_icons_extra2:setFilter("linear", "linear")

icons = {
    UP = love.graphics.newQuad(0, 0, 16, 16, key_icons:getDimensions()),
    LEFT = love.graphics.newQuad(32, 0, 16, 16, key_icons:getDimensions()),
    RIGHT = love.graphics.newQuad(48, 0, 16, 16, key_icons:getDimensions()),
    D = love.graphics.newQuad(48, 32, 16, 16, key_icons:getDimensions()),
    W = love.graphics.newQuad(64, 112, 16, 16, key_icons:getDimensions()),
    A = love.graphics.newQuad(0, 32, 16, 16, key_icons:getDimensions()),
    Q = love.graphics.newQuad(0, 64, 16, 16, key_icons:getDimensions()),
    SHIFT = love.graphics.newQuad(0, 16, 32, 16, key_icons_extra:getDimensions()),
    SPACE = love.graphics.newQuad(64, 32, 32, 16, key_icons_extra:getDimensions()),
}