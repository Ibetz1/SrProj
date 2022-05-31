local pipeline = Object:new()

function pipeline:init()
    self.layers = {}

    self:setBuffers()
end

function pipeline:clear()
    self.layers = {}
end

-- resets pipeline buffers
function pipeline:setBuffers(w, h)
    local w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    self.buffer = love.graphics.newCanvas(w, h)
end

-- adds a layer as a function
function pipeline:addLayer(func, ...)
    table.insert(self.layers, {
        func, {...}
    })

    return #self.layers
end

-- execute pipeline layers onto pipeline buffer
function pipeline:update()
    self.buffer:renderTo(function()
        love.graphics.clear()
        love.graphics.origin()

        for i = 1, #self.layers do
            love.graphics.push()

                self.layers[i][1](unpack(self.layers[i][2]))
            
            love.graphics.pop()
        end
    end)

end

-- render the pipeline
function pipeline:draw()
    love.graphics.scale(_Screen.aspectRatio.x, _Screen.aspectRatio.y) 

    love.graphics.draw(self.buffer)
end

return pipeline