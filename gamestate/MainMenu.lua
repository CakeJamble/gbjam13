local MainMenu = {}

function MainMenu:init()
end;

---@param previous table Previously active State
function MainMenu:enter(previous)
end;

---@param joystick string
---@param button string
function MainMenu:gamepadpressed(joystick, button)
	if button == 'a' then
		Gamestate.switch(States["Game"])
	end
end;

---@param dt number
function MainMenu:update(dt)
end;

function MainMenu:draw()
	love.graphics.print("Press A to go to Game gamestate")
end;

return MainMenu