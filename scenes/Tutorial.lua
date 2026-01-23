local Tutorial = {}
local Player = require("entities.Player")
local Platform = require("entities.Platform")
local simpleD = require("engine.DialogTypes.SimpleDialogue")
local Camera -- Referência para a câmera

function Tutorial.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    Platform.clear()
    
    Platform.new(0, 550, 800, 32, nil, love.graphics.newImage("assets/entities/platformsTextures/tile1.png"))
    
    Platform.new(200, 450, 150, 20, {0.8, 0.4, 0.2})
    Platform.new(400, 350, 120, 20, {0.8, 0.4, 0.2})
    Platform.new(100, 250, 100, 20, {0.8, 0.4, 0.2})
    Platform.new(550, 400, 140, 20, {0.8, 0.4, 0.2})
    
    Platform.new(700, 300, 30, 250, {0.5, 0.5, 0.8})
    
    Player.load()
    
    -- Obter a câmera do Player
    Camera = Player.getCamera()
    
    -- Configurar a câmera (opcional)
    Camera.smoothness = 6
    Camera.scale = 1.8 -- Ajuste aqui: 1 = normal, 1.5 = perto, 2 = muito perto, 2.5 = super perto
    -- Camera.setBounds(0, 0, 1600, 1200) -- Descomente e ajuste se quiser limites
    
    simpleD.config({
        x = 300,
        y = 15,
        width = 400
    })
    simpleD.showSequence({
        "Bem-vindo!", "Boa sorte!"
    })
end

function Tutorial.update(dt)
    simpleD.update(dt)
    Player.update(dt)
end

function Tutorial.draw()
    -- Verificar se a câmera existe antes de usar
    if Camera then
        -- Iniciar renderização com câmera (tudo que se move com o mundo)
        Camera.set()
    end
    
    -- Desenhar elementos do mundo
    Platform.draw()
    Player.draw()
    
    if Camera then
        -- Finalizar renderização com câmera
        Camera.unset()
    end
    
    -- Desenhar UI (não afetada pela câmera - fica fixa na tela)
    simpleD.draw()
end

return Tutorial