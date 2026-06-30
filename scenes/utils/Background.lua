local Background = {}

local stars = {}
local NUM_STARS = 60
local initialized = false

Background.titleGlow = 0
Background.titleGlowDir = 1
Background.image = nil

local function initStars()
    stars = {}
    for i = 1, NUM_STARS do
        stars[i] = {
            x = math.random(0, BASE_WIDTH),
            y = math.random(0, BASE_HEIGHT),
            size = math.random() * 1.8 + 0.4,
            alpha = math.random() * 0.6 + 0.2,
            speed = math.random() * 12 + 4,
            twinkleOffset = math.random() * math.pi * 2,
        }
    end
end

function Background.load()
    if initialized then return end
    initialized = true
    math.randomseed(os.time())
    initStars()
    Background.image = love.graphics.newImage("assets/background/Menu.png")
end

function Background.update(dt)
    Background.titleGlow = Background.titleGlow + dt * Background.titleGlowDir * 1.2
    if Background.titleGlow >= 1 then Background.titleGlowDir = -1
    elseif Background.titleGlow <= 0 then Background.titleGlowDir = 1 end

    for _, s in ipairs(stars) do
        s.y = s.y + s.speed * dt
        if s.y > BASE_HEIGHT + 4 then
            s.y = -4
            s.x = math.random(0, BASE_WIDTH)
        end
    end
end

function Background.draw()
    local t = love.timer.getTime()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Background.image, -300, -280, 0, 0.7, 0.7)

    love.graphics.setColor(0.02, 0.05, 0.15, 0.45)
    love.graphics.rectangle("fill", 0, 0, BASE_WIDTH, BASE_HEIGHT)

    for _, s in ipairs(stars) do
        local twinkle = 0.5 + 0.5 * math.sin(t * 2.5 + s.twinkleOffset)
        love.graphics.setColor(0.85, 0.93, 1.0, s.alpha * twinkle)
        love.graphics.circle("fill", s.x, s.y, s.size)
    end
end

return Background