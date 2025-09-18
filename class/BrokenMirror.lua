local createAnimation = require('util.create_animation')
local Calendar = require('class.Calendar')
local Timer = require('lib.hump.timer')
local Class = require('lib.hump.class')

local BrokenMirror = Class{__includes = Calendar,
sprite = love.graphics.newImage('asset/sprite/enemy/mirror.png'),
projectileSprite = love.graphics.newImage('asset/sprite/enemy/mirror_projectile.png')}

function BrokenMirror:init(data)
	Calendar.init(self, data)
	self.name = "Broken Mirror"
	local sprite = createAnimation(BrokenMirror.sprite, 16, 16)
	sprite.loop = true
	self.animations.idle = sprite
	self:start()
end;

function BrokenMirror:start()
	Timer.every(3, function() self:shoot(BrokenMirror.projectileSprite) end)
end;

return BrokenMirror