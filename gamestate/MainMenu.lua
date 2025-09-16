local MainMenu = {}

function MainMenu:init()
end;

---@param previous table Previously active State
function MainMenu:enter(previous)
	shove.createLayer("background", {zIndex = 1})
	self.bg = love.graphics.newImage("asset/sprite/splash_screen.png")
	self.textBox = Text.new("left",
	{
    color = {0.9,0.9,0.9,0.95},
    shadow_color = {0.5,0.5,1,0.4},
    character_sound = true,
    sound_every = 2,
	})

	self.text = "Something's wrong at the pole station! [bounce]Let's check it out![/bounce]"
	self:start()
end;

function MainMenu:start()
	self.textBox:send(self.text, 140)
end;

---@param joystick string
---@param button string
function MainMenu:gamepadpressed(joystick, button)
	if button == 'a' then
		Gamestate.switch(States["Game"])
	end
end;

function MainMenu:keypressed(key)
	if key == 'z' then
		Gamestate.switch(States["Game"])
	end
end;

---@param dt number
function MainMenu:update(dt)
	self.textBox:update(dt)
	-- cam:update(dt)
end;

function MainMenu:draw()
	shove.beginDraw()
	shove.beginLayer("background")
	love.graphics.draw(self.bg,0,0)
	Frame.draw("eb", 0, 100, 160, 44)
	self.textBox:draw(5, 100)
	shove.endLayer()
	shove.endDraw()
end;

return MainMenu