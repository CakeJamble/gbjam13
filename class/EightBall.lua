local createAnimation = require('util.create_animation')
local Signal = require('lib.hump.signal')
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
	self.baseSpeed = data.speed or 50
	self.speed = self.baseSpeed
	self.moveDir = -1
	self.v.x = self.speed * self.moveDir
	self.spriteOffsets = {x = 16, y = 16}
	self.damage = 1
	self.isUnlucky = false
	
	Signal.register('OnUnlucky', function() 
		self.isUnlucky = true
		self.speed = self.baseSpeed * 2
	end)
	Signal.register('OnUnluckyEnd', function() 
		self.isUnlucky = false
		self.speed = self.baseSpeed
	end)
end;

function EightBall:onCollision(other)
	other:takeDamage(self.damage)
end;

function EightBall:update(dt)
	if not self.dead then
		Entity.update(self, dt)

		if self.dying then
			return
		end

		self.v.x = self.moveDir * self.speed
		self.v.y = self.v.y * dt
		local goalX = self.pos.x + self.v.x * dt
		local goalY = self.pos.y + self.v.y * dt
		local actualX, actualY, cols, len = self.world:move(self, goalX, goalY,
			function(item, other)
				if other.type == "ground" or other.type == "enemy" then
					return "slide"
				elseif other.type == "player" then
					return "cross"
				end
			end)
		self.pos.x, self.pos.y = actualX, actualY

		for _,col in ipairs(cols) do
			if col.normal.x ~= 0 then
				if col.other.type ~= "player" then
					-- Always turn around when hitting walls/ground
					self:turnAround()
				elseif col.other.type == "player" and col.other.canTakeDamage and not col.other.dead then
					-- Only turn around if player is in front of ball's movement direction
					local playerInFront = false
					if self.moveDir > 0 then
						playerInFront = col.other.pos.x > self.pos.x
					else
						playerInFront = col.other.pos.x < self.pos.x
					end
					
					if playerInFront then
						self:turnAround()
					end
				end
			end

			if col.other.type == "player" and col.other.canTakeDamage and not col.other.dead then
				if not self.dying and not self.dead then
					col.other:takeDamage(self.damage)
				end
			end
		end
	end
end;

function EightBall:isAtEdge()
	local aheadX = self.pos.x + (self.dims.w/2 + 1) * self.moveDir
	local baseY = self.pos.y + self.dims.h + 1

	local items, len = self.world:queryRect(aheadX, baseY, 1, 1)
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
	if not self.dead then
		self:drawSprite(self.spriteOffsets, -self.moveDir)
	end
end;

return EightBall