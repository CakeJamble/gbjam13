local SoundManager = require('class.SoundManager')
local Projectile = require('class.Projectile')
local Signal = require('lib.hump.signal')
local Class = require('lib.hump.class')

---@class Gun
---@field sprite love.Image
local Gun = Class{sprite = love.graphics.newImage('asset/sprite/player/projectile.png')}

function Gun:init(data)
	self.sfx = SoundManager(AllSounds.sfx.player)
	self.world = data.world
	self.projectiles = {}
	self.projectileType = data.projectileType
	self.damage = data.damage or 1
	self.projectileSpeed = {x = data.speed.x, y = data.speed.y}
	self.pos = {x = data.x, y = data.y}
	self.dims = {w = data.w, h = data.h}
	self.direction = {x=1,y=0}
	self.isUnlucky = false
	self.owner = data.owner

	Signal.register("OnUnluckyEnd", function() self.isUnlucky = false end)
end;

function Gun:shoot(isUnlucky)
	if self.isUnlucky then
		self.sfx:play("misfire")
	else
		-- Adjust Y position based on shooting direction
		local yOffset = 0
		if self.direction.y > 0 then -- shooting up
			yOffset = -6
		elseif self.direction.y < 0 then -- shooting down
			yOffset = 6
		end
		
		local pData = {
			x = self.direction.x * self.dims.w + self.pos.x,
			y = self.pos.y + self.dims.h / 2 + yOffset,
			speed = {
				x = self.direction.x * self.projectileSpeed.x,
				y = -self.direction.y * self.projectileSpeed.y
			},
			w = 8, h = 8,
			sprite = Gun.sprite,
			damage = self.damage,
			world = self.world
		}
		local projectile = Projectile(pData, self.owner)
		self.world:add(projectile, projectile.pos.x, projectile.pos.y, projectile.dims.w, projectile.dims.h)
		table.insert(self.projectiles, projectile)
		self.sfx:play("shoot")
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

function Gun:keypressed(key)
	if key == "left" then
		self.direction.x = -1
	elseif key == "right" then
		self.direction.x = 1
	elseif key == "up" then
		self.direction.y = 1
	elseif key == "down" then
		self.direction.y = -1
	elseif key == "x" then
		self:shoot(self.isUnlucky)
	end
end;

function Gun:gamepadreleased(joystick, button)
	if button == "dpup" or button == "dpdown" then
		self.direction.y = 0
	end
end;

function Gun:keyreleased(key)
	if key == "up" or key == "down" then
		self.direction.y = 0
	end
end;

function Gun:update(dt)
	for i,p in ipairs(self.projectiles) do
		p:update(dt)
		if not p.active then
			table.remove(self.projectiles, i)
			self.world:remove(p)
		end
	end
end;

function Gun:draw()
	for _,p in ipairs(self.projectiles) do
		p:draw()
	end
end;

return Gun