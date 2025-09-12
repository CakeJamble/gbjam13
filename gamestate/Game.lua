local bump = require('lib.bump')
local map = require('map.map_example')
local Player = require('class.Player')
local Game = {}

function Game:init()
	local songPath = "asset/audio/castle_lololo.mp3"
	self.music = love.audio.newSource(songPath, "stream")
	self.music:play()

	self.gravity = 500
end;

---@param previous table Previously active State
function Game:enter(previous)
	self.showText = false

	local playerData = {
		name = "player",
		x = 32, y = 32,
		w = 14, h = 14,
		animations = {
			"idle", "walk", "jump", -- "shoot", ...
		}
	}

	self.player = Player(playerData)

-- For when we have tiles and gravity ready to implement
	-- local tileSize = 16
	-- self.world = bump.newWorld(tileSize)
	-- self.world:add(self.player, self.player.pos.x, self.player.pos.y,
	-- 	self.player.dims.w, self.player.dims.h)
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
	self.player:update(dt)
end;

function Game:draw()
	self.player:draw()

	if self.showText then
		love.graphics.print("GBJam13")
	end
end;

return Game