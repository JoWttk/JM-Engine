local Image = {}

Image.list = {}

function Image.new(path, x,y, width,height, scale)
    local img = {
        path = path,
        x = x,
        y = y,
        width = width,
        height = height,
        scale = scale
    }

    table.insert(Image.list, img)
    return img
end

function Image.draw()
    for _, img in ipairs(Image.list) do
        local image = love.graphics.newImage(img.path)
        love.graphics.draw(image, img.x, img.y, 0, img.scale or 1, img.scale or 1)
    end
end

function Image.clear()
    Image.list = {}
end

return Image