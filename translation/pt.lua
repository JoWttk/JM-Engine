local Texts = {}
local Player = require("entities.Player")

Texts.Type = "PT"

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
    [3] = "Controle: ",
    [4] = "Volume: ",
    [5] = "VSync: ",
    [6] = "Voltar",

    ControlTypes = {
        [1] = "Teclado",
        [2] = "Controle",
        [3] = "(Controle não encontado)"
    }
}

Texts.Tutorial = {
    [1] = "Bem-vindo, " .. Player.getName() .. "!",
    [2] = "Vamos aprender o básico antes de começar sua aventura.",
    [3] = "Use {A} ou {LEFT} para andar para a esquerda.",
    [4] = "Use {D} ou {RIGHT} para andar para a direita.",
    [5] = "Pressione {SPACE} para pular e {Q} para dar um dash.",
    [6] = "Agora é com você. Boa sorte!",

    ["StomperExplain"] = {
        "Stomper é um inimigo que anda de um lado para o outro, e se você pular em cima dele, ele irá morrer...",
        "Mas não se engane, ao encostar nele, você morrerá instanteamente."
    }
}

Texts.UserCreator = {
    title = "Crie Seu Personagem",
    create = "Criar Usuário",
    minchar = "Mín. 1 caracter"
}

return Texts