local Signal = require('lib.hump.signal')
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
  self.speed = data.speed or 100
  self.moveDir = data.moveDir or 0
  self.dead = false
  self.movedToNextLevel = false
  self.canTakeDamage = true
  self.health = data.health or 3
end;

function Entity:takeDamage(amount)
  if self.canTakeDamage then
    amount = amount or 1
    self.health = self.health - amount

    if self.health < 1 then
      self.dead = true
    end
  end
end;

---@param dt number
function Entity:update(dt)
  if not self.dead then
    self:updateAnimation(dt)
  end
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

---@param dt number
---@return table
function Entity:updatePosition(dt)
  self.v.x = self.moveDir * self.speed
  self.v.y = self.v.y + Gravity * dt

  local goalX = self.pos.x + self.v.x * dt
  local goalY = self.pos.y + self.v.y * dt
  local actualX, actualY, cols, len = World:move(self, goalX, goalY,
    function(item, other)
      if other.solid then return "slide" 
      elseif other.type == "item" then 
        if other.name == "Lamp" then
          Signal.emit("OnLampCollision", 10, dt)
          return nil
        else
          return nil 
        end
      elseif other.type == "levelEnd" and not self.movedToNextLevel then
        self.movedToNextLevel = true
        Signal.emit("EndLevel")
      else
        return nil
      end
    end)

  self.isBlocked = self:checkBlocked()
  self.pos.x, self.pos.y = actualX, actualY
  self.wasOnGround = self.onGround
  self.onGround = false
  return {cols = cols, len = len}
end;

function Entity:checkBlocked(actualX, goalX, moveDir)
  return (actualX ~= goalX) and self.moveDir ~= 0
end;

function Entity:draw()
  self:drawSprite()
end;

function Entity:drawSprite(spriteOffsets, facing)
  if not self.dead then
    local xOff, yOff = spriteOffsets.x, spriteOffsets.y
    local animation = self.animations[self.currentAnimationTag]
    local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    spriteNum = math.min(spriteNum, #animation.quads)
    local transform = love.math.newTransform(self.pos.x + self.dims.w / 2, self.pos.y + self.dims.h / 2, 0, facing, 1, math.floor(0.5 + self.dims.w/ 2), math.floor(0.5 + self.dims.h /2))
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], transform)
  end
end;

return Entity