local Class = require('lib.hump.class')

---@class Projectile
local Projectile = Class{}

---@param data table
function Projectile:init(data)
	self.pos = {x = data.x, y = data.y}
	self.v = {x = data.speed, y = 0}
	self.dims = {w = data.w, h = data.h}

	if data.spritePath then
		self.image = love.graphics.newImage(data.spritePath)
	end
	self.active = true
	self.damage = data.damage or 1
	self.solid = true
end;

---@param player Player
function Projectile:onCollision(player)
	player:takeDamage(self.damage)
end;

---@param dt number
function Projectile:update(dt)
	if not self.active then return end

	local goalX = self.pos.x + self.v.x * dt
	local goalY = self.pos.y + self.v.y * dt

	if World then
		local actualX, actualY, cols, len = World:move(self, goalX, goalY,
			function(item, other)
				if other.solid then
					self.active = false
					return "cross"
				end
			end)
		self.pos.x = actualX
		self.pos.y = actualY
	end

	if self.pos.x < -self.dims.w or self.pos.x > love.graphics.getWidth() then
		self.active = false
	end
end;

function Projectile:draw()
	if self.image then
		love.graphics.draw(self.image, self.pos.x, self.pos.y)
	else
		love.graphics.setColor(1,0,0)
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.dims.w / 2)
		love.graphics.setColor(1,1,1)
	end
end;

return Projectile