local Player = {}

local task = require("engine.Utils.task")
local bar = require("engine.Interface.bar")

lick = require("libs.lick")
lick.reset = true 

Player.baseSpeed = 200
Player.speed = 200
Player.died = false

Player.stamina = 30
Player.maxStamina = 30

stamina = Player.stamina
maxStamina = Player.maxStamina

local staminaBar
local lastStamina

local gravity = 1200
local jumpVel = -520
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

local stats = {
    Attack = 1,
    Defense = 1,
    Power = 1,
    Stamina = 1;
}

function Player.load()
    player = Entity.new()
    Components.Position[player] = { x = 100, y = 100 }
    Components.Velocity[player] = { x = 0, y = 0 }
    Components.Collider[player] = { w = 32 * 1.4, h = 32 * 1.9}
    
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
            }
        },

        current = "idle",
        frame = 1,
        timer = 0,
    }
    
    Camera.load()

    staminaBar = bar.new({
        label = "STA",
        fgColor = {0.2, 0.6, 1, 1},
        bgColor = {0.1, 0.1, 0.1, 1},
        width = 140,
        height = 14,
        padding = 2,
        tweenDuration = 0.12,
        showText = true
    })

    staminaBar:setValue(stamina, maxStamina,0)
    lastStamina = stamina

    task.spawn(function()
        while true do
            if sprinting then
                stamina = math.max(0, stamina-1)
            else
                stamina = math.min(maxStamina,stamina+1)
            end

            task.wait(0.15)
        end
    end)
    
    -- Opcional: Configurar limites da câmera (ajuste conforme seu mapa)
    -- Camera.setBounds(0, 0, 3200, 2400)
    
    -- Opcional: Configurar deadzone (área onde o player pode se mover sem mover a câmera)
    -- Camera.setDeadzone(200, 150)
end

function Player.update(dt)
    if not love.window.hasFocus() then return end

    task.step(dt)

    if staminaBar then
        staminaBar:update(dt)
        if stamina ~= lastStamina then
            staminaBar:setValue(stamina, maxStamina)
            lastStamina = stamina
        end
    end

    local pos = Components.Position[player]
    local vel = Components.Velocity[player]
    local col = Components.Collider[player]
    local sprite = Components.Sprite[player]
    local anim = Components.Animation[player]

    local move = 0
    if Input.isDown("a") then move = -1 end
    if Input.isDown("d") then move = 1 end

    if Input.isDown("lshift") and stamina > 1 and not SimpleD.isActive() then
        sprinting = true
    else
        sprinting = false
    end
    if stamina <= 1 then sprinting = false end

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

    print(stamina)

    if not SimpleD.isActive() then
        vel.x = move * speed
    else
        vel.x = 0
    end

    if move < 0 and not SimpleD.isActive() then sprite.flip = true end
    if move > 0 and not SimpleD.isActive() then sprite.flip = false end

    vel.y = vel.y + gravity * dt

    pos.x = pos.x + vel.x * dt

    for _, platform in ipairs(Platform.list) do
        if aabb(pos.x, pos.y, col.w, col.h, platform.x, platform.y, platform.w, platform.h) then
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

    if Input.wasPressed("space") and onGround and not SimpleD.isActive() then
        vel.y = jumpVel
        onGround = false
        Camera.startShake(0.1, 1)
    end

    if anim then
        if not onGround then
            setAnimation(anim, (vel.y < 0) and "jump" or "fall")
        elseif move ~= 0 then
            setAnimation(anim, "run")
        else
            setAnimation(anim, "idle")
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

    Camera.follow(centerX, centerY)
    Camera.update(dt)
    Camera.updateShake(dt)
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
        staminaBar:draw(50, 12)
    end
end

function Player.getEntity()
    return player
end

function Player.getCamera()
    return Camera
end

return Player