_Constants = {
    Friction = 0.8,
    Gravity = 100,
    Tilesize = 16
}

_Util = {
    Vector = require("game.util.vec2"),
    UUID = require("game.util.uuid"),
    Array3D = require("game.util.array3D"),
    Object = require("game.util.object")
}

_Components = {
    PhysicsBody = require("game.components.physicsBody"),
    PhysicsGridUpdater = require("game.components.physicsGridUpdater"),
    RigidBody = require("game.components.rigidBody")
}

_Internal = {
    Scene = require("game.internal.scene"),
    Stack = require("game.internal.stack"),
    EventHandler = require("game.internal.events"),
    Entity = require("game.internal.entity"),
    World = require("game.internal.world"),
    Lighting = require("game.internal.lighting")
}

_Res = {
    love.graphics.getWidth(),
    love.graphics.getHeight()
}