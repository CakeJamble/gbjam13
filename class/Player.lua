local createAnimation = require('util.create_animation')
local Entity = require('class.Entity')
local Class = require('lib.hump.class')

---@class Player: Entity
local Player = Class{__includes = Entity}

function Player:init(data)
	Entity.init(self, data)
	self.startingPosition = {x = data.x, y = data.y} -- copy for restart
	self.onGround = false
	self.wasOnGround = self.onGround
	local assetDir = "asset/sprite/" .. data.name .. "/"
	self.animations = self:initAnimations(assetDir, data.animations)
	self.currentAnimationTag = "idle"
	self.speed = 100
	self.jumpForce = -200
	self.moveDir = 0
	self.facing = 1
	self.health = 3
	self.maxJumps = 2
	self.jumpCount = 0
end;

function Player:takeDamage(amount)
	amount = amount or 1
	self.health = self.health - amount
	self:resetPosition()
end;

function Player:resetPosition()
	self.pos.x = self.startingPosition.x
	self.pos.y = self.startingPosition.y
	self.v.x = 0
	self.v.y = 0
end;

---@param dir string
---@param animations string[]
function Player:initAnimations(dir, animations)
	local result = {}
	for _,animName in ipairs(animations) do
		local image = love.graphics.newImage(dir .. animName .. ".png")
		local animation = createAnimation(image, self.dims.w, self.dims.h)
		animation.loop = animName ~= "jump"
		result[animName] = animation
	end

	return result
end;

---@param joystick string
---@param button string
function Player:gamepadpressed(joystick, button)
	if button == 'dpleft' then
		self.moveDir = -1
		self.facing = -1
		self.currentAnimationTag = "walk"
	elseif button == 'dpright' then
		self.moveDir = 1
		self.facing = 1
		self.currentAnimationTag = "walk"
	elseif button == 'a' then
		self:jump()
	end
end;

---@param joystick string
---@param button string
function Player:gamepadreleased(joystick, button)
	if button == 'dpleft' or button == 'dpright' then
		self.moveDir = 0
		self.currentAnimationTag = "idle"
	end
end;

function Player:jump()
	if self.jumpCount < self.maxJumps then
		self.v.y = self.jumpForce
		self.jumpCount = self.jumpCount + 1
		self.currentAnimationTag = "jump"
	end
end;

---@param dt number
function Player:update(dt)
	Entity.update(self, dt)
	local collisionInfo = self:updatePosition(dt)
	self:handleCollision(collisionInfo)
end;

---@param dt number
function Player:updateAnimation(dt)
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
function Player:updatePosition(dt)
	self.v.x = self.moveDir * self.speed
	self.v.y = self.v.y + Gravity * dt

	local goalX = self.pos.x + self.v.x * dt
	local goalY = self.pos.y + self.v.y * dt
	local actualX, actualY, cols, len = World:move(self, goalX, goalY,
		function(item, other)
			if other.solid then return "slide" end
		end)
	self.pos.x, self.pos.y = actualX, actualY
	self.wasOnGround = self.onGround
	self.onGround = false
	return {cols = cols, len = len}
end;

---@param collisionInfo table
function Player:handleCollision(collisionInfo)
	local cols, len = collisionInfo.cols, collisionInfo.len
	for i=1,len do
		local col = cols[i]
		if col.normal.y == -1 then
			self.v.y = 0
			self.jumpCount = 0
			self.onGround = true
		end
		if col.other.onCollision then
			col.other:onCollision(self)
		end
	end

	if self.onGround and not self.wasOnGround then
		if self.v.x ~= 0 then
			self.currentAnimationTag = "walk"
		else
			self.currentAnimationTag = "idle"
		end
		self.animations[self.currentAnimationTag].currentTime = 0
	end
end;

function Player:draw()
	self:drawSprite()
end;

function Player:drawSprite()
	local animation = self.animations[self.currentAnimationTag]
	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	spriteNum = math.min(spriteNum, #animation.quads)
	local transform = love.math.newTransform(self.pos.x + (32 - 20), self.pos.y + (32 - 20), 0, self.facing, 1, math.floor(0.5 + self.dims.w/ 2), math.floor(0.5 + self.dims.h /2))
	love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], transform)
end;

return Player