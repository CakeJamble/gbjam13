local Tile = require('class.Tile')
local Class = require('lib.hump.class')

---@class Spike: Tile
---@field sprite love.Image
local Spike = Class{__includes = Tile,
sprite = love.graphics.newImage('asset/sprite/tile/spike.png')}

function Spike:init(data)
	Tile.init(self, data)
	self.damage = 1
	self.solid = true
end;

function Spike:onCollision(player)
	player:takeDamage(self.damage)
end;

function Spike:draw()
	love.graphics.draw(Spike.sprite, self.pos.x, self.pos.y)
end;

return Spike