local Tile = require('class.Tile')
local Signal = require('lib.hump.signal')
local Class = require('lib.hump.class')

---@class Clover: Tile
---@field sprite love.Image
local Clover = Class{__includes = Tile,
sprite = love.graphics.newImage('asset/sprite/object/clover.png')}

function Clover:init(data)
	Tile.init(self, data)
	self.type = "item"
	self.dims = {w=16, h=16}
	self.baseY = data.y
	self.floatAmplitude = 0.25
	self.floatSpeed = 2
	self.amount = 25
	self.dead = false
end;

function Clover:update(dt)
	if not self.dead then
		local offsetY = math.sin(love.timer.getTime() * self.floatSpeed) * self.floatAmplitude
		local goalX, goalY = self.pos.x, self.pos.y + offsetY

		local actualX, actualY, cols, len = self.world:move(self, goalX, goalY, 
			function(item, other)
				if other.type == "player" then
					return "cross" 
				end
				return nil
			end)
		self.pos.x, self.pos.y = actualX, actualY

		for _,col in ipairs(cols) do
			if col.other and col.other.type == "player" then
				Signal.emit("OnGetClover", self)
				self.dead = true
			end
		end
	end
end;

function Clover:draw()
	if not self.dead then
		love.graphics.draw(self.sprite, self.pos.x, self.pos.y)
	end
end;

return Clover