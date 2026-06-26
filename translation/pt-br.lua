local Texts = {}

local Player = require("entities.Player")

Texts.Type = "PT-BR"

Texts.Menu = {
    [1] = "Jogar",
    [2] = "Configurações",
}

Texts.Dead = {
    [1] = "Você Morreu",
    [2] = "Pressione R para Reiniciar",
}

Texts.Settings = {
    [1] = "Configurações",
    [2] = "Idioma: ",
    [3] = "Controles: ",
    [4] = "Volume: ",
    [5] = "Dificuldade: ",
    [6] = "Voltar",

    ControlTypes = {
        [1] = "Teclado",
        [2] = "Controle"
    }
}

Texts.Tutorial = {
    [1] = "Olá, " ..Player.getName() .. "! Bem-vindo ao Untitled game",
    [2] = "Aqui você irá passar agora pelo tutorial do jogo",
    [3] = "Para se mover para os lados aperte {A} e {D}, e para correr segure {SHIFT}",
    [4] = "Para pular aperte {SPACE} e para dar um dash aperte {Q}",
    [5] = "Cuidado com os inimigos e armadilhas, e boa sorte!"
}

Texts.UserCreator = {
    title = "Crie Seu Personagem",
    create = "Criar Usuário",
    minchar = "Mín. 1 caracter"
}

return Texts