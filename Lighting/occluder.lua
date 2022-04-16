local occluder = Object:new()

function occluder:init(x, y, w, h, settings)
    local w, h = w or 0, h or 0

    self.position = Vector(x, y); self.position.z = 1
    self.w, self.h = w, h

    -- optional
    self.texture = nil
    self.normal = nil
    self.glow = nil

    for name, val in pairs(settings or {}) do
        self[name] = val
    end

    self:sizeMatrix(w, h)

    self.mesh = love.graphics.newMesh(self.matrix, "strip")
end

-- defines shadow transform
function occluder:defineShadowTransform(lx, ly, l)
    local cx, cy = self.position.x + self.w / 2, self.position.y + self.h / 2
    local dx, dy = lx - cx, ly - cy

    -- y align
    if (lx > self.position.x and lx < self.position.x + self.w) then
        _ = (dy < 0) or self.shadowMatrix:map(self.matrix, {3, 4})
        _ = (dy > 0) or self.shadowMatrix:map(self.matrix, {1, 2})
    -- x align
    elseif (ly  > self.position.y and ly < self.position.y + self.w) then
        _ = (dx < 0) or self.shadowMatrix:map(self.matrix, {2, 3})
        _ = (dx > 0) or self.shadowMatrix:map(self.matrix, {1, 4})
    -- diagonal align
    else
        _ = (dy / dx < 0) or self.shadowMatrix:map(self.matrix, {2, 4})
        _ = (dy / dx > 0) or self.shadowMatrix:map(self.matrix, {1, 3})
    end
    
    -- apply shadow transform
    for i = 2, 1, -1 do
        local px, py = self.shadowMatrix[i][1], self.shadowMatrix[i][2]
        local dx, dy = lx - px - self.position.x, ly - py - self.position.y
        local theta = math.atan2(dx, dy)
        
        self.shadowMatrix[i + 2][1] = px - math.sin(theta) * (l or 0)
        self.shadowMatrix[i + 2][2] = py - math.cos(theta) * (l or 0)
    end
end

-- renders shadow
function occluder:renderShadow(lx, ly, length)
    -- define transform matrix
    if not aabb(self.position.x, self.position.y, self.w, self.h, lx, ly, 0, 0) then
        
        self:defineShadowTransform(lx, ly, length)

    end

    -- apply matrix to mesh
    self.mesh:setVertices(self.shadowMatrix)

    love.graphics.rectangle("fill", self.position.x, self.position.y, self.w, self.h)
    love.graphics.draw(self.mesh, self.position.x, self.position.y)
end

-- draws texture
function occluder:drawTexture()
    if not self.texture then return end

    love.graphics.draw(self.texture, self.position.x, self.position.y)
end

-- sets texture
function occluder:setTexture(tex, resize)
    self.texture = tex

    if resize then
        self.w, self.h = tex:getWidth(), tex:getHeight()
        self:sizeMatrix(self.w, self.h)
    end
end

-- sets normal
function occluder:setNormal(normal)
    self.normal = normal
end

-- resizes matrices
function occluder:sizeMatrix(w, h)
    self.matrix = Matrix {
        {0, 0}, 
        {w, 0}, 
        {w, h}, 
        {0, h}
    }

    self.shadowMatrix = Matrix {
        {0, 0}, {0, 0}, {0, 0}, {0, 0}
    }
end

-- checks if light in range
function occluder:inRange(lx, ly, d)
    local dsq = d * d
    for i = 1, #self.matrix do
        local px, py = self.matrix[i][1] + self.position.x, self.matrix[i][2] + self.position.y
        local dx, dy = px - lx, py - ly

        if dx * dx + dy * dy < dsq then return true end
    end

    return false
end

-- sets world
function occluder:setWorld(world)
    self.world = world
end

return occluder