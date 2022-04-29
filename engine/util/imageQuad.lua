return function(image, qx, qy, qw, qh)
    local iw, ih = image:getWidth(), image:getHeight()

    return {
        w = qw, h = qh,
        quad = love.graphics.newQuad(qx, qy, qw, qh, iw, ih),
        image = image
    }
end