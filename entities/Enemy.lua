local Enemy = {}
Enemy.__index = Enemy

local Text   = require("engine.Interface.text")
local Signal = require("engine.Utils.signal")

Enemy.list   = {}
Enemy.onDied = Signal.new()

-- ============================================================
-- TIPOS DISPONÍVEIS:
--   "walker"   - patrulha básica, dano leve
--   "stomper"  - patrulha, morre se player pular em cima (Mario)
--   "tank"     - patrulha lenta, muito HP, dano pesado
--   "shooter"  - patrulha, para e atira quando player entra no range
--   "dasher"   - patrulha, faz dash quando player se aproxima
--
-- SPAWN:
--   Enemy:new("walker", x, y)
--   Enemy:new("walker", x, y, { patrolDist = 200 })
--   Enemy:new("walker", x, y, { sprite = love.graphics.newImage(...) })
--   Enemy:new("walker", x, y, {
--       sprite = img,
--       animations = {
--           walk = { frames = { q1, q2 }, speed = 0.15 },
--           idle = { frames = { q0 },    speed = 0.4  },
--       }
--   })
--
-- SIGNAL:
--   Enemy.onDied:connect(function(enemy)
--       print("morreu:", enemy.name, "em", enemy.x, enemy.y)
--   end)
-- ============================================================

function Enemy:new(enemyType, x, y, overrides)
    local templates = {
        walker = {
            name        = "Walker",
            health      = 30,
            damage      = 10,
            speed       = 70,
            width       = 32,
            height      = 32,
            color       = {1, 0.3, 0.3},
            patrolDist  = 120,
        },
        stomper = {
            name        = "Stomper",
            health      = 15,
            damage      = 20,
            speed       = 80,
            width       = 32,
            height      = 32,
            color       = {0.9, 0.6, 0.1},
            patrolDist  = 100,
            stompable   = true,
            stompHeight = 16,
        },
        tank = {
            name        = "Tank",
            health      = 120,
            damage      = 25,
            speed       = 28,
            width       = 48,
            height      = 48,
            color       = {0.4, 0.4, 0.9},
            patrolDist  = 80,
            knockbackResist = true,
        },
        shooter = {
            name             = "Shooter",
            health           = 40,
            damage           = 8,
            speed            = 45,
            width            = 30,
            height           = 34,
            color            = {0.8, 0.2, 0.8},
            patrolDist       = 150,
            shootCooldown    = 2.5,
            shootTimer       = 0,
            projectileDamage = 15,
            projectileSpeed  = 200,
            shootRange       = 280,
            isShooting       = false,
        },
        dasher = {
            name         = "Dasher",
            health       = 50,
            damage       = 18,
            speed        = 50,
            dashSpeed    = 420,
            width        = 28,
            height       = 36,
            color        = {0.2, 0.9, 0.7},
            patrolDist   = 130,
            dashRange    = 180,
            dashCooldown = 3,
            dashTimer    = 0,
            dashing      = false,
            dashDuration = 0.25,
            dashTimeLeft = 0,
            dashDirX     = 0,
        },
    }

    local t = templates[enemyType]
    assert(t, "Tipo de inimigo desconhecido: " .. tostring(enemyType))

    local enemy = {}
    for k, v in pairs(t) do enemy[k] = v end

    if overrides then
        for k, v in pairs(overrides) do
            if k ~= "animations" then
                enemy[k] = v
            end
        end
    end

    enemy.type        = enemyType
    enemy.x           = x
    enemy.y           = y
    enemy.maxHealth   = enemy.health
    enemy.projectiles = {}

    enemy.patrolOrigin = x
    enemy.patrolDir    = 1
    enemy.flip         = false

    enemy.sprite = overrides and overrides.sprite or nil
    enemy.anim   = nil

    if overrides and overrides.animations and overrides.sprite then
        enemy.anim = {
            animations = overrides.animations,
            current    = next(overrides.animations),
            frame      = 1,
            timer      = 0,
        }
    end

    setmetatable(enemy, self)
    table.insert(Enemy.list, enemy)
    return enemy
end

function Enemy:takeDamage(amount)
    if not self:isAlive() then return end
    self.health = math.max(self.health - amount, 0)
    if self.health <= 0 then
        Enemy.onDied:fire(self)
    end
end

function Enemy:isAlive()
    return self.health > 0
end

function Enemy:update(dt, player)
    if not self:isAlive() then return end

    local dx   = player.x - self.x
    local dy   = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if self.type == "walker" then
        self:_patrol(dt)

    elseif self.type == "stomper" then
        self:_patrol(dt)

    elseif self.type == "tank" then
        self:_patrol(dt)

    elseif self.type == "shooter" then
        if dist <= self.shootRange then
            self.isShooting = true
            self.shootTimer = self.shootTimer + dt
            if self.shootTimer >= self.shootCooldown then
                self.shootTimer = 0
                self:_shoot(player)
            end
            self:_setAnim("idle")
        else
            self.isShooting = false
            self:_patrol(dt)
        end
        self:_updateProjectiles(dt, player)

    elseif self.type == "dasher" then
        self.dashTimer = self.dashTimer + dt

        if self.dashing then
            self.dashTimeLeft = self.dashTimeLeft - dt
            self.x = self.x + self.dashDirX * self.dashSpeed * dt
            self.flip = self.dashDirX < 0
            if self.dashTimeLeft <= 0 then
                self.dashing = false
            end
            self:_setAnim("dash")
        else
            if dist <= self.dashRange and self.dashTimer >= self.dashCooldown then
                self.dashTimer    = 0
                self.dashing      = true
                self.dashTimeLeft = self.dashDuration
                self.dashDirX     = (dx ~= 0) and (dx / math.abs(dx)) or 0
            else
                self:_patrol(dt)
            end
        end
    end

    self:_updateAnim(dt)
end

function Enemy:draw()
    if not self:isAlive() then return end

    if self.sprite and self.anim then
        local a = self.anim
        local cur = a.animations[a.current]
        local frame = cur and cur.frames and cur.frames[a.frame]
        if frame then
            love.graphics.setColor(1, 1, 1)
            local scaleX = self.flip and -1 or 1
            local drawX  = self.flip and (self.x + self.width) or self.x
            love.graphics.draw(self.sprite, frame, drawX, self.y, 0, scaleX, 1)
        end
    elseif self.sprite then
        love.graphics.setColor(1, 1, 1)
        local scaleX = self.flip and -1 or 1
        local drawX  = self.flip and (self.x + self.width) or self.x
        love.graphics.draw(self.sprite, drawX, self.y, 0, scaleX, 1)
    else
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        love.graphics.setColor(0, 0, 0)
        local eyeX = self.flip
            and (self.x + self.width * 0.25 - 3)
            or  (self.x + self.width * 0.75 - 3)
        love.graphics.ellipse("fill", eyeX, self.y + self.height * 0.3, 4, 5)

        if self.type == "dasher" and self.dashing then
            love.graphics.setColor(1, 1, 0, 0.45)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        end

        if self.type == "shooter" and self.isShooting then
            love.graphics.setColor(1, 0.3, 1, 0.35)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        end
    end

    if self.type == "shooter" then
        love.graphics.setColor(1, 0.4, 1)
        for _, p in ipairs(self.projectiles) do
            love.graphics.circle("fill", p.x, p.y, 5)
        end
    end

    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", self.x, self.y - 10, self.width, 5)
    local hpRatio = self.health / self.maxHealth
    love.graphics.setColor(0.1 + 0.9 * (1 - hpRatio), 0.9 * hpRatio, 0.05)
    love.graphics.rectangle("fill", self.x, self.y - 10, self.width * hpRatio, 5)
    love.graphics.setColor(1, 1, 1, 1)

    Text:new(self.x, self.y - 25, "assets/fonts/PressStart2P-Regular.ttf", 5, self.name, {1, 1, 1}, 1, {0, 0, 0}):draw()
end

function Enemy.checkStomp(enemy, player)
    if not enemy.stompable then return false end
    if not enemy:isAlive() then return false end

    local playerBottom = player.y + player.height
    local enemyTop     = enemy.y
    local enemyMid     = enemy.y + enemy.height * 0.5

    local hOverlap =
        player.x < enemy.x + enemy.width and
        player.x + player.width > enemy.x

    local cameFromAbove
    if player.lastY then
        local prevBottom = player.lastY + player.height
        cameFromAbove = prevBottom <= enemyMid
    else
        cameFromAbove = (player.vy and player.vy > 0) or (playerBottom < enemyMid + 8)
    end

    return hOverlap and cameFromAbove
end

function Enemy:isTouching(player)
    return
        self.x < player.x + player.width and
        self.x + self.width > player.x   and
        self.y < player.y + player.height and
        self.y + self.height > player.y
end

function Enemy.updateAll(dt, player)
    for _, e in ipairs(Enemy.list) do
        e:update(dt, player)

        if e:isAlive() and e:isTouching(player) then
            if Enemy.checkStomp(e, player) then
                Enemy.remove(e)
                Enemy.onDied:fire(e)
                if player.bounceJump then player:bounceJump() end
            else
                if player.takeDamage then
                    player:takeDamage(e.damage)
                end
            end
        end
    end

    for i = #Enemy.list, 1, -1 do
        if not Enemy.list[i]:isAlive() then
            table.remove(Enemy.list, i)
        end
    end
end

function Enemy.drawAll()
    for _, e in ipairs(Enemy.list) do
        e:draw()
    end
end

function Enemy.remove(enemy)
    for i, e in ipairs(Enemy.list) do
        if e == enemy then
            table.remove(Enemy.list, i)
            break
        end
    end
end

function Enemy.clear()
    Enemy.list = {}
end

function Enemy:_patrol(dt)
    local dest = self.patrolOrigin + self.patrolDir * self.patrolDist

    if self.patrolDir == 1 and self.x >= dest then
        self.patrolDir = -1
    elseif self.patrolDir == -1 and self.x <= self.patrolOrigin - self.patrolDist then
        self.patrolDir = 1
    end

    self.x    = self.x + self.patrolDir * self.speed * dt
    self.flip = self.patrolDir < 0

    self:_setAnim("walk")
end

function Enemy:_setAnim(name)
    if not self.anim then return end
    if not self.anim.animations[name] then return end
    if self.anim.current == name then return end
    self.anim.current = name
    self.anim.frame   = 1
    self.anim.timer   = 0
end

function Enemy:_updateAnim(dt)
    if not self.anim then return end
    local a   = self.anim
    local cur = a.animations[a.current]
    if not cur then return end

    a.timer = a.timer + dt
    if a.timer >= cur.speed then
        a.timer = 0
        a.frame = a.frame + 1
        if a.frame > #cur.frames then
            a.frame = 1
        end
    end
end

function Enemy:_shoot(player)
    local dx   = player.x - self.x
    local dy   = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 1 then return end

    table.insert(self.projectiles, {
        x  = self.x + self.width / 2,
        y  = self.y + self.height / 2,
        vx = (dx / dist) * self.projectileSpeed,
        vy = (dy / dist) * self.projectileSpeed,
    })
end

function Enemy:_updateProjectiles(dt, player)
    for i = #self.projectiles, 1, -1 do
        local p = self.projectiles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        if player.takeDamage then
            local px, py = player.x, player.y
            local pw     = player.width  or 16
            local ph     = player.height or 32
            if p.x >= px and p.x <= px + pw and p.y >= py and p.y <= py + ph then
                player:takeDamage(self.projectileDamage)
                table.remove(self.projectiles, i)
            end
        end

        local sw = love.graphics.getWidth()
        local sh = love.graphics.getHeight()
        if p.x < -20 or p.x > sw + 20 or p.y < -20 or p.y > sh + 20 then
            table.remove(self.projectiles, i)
        end
    end
end

return Enemy