local BodyController = require("game.components.BodyController")
local BodyDetector = require("game.components.BodyDetector")
local BodySelector = require("game.components.BodySelector")

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
        
        _Textures = {

        sideWallTex = imageQuad(_Assets.tileset, 0, 0, 16, 32),
        sideWallNorm = imageQuad(_Assets.tileset, 32, 0, 16, 32),
        frontWallTex = imageQuad(_Assets.tileset, 0, 0, 16, 16),
        frontWallNorm = imageQuad(_Assets.tileset, 32, 0, 16, 16),
        
        player = {
            -- ldown
            {
                Tex = batchedImage(imageQuad(_Assets.tileset, 16, 0, 16, 16), 1, 1),
                Norm = batchedImage(imageQuad(_Assets.tileset, 48, 0, 16, 16), 1, 1),
                GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 0, 16, 16), 1, 1),
                GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 0, 16, 16), 1, 1),
            },

            -- down
            {
                Tex = batchedImage(imageQuad(_Assets.tileset, 16, 16, 16, 16), 1, 1),
                Norm = batchedImage(imageQuad(_Assets.tileset, 48, 16, 16, 16), 1, 1),
                GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 16, 16, 16), 1, 1),
                GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 16, 16, 16), 1, 1),
            },

            -- right
            {
                Tex = batchedImage(imageQuad(_Assets.tileset, 16, 32, 16, 16), 1, 1),
                Norm = batchedImage(imageQuad(_Assets.tileset, 48, 32, 16, 16), 1, 1),
                GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 32, 16, 16), 1, 1),
                GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 32, 16, 16), 1, 1),
            },

            -- up
            {
                Tex = batchedImage(imageQuad(_Assets.tileset, 16, 48, 16, 16), 1, 1),
                Norm = batchedImage(imageQuad(_Assets.tileset, 48, 48, 16, 16), 1, 1),
                GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 48, 16, 16), 1, 1),
                GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 48, 16, 16), 1, 1),
            },
        },


        floorTile = imageQuad(_Assets.tileset, 0, 32, 16, 16),
        floorNormal = imageQuad(_Assets.tileset, 32, 32, 16, 16),
        
        goalTex = imageQuad(_Assets.tileset, 0, 48, 16, 16),
        goalNorm = imageQuad(_Assets.tileset, 32, 48, 16, 16),
        goalGlow = imageQuad(_Assets.tileset, 64, 48, 16, 16)

        }

        globalEventHandler:newEvent("rotate", function() return true end)

        local block1 = game.entities:block((tw - 3) * 16, (th - 3) * 16, 16, 13,                                   
                                    _Textures.player[1].Tex,
                                    _Textures.player[1].Norm,
                                    _Textures.player[1].GlowHover, 
                                    {
                                       ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                       selectedGlow = _Textures.player[1].GlowSelect, direction = {-1, 0}
                                    })

        local block2 = game.entities:block(32, 48, 16, 13,                                   
                                    _Textures.player[2].Tex,
                                    _Textures.player[2].Norm,
                                    _Textures.player[2].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[2].GlowSelect, direction = {1, 0}
                                    })

        local block3 = game.entities:block((tw - 3) * 16, 48, 16, 13,                                   
                                    _Textures.player[3].Tex,
                                    _Textures.player[3].Norm,
                                    _Textures.player[3].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[3].GlowSelect, direction = {0, 1}
                                    })
        
        local block4 = game.entities:block(32, (th - 3) * 16, 16, 13,                                   
                                    _Textures.player[4].Tex,
                                    _Textures.player[4].Norm,
                                    _Textures.player[4].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[4].GlowSelect, direction = {0, -1}
                                    })



        local topWall = game.entities:wall(0, 0, _Textures.sideWallTex, _Textures.sideWallNorm, nil, tw, 1,
        {
            ox = 0, oy = 16, oh = 16, ch = 29
        })

        local bottomWall = game.entities:wall(0, (th - 1) * _Constants.Tilesize, _Textures.frontWallTex,  _Textures.frontWallNorm, nil, tw, 1,
        {
            ox = 0, oy = 16, oh = 16
        })

        local leftWall = game.entities:wall(0, 0, _Textures.frontWallTex, _Textures.frontWallNorm, nil, 1, th,
        {
            ox = 0, oy = 0
        })

        local rightWall = game.entities:wall(_Constants.Tilesize * (tw - 1), 0, _Textures.frontWallTex,  _Textures.frontWallNorm, nil, 1, th,
        {
            ox = 0, oy = 0
        })

        local floor = game.entities:tiledImage(0, 0, _Textures.floorTile, _Textures.floorNormal, nil, tw, th)
        local goalTex = game.entities:quadedImage(math.floor(tw / 2) * _Constants.Tilesize, math.floor(th / 2) * _Constants.Tilesize, 16, 16, 
                                        batchedImage(_Textures.goalTex, 1, 1), 
                                        batchedImage(_Textures.goalNorm, 1, 1), 
                                        batchedImage(_Textures.goalGlow, 1, 1))
        local goalDetector = game.entities:goal(math.floor(tw / 2) * _Constants.Tilesize, math.floor(th / 2) * _Constants.Tilesize, 16, 16)
        
        world:addEntity(floor, 1)
        world:addEntity(goalTex, 1)
        world:addEntity(goalDetector, 2)

        -- player
        world:addEntity(block1, 2)
        world:addEntity(block2, 2)
        world:addEntity(block3, 2)
        world:addEntity(block4, 2)

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