local bump = require('lib.bump')
local loadMaps = require('util.map_loader')
local loadEnemies = require('util.enemy_loader')
local tileRegistry = require('level.tile_registry')
local Player = require('class.Player')
local Camera = require('lib.hump.camera')
local Timer = require('lib.hump.timer')
local imgui = require('lib.cimgui')
local ffi = require('ffi')
local hitboxCheckboxState = ffi.new("bool[1]", false)
local zoomValue = ffi.new("int[1]", 4)
local Gun = require('class.Gun')
local SoundManager = require('class.SoundManager')
local ProgressBar = require('class.ProgressBar')
local Signal = require('lib.hump.signal')

local Game = {}

function Game:init()
	imgui.love.Init()
	self.maps = loadMaps()
	self.levelIndex = 1
	self.tileSize = 16
	-- local songPath = "asset/audio/casino.mp3"
	-- self.music = love.audio.newSource(songPath, "stream")
	-- self.music:play()
	self.showDebug = false
	self.player = self:loadPlayer()
	Gravity = 500
	self.zoomValue = 4
	camera = Camera(self.player.pos.x, self.player.pos.y, self.zoomValue)
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
	self.enemies = loadEnemies(self.levelIndex, self.tileSize)
	local tileMap = self.maps[self.levelIndex]
	World = bump.newWorld(self.tileSize)
	self.level = self.loadLevel(tileMap, self.tileSize)
	self.levelWidth = self.tileSize * #self.level[1]
	self.levelHeight = self.tileSize * #self.level
	self.addToWorld(self.player, self.enemies, self.level)
	camera:lockPosition(self.player.pos.x, self.player.pos.y)
	local songName = "level_" .. self.levelIndex
	self.soundManager:play(songName)
	self.unluckyMeter = self.initUnluckyMeter(self.player.pos)
end;

function Game.initUnluckyMeter(playerPos)
	local x,y = playerPos.x + 10, playerPos.y + 10 
	-- local cx,cy = camera:worldCoords(x,y)
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
	World:add(player, player.pos.x, player.pos.y, player.dims.w, player.dims.h)

	for _,enemy in ipairs(enemies) do
		World:add(enemy, enemy.pos.x, enemy.pos.y, enemy.dims.w, enemy.dims.h)
	end

	for _,tile in ipairs(level) do
		World:add(tile, tile.pos.x, tile.pos.y, tile.dims.w, tile.dims.h)
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

---@param joystick string
---@param button string
function Game:gamepadreleased(joystick, button)
	if not self.paused then
		self.player:gamepadreleased(joystick, button)
	end
end;

---@param key string
function Game:keypressed(key)
	if key == '`' then
		self.showDebug = not self.showDebug
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
	-- self.numVisible = self:countVisibleObj()
	-- local x,y = camera:cameraCoords()
	-- local w,h = shove.getViewportDimensions()
	-- local visible = World:queryRect(x,y,w,h)
	-- local slowdown = math.max(0.5, 1 - self.numVisible / 10)
	-- local x,y = camera:position()
	-- local px,py = self.player.pos.x, self.player.pos.y
	-- print(x, y, px, py)
	if not self.paused then
		if self.showUnluckyMessage then
			self.unluckyMessageBox:update(dt)
		end
		local slowdown = 1
		local delta = dt * slowdown
		self.player:update(delta)
		for _,enemy in ipairs(self.enemies) do
			enemy:update(delta)
		end
		if self.player.health == 0 then
			self:reset()
		end

		local x, y = self.player.pos.x, self.player.pos.y + self.player.lookYOffset.curr
		camera:lookAt(x, y)
		self.soundManager:update(dt)
	end
	-- imgui debug stuff
	imgui.love.Update(dt)
	imgui.NewFrame()

	if self.showDebug then
		imgui.Begin("Debug Window")

		if imgui.Checkbox("Show Hitboxes", hitboxCheckboxState) then
			self.drawHitboxes = hitboxCheckboxState[0]
		end

		if imgui.InputInt("Zoom", zoomValue) then
			self.zoomValue = math.max(1, zoomValue[0])
			zoomValue[0] = self.zoomValue
			camera:zoomTo(self.zoomValue)
			camera:lockPosition(self.player.pos.x, self.player.pos.y)
		end

		imgui.End()
	end
end;

function Game:draw()
	-- shove.beginDraw()
	camera:attach()
	self.player:draw()
	if self.showUnluckyMessage then
		self.unluckyMessageBox:draw(self.player.pos.x - 25, self.player.pos.y + 40)
	end
	self:drawTiles()
	for _,enemy in ipairs(self.enemies) do
		enemy:draw()
	end

	if self.drawHitboxes then
		self:drawCollision()
	end

	camera:detach()
	self.unluckyMeter:draw(self.zoomValue)
	local hp = tostring(self.player.health)
	love.graphics.print(hp, 10, 10)
	local numVis = tostring(self.numVisible)
	love.graphics.print(numVis, 15, 20)
	-- shove.endDraw()
	imgui.Render()
	imgui.love.RenderDrawLists()
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

---- imgui callbacks
---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean
function Game:mousemoved(x, y, dx, dy, istouch)
  imgui.love.MouseMoved(x, y)
end;

---@param x number
---@param y number
---@param button string
---@param istouch boolean
---@param presses number
function Game:mousepressed(x, y, button, istouch, presses)
  imgui.love.MousePressed(button)
end;

---@param x number
---@param y number
---@param button string
---@param istouch boolean
---@param presses number
function Game:mousereleased(x, y, button, istouch, presses)
  imgui.love.MouseReleased(button)
end;

function Game:quit()
	imgui.love.Shutdown()
end;


return Game