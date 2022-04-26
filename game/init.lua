local renderToGrid = function(tw, th, w, h, tex)
     for x = 0, tw -1 do
         for y = 0, th - 1 do
             local px, py = x * w, y * h

             love.graphics.draw(tex, px, py)
         end
     end

end

local controller = require("game/components/Controller")

local game = {
    entities = {
        block = function(_, x, y, w, h, texture, normal, glow, ox, oy)
            local ent = _Internal.Entity()
            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Texture(texture, normal, glow, {
                w = w, h = h,
                offset = Vector(ox, oy),
                occlude = true
            }))

            ent:addComponent(_Components.PhysicsBody(x, y, w, h, {
                directionalLimits = {
                    {-1, 1}, {-1, 1}
                }
            }))
            ent:addComponent(_Components.RigidBody())
            ent:addComponent(_Components.PhysicsGridUpdater())

            return ent
        end,

        wall = function(_, x, y, tw, th, w, h, tex, norm, glow, ox, oy)
            local ent = _Internal.Entity()

            local w, h = w or tw * _Constants.Tilesize, h or th * _Constants.Tilesize
            local texw, texh = tw * _Constants.Tilesize, th * _Constants.Tilesize

            if tex then texw, texh = tw * tex:getWidth(), th * tex:getHeight() end

            -- make texture map
            local normal, glowMap
            local texture = love.graphics.newCanvas(texw, texh)

            love.graphics.setCanvas(texture); renderToGrid(tw, th, w, h, tex)

            -- make normal map
            if norm then
                normal = love.graphics.newCanvas(texw, texh) 
                love.graphics.setCanvas(normal); renderToGrid(tw, th, w, h, norm)
            end

            -- make glow map
            if glow then 
                glowMap = love.graphics.newCanvas(texw, texh) 
                love.graphics.setCanvas(glowMap); renderToGrid(tw, th, w, h, glow)
            end

            love.graphics.setCanvas()

            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Texture(texture, normal, glowMap, {
                w = tw * w, h = th * h,
                offset = Vector(ox, oy),
                occlude = true
            }))

            ent:addComponent(_Components.PhysicsBody(x, y, tw * w, th * h, {static = true}))
            ent:addComponent(_Components.RigidBody())
            ent:addComponent(_Components.PhysicsGridUpdater())

            return ent
        end,

        tile = function(_, x, y, tex, norm, glow, tw, th)
            local w, h = tex:getWidth(), tex:getHeight()

            local ent = _Internal.Entity()

            -- render texture
            local texture = love.graphics.newCanvas(w * tw, h * th)
            love.graphics.setCanvas(texture); renderToGrid(tw, th, w, h, tex)

            local normal, glowMap

            -- render normal if needed
            if norm then 
                normal = love.graphics.newCanvas(w * tw, h * th)
                love.graphics.setCanvas(normal); renderToGrid(tw, th, w, h, norm)
            end

            -- render glow if needed
            if glow then 
                glowMap = love.graphics.newCanvas(w * tw, h * th)
                love.graphics.setCanvas(glowMap); renderToGrid(tw, th, w, h, glow)
            end
            
            love.graphics.setCanvas()


            ent:addComponent(_Components.WorldBody(x, y, tw * w, th * h))
            ent:addComponent(_Components.Texture(texture, normal, glowMap, {
                w = 0, h = 0,
                offset = Vector(),
                occlude = false
            }))
            
            
            return ent
        end
    },

    __call = function(self, worldW, worldH, worldD, worldAmbience)
        self.stack =_Internal.Stack()
        self.world = _Internal.World(worldW, worldH, worldD, worldAmbience)
        self.worldIndex = self.stack:addScene(self.world)

        self.stack:setScene(self.worldIndex)
        return self.stack, self.world, self.worldIndex
    end
}

game.constructors = {
    gameWorld1 = function(_, world, tw, th)

        local topWall = game.entities:wall(32, 0, tw - 1, 1, 32, 24,                              
                                   _Assets.machine,
                                   _Assets.machine_normal,
                                   _Assets.machine_glow, 0, 22)

        local leftWall = game.entities:wall(0, 0, 1, th, 32, 24,                              
                                   _Assets.machine,
                                   _Assets.machine_normal,
                                   _Assets.machine_glow, 0, 22)

        local bottomWall = game.entities:wall(32, 24 * (th - 1), tw - 1, 1, 32, 24,                              
                                   _Assets.machine,
                                   _Assets.machine_normal,
                                   _Assets.machine_glow, 0, 22)

        local rightWall = game.entities:wall((tw - 1) * 32, 24, 1, th - 2, 32, 24,                              
                                   _Assets.machine,
                                   _Assets.machine_normal,
                                   _Assets.machine_glow, 0, 22)

        local background = game.entities:tile(0, 0, _Assets.brick, nil, nil, tw, th)

        local player = game.entities:block(64, 64, 32, 24,                                   
                                   _Assets.machine,
                                   _Assets.machine_normal,
                                   _Assets.machine_glow, 0, 22)
        
        player:addComponent(controller())

        world:addEntity(background, 1)
        world:addEntity(topWall, 1)
        world:addEntity(leftWall, 1)
        world:addEntity(bottomWall, 1)
        world:addEntity(rightWall, 1)
        world:addEntity(player, 1)

        world.lightWorld:setBufferWindow(tw * 32 * world.lightWorld.scale.x, 
                                        (th * 24 * world.lightWorld.scale.y))
    end
}

game.entities.__index = game
game.__index = game

setmetatable(game.entities, game)
return setmetatable(game, game)