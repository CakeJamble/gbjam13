local createAnimation = require('util.create_animation')
local flux = require('lib.flux')
local Timer = require('lib.hump.timer')
local SoundManager = require('class.SoundManager')
local TitleScreen = {}

function TitleScreen:init()
	shove.createLayer("background", {zIndex = 1})
	self.background = love.graphics.newImage('asset/sprite/title_bg.png')
	
	shove.createLayer("foreground", {zIndex = 5})
	self.player = self.loadPlayer()
	self.lamp = self.loadLamp()
	self.canProceed = false

	shove.createLayer("ui", {zIndex = 10})
	self.showInstructions = false
	self.instuctions = "Start/Enter to begin"

	self.musicManager = SoundManager(AllSounds.music)
	self.sfxManager = SoundManager(AllSounds.sfx.player)
	self.gameName = "Game Name Placeholder"
	self.uiOptions = {a=0}
end;

function TitleScreen:enter(previous)
	self.bgOptions = {x=0,y=0,a=0}
	self.song = self.musicManager.sounds["title_screen"][1]
	self:start()
	-- self.song:play()
end;

function TitleScreen.loadPlayer()
	local img1 = love.graphics.newImage('asset/sprite/player/idle.png')
	local idle = createAnimation(img1, 25, 24)
	idle.loop = true
	local img2 = love.graphics.newImage('asset/sprite/player/walk.png')
	local walk = createAnimation(img2, 25, 24)
	walk.loop = true

	local player = {
		x = -25, y = 144/2,
		idle = idle, walk = walk,
		tag = "walk"
	}

	return player
end;

---@return table
function TitleScreen.loadLamp()
	local image1 = love.graphics.newImage('asset/sprite/object/lamp_on.png')
	local image2 = love.graphics.newImage('asset/sprite/object/lamp_off.png')

	local lamp = {
		x = 160 / 1.5, y = 144/2,
		on=image1,off=image2,
		state="off"
	}
	return lamp
end;

function TitleScreen:start()
	Timer.every(0.45, function() self.sfxManager:play("walk") end)
	local duration = 2
	local goalX = self.lamp.x + self.lamp.on:getWidth() / 2 - 12
	flux.to(self.player, duration, {x = goalX}):ease("linear")
		:oncomplete(function()
			self.player.tag = "idle"
			Timer.clear()
		end)
	:after(self.bgOptions, 1, {a = 1})
		:delay(1)
		:onstart(function() 
			self.lamp.state = "on"
			-- self.musicManager:play("title_screen")
			self.song:play()

		end)
		:oncomplete(function()
			self.canProceed = true
			self.showInstructions = true
			flux.to(self.uiOptions, 0.5, {a = 1})
		end)
end;

function TitleScreen:gamepadpressed(joystick, button)
	if self.canProceed and button == "start" then
		self.song:stop()
		Gamestate.switch(States["SplashScreen"])
	end
end;

function TitleScreen:keypressed(key)
	if self.canProceed and key == "return" then
		self.song:stop()
		Gamestate.switch(States["SplashScreen"])
	end
end;

function TitleScreen:update(dt)
	Timer.update(dt)
	self:updateAnimation(dt)
end;

function TitleScreen:updateAnimation(dt)
  local animation = self.player[self.player.tag]
  animation.currentTime = animation.currentTime + dt

  if not animation.loop then
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.duration
    end
  else 
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
    end
  end
end;

function TitleScreen:draw()
	shove.beginDraw()

	shove.beginLayer("background")
	love.graphics.setColor(1,1,1,self.bgOptions.a)
	love.graphics.draw(self.background, self.bgOptions.x, self.bgOptions.y)
	love.graphics.setColor(1,1,1,1)
	shove.endLayer()

	shove.beginLayer("foreground")
	love.graphics.draw(self.lamp[self.lamp.state], self.lamp.x, self.lamp.y)
	self:animatePlayer()
	shove.endLayer()

	shove.beginLayer("ui")
	if self.showInstructions then
		love.graphics.setColor(1,1,1, self.uiOptions.a)
		love.graphics.print(self.gameName, 27, 10)
		love.graphics.print(self.instuctions, 10, 120)
	end
	shove.endLayer()
	shove.endDraw()
end;

function TitleScreen:animatePlayer()
	local animation = self.player[self.player.tag]
	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	spriteNum = math.min(spriteNum, #animation.quads)
	love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.player.x, self.player.y + 40)
end;

return TitleScreen