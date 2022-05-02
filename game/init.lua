local BodyController = require("game.components.BodyController")
local BodyDetector = require("game.components.BodyDetector")
local BodySelector = require("game.components.BodySelector")
local BodyTweener = require("game.components.BodyTweener")

_Game.selected = nil

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

            -- game components
            ent:addComponent(BodyTweener(options.tweenSpeed or 0.5))

            local selector = BodySelector(
            -- on hover
            function()
                if not glow then return end
                local tex = ent.texture.body
                


                if tex.glow ~= glow and _Game.selected ~= ent.id then
                    tex.glow = glow

                end

            end,

            -- on selected
            function()
                local gl = options.selectedGlow
                if not gl then return end

                local tex = ent.texture.body

                if tex.glow ~= gl then
                    tex.glow = gl
                end
            end)
            
            ent:addComponent(selector)

            local dx, dy = 0, 0
            if options.direction then
                dx, dy = options.direction[1], options.direction[2]
            end

            ent:addComponent(BodyController(dx, dy, options.ww, options.wh))


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

        goal = function(_, x, y, w, h, options)
            local options = options or {}

            local ent = _Internal.Entity()


            ent:addComponent(_Components.PhysicsBody(x, y, w, h, {
                static = true
            }))

            ent:addComponent(BodyDetector)
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
        local leftPlayerGlowHover = imageQuad(_Assets.tileset, 80, 0, 16, 16)
        local leftPlayerGlowSelect = imageQuad(_Assets.tileset, 96, 0, 16, 16)

        local downPlayerTex = imageQuad(_Assets.tileset, 16, 16, 16, 16)
        local downPlayerNorm = imageQuad(_Assets.tileset, 48, 16, 16, 16)
        local downPlayerGlowHover = imageQuad(_Assets.tileset, 80, 16, 16, 16)
        local downPlayerGlowSelect = imageQuad(_Assets.tileset, 96, 16, 16, 16)

        local rightPlayerTex = imageQuad(_Assets.tileset, 16, 32, 16, 16)
        local rightPlayerNorm = imageQuad(_Assets.tileset, 48, 32, 16, 16)
        local rightPlayerGlowHover = imageQuad(_Assets.tileset, 80, 32, 16, 16)
        local rightPlayerGlowSelect = imageQuad(_Assets.tileset, 96, 32, 16, 16)

        local upPlayerTex = imageQuad(_Assets.tileset, 16, 48, 16, 16)
        local upPlayerNorm = imageQuad(_Assets.tileset, 48, 48, 16, 16)
        local upPlayerGlowHover = imageQuad(_Assets.tileset, 80, 48, 16, 16)
        local upPlayerGlowSelect = imageQuad(_Assets.tileset, 96, 48, 16, 16)

        local floorTile = imageQuad(_Assets.tileset, 0, 32, 16, 16)
        local floorNormal = imageQuad(_Assets.tileset, 32, 32, 16, 16)
        
        local goalTex = imageQuad(_Assets.tileset, 0, 48, 16, 16)
        local goalNorm = imageQuad(_Assets.tileset, 32, 48, 16, 16)
        local goalGlow = imageQuad(_Assets.tileset, 64, 48, 16, 16)

        local playerLeft = game.entities:block((tw - 3) * 16, (th - 3) * 16, 16, 13,                                   
                                    batchedImage(leftPlayerTex, 1, 1),
                                    batchedImage(leftPlayerNorm, 1, 1),
                                    batchedImage(leftPlayerGlowHover, 1, 1), 
                                    {
                                       ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                       selectedGlow = batchedImage(leftPlayerGlowSelect, 1, 1), direction = {-1, 0}
                                    })

        local playerRight = game.entities:block(32, 48, 16, 13,                                   
                                    batchedImage(rightPlayerTex, 1, 1),
                                    batchedImage(rightPlayerNorm, 1, 1),
                                    batchedImage(rightPlayerGlowHover, 1, 1), 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = batchedImage(rightPlayerGlowSelect, 1, 1), direction = {1, 0}
                                    })

        local playerDown = game.entities:block((tw - 3) * 16, 48, 16, 13,                                   
                                    batchedImage(downPlayerTex, 1, 1),
                                    batchedImage(downPlayerNorm, 1, 1),
                                    batchedImage(downPlayerGlowHover, 1, 1), 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = batchedImage(downPlayerGlowSelect, 1, 1), direction = {0, 1}
                                    })
        
        local playerUp = game.entities:block(32, (th - 3) * 16, 16, 13,                                   
                                    batchedImage(upPlayerTex, 1, 1),
                                    batchedImage(upPlayerNorm, 1, 1),
                                    batchedImage(upPlayerGlowHover, 1, 1), 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = batchedImage(upPlayerGlowSelect, 1, 1), direction = {0, -1}
                                    })



        local topWall = game.entities:wall(0, 0, sideWallTex, sideWallNorm, nil, tw, 1,
        {
            ox = 0, oy = 16, oh = 16, ch = 29
        })

        local bottomWall = game.entities:wall(0, (th - 1) * _Constants.Tilesize, frontWallTex,  fromWallNorm, nil, tw, 1,
        {
            ox = 0, oy = 16, oh = 16
        })

        local leftWall = game.entities:wall(0, 0, frontWallTex, fromWallNorm, nil, 1, th,
        {
            ox = 0, oy = 0
        })

        local rightWall = game.entities:wall(_Constants.Tilesize * (tw - 1), 0, frontWallTex,  fromWallNorm, nil, 1, th,
        {
            ox = 0, oy = 0
        })

        bottomWall.onremove = f

        local floor = game.entities:tiledImage(0, 0, floorTile, batchedImage(floorNormal, 1, 1), nil, tw, th)
        local goalTex = game.entities:quadedImage(math.floor(tw / 2) * _Constants.Tilesize, math.floor(th / 2) * _Constants.Tilesize, 16, 16, 
                                        batchedImage(goalTex, 1, 1), 
                                        batchedImage(goalNorm, 1, 1), 
                                        batchedImage(goalGlow, 1, 1))
        local goalDetector = game.entities:goal(math.floor(tw / 2) * _Constants.Tilesize, math.floor(th / 2) * _Constants.Tilesize, 16, 16)
        
        world:addEntity(floor, 1)
        world:addEntity(goalTex, 1)
        world:addEntity(goalDetector, 2)

        -- player
        world:addEntity(playerLeft, 2)
        world:addEntity(playerRight, 2)
        world:addEntity(playerDown, 2)
        world:addEntity(playerUp, 2)

        -- walls
        world:addEntity(topWall, 2)
        world:addEntity(bottomWall, 2)
        world:addEntity(leftWall, 2)
        world:addEntity(rightWall, 2)

        world:setScale(
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize),
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize)
        )

        world.lightWorld:setBufferWindow(tw * _Constants.Tilesize * world.lightWorld.scale.x, 
                                        ((th) * _Constants.Tilesize * world.lightWorld.scale.y))


        -- lighting
        world.lightWorld:addLight(_Lighting.Light(16, 32, 100, {0.5, 0.2, 1}))
        world.lightWorld:addLight(_Lighting.Light((tw - 1) * 16, 32, 100, {0.5, 0.2, 1}))
        world.lightWorld:addLight(_Lighting.Light(16, (th - 1) * 16, 100, {0.5, 0.2, 1}))
        world.lightWorld:addLight(_Lighting.Light((tw - 1) * 16, (th - 1) * 16, 100, {0.5, 0, 1}))
        world.lightWorld:addLight(_Lighting.Light((tw * 16) / 2, (th * 16) / 2, 100, {0.2, 0.2, 1}))
                                
        -- translation
        world.lightWorld:center()
    end
}

game.entities.__index = game
game.__index = game

setmetatable(game.entities, game)
return setmetatable(game, game)