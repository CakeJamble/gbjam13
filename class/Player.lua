local Signal = require('lib.hump.signal')
local Timer = require('lib.hump.timer')
local createAnimation = require('util.create_animation')
local flux = require('lib.flux')
local Entity = require('class.Entity')
local Gun = require('class.Gun')
local SoundManager = require('class.SoundManager')
local Class = require('lib.hump.class')

---@class Player: Entity
local Player = Class{__includes = Entity}

---@param data table
function Player:init(data)
	Entity.init(self, data)
	self.name = "Player"
	self.type = "player"
	self.isBlocked = false
	self.gun = nil
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
	self.lookYOffset = {base = 0, curr = 0, max = 32, duration = 0.5}
	self.lookTween = nil
	self.sfx = SoundManager(AllSounds.sfx.player)
	--self.unluckyMeter = ProgressBar()
	self.canTakeDamage = true
	self.invulnTime = 2
	self.invulnTimer = 0
	self.stumbleTime = 0.5
	self.vis = true
	self.blink = 0
	self.showHealth = true
	Timer.after(3, function() self.showHealth = false end)

	Signal.register('OnUnlucky',
		function()
			self.isUnlucky = true
			self.gun.isUnlucky = true
		end)
	Signal.register("OnUnluckyEnd", function() self.isUnlucky = false end)
end;

---@param gun Gun
function Player:setGun(gun)
	self.gun = gun
end;

---@param amount integer
function Player:takeDamage(amount)
	if self.canTakeDamage and not self.dead then
		amount = amount or 1
		self.health = math.max(0, self.health - amount)
		self.currentAnimationTag = "stun"
		if self.health < 1 then
			self.dead = true
			local deathSFX = self.sfx:play("death")
			local t = deathSFX:getDuration()
			Timer.after(t, function() Signal.emit("OnDeath") end)
		else
			self.canTakeDamage = false
			self:stumbleAndBlink()
		end
	end
end;

function Player:stumbleAndBlink()
	self.showHealth = true
	self.sfx:play("stun")
	local knockback = -self.moveDir * 16
	local px = self.pos.x
	flux.to(self.pos, 0.5, {x = px + knockback}):ease("quadout")
	self.blinkTween = flux.to(self, self.invulnTime, {blink = 1})
		:onupdate(
			function()
				self.vis = math.floor(self.blink * 5) % 2 == 0
			end)
		:oncomplete(
			function()
				self.canTakeDamage = true
				self.vis = true
				self.showHealth = false
			end)
end;

function Player:resetPosition()
	self.pos.x = self.startingPosition.x
	self.pos.y = self.startingPosition.y
	self.v.x = 0
	self.v.y = 0
end;

---@param dir string
---@param animations string[]
---@return table
function Player:initAnimations(dir, animations)
	local result = {}
	for _,animName in ipairs(animations) do
		local image = love.graphics.newImage(dir .. animName .. ".png")
		local animation = createAnimation(image, self.dims.w, self.dims.h)
		animation.loop = animName ~= "jump" and animName ~= "look_up" and animName ~= "look_down" and anim ~= "in_light"
		result[animName] = animation
	end

	return result
end;

---@param key string base or max
---@param flip integer? -1 or 1
function Player:tweenCamera(key, flip)
	if self.lookTween then self.lookTween:stop() end
	local validFlip = flip or 1
	self.lookTween = flux.to(self.lookYOffset, self.lookYOffset.duration, {curr = validFlip * self.lookYOffset[key]})
end;

---@param joystick string
---@param button string
function Player:gamepadpressed(joystick, button)
	if self.dead == false then
		if button == 'dpleft' then
			self.moveDir = -1
			self.facing = -1
			self:tweenCamera("base")
			self.currentAnimationTag = "walk"
		elseif button == 'dpright' then
			self.moveDir = 1
			self.facing = 1
			self:tweenCamera("base")
			self.currentAnimationTag = "walk"
		elseif button == 'dpup' then
			if self.moveDir == 0 then
				self.currentAnimationTag = "look_up"
				self:tweenCamera("max", -1)
			end
		elseif button == 'dpdown' then
			if self.moveDir == 0 then
				self.currentAnimationTag = "look_down"
				self:tweenCamera("max", 1)
			end
		elseif button == 'a' then
			self:jump()
		end

		self.gun:gamepadpressed(joystick, button)
	end
end;

---@param key string
function Player:keypressed(key)
	if not self.dead then
		if key == "left" then
			self.moveDir = -1
			self.facing = -1
			self:tweenCamera("base")
			self.currentAnimationTag = "walk"
		elseif key == "right" then
			self.moveDir = 1
			self.facing = 1
			self:tweenCamera("base")
			self.currentAnimationTag = "walk"
		elseif key == "up" then
			if self.moveDir == 0 then
				self.currentAnimationTag = "look_up"
				self:tweenCamera("max", -1)
			end
		elseif key == "down" then
			if self.moveDir == 0 then
				self.currentAnimationTag = "look_down"
				self:tweenCamera("max", 1)
			end
		elseif key == "z" then
			self:jump()
		end

		self.gun:keypressed(key)
	end
end;

---@param joystick string
---@param button string
function Player:gamepadreleased(joystick, button)
	if not self.dead then
		if button == 'dpleft' or button == 'dpright' then
			self.moveDir = 0
			self.currentAnimationTag = "idle"
		elseif button == 'dpup' or button == 'dpdown' then
			self.currentAnimationTag = "idle"
			self:tweenCamera("base")
		end

		self.gun:gamepadreleased(joystick, button)
	end
end;

---@param key string
function Player:keyreleased(key)
	if not self.dead then
		if key == "left" or key == "right" then
			self.moveDir = 0
			self.currentAnimationTag = "idle"
		elseif key == "up" or key == "down" then
			self:tweenCamera("base")
			self.currentAnimationTag = "idle"
		end

		self.gun:keyreleased(key)
	end
end;

function Player:jump()
	if self.jumpCount < self.maxJumps then
		self.v.y = self.jumpForce
		self.jumpCount = self.jumpCount + 1
		self.currentAnimationTag = "jump"
		self.sfx:play("jump")
	end
end;

---@param dt number
function Player:update(dt)
	Entity.update(self, dt)
	self.sfx:update(dt)
	if not self.dead then
		local collisionInfo = self:updatePosition(dt)
		self:handleCollision(collisionInfo)
		self.gun.pos.x = self.pos.x
		self.gun.pos.y = self.pos.y
		self.gun:update(dt)
	end
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
		if col.other.onCollision and col.other.dead == false then
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
	if self.vis then
		self:drawSprite()
		if self.gun then
			self.gun:draw()
		end
	end
	if self.showHealth then
		self:drawHealth()
	end
end;

function Player:drawSprite()
	local animation = self.animations[self.currentAnimationTag]
	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	spriteNum = math.min(spriteNum, #animation.quads)
	local transform = love.math.newTransform(self.pos.x + (32 - 19), self.pos.y + (32 - 20), 0, self.facing, 1, math.floor(0.5 + self.dims.w/ 2), math.floor(0.5 + self.dims.h /2))
	love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], transform)
end;

function Player:drawHealth()
	for i=1, self.health do
		love.graphics.circle("fill", self.pos.x + i * 8, self.pos.y + self.dims.h + 8, 3)
	end
end;
return Player