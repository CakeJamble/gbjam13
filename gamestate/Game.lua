local bump = require('lib.bump')
local loadSTI = require('util.sti_loader')
local Camera = require('lib.hump.camera')
local Player = require('class.Player')
local Timer = require('lib.hump.timer')
local Gun = require('class.Gun')
local SoundManager = require('class.SoundManager')
local ProgressBar = require('class.ProgressBar')
local Signal = require('lib.hump.signal')

local Game = {}

function Game:init()
	self.tileSize = 8
	self.drawHitboxes = false
	self.camera = {x=0,y=0, speed = 8, deadzone = {x = 40, y = 32}}
	Gravity = 500
	self.soundManager = SoundManager(AllSounds.music)
	self.sfxManager = SoundManager(AllSounds.sfx)
	self.paused = false
	self.showUnluckyImage = false
	self.showLuckReturnedImage = false
	self.isCurrentlyUnlucky = false
	self.lampChargeSound = nil
	self.isUnderLamp = false
	self.uhohImage = love.graphics.newImage('asset/sprite/UHOH.png')
	self.luckReturnedImage = love.graphics.newImage('asset/sprite/YOURLUCKHASRETURNED.png')
	self.uiTextColor = {240/255, 225/255, 209/255, 1}
	
	Signal.register('OnUnlucky',
		function()
			self.showUnluckyImage = true
			self.isCurrentlyUnlucky = true
		end)

	Signal.register('OnUnluckyEnd',
		function()
			if self.isCurrentlyUnlucky then
				self.showUnluckyImage = false
				self.showLuckReturnedImage = true
				self.isCurrentlyUnlucky = false
				Timer.after(2, function()
					self.showLuckReturnedImage = false
				end)
			end
		end)

	Signal.register('OnGetClover', function(clover)
		self.unluckyMeter:tweenLucky(1, clover.amount)
		self.sfxManager:play("clover_pickup")
		self.player.health = math.min(self.player.health + 3, 5)
	end)
	Signal.register("OnLampCollision", function(amount, dt)
		local val = amount * dt
		self.unluckyMeter:tweenLucky(dt, val)
		
		if not self.isUnderLamp then
			self.isUnderLamp = true
			if self.lampChargeSound then
				self.lampChargeSound:stop()
			end
			self.lampChargeSound = self.sfxManager.sounds["lamp"]["charge"]["light_charge"][1]
			self.lampChargeSound:setLooping(true)
			self.lampChargeSound:play()
		end
		-- self.player.currentAnimationTag = "in_light"
	end)
	Signal.register("EndLevel",function()
		self.checkCollision = false
		self.player.dead = true
		self.song:stop()
		self.unluckyMeter:stop()
		
		if self.lampChargeSound then
			self.lampChargeSound:stop()
			self.lampChargeSound = nil
		end
		self.isUnderLamp = false
		
		local sfx = self.sfxManager:play("level_complete")
		local dur = sfx:getDuration()
		Timer.after(dur, function()
			Gamestate.switch(States["SplashScreen"], self.levelIndex)
		end)
	end)
	Signal.register("OnDeath", function()
		self.song:stop()
		
		if self.lampChargeSound then
			self.lampChargeSound:stop()
			self.lampChargeSound = nil
		end
		self.isUnderLamp = false
		
		self.levelIndex = 1

		self.checkCollision = false
		local items = self.world:getItems()
		for _,item in ipairs(items) do
			self.world:remove(item)
		end

		Gamestate.switch(States["TitleScreen"])
	end)
end;

---@param previous table Previously active State
function Game:enter(previous, levelIndex)
	-- Reset UI state for new level
	self.showUnluckyImage = false
	self.showLuckReturnedImage = false
	self.isCurrentlyUnlucky = false
	
	if self.lampChargeSound then
		self.lampChargeSound:stop()
		self.lampChargeSound = nil
	end
	self.isUnderLamp = false
	
	if self.player then self.player = nil end
	self.world = bump.newWorld(self.tileSize)
	self.checkCollision = true
	self.player = self:loadPlayer()
	self.levelIndex = levelIndex
	self.backgroundTile = love.graphics.newImage("asset/sprite/tile/star_bg.png")
	self.levelBgTile = love.graphics.newImage("asset/sprite/tile/bg_stripes.png")

	self.hpLabel = love.graphics.newImage("asset/sprite/HP_LABEL.png")
	self.luckLabel = love.graphics.newImage("asset/sprite/LUCK_LABEL.png")

	local mapPath = 'level/test.lua'
	self.stiMap, self.entities, self.levelWidth, self.levelHeight = loadSTI(mapPath, self.world, self.player)

	self.world:add(self.player, self.player.pos.x, self.player.pos.y, self.player.dims.w, self.player.dims.h)
	local vH = push:getHeight()
	self.camera.x = self.player.pos.x - 80
	self.camera.y = self.player.pos.y - (vH/2 - 8)
	local songName = "level_" .. self.levelIndex
	self.song = self.soundManager.sounds[songName][1]
	self.song:play()
	self.unluckyMeter = self.initUnluckyMeter(self.player.pos)
	self.world:add(self.unluckyMeter, self.unluckyMeter.pos.x, self.unluckyMeter.pos.y,
		self.unluckyMeter.containerOptions.width, self.unluckyMeter.containerOptions.height)
end;

---@param playerPos table
function Game.initUnluckyMeter(playerPos)
	local x,y = playerPos.x - 10, playerPos.y - 10 
	local options = {
		x = x,
		y = y,
		w = 120,
		h = 12,
		min=0,max=100,
		horizontal = true
	}
	return ProgressBar(options)
end;

---@return Player
function Game:loadPlayer()
	local col, row = 2, 16
	local x = (col - 1) * self.tileSize
	local y = (row - 1) * self.tileSize

	local playerData = {
		name = "player",
		x = x, y = y,
		w = 25, h = 24,
		animations = {
			"idle", "walk", "jump", "fall", "in_light", "look_down", "look_up", "stun"
		}
	}
	local player = Player(playerData)
	player.world = self.world
	local startGun = Gun({
		x=x,y=y,
		w = 25, h = 18,
		damage=1,
		speed={x=200,y=200},
		owner = player,
		world = self.world
	})
	player:setGun(startGun)
	return player
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
			self.unluckyMeter:stop()
		else
			local dur = self.unluckyMeter.remaining
			self.unluckyMeter:tweenUnlucky(dur)
		end

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

---@param dt number
function Game:update(dt)
	Timer.update(dt)
	if self.checkCollision then
		if not self.paused then
			if self.showUnluckyMessage then
				self.unluckyMessageBox:update(dt)
			end

			for _,entity in ipairs(self.entities) do
				if entity.update then
					entity:update(dt)
				end
			end

			for i = #self.entities, 1, -1 do
				local entity = self.entities[i]

				if entity.removeFromWorld then
					pcall(function() self.world:remove(entity) end)
					entity.removeFromWorld = false
				end

				if entity.dead then
					table.remove(self.entities, i)
				end
			end

			self.player:update(dt)

			if self.isUnderLamp then
				local playerRect = {
					x = self.player.pos.x,
					y = self.player.pos.y,
					w = self.player.dims.w,
					h = self.player.dims.h
				}
				
				local stillUnderLamp = false
				local items, len = self.world:queryRect(playerRect.x, playerRect.y, playerRect.w, playerRect.h)
				for _, item in ipairs(items) do
					if item.type == "item" and item.name == "Lamp" then
						stillUnderLamp = true
						break
					end
				end
				
				if not stillUnderLamp then
					self.isUnderLamp = false
					if self.lampChargeSound then
						self.lampChargeSound:stop()
						self.lampChargeSound = nil
					end
				end
			end

			self.soundManager:update(dt)
			self:updateCamera(dt)
			self.unluckyMeter:update(dt)
		end
	end
end;

function Game:updateCamera(dt)
	local x, y = self.player.pos.x, self.player.pos.y + self.player.lookYOffset.curr
	local vH = push:getHeight()
	local tx,ty = x-80, y-(vH/2 - 8)
	self.camera.x = self.camera.x + (tx - self.camera.x) * self.camera.speed * dt
	self.camera.y = self.camera.y + (ty - self.camera.y) * self.camera.speed * dt
end;

function Game:draw()
	push:apply("start")
	local cx = -math.floor(self.camera.x)
	local cy = -math.floor(self.camera.y)

	love.graphics.push()
	love.graphics.translate(cx, cy)
	self:drawBackground()
	love.graphics.pop()

	-- STI renders to its own canvas then blits at (0,0), so camera offset must
	-- be passed as tx/ty and the call must be outside the translated block.
	self.stiMap:draw(cx, cy)

	love.graphics.push()
	love.graphics.translate(cx, cy)
	for _,entity in ipairs(self.entities) do
		if entity.draw then
			entity:draw()
		end
	end
	self.player:draw()
	if self.drawHitboxes then
		self:drawCollision()
	end
	love.graphics.pop()

	self:drawUI()
	push:apply("end")
end;

function Game:drawBackground()
	local starTileSize = 32
	local stripeTileSize = 16
	local startX = math.floor(self.camera.x / stripeTileSize) * stripeTileSize
	local startY = math.floor(self.camera.y / stripeTileSize) * stripeTileSize
	local vW = push:getWidth()
	local vH = push:getHeight()
	
	-- level bg
	-- for x = startX - stripeTileSize, startX + vW + stripeTileSize, stripeTileSize do
	-- 	for y = startY - stripeTileSize, startY + vH + stripeTileSize, stripeTileSize do
	-- 		if x >= 0 and x < self.levelWidth and y >= 0 and y < self.levelHeight then
	-- 			love.graphics.draw(self.levelBgTile, x, y)
	-- 		end
	-- 	end
	-- end
	
	--OOB background
	local starStartX = math.floor(self.camera.x / starTileSize) * starTileSize
	local starStartY = math.floor(self.camera.y / starTileSize) * starTileSize
	for x = starStartX - starTileSize, starStartX + vW + starTileSize, starTileSize do
		for y = starStartY - starTileSize, starStartY + vH + starTileSize, starTileSize do
			if x < 0 or x >= self.levelWidth or y < 0 or y >= self.levelHeight then
				love.graphics.draw(self.backgroundTile, x, y)
			end
		end
	end
	
end;


function Game:drawCollision()
	love.graphics.setColor(1, 0, 0, 0.5)
	for _,item in ipairs(self.world:getItems()) do
		local success, x, y, w, h = pcall(self.world.getRect, self.world, item)
		if success then
			love.graphics.rectangle("line", x, y, w, h)
		end
	end
	love.graphics.setColor(1,1,1,1)
end;

function Game:drawUI()
	love.graphics.push()
	love.graphics.origin()
	local screenWidth = push:getWidth()
	local screenHeight = push:getHeight()
	
	-- Draw UHOH image at top center when unlucky
	if self.showUnluckyImage then
		love.graphics.setColor(1, 1, 1, 1)
		local uhohWidth = self.uhohImage:getWidth()
		local uhohX = (screenWidth - uhohWidth) / 2
		love.graphics.draw(self.uhohImage, uhohX, 8)
	end
	
	-- i think this is too much but maybe we want it
	-- if self.showLuckReturnedImage then
	-- 	love.graphics.setColor(1, 1, 1, 1)
	-- 	local luckReturnedWidth = self.luckReturnedImage:getWidth()
	-- 	local luckReturnedX = (screenWidth - luckReturnedWidth) / 2
	-- 	love.graphics.draw(self.luckReturnedImage, luckReturnedX, 8)
	-- end
	
	-- Draw HP (bottom-left)
	if self.player.health <= 1 then
		love.graphics.setColor(217/255, 151/255, 65/255, 1)
	else
		love.graphics.setColor(self.uiTextColor)
	end
	love.graphics.draw(self.hpLabel, 2, screenHeight - 8)
	love.graphics.setColor(217/255, 151/255, 65/255, 1)
	for i = 1, self.player.health do
		love.graphics.circle("fill", 12 + i * 6, screenHeight - 5, 2)
	end
	
	-- Draw luck meter (bottom-right)
	local luckThreshold = self.unluckyMeter.containerOptions.width * 0.035
	if self.unluckyMeter.meterOptions.width <= luckThreshold then
		love.graphics.setColor(217/255, 151/255, 65/255, 1)
	else
		love.graphics.setColor(self.uiTextColor)
	end
	love.graphics.draw(self.luckLabel, screenWidth - 87, screenHeight - 7)
	self.unluckyMeter:draw(screenWidth - 60, screenHeight - 7)
	
	love.graphics.pop()
end;

return Game