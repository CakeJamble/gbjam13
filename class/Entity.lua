local Class = require('lib.hump.class')

---@class Entity
local Entity = Class{}

---@param data table
function Entity:init(data)
  self.type = data.type
  self.pos = {  -- position
    x = data.x,
    y = data.y
  }

  self.v = {  -- velocity
    x = 0,
    y = 0
  }

  self.dims = { -- dimensions
    w = data.w,
    h = data.h
  }
  self.animations = {}
  self.currentAnimationTag = "idle"
end;

---@param dt number
function Entity:update(dt)
  self:updateAnimation(dt)
end;

---@param dt number
function Entity:updateAnimation(dt)
  local animation = self.animations[self.currentAnimationTag]
  animation.currentTime = animation.currentTime + dt

  if not animation.loop then
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.duration
    end
  else 
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
    end
  end
end;

function Entity:draw()
  self:drawSprite()
end;

function Entity:drawSprite(spriteOffsets)
  local xOff, yOff = spriteOffsets.x, spriteOffsets.y
  local animation = self.animations[self.currentAnimationTag]
  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  spriteNum = math.min(spriteNum, #animation.quads)
  local transform = love.math.newTransform(self.pos.x + self.dims.w / 2, self.pos.y + self.dims.h / 2, 0, self.facing, 1, math.floor(0.5 + self.dims.w/ 2), math.floor(0.5 + self.dims.h /2))
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], transform)
end;

return Entity