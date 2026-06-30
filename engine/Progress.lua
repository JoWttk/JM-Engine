-- engine/Progress.lua
local Progress = {}

local Save = require("engine.Save")

local WORLDS = 3
local LEVELS_PER_WORLD = 6

local data = {}

local function key(world, level)
    return "W" .. world .. "L" .. level
end

function Progress.load()
    data = Save.read("progress.txt") or {}

    -- Garante que Level1 de cada mundo sempre comeca destrancado
    for w = 1, WORLDS do
        local k = key(w, 1)
        if data[k] == nil then
            data[k] = false  -- false = destrancado
        end
    end

    -- Preenche o resto como trancado se não existir
    for w = 1, WORLDS do
        for l = 2, LEVELS_PER_WORLD do
            local k = key(w, l)
            if data[k] == nil then
                data[k] = true  -- true = trancado
            end
        end
    end
end

function Progress.save()
    Save.write("progress.txt", data)
end

function Progress.isLocked(world, level)
    local k = key(world, level)
    if data[k] == nil then return level ~= 1 end
    return data[k]
end

-- Chamar quando o jogador completa uma fase
function Progress.completeLevel(world, level)
    local nextLevel = level + 1
    if nextLevel <= LEVELS_PER_WORLD then
        data[key(world, nextLevel)] = false  -- destranca a próxima
    end
    Progress.save()
end

return Progress

-- AI