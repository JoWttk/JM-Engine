local Texts = {}
local Player = require("entities.Player")

Texts.Menu = {
    [1] = "Press SPACE to play",
}

Texts.Tutorial = {
    [1] = "Hello, " ..Player.getName() .. "! Welcome to Untitled game",
    [2] = "Here you will go through the game's tutorial",
    [3] = "To move left and right press A and D, and to run hold SHIFT",
    [4] = "To jump press space and to dash press Q",
    [5] = "Beware of enemies and traps, and good luck!"
}

return Texts