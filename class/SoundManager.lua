local Class = require('lib.hump.class')

-- Manages sound effects and music for gamestates
	-- Other objects are responsible for their own sfx
---@class SoundManager
local SoundManager = Class{}

function SoundManager:init(sounds)
	self.sounds = sounds or {}
	self.volume = 1.0
end;

---@param key string
---@return table|nil Returns a love.audio.Source or nothing if key not found
function SoundManager:play(key)
	local variants = self.sounds[key]
	if not variants or #variants == 0 then return end

	local i = love.math.random(#variants)
	local base = variants[i]

	local sound = base:clone()
	sound:play()

	return sound
end;

function SoundManager:setVolume(v)
	self.volume = v
end;

return SoundManager