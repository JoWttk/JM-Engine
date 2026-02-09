local combat = {}

function combat.attack(attacker, target)
    local damage = math.max(attacker.attack - target.defense, 0)
    target.health = target.health - damage
    return damage
end

return combat