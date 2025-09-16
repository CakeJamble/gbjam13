Gamestate = require('lib.hump.gamestate')
shove = require('lib.shove')
Text = require('lib.sysl-text.slog-text')
Frame = require('lib.sysl-text.slog-frame')
local loadAudio = require('util.audio_loader')

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
	----- Screen
	love.graphics.setBackgroundColor(24/255, 27/255, 36/255)
	local scale = parseArgs(args) --> 8

	WindowWidth, WindowHeight = 160 * scale, 144 * scale

	shove.setResolution(160, 144, {
		fitMethod = "pixel",
		scalingFilter = "nearest",
		renderMode = "layer" -- change to "layer" if you want to use drawing layers
	})


local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
shove.setWindowMode(desktopWidth * 0.5, desktopHeight * 0.5, {
  resizable = true,
  vsync = true,
  minwidth = 160,
  minheight = 144
})

	----- Text Boxes & Frames
	images = {}
	images.frame = {}
	images.frame.eb_8 = love.graphics.newImage('asset/sprite/frame/eb_8.png')
	Text.configure.image_table("images")
	Frame.load()
	Audio = {}
	Audio.text = {}
	Audio.text.default = love.audio.newSource('asset/audio/text/default.ogg', "static")
	Text.configure.audio_table("Audio")
	Text.configure.add_text_sound(Audio.text.default, 0.75)
	Fonts = {
		golden_apple = love.graphics.newFont("asset/font/golden_apple.fnt", "asset/font/golden_apple.png"),
		comic_neue_small = love.graphics.newFont("asset/font/comic_neue_13.ttf", 11, "mono")
	}

	love.graphics.setFont(Fonts.golden_apple)

	----- Game Mechanics
	Gravity = 500

	----- Music
	AllSounds = {sfx = {}, music = {}}
	local musicDir = 'asset/audio/music'
	local sfxDir = 'asset/audio/sfx'
	loadAudio(musicDir, AllSounds.music, "stream")
	loadAudio(sfxDir, AllSounds.sfx, "static")

	----- Gamestates
	States = {
		MainMenu = require('gamestate.MainMenu'),
		Game = require('gamestate.Game')
		-- ...
	}
	Gamestate.registerEvents()
	Gamestate.switch(States["MainMenu"])
end;