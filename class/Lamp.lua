local Signal = require('lib.hump.signal')
local Class = require('lib.hump.class')

local Lamp = Class{sprite = love.graphics.newImage('asset/sprite/object/lamp_on.png')}

function Lamp:init(data)
	self.type = "item"
	self.name = "Lamp"
	self.solid = false
	self.pos = {x=data.x, y=data.y}
	self.dims = {w=32, h=64}
	self.amount = 10
end;

function Lamp:draw()
	love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
end;

return Lamp