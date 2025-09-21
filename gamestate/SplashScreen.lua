local SplashScreen = {}
local SoundManager = require('class.SoundManager')

function SplashScreen:init()
	self.numLevels = 3
	self.musicManager = SoundManager(AllSounds.music)
end;

---@param previous table Previously active State
function SplashScreen:enter(previous, levelIndex)
	-- levelIndex is the level that was just completed
	self.completedLevel = levelIndex or 1
	self.nextLevel = self.completedLevel + 1
	
	shove.createLayer("background", {zIndex = 1})
	local fname = "splash_screen_" .. self.completedLevel .. ".png"
	self.bg = love.graphics.newImage("asset/sprite/" .. fname)
	self.textBox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})

	self.text = {
		'"Cookie time already? I should save the city first though..."',
		"Despite Fortune's efforts, the city is absolutely luckless!",
		"",
	}
	
	if self.completedLevel >= self.numLevels then
		self.song = self.musicManager.sounds["credits"][1]
		self.song:play()
	end
	
	self:start()
end;

function SplashScreen:start()
	self.textBox:send(self.text[self.completedLevel], 140)
end;

---@param joystick string
---@param button string
function SplashScreen:gamepadpressed(joystick, button)
	if self.completedLevel >= self.numLevels then
		return
	end
	
	if button == 'a' then
		Gamestate.switch(States["Game"], self.nextLevel)
	end
end;

function SplashScreen:keypressed(key)
	if self.completedLevel >= self.numLevels then
		return
	end
	
	if key == 'z' then
		Gamestate.switch(States["Game"], self.nextLevel)
	end
end;

---@param dt number
function SplashScreen:update(dt)
	self.textBox:update(dt)
end;

function SplashScreen:draw()
	shove.beginDraw()
	shove.beginLayer("background")
	love.graphics.draw(self.bg,0,0)
	if self.completedLevel < self.numLevels then
		Frame.draw("eb", 0, 100, 160, 44)
		self.textBox:draw(5, 100)
	end
	shove.endLayer()
	shove.endDraw()
end;

return SplashScreen