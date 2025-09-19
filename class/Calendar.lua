local createAnimation = require('util.create_animation')
local flux = require('lib.flux')
local Signal = require('lib.hump.signal')
local Entity = require('class.Entity')
local Timer = require('lib.hump.timer')
local Class = require('lib.hump.class')
local Projectile = require('class.Projectile')

---@class Calendar: Entity
---@field sprite love.Image
---field projectileSprite love.Image
local Calendar = Class{__includes = Entity,
sprite = love.graphics.newImage('asset/sprite/enemy/calendar.png'),
projectileSprite = love.graphics.newImage('asset/sprite/enemy/calendar_projectile.png')}

function Calendar:init(data)
	Entity.init(self, data)
	self.name = "Calendar"
	self.type = "enemy"
	self.startingPosition = {x = data.x, y = data.y}
	self.projectiles = {}

	local sprite = createAnimation(Calendar.sprite, 16, 16)
	sprite.loop = true
	self.animations.idle = sprite
	self.solid = true
	self.damage = data.damage or 1
	self.amplitude = 25
	self.baseY = data.y
	self.offsetY = 0
	self:tweenUp()
	self.spriteOffsets = {x = 16, y = 16}

	self:start()

	-- Signal.register("EndLevel", function()
	-- 	print('here')
	-- 	for i,projectile in ipairs(self.projectiles) do
	-- 		self.world:remove(projectile)
	-- 		table.remove(self.projectiles, i)
	-- 	end
	-- end)
end;

function Calendar:start()
	Timer.every(3, function() self:shoot(Calendar.projectileSprite) end)
end;

---@param player Player
function Calendar:onCollision(player)
	player:takeDamage(self.damage)
end;

---@param projectileSprite love.Image
function Calendar:shoot(projectileSprite)
	local data = {
		x = self.pos.x - self.dims.w,
		y = self.pos.y + self.dims.h/2,
		w = 16,
		h = 8,
		speed = {x = -200, y = 0},
		damage = 1,
		sprite = projectileSprite,
		world = self.world
	}
	local projectile = Projectile(data)
	self.world:add(projectile, projectile.pos.x, projectile.pos.y, projectile.dims.w, projectile.dims.h)
	table.insert(self.projectiles, projectile)
end;

function Calendar:tweenUp(dur)
	local duration = dur or 2
	flux.to(self, duration, {offsetY = -self.amplitude})
		:ease("sineinout")
		:oncomplete(function() self:tweenDown(duration) end)
end;

function Calendar:tweenDown(duration)
	flux.to(self, duration, {offsetY = self.amplitude})
		:ease("sineinout")
		:oncomplete(function() self:tweenUp(duration) end)
end;

---@param dt number
function Calendar:update(dt)
	if not self.dead then
		Entity.update(self, dt)

		local goalX = self.pos.x
		local goalY = self.baseY + self.offsetY
		local actualX, actualY, cols, len = self.world:move(self, goalX, goalY,
						function(item, other)
				if other.type == "player" then
					return "cross"
				end
			end)
		self.pos.x, self.pos.y = actualX, actualY

		for _,col in ipairs(cols) do
			if col.other.type == "player" and col.other.canTakeDamage then
				col.other:takeDamage(self.damage)
			end
		end

		for i,projectile in ipairs(self.projectiles) do
			projectile:update(dt)
			if not projectile.active then
				table.remove(self.projectiles, i)
				self.world:remove(projectile)
			end
		end
	end
end;

function Calendar:draw()
	if not self.dead then
		Entity.drawSprite(self, self.spriteOffsets)
		for _,projectile in ipairs(self.projectiles) do
			projectile:draw()
		end
	end
end;

return Calendar