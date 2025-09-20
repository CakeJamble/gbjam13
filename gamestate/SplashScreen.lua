local SplashScreen = {}

function SplashScreen:init()
	self.numLevels = 3
end;

---@param previous table Previously active State
function SplashScreen:enter(previous, levelIndex)
	-- if self.world then
	-- 	local items = self.world:getItems()
	-- 	for i=1,#items do
	-- 		self.world:remove(items[i])
	-- 	end
	-- end
	self.nextLevel = levelIndex or 1
	shove.createLayer("background", {zIndex = 1})
	local fname = "splash_screen_" .. self.nextLevel .. ".png"
	self.bg = love.graphics.newImage("asset/sprite/" .. fname)
	self.textBox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})

	self.text = {
		"Something's wrong at the pole station! [bounce]Let's check it out![/bounce]",
		"[shake]The city is in chaos![/shake]",
		"Consider yourself lucky to have made it this far",
		"You saved the universe! Press any button to close the game."
	}
	self:start()
end;

function SplashScreen:start()
	self.textBox:send(self.text[self.nextLevel], 140)
end;

---@param joystick string
---@param button string
function SplashScreen:gamepadpressed(joystick, button)
	if (button == "a" or button == "b" or
	button == "dpup" or button == "dpdown" or button == "dpleft" or button == "dpright"
	or button == "start" or button == "select") and self.nextLevel > self.numLevels then
		love.event.quit()
	end
	if button == 'a' then
		Gamestate.switch(States["Game"], self.nextLevel)
	end
end;

function SplashScreen:keypressed(key)
	if (key == "z" or key == "x" or
	key == "up" or key == "down" or key == "left" or key == "right"
	or key == "return" or key == "tab") and self.nextLevel > self.numLevels then
		love.event.quit()
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
	Frame.draw("eb", 0, 100, 160, 44)
	self.textBox:draw(5, 100)
	shove.endLayer()
	shove.endDraw()
end;

return SplashScreen