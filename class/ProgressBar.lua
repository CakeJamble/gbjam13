local flux = require('lib.flux')
local Signal = require('lib.hump.signal')
local Class = require 'lib.hump.class'

---@class ProgressBar
local ProgressBar = Class{}

---@param options {[string]: any }
function ProgressBar:init(options)
	options.w = options.w/2
	options.h = options.h/2
	self.isUnlucky = false
	self.horizontal = options.horizontal or false -- Support for horizontal orientation
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

	if self.horizontal then
		self.meterStartingWidth = options.w
		self.meterOptions = {
			mode = 'fill',
			width = self.meterStartingWidth,
			height = options.h,
			value = 0
		}
	else
		self.meterStartingHeight = -options.h
		self.meterOptions = {
			mode = 'fill',
			width = options.w,
			height = self.meterStartingHeight,
			value = 0
		}
	end
	self.tween = nil
	self.duration = 20
	self:tweenUnlucky(self.duration)
end;

---@param duration number
---@param value? number
function ProgressBar:tweenUnlucky(duration, value)
	if self.tween then self.tween:stop() end

	if self.horizontal then
		self.tween = flux.to(self.meterOptions, duration, {width = 0})
	else
		self.tween = flux.to(self.meterOptions, duration, {height = 0}) 
	end
end;

function ProgressBar:tweenLucky(duration, value)
	Signal.emit("OnUnluckyEnd")
	
	if self.horizontal then
		local curr = self.meterOptions.width
		local target = math.min(self.containerOptions.width, curr + value)

		flux.to(self.meterOptions, duration, {width = target})
		:oncomplete(function()
			local remainingMeterDistance = target
			local maxDistance = self.containerOptions.width
			local newDuration = (remainingMeterDistance / maxDistance) * self.duration
			self:tweenUnlucky(newDuration)
		end)
	else
		local curr = self.meterOptions.height
		local target = math.max(-self.containerOptions.height, curr - value)

		flux.to(self.meterOptions, duration, {height = target})
		:oncomplete(function()
			local remainingMeterDistance = math.abs(target)
			local maxDistance = self.containerOptions.height
			local newDuration = (remainingMeterDistance / maxDistance) * self.duration
			self:tweenUnlucky(newDuration)
		end)
	end
end;

function ProgressBar:stop()
	self.tween:stop()
	
	if self.horizontal then
		local curr = self.meterOptions.width
		local remainingMeterDistance = self.containerOptions.width - curr
		local maxDistance = self.containerOptions.width
		local newDuration = (remainingMeterDistance / maxDistance) * self.duration
		self.remaining = newDuration
	else
		local curr = self.meterOptions.height
		local target = math.min(0, curr)
		local remainingMeterDistance = math.abs(-self.containerOptions.height - target)
		local maxDistance = self.containerOptions.height
		local newDuration = (remainingMeterDistance / maxDistance) * self.duration
		self.remaining = newDuration 
	end
end;

---@param amount integer
function ProgressBar:increaseMeter(amount)
	self.meterOptions.value = math.min(self.max, self.meterOptions.value + amount)
	self:tweenLucky(1, self.meterOptions.value)
end;

---@param amount integer
function ProgressBar:decreaseMeter(amount)
	self.meterOptions.value = math.max(self.min, self.meterOptions.value - amount)
	Signal.emit("OnUnluckyEnd")
end;

function ProgressBar:reset()
	if self.tween then self.tween:stop(); self.tween = nil; end
	if self.horizontal then
		self.meterOptions.width = self.containerOptions.widthl
	else
		self.meterOptions.height = -self.containerOptions.heightl
	end
	self.meterOptions.value = 0
end;

function ProgressBar:update(dt)
	if self.horizontal then
		local threshold = self.containerOptions.width * 0.03  -- Trigger unlucky when 3% remaining (nearly empty)
		if self.meterOptions.width <= threshold and not self.isUnlucky then
			self.isUnlucky = true
			Signal.emit('OnUnlucky')
			if self.tween then self.tween:stop() end
		end
		if self.isUnlucky and self.meterOptions.width > threshold then
			self.isUnlucky = false
		end
	else
		-- For vertical meters, check height  
		local threshold = -self.containerOptions.height * 0.03
		if self.meterOptions.height >= threshold and not self.isUnlucky then
			self.isUnlucky = true
			Signal.emit('OnUnlucky')
			if self.tween then self.tween:stop() end
		end
		if self.isUnlucky and self.meterOptions.height < threshold then
			self.isUnlucky = false
		end
	end
end;

function ProgressBar:draw(x, y)
	-- local x,y = self.pos.x , self.pos.y
	local cw,ch = self.containerOptions.width , self.containerOptions.height 
	local mw,mh = self.meterOptions.width , self.meterOptions.height 
	love.graphics.setColor(240/255, 225/255, 209/255)
	love.graphics.rectangle(self.containerOptions.mode, x, y, cw, ch)
	love.graphics.setColor(217/255, 151/255, 65/255)
	
	if self.horizontal then
		love.graphics.rectangle(self.meterOptions.mode, x, y, mw, ch)
	else
		love.graphics.rectangle(self.meterOptions.mode, x, y + ch, mw, mh)
	end
	
	love.graphics.setColor(1, 1, 1)
end;

return ProgressBar