local Class = require('lib.hump.class')

-- Manages sound effects and music for gamestates
	-- Other objects are responsible for their own sfx
---@class SoundManager
local SoundManager = Class{}

function SoundManager:init(sounds)
	self.sounds = sounds or {}
	self.volume = 1.0
	self.activeSounds = {}
end;

---@param key string
---@return table|nil Returns a love.audio.Source or nothing if key not found
function SoundManager:play(key)
	local variants = self.sounds[key]
	if not variants or #variants == 0 then return end

	local i = love.math.random(#variants)
	local base = variants[i]

	local sound = base:clone()
	sound:setVolume(self.volume)
	sound:play()

	table.insert(self.activeSounds, sound)
	return sound
end;

function SoundManager:setVolume(v)
	self.volume = v
	for _,src in ipairs(self.activeSounds) do
		src:setVolume(self.volume)
	end
end;

function SoundManager:update(dt)
	for i,src in ipairs(self.activeSounds) do
		if not src:isPlaying() then
			table.remove(self.activeSounds, i)
		end
	end
end;

return SoundManager