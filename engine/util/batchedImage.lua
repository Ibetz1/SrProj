return function(image, tw, th, qw, qh)
    local qw, qh = qw or image.w or image:getWidth(), qh or image.h or image:getHeight()
    if type(image) ~= "table" then image = {image = image} end

    local canvas = love.graphics.newCanvas(tw * qw, th * qh)
    love.graphics.setCanvas(canvas)

    for x = 0, tw - 1 do
        for y = 0, th - 1 do
            local px, py = x * qw, y * qh

            if image.quad then
                love.graphics.draw(image.image, image.quad, px, py)
            else
                love.graphics.draw(image.image, px, py)
            end

        end
    end

    love.graphics.setCanvas()

    return canvas
end