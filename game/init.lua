local game = {
    entities = {
        block = function(_, x, y, w, h, texture, normal, glow)
            local ent = _Internal.Entity()
            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Texture(texture, normal, glow), 4)

            ent:addComponent(_Components.PhysicsBody(x, y, w, h))
            ent:addComponent(_Components.RigidBody())
            ent:addComponent(_Components.PhysicsGridUpdater())

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

game.entities.__index = game
game.__index = game

setmetatable(game.entities, game)
return setmetatable(game, game)