local bump = require('lib.bump')
local loadMaps = require('util.map_loader')
local loadEnemies = require('util.enemy_loader')
local tileRegistry = require('level.tile_registry')
local Player = require('class.Player')
local Camera = require('lib.hump.camera')
local Game = {}

function Game:init()
	self.maps = loadMaps()
	self.levelIndex = 1
	self.tileSize = 16
	local songPath = "asset/audio/casino.mp3"
	self.music = love.audio.newSource(songPath, "stream")
	self.music:play()

	self.player = self:loadPlayer()
	Gravity = 500
	camera = Camera(self.player.pos.x - self.tileSize, self.player.pos.y, 4)
end;

---@param previous table Previously active State
function Game:enter(previous)
	self.enemies = loadEnemies(self.levelIndex, self.tileSize)
	local tileMap = self.maps[self.levelIndex]
	World = bump.newWorld(self.tileSize)
	self.level = self.loadLevel(tileMap, self.tileSize)
	self.addToWorld(self.player, self.enemies, self.level)
	camera:lockPosition(self.player.pos.x, self.player.pos.y)
end;

---@return Player
function Game:loadPlayer()
	local col, row = 5, 6
	local x = (col - 1) * self.tileSize
	local y = (row - 1) * self.tileSize
	local playerData = {
		name = "player",
		x = x, y = y,
		w = 25, h = 24,
		animations = {
			"idle", "walk", "jump", -- "shoot", ...
		}
	}

	return Player(playerData)
end;

---@param player Player
---@param enemies Entity[]
---@param level Tile[]
function Game.addToWorld(player, enemies, level)
	World:add(player, player.pos.x, player.pos.y, player.dims.w, player.dims.h)

	for _,enemy in ipairs(enemies) do
		World:add(enemy, enemy.pos.x, enemy.pos.y, enemy.dims.w, enemy.dims.h)
	end

	for _,tile in ipairs(level) do
		World:add(tile, tile.x, tile.y, tile.w, tile.h)
	end
end;

---@param tileMap table
---@param tileSize integer
function Game.loadLevel(tileMap, tileSize)
	local tiles = {}

	-- map collision
	for row=1, #tileMap do
		for col=1, #tileMap[row] do
			local tileID = tileMap[row][col]
			local TileClass = tileRegistry[tileID]

			if TileClass then
				local data = {
					x = (col - 1) * 32,
					y = (row - 1) * 32,
					w = 32,
					h = 32,
				}
				local tile = TileClass(data)
				table.insert(tiles, tile)
			end
		end
	end

	return tiles
end;

function Game:reset()
	for _, obj in ipairs(World:getItems()) do
		World:remove(obj)
	end


	self.level = self.loadLevel(self.maps[self.levelIndex], self.tileSize)
	self.player = self:loadPlayer()
	self.enemies = loadEnemies(self.levelIndex, self.tileSize)
	self.addToWorld(self.player, self.enemies, self.level)
end;

---@param joystick string
---@param button string
function Game:gamepadpressed(joystick, button)
	self.player:gamepadpressed(joystick, button)
end;

---@param joystick string
---@param button string
function Game:gamepadreleased(joystick, button)
	self.player:gamepadreleased(joystick, button)
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
	for _,enemy in ipairs(self.enemies) do
		enemy:update(dt)
	end
	if self.player.health == 0 then
		self:reset()
	end

	local dx,dy = self.player.pos.x - camera.x, self.player.pos.y - camera.y
	camera:move(dx, dy)
end;

function Game:draw()
	-- shove.beginDraw()
	camera:attach()
	self.player:draw()
	self:drawTiles()
	for _,enemy in ipairs(self.enemies) do
		enemy:draw()
	end

	self:drawCollision()
	camera:detach()
	local hp = tostring(self.player.health)
	love.graphics.print(hp, 10, 10)
	-- shove.endDraw()
end;

function Game:drawTiles()
	for _,tile in ipairs(self.level) do
		tile:draw()
	end
end;

function Game:drawCollision()
	love.graphics.setColor(1, 0, 0, 0.5)
	for _,item in ipairs(World:getItems()) do
		local x, y, w, h = World:getRect(item)
		love.graphics.rectangle("line", x, y, w, h)
	end
	love.graphics.setColor(1,1,1,1)
end;

return Game