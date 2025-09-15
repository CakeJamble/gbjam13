local Projectile = require('class.Projectile')
local Class = require('lib.hump.class')

---@class Gun
local Gun = Class{}

function Gun:init(data)
	self.projectiles = {}
	self.projectileType = data.projectileType
	self.damage = data.damage or 1
	self.projectileSpeed = {x = data.speed.x, y = data.speed.y}
	self.pos = {x = data.x, y = data.y}
	self.dims = {w = data.w, h = data.h}
	self.direction = {x=1,y=0}
	self.isUnlucky = false
	self.owner = nil
end;

function Gun:shoot(isUnlucky)
	if self.isUnlucky then
		-- play dud sound
	else
		local pData = {
			x = self.direction.x * self.dims.w + self.pos.x,
			y = self.pos.y + self.dims.h / 2,
			speed = {
				x = self.direction.x * self.projectileSpeed.x,
				y = -self.direction.y * self.projectileSpeed.y
			},
			w = 8, h = 8,
			spritePath = self.projectileType,
			damage = self.damage
		}
		local projectile = Projectile(pData, self.owner)
		World:add(projectile, projectile.pos.x, projectile.pos.y, projectile.dims.w, projectile.dims.h)
		table.insert(self.projectiles, projectile)
		-- play fire sound
	end
end;

function Gun:gamepadpressed(joystick, button)
	if button == "dpleft" then
		self.direction.x = -1
	elseif button == "dpright" then
		self.direction.x = 1
	elseif button == "dpup" then
		self.direction.y = 1
	elseif button == "dpdown" then
		self.direction.y = -1
	elseif button == "b" then
		self:shoot(self.isUnlucky)
	end
end;

function Gun:gamepadreleased(joystick, button)
	if button == "dpup" or button == "dpdown" then
		self.direction.y = 0
	end
end;

function Gun:update(dt)
	for i,p in ipairs(self.projectiles) do
		p:update(dt)
		if not p.active then
			table.remove(self.projectiles, i)
			World:remove(p)
		end
	end
end;

function Gun:draw()
	for _,p in ipairs(self.projectiles) do
		p:draw()
	end
end;

return Gun