local Class = require('lib.hump.class')

local Lamp = Class{sprite = love.graphics.newImage('asset/sprite/object/end_flag.png')}

function Lamp:init(data)
	self.type = "levelEnd"
	self.name = "End Level Flag"
	self.solid = false
	self.pos = {x=data.x, y=data.y}
	self.dims = {w=16, h=16}
	self.amount = 10
end;

function Lamp:draw()
	love.graphics.draw(self.sprite, self.pos.x - self.dims.w / 2, self.pos.y)
end;

return Lamp