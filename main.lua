Gamestate = require('lib.hump.gamestate')
shove = require('lib.shove')

---@param args string[]
---@return integer
local function parseArgs(args)
	local scale = 8 -- (1280x1152)

	for _,arg in ipairs(args) do
		local n = tonumber(arg)
		if n and n >=1 then
			scale = math.floor(n)
			break
		end
	end

	return scale
end;

---@param args string[]
function love.load(args)
	----- Screen Resolution
	shove.setResolution(160, 144, {
		fitMethod = "pixel",
		renderMode = "direct" -- change to "layer" if you want to use drawing layers
	})

	local scale = parseArgs(args)

	WindowWidth, WindowHeight = 160 * scale, 144 * scale
	shove.setWindowMode(WindowWidth, WindowHeight, {
		resizable = true
	})

	----- Game Mechanics
	Gravity = 500

	----- Gamestates
	States = {
		MainMenu = require('gamestate.MainMenu'),
		Game = require('gamestate.Game')
		-- ...
	}
	Gamestate.registerEvents()
	Gamestate.switch(States["MainMenu"])
end;