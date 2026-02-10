local Texts = {}

local Player = require("entities.Player")

Texts.Menu = {
    [1] = "Pressione ESPAÇO para iniciar",
}

Texts.Tutorial = {
    [1] = "Olá, " ..Player.getName() .. "! Bem-vindo ao Untitled game",
    [2] = "Aqui você irá passar agora pelo tutorial do jogo",
    [3] = "Para se mover para os lados aperte A e D, e para correr segure SHIFT",
    [4] = "Para pular aperte espaço e para dar um dash aperte Q",
    [5] = "Cuidado com os inimigos e armadilhas, e boa sorte!"
}

return Texts