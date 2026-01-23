local Components = require("engine.EntitySystem.Components")

local Systems = {}

function Systems.update(dt)
    -- MOVEMENT
    for e, pos in pairs(Components.Position) do
        local vel = Components.Velocity[e]
        if vel then
            pos.x = pos.x + vel.x * dt
            pos.y = pos.y + vel.y * dt
        end
    end

    -- ANIMATION
    for e, anim in pairs(Components.Animation) do
        local animData = anim.animations[anim.current]
        if animData and #animData.frames > 1 then
            anim.timer = anim.timer + dt
            if anim.timer >= anim.speed then
                anim.timer = anim.timer - anim.speed
                anim.frame = anim.frame + 1
                if anim.frame > #animData.frames then
                    anim.frame = 1
                end
            end
        else
            anim.frame = 1
            anim.timer = 0
        end
    end
end

function Systems.draw()
    for e, sprite in pairs(Components.Sprite) do
        local pos = Components.Position[e]
        if pos then
            local anim = Components.Animation[e]
            local scale = sprite.scale or 1

            if anim then
                local quad = anim.animations[anim.current].frames[anim.frame]

                -- tamanho do frame (tu usa 32x32)
                local fw, fh = 32, 32

                -- flip horizontal
                local sx = sprite.flip and -scale or scale
                local ox = sprite.flip and (fw * scale) or 0

                love.graphics.draw(
                    sprite.image,
                    quad,
                    pos.x + ox, pos.y,
                    0,
                    sx, scale
                )
            else
                -- sem animação: desenha normal (com scale)
                local sx = sprite.flip and -scale or scale
                local ox = sprite.flip and (sprite.image:getWidth() * scale) or 0
                love.graphics.draw(sprite.image, pos.x + ox, pos.y, 0, sx, scale)
            end
        end
    end
end

return Systems
