local createAnimation = require('create_animation')
local Entity = require('class.Entity')
local Class = require('lib.hump.class')

---@class Player: Entity
local Player = Class{__includes = Entity}

function Player:init(data)
	Entity.init(self, data)
	self.onGround = true
	local assetDir = "asset/sprite/" .. data.name .. "/"
	self.animations = self:initAnimations(assetDir, data.animations)
	self.currentAnimationTag = "idle"
end;

---@param dir string
---@param animations string[]
function Player:initAnimations(dir, animations)
	local result = {}
	for _,animName in ipairs(animations) do
		local image = love.graphics.newImage(dir .. animName .. ".png")
		local animation = createAnimation(image, self.dims.w, self.dims.h)
		result[animName] = animation
	end

	return result
end;

---@param dt number
function Player:update(dt)
	self:updateAnimation(dt)
end;

---@param dt number
function Player:updateAnimation(dt)
	local animation = self.animations[self.currentAnimationTag]
	animation.currentTime = animation.currentTime + dt
	if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
	end
end;

function Player:draw()
	self:drawSprite()
end;

function Player:drawSprite()
	local animation = self.animations[self.currentAnimationTag]
	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	spriteNum = math.min(spriteNum, #animation.quads)
	love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.pos.x, self.pos.y)
end;