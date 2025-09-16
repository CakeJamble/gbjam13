local bump = require('lib.bump')
local loadMaps = require('util.map_loader')
local loadEnemies = require('util.enemy_loader')
local tileRegistry = require('level.tile_registry')
local Player = require('class.Player')
local Timer = require('lib.hump.timer')
local Gun = require('class.Gun')
local SoundManager = require('class.SoundManager')
local ProgressBar = require('class.ProgressBar')
local Signal = require('lib.hump.signal')


local Game = {}

function Game:init()
	-- imgui.love.Init()
	shove.createLayer("everything_else", {zIndex = 1000})
	shove.createLayer("ui", {zIndex = 1001})
	self.camera = {x=0,y=0, speed = 8, deadzone = {x = 40, y = 32}}
	self.maps = loadMaps()
	self.levelIndex = 1
	self.tileSize = 16
	self.showDebug = false
	self.player = self:loadPlayer()
	Gravity = 500
	self.zoomValue = 4
	self.numVisible = 0
	self.soundManager = SoundManager(AllSounds.music)
	self.paused = false
	self.showUnluckyMessage = false
	self.unluckyMessageBox = Text.new("left", {
		color = {0.9,0.9,0.9,0.95},
	})
	self.unluckyMessage = "[bounce]Your luck has turned...[/bounce]"
	Signal.register('OnUnlucky',
		function()
			self.showUnluckyMessage = true
			self.unluckyMessageBox:send(self.unluckyMessage, 140)
			Timer.after(3, function()
				self.showUnluckyMessage = false
			end)
		end)
end;

---@param previous table Previously active State
function Game:enter(previous)
	self.parallax = self.initBG()
	self.enemies = loadEnemies(self.levelIndex, self.tileSize)
	local tileMap = self.maps[self.levelIndex]
	World = bump.newWorld(self.tileSize)
	self.level = self.loadLevel(tileMap, self.tileSize)
	self.levelWidth = self.tileSize * #self.level[1]
	self.levelHeight = self.tileSize * #self.level
	self.addToWorld(self.player, self.enemies, self.level)
	local songName = "level_" .. self.levelIndex
	self.soundManager:play(songName)
	self.unluckyMeter = self.initUnluckyMeter(self.player.pos)
end;

function Game.initBG()
  local parallax = {
    layers = {},
    scrollAmplitude = 600,
    currentX = 0,            -- Current scroll position
    time = 0,                -- Time counter for scroll animation
    speed = 0.15
  }
  local layerImages = {
  	{img = love.graphics.newImage("asset/sprite/tile/TILE_Stars_1_ANIMATED.png"), depth = 1.0, name = "layer_01"},
  	{img = love.graphics.newImage("asset/sprite/tile/TILE_Stars_2_ANIMATED.png"), depth = 0.5, name = "layer_02"}
  }
  local vW = shove.getViewportWidth()
  local vH = shove.getViewportHeight()
  for i,layer in ipairs(layerImages) do
  	local w,h = layer.img:getDimensions()
  	local sx = vH / w
  	local sy = vH / h
  	local scale = math.max(sx, sy) * 1.2
  	parallax.layers[i] = {
  		img = layer.img,
  		depth = layer.depth,
  		name = layer.name,
  		scale = scale,
  		zIndex = 90 - (1 * 10) -- zIndex goes up -> closer to foreground
  	}

  	shove.createLayer(layer.name, {zIndex = parallax.layers[i].zIndex})
  end
  shove.createLayer("background", {zIndex = 5})
	return parallax
end;

function Game.initUnluckyMeter(playerPos)
	local x,y = playerPos.x + 10, playerPos.y + 10 
	local options = {
		x = x,
		y = y,
		w = 10,
		h = 40,
		min=0,max=100,
	}
	return ProgressBar(options)
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
	local player = Player(playerData)
	local startGun = Gun({
		x=x,y=y,
		w = 25, h = 18,
		damage=1,
		speed={x=200,y=200},
		owner = player
	})
	player:setGun(startGun)
	return player
end;

---@param player Player
---@param enemies Entity[]
---@param level Tile[]
function Game.addToWorld(player, enemies, level)
	for _,tile in ipairs(level) do
		World:add(tile, tile.pos.x, tile.pos.y, tile.dims.w, tile.dims.h)
	end

	World:add(player, player.pos.x, player.pos.y, player.dims.w, player.dims.h)

	for _,enemy in ipairs(enemies) do
		World:add(enemy, enemy.pos.x, enemy.pos.y, enemy.dims.w, enemy.dims.h)
		enemy:start()
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
					x = (col - 1) * 8,
					y = (row - 1) * 8,
					w = 8,
					h = 8,
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
	if not self.paused then
		self.player:gamepadpressed(joystick, button)
	end
	if button == "start" then
		self.paused = not self.paused

		if self.paused then
			self.soundManager:pause()
			self.player.sfx:pause()
		else
			self.soundManager:resume()
			self.player.sfx:resume()
		end
	end
end;

function Game:keypressed(key)
	if not self.paused then
		self.player:keypressed(key)
	end
	if key == "return" then
		self.paused = not self.paused

		if self.paused then
			self.soundManager:pause()
			self.player.sfx:pause()
		else
			self.soundManager:resume()
			self.player.sfx:resume()
		end
	end
end;

---@param joystick string
---@param button string
function Game:gamepadreleased(joystick, button)
	if not self.paused then
		self.player:gamepadreleased(joystick, button)
	end
end;

function Game:keyreleased(key)
	if not self.paused then
		self.player:keyreleased(key)
	end
end;

function Game:isInView(obj, viewport)
  local x = obj.pos.x or obj.x
  local y = obj.pos.y or obj.y
  local w = obj.dims.w or obj.w
  local h = obj.dims.h or obj.h
  return not (
    x + w < viewport.x or
    x > viewport.x + viewport.width or
    y + h < viewport.y or
    y > viewport.y + viewport.height
  )
end;

function Game:countVisibleObj()
	local x, y, width, height = shove.getViewport()
	local view = {x=x,y=y,width=width,height=height}
	local count = 0

	for _,item in ipairs(World:getItems()) do
		if self:isInView(item, view) then
			count = count + 1
		end
	end
	return count
end;

---@param dt number
function Game:update(dt)
	if not self.paused then
		if self.showUnluckyMessage then
			self.unluckyMessageBox:update(dt)
		end
		self.player:update(dt)
		for _,enemy in ipairs(self.enemies) do
			enemy:update(dt)
		end
		if self.player.health == 0 then
			self:reset()
		end

		self.soundManager:update(dt)
		self:updateCamera(dt)
		self:updateParallax(dt)
	end
end;

function Game:updateCamera(dt)
	local x, y = self.player.pos.x, self.player.pos.y + self.player.lookYOffset.curr
	local tx,ty = x-80,y-72
	self.camera.x = self.camera.x + (tx - self.camera.x) * self.camera.speed * dt
	self.camera.y = self.camera.y + (ty - self.camera.y) * self.camera.speed * dt
end;

function Game:updateParallax(dt)
	-- for time based animation like rain
	self.parallax.time = self.parallax.time + dt
	-- self.parallax.currentX = math.sin(self.parallax.time * self.parallax.speed) * self.parallax.scrollAmplitude
	-- for movement based animation like scrolling bg
	if not self.player.isBlocked then
		self.parallax.currentX = self.parallax.currentX + self.player.moveDir * self.player.speed * dt
	end
end;


function Game:draw()
	shove.beginDraw()
	love.graphics.push()

	-- camera smoothing
	love.graphics.translate(-math.floor(self.camera.x), -math.floor(self.camera.y))

	-- parallax scrolling background
	for i,layer in ipairs(self.parallax.layers) do
		shove.beginLayer(layer.name)
		local offsetX = self.parallax.currentX * layer.depth
		local vW = shove.getViewportWidth()
		local vH = shove.getViewportHeight()
		local imgWidth = layer.img:getWidth() * layer.scale
		local imgHeight = layer.img:getHeight() * layer.scale
		local posY = vH - imgHeight
		local totalWidthNeeded = vW + self.parallax.scrollAmplitude * 2 * layer.depth
		local copiesNeeded = math.ceil(totalWidthNeeded / imgWidth)
		local baseX = offsetX % imgWidth

		for j=0, copiesNeeded do
			local drawX = baseX - imgWidth + (j * imgWidth)
			love.graphics.draw(layer.img, drawX, posY, 0, layer.scale, layer.scale)
		end
		shove.endLayer()
	end

	shove.beginLayer("everything_else")
	self:drawTiles()
	for _,enemy in ipairs(self.enemies) do
		enemy:draw()
	end
	self.player:draw()
	if self.showUnluckyMessage then
		self.unluckyMessageBox:draw(self.player.pos.x - 25, self.player.pos.y + 40)
	end
	if self.drawHitboxes then
		self:drawCollision()
	end

	shove.endLayer()
	love.graphics.pop()

	-- ui, drawn independently from camera/scroll
	shove.beginLayer("ui")
	self.unluckyMeter:draw(self.zoomValue)
	local hp = tostring(self.player.health)
	love.graphics.print(hp, 10, 10)
	local numVis = tostring(self.numVisible)
	love.graphics.print(numVis, 15, 20)
	shove.endLayer()
	shove.endDraw()
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