local Player = {}

require("GLOBALS")

local Save = require("engine.Save")
local Signal = require("engine.Utils.signal")

Player.onCollision = Signal.new()

local task = require("engine.Utils.task")
local bar = require("engine.Interface.bar")
local Scene = require("engine.Scene")

lick = require("libs.lick")
lick.reset = true 

Player.name = "Player"
Player.level = 1

Player.baseSpeed = 200
Player.speed = 200
Player.died = false

Player.stamina = 30
Player.maxStamina = 30

Player.maxHealth = 100
Player.health = 100

stamina = Player.stamina
maxStamina = Player.maxStamina

local staminaBar
local lastStamina

local healthBar
local lastHealth
local shiftblock = false

local gravity = 1200
local jumpVel = -520

local dashing = false
local dashTimer = 0
local dashDir = 1

local DASH_DURATION = 0.15
local DASH_SPEED = 600

local Entity = require("engine.EntitySystem.Entity")
local Components = require("engine.EntitySystem.Components")
local Input = require("engine.Input")
local Platform = require("entities.Platform")
local SimpleD = require("engine.DialogTypes.SimpleDialogue")
local Camera = require("engine.EntitySystem.Camera") 

local player

local function aabb(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

local function setAnimation(anim, newAnim)
    if SimpleD.isActive() then return end
    if anim.current ~= newAnim then
        anim.current = newAnim
        anim.frame = 1
        anim.timer = 0
    end
end

Player.stats = {
    Attack = 1,
    Defense = 1,
    Power = 1,
    Stamina = 1;
}

function Player.setName(newName)
    Player.name = newName
end

function Player.getName()
    return Player.name
end

local data
local plrx,plry

function Player.load()
    if Save.read("player.txt") then
        data = Save.read("player.txt")
        Player.name = data.name or Player.name
        Player.level = data.level or Player.level
        Player.stats.Attack = data.Attack or Player.stats.Attack
        Player.stats.Defense = data.Defense or Player.stats.Defense
        Player.stats.Power = data.Power or Player.stats.Power
        Player.stats.Stamina = data.Stamina or Player.stats.Stamina
    end

    if data then
        plrx = data.posX or 100
        plry = data.posY or 100
    else
        plrx = 100
        plry = 100
    end

    Player._touching = {}

    player = Entity.new()
    Components.Position[player] = { x = plrx, y = plry }
    Components.Velocity[player] = { x = 0, y = 0 }
    Components.Collider[player] = { w = 32 * 1.4, h = 32 * 1.9 }
    
    local image = love.graphics.newImage("assets/entities/plr.png")

    Components.Sprite[player] = {
        image = image,
        flip = false,
        scale = 2.4
    }

    Components.Animation[player] = {
        animations = {
            idle = {
                frames = {
                    love.graphics.newQuad(0, 0, 32, 32, image),
                    love.graphics.newQuad(32, 0, 32, 32, image),
                },
                speed = 0.4
            },

            run = {
                frames = {
                    love.graphics.newQuad(0, 32, 32, 32, image),
                    love.graphics.newQuad(32, 32, 32, 32, image),
                    love.graphics.newQuad(64, 32, 32, 32, image),
                    love.graphics.newQuad(96, 32, 32, 32, image),
                },
                speed = 0.1,
                runSpeed = 0.07
            },

            fall = {
                frames = {
                    love.graphics.newQuad(0, 128, 32, 32, image)
                },
                speed = 0.1
            },

            jump = {
                frames = {
                    love.graphics.newQuad(0, 96, 32, 32, image)
                },
                speed = 0.1
            },
            
            sit = {
                frames = {
                    love.graphics.newQuad(0,64,32,32, image),
                    love.graphics.newQuad(32,64,32,32, image),
                    love.graphics.newQuad(64,64,32,32, image),
                    love.graphics.newQuad(96,64,32,32, image),
                },
                speed = 0.4
            },

            dash = {
                frames = {
                    love.graphics.newQuad(32, 32, 32, 32, image),
                },
                speed = 0.1
            },
        },

        current = "idle",
        frame = 1,
        timer = 0,
    }
    
    Camera.load()

    local hudFont = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 15)

    staminaBar = bar.new({
        label = "STA",
        fgColor = {0.2, 0.6, 1, 1},
        bgColor = {0.1, 0.1, 0.1, 1},
        width = 140,
        height = 14,
        padding = 2,
        tweenDuration = 0.12,
        showText = true,
        font = hudFont
    })

    staminaBar:setValue( stamina, maxStamina,0 )
    lastStamina = stamina

    healthBar = bar.new({
        label = "LIF",
        fgColor = {0.8, 0.2, 0.2, 1},
        bgColor = {0.1, 0.1, 0.1, 1},
        width = 140,
        height = 14,
        padding = 2,
        tweenDuration = 0.12,
        showText = true,
        font = hudFont
    })
    healthBar:setValue( Player.health, Player.maxHealth,0 )

    task.spawn(function()
        while true do
            if sprinting then
                stamina = math.max( 0, stamina-1 )
            else
                stamina = math.min( maxStamina,stamina+1 )
            end

            task.wait(0.15)
        end
    end)

    task.spawn(function()
        while true do
            if Player.health < Player.maxHealth then
                Player.health = math.min( Player.maxHealth, Player.health + 1 )
            end

            task.wait(1)
        end
    end)
    
    -- Opcional: Configurar limites da câmera (ajuste conforme seu mapa)
    -- Camera.setBounds(0, 0, 3200, 2400)
    
    -- Opcional: Configurar deadzone (área onde o player pode se mover sem mover a câmera)
    -- Camera.setDeadzone(200, 150)
end

function Player.update(dt)
    if not love.window.hasFocus() then return end
    if not player then return end

    task.step(dt)

    if staminaBar then
        staminaBar:update(dt)
        if stamina ~= lastStamina then
            staminaBar:setValue(stamina, maxStamina)
            lastStamina = stamina
        end
    end

    if healthBar then
        healthBar:update(dt)
        if Player.health ~= lastHealth then
            healthBar:setValue(Player.health, Player.maxHealth)
            lastHealth = Player.health
        end
    end

    local pos = Components.Position[player]
    local vel = Components.Velocity[player]
    local col = Components.Collider[player]
    local sprite = Components.Sprite[player]
    local anim = Components.Animation[player]

    local move = 0

    if dashing then
        setAnimation( anim, "dash" )
        dashTimer = dashTimer - dt
        if dashTimer <= 0 then
            dashing = false
        end
    end

    if Input.isDown("a") then move = -1 end
    if Input.isDown("d") then move = 1 end

    if shiftblock and not Input.isDown("lshift") then
        shiftblock = false
    end

    if Input.isDown("lshift") and stamina > 1 and not shiftblock and not SimpleD.isActive() then
        sprinting = true
    else
        sprinting = false
    end
    if stamina <= 1 then shiftblock=true; sprinting = false end

    local speed = Player.baseSpeed
    if sprinting then
        if anim.animations[anim.current]=="run" then
            anim.animations[anim.current].speed =anim.animations[anim.current].runSpeed
        end

        speed = speed * 1.6
    else
        if anim.animations[anim.current]=="run" then
            anim.animations[anim.current].speed =anim.animations[anim.current].speed
        end
    end

    if not SimpleD.isActive() then
        if dashing then
            vel.x = dashDir * DASH_SPEED
        else
            vel.x = move * speed
        end
    else
        vel.x = 0
    end

    if move < 0 and not SimpleD.isActive() then sprite.flip = true end
    if move > 0 and not SimpleD.isActive() then sprite.flip = false end

    vel.y = vel.y + gravity * dt
    pos.x = pos.x + vel.x * dt

    local touchingNow = {}

    for _, platform in ipairs(Platform.list) do
        if aabb(pos.x, pos.y, col.w, col.h, platform.x, platform.y, platform.w, platform.h) then
            touchingNow[platform] = true

            if not Player._touching[platform] then
                Player.onCollision:fire(platform, "enter")
            else
                Player.onCollision:fire(platform, "stay")
            end

            if vel.x > 0 then
                pos.x = platform.x - col.w
            elseif vel.x < 0 then
                pos.x = platform.x + platform.w
            end
            vel.x = 0
            break
        end
    end

    pos.y = pos.y + vel.y * dt

    local onGround = false
    for _, platform in ipairs(Platform.list) do
        if aabb(pos.x, pos.y, col.w, col.h, platform.x, platform.y, platform.w, platform.h) then
            touchingNow[platform] = true

            if not Player._touching[platform] then
                Player.onCollision:fire(platform, "enter")
            else
                Player.onCollision:fire(platform, "stay")
            end

            if vel.y > 0 then
                pos.y = platform.y - col.h
                vel.y = 0
                onGround = true
            elseif vel.y < 0 then
                pos.y = platform.y + platform.h
                vel.y = 0
            end
        end
    end

    for _, platform in ipairs(Platform.list) do
        if aabb(pos.x, pos.y, col.w, col.h, platform.x, platform.y, platform.w, platform.h) then
            touchingNow[platform] = true

            if not Player._touching[platform] then
                Player.onCollision:fire(platform, "enter")
            else
                Player.onCollision:fire(platform, "stay")
            end
        end
    end

    for platform in pairs(Player._touching) do
        if not touchingNow[platform] then
            Player.onCollision:fire(platform, "exit")
        end
    end

    Player._touching = touchingNow

    if Input.wasPressed("space") and onGround and not SimpleD.isActive() then
        if stamina < 4 then return end
        
        vel.y = jumpVel
        onGround = false
        stamina = stamina - 4
        Camera.startShake( 0.1, 1 )
    end

    -- if Input.wasPressed("u") then Player.health = Player.health - 10 end

    if Input.wasPressed("q") and not SimpleD.isActive() and not dashing then
        if onGround then return end
        if stamina < 6 then return end
        stamina = stamina - 6

        dashDir = (move ~= 0) and move or (sprite.flip and -1 or 1)

        dashing = true
        dashTimer = DASH_DURATION

        Camera.startShake( 0.15, 1.5 )
    end

    if anim then
        if not onGround then
            setAnimation( anim, (vel.y < 0) and "jump" or "fall" )
        elseif move ~= 0 then
            setAnimation( anim, "run" )
        else
            setAnimation( anim, "idle" )
        end

        anim.timer = anim.timer + dt
        if anim.timer >= anim.animations[anim.current].speed then
            anim.timer = 0
            local currentAnim = anim.animations[anim.current]
            if currentAnim and currentAnim.frames then
                anim.frame = anim.frame + 1
                if anim.frame > #currentAnim.frames then
                    anim.frame = 1
                end
            end
        end
    end

    local centerX = pos.x + col.w / 2
    local centerY = pos.y + col.h / 2

    Camera.follow( centerX, centerY )
    Camera.update(dt)
    Camera.updateShake(dt)

    if Input.wasPressed("r") then
        Player.die()
    end

    if pos.y > 1500 then
        Player.respawn( 100, 100 )
    end
end

function Player.draw()
    local pos = Components.Position[player]
    local col = Components.Collider[player]
    local sprite = Components.Sprite[player]
    local anim = Components.Animation[player]
    
    if sprite and anim then
        local currentAnim = anim.animations[anim.current]
        if currentAnim and currentAnim.frames and currentAnim.frames[anim.frame] then
            local frame = currentAnim.frames[anim.frame]
            
            local spriteWidth = 32 * sprite.scale
            local spriteHeight = 32 * sprite.scale
            local offsetX = (col.w - spriteWidth) / 2
            local offsetY = (col.h - spriteHeight) / 2
            
            local scaleX = sprite.scale * (sprite.flip and -1 or 1)
            local drawX = sprite.flip and (pos.x + col.w - offsetX) or (pos.x + offsetX)
            local drawY = pos.y + offsetY - 8
            
            love.graphics.draw(
                sprite.image,
                frame,
                drawX,
                drawY,
                0,
                scaleX,
                sprite.scale
            )
        end
    end

    love.graphics.push()
    love.graphics.origin()
    Player.drawHUD()
    love.graphics.pop()
    
    -- love.graphics.setColor(1, 0, 0, 0.3)
    -- love.graphics.rectangle("line", pos.x, pos.y, col.w, col.h)
    -- love.graphics.setColor(1, 1, 1)
end

function Player.drawHUD()
    if staminaBar then
        staminaBar:draw(60, 12)
    end

    if healthBar then
        healthBar:draw(60, 50)
    end
end

function Player.getEntity()
    return player
end

function Player.destroy()
    Entity.destroy(player)
end

function Player.takeDamage(amount)
    Player.health = math.max(0, Player.health - amount)
    if Player.health <= 0 then
        Player.died = true
    end
end

function Player.die()
    Scene.change("Dead")
end

function Player.respawn(x, y)
    local pos = Components.Position[player]
    local vel = Components.Velocity[player]

    pos.x = x or 100
    pos.y = y or 100

    vel.x = 0
    vel.y = 0

    Player.health = Player.maxHealth
    stamina = maxStamina

    Player.hang = false
    dashing = false
    shiftblock = false

    Camera.startShake(0.2, 2)
end

function Player.getCamera()
    return Camera
end

function Player.quit()
    if not Save.read("player.txt") then
        return
    end

    if not Player then return end
    if not player then return end
    
    Save.write("player.txt", {
        name = Player.name,
        level = Player.level or 1,
        Attack = Player.stats.Attack,
        Defense = Player.stats.Defense,
        Power = Player.stats.Power,
        Stamina = Player.stats.Stamina,
        posX=Components.Position[player].x,
        posY=Components.Position[player].y,
        scene=CURRENT_SCENE,
        recentlyJoined = require("scenes."..CURRENT_SCENE).recentlyJoined
    })
end

function Player.addStat(stat, amount)
    if Player.stats[stat] then
        Player.stats[stat] = Player.stats[stat] + amount
    end
end

function Player.moveTo(x, y)
    local pos = Components.Position[player]
    pos.x = x
    pos.y = y
end

-- CONNECTIONS
Player.onCollision:connect(function(platform, eventType)
    if eventType == "enter" then
        print("Player colidiu com plataforma:", platform.tag)
    elseif eventType == "exit" then
        print("Player saiu da plataforma:", platform.tag)
    end
end)

return Player