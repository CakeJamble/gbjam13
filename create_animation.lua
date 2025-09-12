---@param image love.Image
---@param frameWidth integer
---@param frameHeight integer
---@param duration? number
return function(image, frameWidth, frameHeight, duration)
  local animation = {}
  animation.spriteSheet = image
  animation.quads = {}

  for y = 0, image:getHeight() - frameHeight, frameHeight do
    for x = 0, image:getWidth() - frameWidth, frameWidth do
      table.insert(animation.quads, love.graphics.newQuad(x, y, frameWidth, frameHeight, image:getDimensions()))
    end
  end

  animation.duration = duration or 1
  animation.currentTime = 0
  animation.spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads)

  return animation
end;