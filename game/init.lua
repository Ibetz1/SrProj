local controller = require("game/components/Controller")

local game = {
    entities = {
        block = function(_, x, y, w, h, texture, normal, glow, options)
            local options = options or {}

            local ent = _Internal.Entity()
            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Texture(texture, normal, glow, {
                w = w, h = h,
                offset = Vector(options.ox or 0, options.oy or 0),
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

        wall = function(_, x, y, texture, normal, glow, tw, th, options)
            local options = options or {}
            local tx, nm, gl

            if texture then tx = batchedImage(texture, tw, th) end
            if normal then nm = batchedImage(normal, tw, th) end
            if glow then gl = batchedImage(normal, tw, th) end

            local tw, th = tw * (texture.w or _Constants.Tilesize), th * (texture.h or _Constants.Tilesize)

            local ent = _Internal.Entity()
            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Texture(tx, nm, gl, {
                w = options.ow or tw, h = options.oh or th,
                offset = Vector(options.ox or 0, options.oy or 0),
                occlude = true
            }))

            ent:addComponent(_Components.PhysicsBody(x, y, options.cw or tw, options.ch or th, {
                static = true
            }))

            ent:addComponent(_Components.RigidBody())
            ent:addComponent(_Components.PhysicsGridUpdater())

            return ent
        end,

        tiledImage = function(_, x, y, texture, normal, glow, tw, th, options)
            local options = options or {}
            local tx, nm, gl

            if texture then tx = batchedImage(texture, tw, th) end
            if normal then nm = batchedImage(normal, tw, th) end
            if glow then gl = batchedImage(normal, tw, th) end

            local ent = _Internal.Entity()
            ent:addComponent(_Components.Texture(tx, nm, gl, {
                w = 0, h = 0,
                occlude = false
            }))

            ent:addComponent(_Components.WorldBody(x, y, options.cw or tw, options.ch or th))

            return ent
        end,

        quadedImage = function(_, x, y, w, h, texture, normal, glow, options)
            local options = options or {}

            local ent = _Internal.Entity()

            ent:addComponent(_Components.Texture(texture, normal, glow, {
                w = w or options.ow, h = h or options.oh,
                occlude = false
            }))

            ent:addComponent(_Components.WorldBody(x, y, options.cw or tw, options.ch or th))
            return ent
        end,


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

        local sideWallTex = imageQuad(_Assets.tileset, 0, 0, 16, 32)
        local sideWallNorm = imageQuad(_Assets.tileset, 32, 0, 16, 32)
        local frontWallTex = imageQuad(_Assets.tileset, 0, 0, 16, 16)
        local fromWallNorm = imageQuad(_Assets.tileset, 32, 0, 16, 16)

        local leftPlayerTex = imageQuad(_Assets.tileset, 16, 0, 16, 16)
        local leftPlayerNorm = imageQuad(_Assets.tileset, 48, 0, 16, 16)
        local leftPlayerGlow = imageQuad(_Assets.tileset, 80, 0, 16, 16)

        local downPlayerTex = imageQuad(_Assets.tileset, 16, 16, 16, 16)
        local downPlayerNorm = imageQuad(_Assets.tileset, 48, 16, 16, 16)
        local downPlayerGlow = imageQuad(_Assets.tileset, 80, 16, 16, 16)

        local rightPlayerTex = imageQuad(_Assets.tileset, 16, 32, 16, 16)
        local rightPlayerNorm = imageQuad(_Assets.tileset, 48, 32, 16, 16)
        local rightPlayerGlow = imageQuad(_Assets.tileset, 80, 32, 16, 16)

        local upPlayerTex = imageQuad(_Assets.tileset, 16, 48, 16, 16)
        local upPlayerNorm = imageQuad(_Assets.tileset, 48, 48, 16, 16)
        local upPlayerGlow = imageQuad(_Assets.tileset, 80, 48, 16, 16)

        local floorTile = imageQuad(_Assets.tileset, 0, 32, 16, 16)
        
        local goalTex = imageQuad(_Assets.tileset, 0, 48, 16, 16)
        local goalNorm = imageQuad(_Assets.tileset, 32, 48, 16, 16)
        local goalGlow = imageQuad(_Assets.tileset, 64, 48, 16, 16)

        local player = game.entities:block(32, 32, 16, 13,                                   
                                    batchedImage(leftPlayerTex, 1, 1),
                                    batchedImage(leftPlayerNorm, 1, 1),
                                    batchedImage(leftPlayerGlow, 1, 1), 
                                    {
                                       ox = 0, oy = 3
                                    })

        local topWall = game.entities:wall(0, 0, sideWallTex, sideWallNorm, nil, tw, 1,
        {
            ox = 0, oy = 16, oh = 16, ch = 29
        })

        local bottomWall = game.entities:wall(0, (th - 1) * _Constants.Tilesize, frontWallTex,  fromWallNorm, nil, tw, 1,
        {
            ox = 0, oy = 16, oh = 16
        })

        local leftWall = game.entities:wall(0, _Constants.Tilesize, frontWallTex, fromWallNorm, nil, 1, th - 2,
        {
            ox = 0, oy = 0
        })

        local rightWall = game.entities:wall(_Constants.Tilesize * (tw - 1), _Constants.Tilesize, frontWallTex,  fromWallNorm, nil, 1, th - 2,
        {
            ox = 0, oy = 0
        })

        local floor = game.entities:tiledImage(0, 0, floorTile, nil, nil, tw, th)
        local goalTex = game.entities:quadedImage(math.floor(tw / 2) * _Constants.Tilesize, math.floor(th / 2) * _Constants.Tilesize, 16, 16, 
                                        batchedImage(goalTex, 1, 1), 
                                        batchedImage(goalNorm, 1, 1), 
                                        batchedImage(goalGlow, 1, 1))

        
        world:addEntity(floor, 1)
        world:addEntity(goalTex, 1)

        player:addComponent(controller())
        world:addEntity(player, 2)

        -- walls
        world:addEntity(topWall, 2)
        world:addEntity(bottomWall, 2)
        world:addEntity(leftWall, 2)
        world:addEntity(rightWall, 2)

        world.lightWorld:setBufferWindow(tw * _Constants.Tilesize * world.lightWorld.scale.x, 
                                        ((th) * _Constants.Tilesize * world.lightWorld.scale.y))

        local light = _Lighting.Light((tw / 2) * _Constants.Tilesize, (th / 2) * _Constants.Tilesize, 200, {0.5, 1, 1})
        world.lightWorld:addLight(light)
    end
}

game.entities.__index = game
game.__index = game

setmetatable(game.entities, game)
return setmetatable(game, game)