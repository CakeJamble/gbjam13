local Game = {}

function Game:init()
	local songPath = "asset/audio/castle_lololo.mp3"
	self.music = love.audio.newSource(songPath, "stream")
	self.music:play()
end;

---@param previous table Previously active State
function Game:enter(previous)
	self.showText = false
end;

---@param joystick string
---@param button string
function Game:gamepadpressed(joystick, button)
	if button == 'a' then
		self.showText = not self.showText
	end
end;

---@param key string
function Game:keypressed(key)
	if key == 'z' then
		self.showText = not self.showText
	end
end;

---@param dt number
function Game:update(dt)
end;

function Game:draw()
	if self.showText then
		love.graphics.print("GBJam13")
	end
end;

return Game