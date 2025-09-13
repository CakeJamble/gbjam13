local Tile = require('class.Tile')
local Class = require('lib.hump.class')

---@class Solid: Tile
---@field sprite love.Image
local Solid = Class{__includes = Tile,
sprite = love.graphics.newImage('asset/sprite/tile/solid.png')}

function Solid:init(data)
	Tile.init(self, data)
	self.solid = true
end;

function Solid:draw()
	love.graphics.draw(Solid.sprite, self.x, self.y)
end;

return Solid