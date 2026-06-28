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
    [1] = "Welcome, " .. Player.getName() .. "!",
    [2] = "You will now go through the basic tutorial.",
    [3] = "Press {A} or {LEFT} to move left.",
    [4] = "Press {D} or {RIGHT} to move right.",
    [5] = "Press {SPACE} to jump and {Q} to dash.",
    [6] = "Be careful, and have fun!",

    ["StomperExplain"] = {
        "The Stomper is an enemy that patrols back and forth. If you jump on its head, you'll defeat it...",
        "But don't be fooled—if you touch it, you'll die instantly."
    }
}

Texts.UserCreator = {
    title = "Create Your Character",
    create = "Create User",
    minchar = "Min. 1 character"
}

return Texts