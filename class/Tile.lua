local Class = require('lib.hump.class')

---@class Tile
local Tile = Class{}

---@param data table
function Tile:init(data)
	self.x, self.y = data.x, data.y
	self.w, self.h = data.w, data.h
end;

function Tile:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y,
	self.w, self.h)
	love.graphics.setColor(0, 0, 0)
end;

return Tile