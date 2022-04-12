local game = {
    entities = {
        block = function(_, x, y, w, h, texture, normal, glow)
            local ent = _Internal.Entity()
            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Occluder())
            ent:addComponent(_Components.Texture(texture, normal, glow), 4)

            ent:addComponent(_Components.PhysicsBody(x, y, w, h))
            ent:addComponent(_Components.RigidBody())
            ent:addComponent(_Components.PhysicsGridUpdater())

            return ent
        end,

        light = function(self, x, y, z, r, g, b, range, smoothing)
            local light = self.world.lightWorld:newLight(x, y, r, g, b, range)
            light:setPosition(x, y, z)
            light:setSmooth(smoothing)

            return light
        end
    },

    __call = function(self, worldW, worldH, worldD, worldAmbience)
        self.stack =_Internal.Stack()
        self.world = _Internal.World(worldW, worldH, worldD, worldAmbience)
        self.worldIndex = self.stack:addScene(self.world)

        self.stack:setScene(self.worldIndex)
        self.world:setAmbience(unpack(worldAmbience or {1, 1, 1}))

        return self.stack, self.world, self.worldIndex
    end
}

game.entities.__index = game
game.__index = game

setmetatable(game.entities, game)
return setmetatable(game, game)