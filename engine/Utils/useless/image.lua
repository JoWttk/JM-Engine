local image = {}

function image:PutAbovePlayer(addImage, player, x, y)
    local playerX, playerY = player.getPosition()
    local playerWidth, playerHeight = player.getDimensions()
    
    local loadedImage= love.graphics.newImage(addImage)

    local imageX = playerX + (playerWidth / 2) - (loadedImage:getWidth() / 2) + (x or 0)
    local imageY = playerY - loadedImage:getHeight() + (y or 0)
    
    love.graphics.draw(loadedImage, imageX, imageY)
end

return image