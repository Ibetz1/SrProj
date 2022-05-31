local BodyController = require("game.components.BodyController")
local BodyDetector = require("game.components.BodyDetector")
local BodySelector = require("game.components.BodySelector")

_Textures = {

    sideWallTex = imageQuad(_Assets.tileset, 0, 0, 16, 32),
    sideWallNorm = imageQuad(_Assets.tileset, 32, 0, 16, 32),
    frontWallTex = imageQuad(_Assets.tileset, 0, 0, 16, 16),
    frontWallNorm = imageQuad(_Assets.tileset, 32, 0, 16, 16),
    
    player = {
        -- right
        {
            Tex = batchedImage(imageQuad(_Assets.tileset, 16, 32, 16, 16), 1, 1),
            Norm = batchedImage(imageQuad(_Assets.tileset, 48, 32, 16, 16), 1, 1),
            GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 32, 16, 16), 1, 1),
            GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 32, 16, 16), 1, 1),
        },

        -- down
        {
            Tex = batchedImage(imageQuad(_Assets.tileset, 16, 16, 16, 16), 1, 1),
            Norm = batchedImage(imageQuad(_Assets.tileset, 48, 16, 16, 16), 1, 1),
            GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 16, 16, 16), 1, 1),
            GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 16, 16, 16), 1, 1),
        },

        -- left
        {
            Tex = batchedImage(imageQuad(_Assets.tileset, 16, 0, 16, 16), 1, 1),
            Norm = batchedImage(imageQuad(_Assets.tileset, 48, 0, 16, 16), 1, 1),
            GlowHover = batchedImage(imageQuad(_Assets.tileset, 80, 0, 16, 16), 1, 1),
            GlowSelect = batchedImage(imageQuad(_Assets.tileset, 96, 0, 16, 16), 1, 1),
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

local game = {
    entities = {
        block = function(_, x, y, w, h, texture, normal, glow, options)
            local options = options or {}

            local ent = _Internal.Entity()
            ent:addComponent(_Components.Ysort())
            ent:addComponent(_Components.Texture(texture, normal, glow, {
                w = w, h = h,
                offset = Vector(options.ox or 0, options.oy or 0),
                occlude = true,
                imageIndex = options.imageIndex
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
                local tex = ent.texture
                local gl = _Textures.player[ent.texture.imageIndex].GlowHover

                if tex.body.glow ~= gl and _Game.selected ~= ent.id then
                    tex:setGlowMap(gl)
                end

            end,

            -- on selected
            function()
                local tex = ent.texture
                local gl = _Textures.player[ent.texture.imageIndex].GlowSelect

                if tex.body.glow ~= gl then
                    tex:setGlowMap(gl)
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
        self.world = _Internal.World(worldW, worldH, worldD, worldAmbience)

        _Stack:addScene(self.world)

        return self.world
    end
}

game.constructors = {
    gameWorld1 = function(_, world, tw, th)
        _Game.selected = nil
        _Game.remainingRotations = 100
        _Game.remainingBlocks = 4

        _EventManager:newEvent("rotate", function(dir) return dir end)
        
        -- blocks
        local block1 = game.entities:block(32, 32, 16, 13,                                   
                                    _Textures.player[1].Tex,
                                    _Textures.player[1].Norm,
                                    _Textures.player[1].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[1].GlowSelect, direction = {1, 0}, imageIndex = 1
                                    })

        local block2 = game.entities:block((tw - 3) * 16, 32, 16, 13,                                   
                                    _Textures.player[2].Tex,
                                    _Textures.player[2].Norm,
                                    _Textures.player[2].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[2].GlowSelect, direction = {0, 1}, imageIndex = 2
                                    })

        




        local block3 = game.entities:block((tw - 3) * 16, (th - 3) * 16, 16, 13,                                   
                                    _Textures.player[3].Tex,
                                    _Textures.player[3].Norm,
                                    _Textures.player[3].GlowHover, 
                                    {
                                       ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                       selectedGlow = _Textures.player[4].GlowSelect, direction = {-1, 0}, imageIndex = 3
                                    })

        local block4 = game.entities:block(32, (th - 3) * 16, 16, 13,                                   
                                    _Textures.player[4].Tex,
                                    _Textures.player[4].Norm,
                                    _Textures.player[4].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[4].GlowSelect, direction = {0, -1}, imageIndex = 4
                                    })
        
        -- walls
        local outterTopWall = game.entities:wall(0, -16, 
                                    _Textures.sideWallTex, 
                                    _Textures.sideWallNorm, 
                                    nil, tw, 1,
                                    {
                                        ox = 0, oy = 16, oh = 16, ch = 29
                                    })

        local outterBottomWall = game.entities:wall(0, (th - 1) * _Constants.Tilesize, 
                                    _Textures.frontWallTex,  
                                    _Textures.frontWallNorm, 
                                    nil, tw, 1,
                                    {
                                        ox = 0, oy = 16, oh = 16
                                    })

        local outterLeftWall = game.entities:wall(0, 0, 
                                    _Textures.frontWallTex, 
                                    _Textures.frontWallNorm, 
                                    nil, 1, th,
                                    {
                                        ox = 0, oy = 0
                                    })
            

        local outterRightWall = game.entities:wall(_Constants.Tilesize * (tw - 1), 0, 
                                    _Textures.frontWallTex,  
                                    _Textures.frontWallNorm, 
                                    nil, 1, th,
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
        world:addEntity(outterTopWall, 2)
        world:addEntity(outterBottomWall, 2)
        world:addEntity(outterLeftWall, 2)
        world:addEntity(outterRightWall, 2)

        -- lighting
        -- world.lightWorld:addLight(_Lighting.Light(16, 16, 100, {0.9, 0.2, 0}))
        -- world.lightWorld:addLight(_Lighting.Light((tw - 1) * 16, 16, 100, {0.9, 0.2, 0}))
        -- world.lightWorld:addLight(_Lighting.Light(16, (th - 1) * 16, 100, {0.9, 0.2, 0}))
        -- world.lightWorld:addLight(_Lighting.Light((tw - 1) * 16, (th - 1) * 16, 100, {0.9, 0.2, 0}))
        world.lightWorld:addLight(_Lighting.Light((tw * 16) / 2, (th * 16) / 2, 150, {1.0, 0.5, 0.3}))
                                
        -- translation
        world:setScale(
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize),
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize)
        )

        world.lightWorld:setBufferWindow(tw * _Constants.Tilesize, 
                                        (th * _Constants.Tilesize))

        world.lightWorld:centerBufferWindow()

        return function()
            
        end
    end,

    lightDemo = function(_, world, tw, th)
        _Game.selected = nil
        _Game.remainingRotations = 100
        _Game.remainingBlocks = 4

        _EventManager:newEvent("rotate", function(dir) return dir end)


        local floor = game.entities:tiledImage(0, 0, _Textures.floorTile, _Textures.floorNormal, nil, tw, th)
        local block1 = game.entities:block(32, 32, 16, 13,                                   
                                    _Textures.player[1].Tex,
                                    _Textures.player[1].Norm,
                                    _Textures.player[1].GlowHover, 
                                    {
                                        ox = 0, oy = 3, ww = tw * _Constants.Tilesize, wh = th * _Constants.Tilesize, 
                                        selectedGlow = _Textures.player[1].GlowSelect, direction = {1, 0}, imageIndex = 1
                                    })

        _Game.selected = block1.id

        world:addEntity(floor, 1)
        world:addEntity(block1, 2);

        world:setScale(
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize),
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize)
        )

        local light = _Lighting.Light((tw * 16) / 2, (th * 16) / 2, 150, {1.0, 0.5, 0.3})

        world.lightWorld:addLight(light)

        local h = 0
        local r, g, b = 0.9, 0.4, 0

        _Interface:newEventInterface("mousepressed", 3, 2, function() 
            local px, py = world:convertScreenCoord(love.mouse.getPosition())
            world.lightWorld:addLight(_Lighting.Light(px, py, 100, {r, g, b}))
        end)

        -- translation
        world:setScale(
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize),
            _Screen.smallScreenSize.y / (th * _Constants.Tilesize)
        )

        world.lightWorld:setBufferWindow(tw * _Constants.Tilesize, 
                                        (th * _Constants.Tilesize))

        world.lightWorld:centerBufferWindow()

        return function()
            h = h + 0.5
            if (h > 360) then
                h = 0
            end

            r, g, b = HSV(h, 1, 1)

            local px, py = love.mouse.getPosition()
            light:setPosition(world:convertScreenCoord(px, py))
            light:setColor(r, g, b)
        end
    end
}

game.entities.__index = game
game.__index = game

setmetatable(game.entities, game)
return setmetatable(game, game)