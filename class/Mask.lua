local createAnimation = require('util.create_animation')
local flux = require('lib.flux')
local Entity = require('class.Entity')
local Signal = require('lib.hump.signal')
local Timer = require('lib.hump.timer')
local Class = require('lib.hump.class')

---@class Mask: Entity
---@field sprite love.Image
local Mask = Class{__includes = Entity,
sprite = love.graphics.newImage('asset/sprite/enemy/mask.png')}

---@param data table
function Mask:init(data)
	Entity.init(self, data)
	self.hoverX = self.pos.x - 60
	self.hoverOffsetX = data.hoverOffset.x
	self.hoverY = self.pos.y - data.hoverOffset.y
	self.name = "Mask"
	self.type = "enemy"
	self.startingPos = {x = self.pos.x, y = self.pos.y}
	local sprite = createAnimation(Mask.sprite, 16, 16)
	sprite.loop = true
	self.animations.idle = sprite
	self.solid = true
	self.damage = data.damage or 1
	self.spriteOffsets = {x=16,y=16}
	self.swoopTime = 2
	self.elapsed = 0
	self.cadence = love.math.random(7, 10)

	-- states: "idle", "follow", "swoop"
	self.state = "idle"
	self.speed = 50
	self.swoopSpeed = 100
	self.wobbleAmplitude = 5
	self.wobbleFreq = 10
	-- self.wobbleOffset = math.sin(love.timer.getTime() * self.wobbleFreq) * self.wobbleAmplitude
	self.swoopTimer = Timer.new()
	self.player = data.player
	-- self.isChasing = false
	-- self.turnMod = 0.1
	self.isSwooping = false
	self.tween = nil

	Signal.register("OnUnlucky",
		function()
			self:start()
	end)

	Signal.register("OnUnluckyEnd",
		function()
			print('its over')
			self.swoopTimer:clear()
			self.tween:stop()
		end)
end;

function Mask:start()
	self:transitionToFollow()
end;

function Mask:transitionToFollow()
	self.state = "transition"
	local startX, startY = self.pos.x, self.pos.y
	local targetX, targetY = self.hoverX, self.hoverY

	self.tween = flux.to(self.pos, 1, {x = targetX, y = targetY}):ease("linear")
		:oncomplete(function() 
			self.state = "follow" 

			self.swoopTimer:after(self.cadence, function()
				self.state = "swoop"
				self.swoopTarget = {x = self.player.pos.x, y = self.player.pos.y}
			end)
		end)
end;

function Mask:returnToHover()
	self.state = "transition"
	local goalX, goalY = self.player.pos.x + self.hoverOffsetX, self.hoverY

	self.tween = flux.to(self.pos, 0.5, {x = goalX, y = goalY}):ease("linear")
		:oncomplete(function()
			self.state = "follow"

			self.swoopTimer:after(self.cadence, function()
				self.state = "swoop"
				self.swoopTarget = {x = self.player.pos.x + self.player.dims.w / 2, 
				y = self.player.pos.y + self.player.dims.h / 2}
			end)
		end)
end;

---@param dt number
function Mask:update(dt)
	if not self.dead then
		self.swoopTimer:update(dt)
		-- follow
		if self.state == "follow" then
			self.hoverX = Mask.lerp(self.hoverX, self.player.pos.x + self.hoverOffsetX, 0.02)
			self.pos.x = self.hoverX
			self.pos.y = self.hoverY + math.sin(love.timer.getTime() * self.wobbleFreq) * self.wobbleAmplitude
			-- local dx = self.player.pos.x - self.pos.x
			-- self.pos.x = self.hoverX + dx * 0.02

			local goalX = self.hoverX + (self.player.pos.x - self.hoverX) * 0.02
			local goalY = self.hoverY + math.sin(love.timer.getTime() * self.wobbleFreq) * self.wobbleAmplitude

			-- ignore collision
			local actualX, actualY = self.world:move(self, goalX, goalY, function() return nil end)
			self.pos.x, self.pos.y = actualX, actualY
		elseif self.state == "swoop" then
			local dx = self.swoopTarget.x - self.pos.x
			local dy = self.swoopTarget.y - self.pos.y
			local distance = math.sqrt(dx*dx + dy*dy)

			if distance < 3 then
				self:returnToHover()
			else
				local vx = (dx/distance) * self.swoopSpeed * dt
				local vy = (dy/distance) * self.swoopSpeed * dt

				local goalX, goalY = self.pos.x + vx, self.pos.y + vy
				local actualX, actualY, cols, len = self.world:move(self, goalX, goalY,
					function(item, other)
						if other.type == "player" then return "cross"
						else return nil end
					end)
				self.pos.x, self.pos.y = actualX, actualY

				for _,col in ipairs(cols) do
					if col.other.type == "player" and col.other.canTakeDamage then
						col.other:takeDamage(self.damage)
					end
				end
			end
		end
	end
end;

---@param a number
---@param b number
---@param t number
function Mask.lerp(a,b,t)
	return a + (b - a) * t
end;

function Mask:draw()
	if not self.dead then
		local xOff, yOff = self.spriteOffsets.x, self.spriteOffsets.y
	  local animation = self.animations[self.currentAnimationTag]
	  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	  spriteNum = math.min(spriteNum, #animation.quads)
	  local transform = love.math.newTransform(self.pos.x, self.pos.y)
	  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], transform)
	end
end;

return Mask