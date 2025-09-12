local Class = require('lib.hump.class')

---@class Entity
local Entity = Class{}

---@param data table
function Entity:init(data)
  self.pos = {  -- position
    x = data.x,
    y = data.y
  }

  self.v = {  -- velocity
    x = 0,
    y = 0
  }

  self.dims = { -- dimensions
    w = data.w,
    h = data.h
  }
end;

---@param dt number
function Entity:update(dt)
end;

function Entity:draw()
end;

return Entity