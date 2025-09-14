local Projectile = require('class.Projectile')
local Class = require('lib.hump.class')

---@class Gun
local Gun = Class{}

function Gun:init(data)
	self.projectiles = {}
	self.projectileType = data.projectileType
	self.damage = data.damage or 1
	self.projectileSpeed = data.speed
	self.pos = {x = data.x, y = data.y}
	self.sprite = love.graphics.newImage(data.spritePath)
end;

function Gun:shoot(isUnlucky, direction)
	if isUnlucky then
		-- play dud sound
	else
		local pData = {
			x = direction * self.pos.x,
			y = self.pos.y,
			speed = direction * self.projectileSpeed,
			spritePath = self.projectileType,
			damage = self.damage
		}
		local projectile = Projectile(pData)
		table.insert(self.projectiles, projectile)
		-- play fire sound
	end
end;

function Gun:onCollision(other)
	other:takeDamage(self.damage)
end;

function Gun:update(dt)
	for _,p in ipairs(self.projectiles) do
		p:update(dt)
	end
end;

function Gun:draw()
	for _,p in ipairs(self.projectiles) do
		p:draw()
	end
	love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end;

return Gun