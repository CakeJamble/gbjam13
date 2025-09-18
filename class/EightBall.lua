local createAnimation = require('util.create_animation')
local Entity = require('class.Entity')
local Class = require('lib.hump.class')

---@class EightBall: Entity
---@field sprite love.Image
local EightBall = Class{__includes = Entity,
sprite = love.graphics.newImage('asset/sprite/enemy/eight_ball.png')}

function EightBall:init(data)
	Entity.init(self, data)
	self.name = "Eight Ball"
	self.type = "enemy"
	local sprite = createAnimation(EightBall.sprite, 16, 16)
	sprite.loop = true
	self.animations.idle = sprite
	self.speed = data.speed or 50
	self.moveDir = -1
	self.v.x = self.speed * self.moveDir
	self.spriteOffsets = {x = 16, y = 16}
	self.damage = 1
end;

function EightBall:onCollision(other)
	other:takeDamage(self.damage)
end;

function EightBall:update(dt)
	Entity.update(self, dt)

	self.v.x = self.moveDir * self.speed
	self.v.y = self.v.y + Gravity * dt
	local goalX = self.pos.x + self.v.x * dt
	local goalY = self.pos.y + self.v.y * dt
	local actualX, actualY, cols, len = World:move(self, goalX, goalY,
		function(item, other)
			if other.type == "ground" or other.type == "enemy" then
				return "slide"
			elseif other.type == "player" then
				return "cross"
			end
		end)
	self.pos.x, self.pos.y = actualX, actualY

	-- turn around after hitting a wall
	for _,col in ipairs(cols) do
		if col.normal.x ~= 0 then
			self:turnAround()
		end

		if col.other.type == "player" and col.other.canTakeDamage then
			col.other:takeDamage(self.damage)
		end
	end
end;

function EightBall:isAtEdge()
	local aheadX = self.pos.x + (self.dims.w/2 + 1) * self.moveDir
	local baseY = self.pos.y + self.dims.h + 1

	local items, len = World:queryRect(aheadX, baseY, 1, 1)
	for _,item in ipairs(items) do
		if item.type == "ground" then
			return false
		end
	end

	return true
end;

function EightBall:turnAround()
	self.moveDir = -self.moveDir
	self.v.x = self.speed * self.moveDir
end;

function EightBall:draw()
	self:drawSprite(self.spriteOffsets, -self.moveDir)
end;

return EightBall