--
-- Sando Actor exporter for TexturePacker
-- generated with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:c4880ab1c0faaa6241d03f53b17aff5d:58abc7768711c8689deeff3086434d52:918fffbb11ec547b105114d92d15939f$
--
-- Usage in LÖVE2D with animX:
--
--   local animx = require("libs.animX")
--   local img   = love.graphics.newImage("path/to/actor.png")
--
--   -- animx.newActor will auto-detect the .lua file and use it instead of XML.
--   -- Sprite names must follow the animName+frameNumber convention:
--   --   e.g. "idle1", "idle2", "walk1", "walk2"
--   -- The loader groups them into per-animation quad tables automatically.
--   local actor = animx.newActor("path/to/actor.png", img)
--

return {

  -- Flat table of every sprite in the atlas keyed by trimmed name.
  -- Names must follow the animName+frameNumber convention, e.g. "idle1", "walk2".
  -- Untrimmed sprites:  { x, y, w, h }
  -- Trimmed sprites:    { x, y, w, h, ox, oy, ow, oh }
  --   x, y, w, h  = position and size of the packed (trimmed) region in the atlas PNG
  --   ox, oy      = offset of the trimmed region within the original (untrimmed) image
  --   ow, oh      = dimensions of the original (untrimmed) image
  quads = {
    ["ground"] = { x = 2, y = 52, w = 8, h = 2, ox = 0, oy = 0, ow = 8, oh = 8 },
    ["ground_1"] = { x = 2, y = 2, w = 8, h = 8 },
    ["ground_2"] = { x = 2, y = 12, w = 8, h = 8 },
    ["ground_3"] = { x = 2, y = 22, w = 8, h = 8 },
    ["ground_4"] = { x = 2, y = 32, w = 8, h = 8 },
    ["ground_corner"] = { x = 2, y = 42, w = 8, h = 8 },
    
  },

  meta = {
    atlasWidth    = 12,
    atlasHeight   = 56,
    borderPadding = 1,
    shapePadding  = 0,
    extrude       = 1,
  },

}
