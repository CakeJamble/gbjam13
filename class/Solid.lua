local Tile = require('class.Tile')
local Class = require('lib.hump.class')

---@class Solid: Tile
---@field sprite love.Image
local Solid = Class{__includes = Tile,
sprite = love.graphics.newImage('asset/sprite/tile/ground_1.png')}

function Solid:init(data)
	Tile.init(self, data)
	self.solid = true
	self.type = "ground"
end;

function Solid:draw()
	love.graphics.draw(Solid.sprite, self.pos.x, self.pos.y)
end;

return Solid