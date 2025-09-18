local flux = require('lib.flux')
local Signal = require('lib.hump.signal')
local Class = require 'lib.hump.class'

---@class ProgressBar
local ProgressBar = Class{}

---@param options {[string]: any }
function ProgressBar:init(options)
	self.isUnlucky = false
	self.pos = {
		x = options.x,
		y = options.y
	}
	self.min = options.min
	self.max = options.max

	self.containerOptions = {
		mode = 'line',
		width = options.w,
		height = options.h
	}

	self.meterStartingHeight = 0
	self.meterOptions = {
		mode = 'fill',
		width = options.w,
		height = self.meterStartingHeight,
		value = 0
	}
	self.tween = nil
	self:tweenUnlucky(15)
end;

function ProgressBar:tweenUnlucky(duration)
	self.tween = flux.to(self.meterOptions, duration, {height = -self.containerOptions.height})
		:oncomplete(function() Signal.emit('OnUnlucky') end)
end;

function ProgressBar:tweenLucky(duration, value)
	local height = self.meterOptions.height
	self.tween = flux.to(self.meterOptions, duration, {height = math.min(0, height + value)})
end;

function ProgressBar:stop()
	self.tween:stop()
end;

---@param amount integer
function ProgressBar:increaseMeter(amount)
	self.meterOptions.value = math.min(self.max, self.meterOptions.value + amount)
	self:tweenLucky(1, self.meterOptions.value)
end;

---@param amount integer
function ProgressBar:decreaseMeter(amount)
	self.meterOptions.value = math.max(self.min, self.meterOptions.value - amount)
end;

function ProgressBar:reset()
	if self.tween then self.tween:stop(); self.tween = nil; end
	self.meterOptions.width = self.meterStartingHeight
	self.meterOptions.value = 0
end;

function ProgressBar:update(dt)
	if self.isUnlucky and self.meterOptions.height > -self.containerOptions.height then
		self.isUnlucky = false
		Signal.emit("OnUnluckyEnd")
	end
end;

function ProgressBar:draw()
	local x,y = self.pos.x , self.pos.y
	local cw,ch = self.containerOptions.width , self.containerOptions.height 
	local mw,mh = self.meterOptions.width , self.meterOptions.height 
	love.graphics.setColor(240/255, 225/255, 209/255)
	love.graphics.rectangle(self.containerOptions.mode, x, y, cw, ch)
	love.graphics.setColor(217/255, 151/255, 65/255)
	love.graphics.rectangle(self.meterOptions.mode, x, y + ch, mw, mh)
	love.graphics.setColor(1, 1, 1)
end;

return ProgressBar