local Enemy = {}

local Enemies = {
    {
        name = "name",
        health = 30,
        attack = 5,
        defense = 2,
        sprite = "assets/entities/npcs/name.png",

        onDeath = function(self)
            print(self.name .. " has been defeated!")
        end
    },
}

function Enemy:new(type)
    local enemy = Enemies[type]
    if not enemy then
        error("Invalid enemy type: " .. tostring(type))
    end
    setmetatable(enemy, self)
    self.__index = self
    return enemy
end

function Enemy:attack(target)
    local damage = math.max(self.attack - target.defense, 0)
    target.health = target.health - damage
    return damage
end

function Enemy:isAlive()
    return self.health > 0
end

function Enemy:checkHealth()
    if self.health <= 0 then
        self.health = 0
        self:onDeath()
    end
end

function Enemy:TakeDamage(amount)
    if not Enemy:isAlive() then
        return
    end
    
    self.health = self.health - amount
end

return Enemy