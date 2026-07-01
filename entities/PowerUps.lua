local Platform = require("entities.Platform")

local PowerUps = {}

local Image = love.graphics.newImage("assets/images/fruits.png")
Image:setFilter("nearest", "nearest")
Image:setWrap("clamp", "clamp")

local function makeQuad(x, y, w, h)
    return love.graphics.newQuad(x, y, w, h, Image:getWidth(), Image:getHeight())
end

PowerUps.types = {
    InfinityHealth = {
        quad = makeQuad(0, 0, 64, 64),
        duration = 12,
        onApply = function(player)
            player.invincible = true
        end,
        onExpire = function(player)
            player.invincible = false
        end,
    },

    Speed = {
        quad = makeQuad(0, 64, 64, 64),
        duration = 9,
        onApply = function(player)
            player.speed = player.baseSpeed * 1.8
        end,
        onExpire = function(player)
            player.speed = player.baseSpeed
        end,
    },

    Jumper = {
        quad = makeQuad(64, 0, 64, 64),
        duration = 10,
        onApply = function(player)
            player.jumpBoost = 1.4
        end,
        onExpire = function(player)
            player.jumpBoost = 1
        end,
    },
}

PowerUps.list = {}
PowerUps.active = {}

local GRAVITY = 280

local function aabb(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

function PowerUps.register(name, def)
    PowerUps.types[name] = def
end

function PowerUps.spawn(name, x, y, opts)
    opts = opts or {}

    local def = PowerUps.types[name]
    if not def then
        print("[PowerUps] tipo inexistente: " .. tostring(name))
        return nil
    end

    local w = opts.w or 32
    local h = opts.h or 32

    local powerup = {
        name = name,
        x = x - w / 2,
        y = y - h,
        w = w,
        h = h,
        quad = def.quad,
        bobTimer = 0,
        collected = false,
        vy = 0,
        grounded = false,
    }

    table.insert(PowerUps.list, powerup)
    return powerup
end

function PowerUps.getRandom()
    local names = {"InfinityHealth", "Speed", "Jumper"}
    if #names == 0 then return nil end
    return names[math.random(1, #names)]
end

function PowerUps.spawnRandom(x, y, opts)
    local name = PowerUps.getRandom()
    if not name then return nil end
    return PowerUps.spawn(name, x, y, opts)
end

function PowerUps.apply(name, player)
    local def = PowerUps.types[name]
    if not def then return end

    local existing = PowerUps.active[name]

    if existing then
        existing.timeLeft = def.duration or existing.timeLeft
        if def.onRefresh then def.onRefresh(player, existing) end
        return
    end

    if def.onApply then def.onApply(player) end

    if def.duration then
        PowerUps.active[name] = {
            def = def,
            timeLeft = def.duration,
        }
    end
end

local function updatePhysics(powerup, dt)
    if powerup.grounded then return end

    powerup.vy = powerup.vy + GRAVITY * dt
    powerup.y = powerup.y + powerup.vy * dt

    for _, platform in ipairs(Platform.list) do
        if platform.canCollide and aabb(powerup.x, powerup.y, powerup.w, powerup.h, platform.x, platform.y, platform.w, platform.h) then
            if powerup.vy >= 0 then
                powerup.y = platform.y - powerup.h
                powerup.vy = 0
                powerup.grounded = true
            end
        end
    end
end

function PowerUps.update(dt, player)
    for _, powerup in ipairs(PowerUps.list) do
        if not powerup.collected then
            powerup.bobTimer = powerup.bobTimer + dt
            updatePhysics(powerup, dt)

            if aabb(player.x, player.y, player.width, player.height, powerup.x, powerup.y, powerup.w, powerup.h) then
                powerup.collected = true
                PowerUps.apply(powerup.name, player)

                local def = PowerUps.types[powerup.name]
                if def and def.onPickup then def.onPickup(player) end
            end
        end
    end

    for i = #PowerUps.list, 1, -1 do
        if PowerUps.list[i].collected then
            table.remove(PowerUps.list, i)
        end
    end

    for name, active in pairs(PowerUps.active) do
        active.timeLeft = active.timeLeft - dt

        if active.def.onTick then
            active.def.onTick(player, dt, active.timeLeft)
        end

        if active.timeLeft <= 0 then
            if active.def.onExpire then active.def.onExpire(player) end
            PowerUps.active[name] = nil
        end
    end
end

function PowerUps.isActive(name)
    return PowerUps.active[name] ~= nil
end

function PowerUps.getActive()
    for name, active in pairs(PowerUps.active) do
        return name, active.timeLeft
    end
    return nil, 0
end

function PowerUps.getTimeLeft(name)
    local active = PowerUps.active[name]
    return active and active.timeLeft or 0
end

function PowerUps.draw()
    for _, powerup in ipairs(PowerUps.list) do
        local bob = powerup.grounded and math.sin(powerup.bobTimer * 4) * 4 or 0

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Image, powerup.quad, powerup.x, powerup.y + bob, 0, powerup.w / 64, powerup.h / 64)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function PowerUps.clear()
    PowerUps.list = {}
    PowerUps.active = {}
end

return PowerUps