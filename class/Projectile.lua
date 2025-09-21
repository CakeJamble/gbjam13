local Class = require('lib.hump.class')

---@class Projectile
local Projectile = Class{}

---@param data table
---@param owner Player|Calendar
function Projectile:init(data, owner)
	self.world = data.world
	self.pos = {x = data.x, y = data.y}
	self.v = {x = data.speed.x, y = data.speed.y}
	self.dims = {w = data.w, h = data.h}

	if data.sprite then
		self.image = data.sprite
	end
	self.active = true
	self.damage = data.damage or 1
	self.solid = false
	self.owner = owner
end;

---@param dt number
function Projectile:update(dt)
	if not self.active then return end

	local goalX = self.pos.x + self.v.x * dt
	local goalY = self.pos.y + self.v.y * dt
	local actualX, actualY, cols, len = self.world:move(self, goalX, goalY,
		function(item, other)
			if other == self.owner then
				return nil
			elseif other.type == "ground" then
				return "slide"
			else
				return "cross"
			end
		end)
	self.pos.x = actualX
	self.pos.y = actualY

	for _,col in ipairs(cols) do
		if col.other.type == "ground" then
			self.active = false
		elseif col.other.canTakeDamage and not col.other.dead and col.other.type ~= self.owner.type then
			local knockbackDir = self.v.x > 0 and 1 or -1
			col.other:takeDamage(self.damage, knockbackDir)
			self.active = false
			break 
		end
	end

	if self.pos.x < -self.dims.w or self.pos.x > love.graphics.getWidth() or
		self.pos.y < -self.dims.h or self.pos.y > love.graphics.getHeight() then
		self.active = false
	end
end;

function Projectile:draw()
	if self.image then
		love.graphics.draw(self.image, self.pos.x, self.pos.y - self.dims.h/2)
	else
		love.graphics.setColor(1,0,0)
		love.graphics.circle("fill", self.pos.x + self.dims.w / 2, self.pos.y + self.dims.h / 2, self.dims.w / 2)
		love.graphics.setColor(1,1,1)
	end
end;

return Projectile