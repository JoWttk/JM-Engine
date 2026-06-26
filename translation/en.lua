local Texts = {}
local Player = require("entities.Player")

Texts.Type = "EN"

Texts.Menu = {
    [1] = "Play",
    [2] = "Settings",
}

Texts.Dead = {
    [1] = "You Died",
    [2] = "Press R to Restart",
}

Texts.Settings = {
    [1] = "Settings",
    [2] = "Language: ",
    [3] = "Controller: ",
    [4] = "Volume: ",
    [5] = "Difficulty: ",
    [6] = "Back",

    ControlTypes = {
        [1] = "Keyboard",
        [2] = "Gamepad"
    }
}

Texts.Tutorial = {
    [1] = "Hello, " ..Player.getName() .. "! Welcome to Untitled game",
    [2] = "Here you will go through the game's tutorial",
    [3] = "To move left and right press A and D, and to run hold SHIFT",
    [4] = "To jump press space and to dash press Q",
    [5] = "Beware of enemies and traps, and good luck!"
}

Texts.UserCreator = {
    title = "Create Your Character",
    create = "Create User",
    minchar = "Min. 1 character"
}

return Texts