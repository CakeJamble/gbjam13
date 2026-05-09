local sti = require('lib.Simple-Tiled-Implementation.sti')
local entityRegistry = require('level.entity_registry')

---@param mapPath string Path to the Tiled Lua export (e.g. 'level/level_1.lua')
---@param world table Bump collision world
---@param player table Player instance (needed for Mask enemy)
---@return table stiMap, table entities, number levelWidth, number levelHeight
return function(mapPath, world, player)
	local map = sti(mapPath)
	map:resize(160, 144)  -- match push viewport, not window size

	local entities = {}

	-- Register all collidable tiles from the tile layer as bump items.
	-- STI handles rendering; we only need lightweight {solid=true} tables for physics.
	local tilesLayer = map.layers["tiles"]
	if tilesLayer then
		for y = 1, tilesLayer.height do
			for x = 1, tilesLayer.width do
				local tile = tilesLayer.data[y] and tilesLayer.data[y][x]
				if tile then
					local tileset = map.tilesets[tile.tileset]
					if tileset.properties and tileset.properties.collidable then
						local item = {solid = true}
						world:add(item,
							(x - 1) * map.tilewidth,
							(y - 1) * map.tileheight,
							map.tilewidth,
							map.tileheight)
					end
				end
			end
		end
	end

	-- Instantiate game entities from the object layer.
	-- Entity type comes from the object's Class field, or falls back to the
	-- tile's type field (set in the Tiled tileset editor).
	local entityLayer = map.layers["entities"]
	if entityLayer then
		entityLayer.visible = false  -- entities draw themselves

		for _, obj in ipairs(entityLayer.objects) do
			local typeName = (obj.type ~= "") and obj.type or nil
			if not typeName and obj.gid then
				local tile = map.tiles[obj.gid]
				if tile then typeName = tile.type end
			end

			if typeName and typeName ~= "" then
				local EntityClass = entityRegistry[typeName]
				if EntityClass then
					local data = {
						-- Tiled tile objects report y at the bottom edge of the tile
						x = math.floor(obj.x),
						y = math.floor(obj.y - (obj.height or 0)),
						w = obj.width,
						h = obj.height,
						world = world,
					}
					if typeName == "Mask" then
						data.player = player
					end
					local entity = EntityClass(data)
					world:add(entity, entity.pos.x, entity.pos.y, entity.dims.w, entity.dims.h)
					table.insert(entities, entity)
				else
					print("sti_loader: unknown entity type '" .. typeName .. "'")
				end
			end
		end
	end

	local levelWidth  = map.width  * map.tilewidth
	local levelHeight = map.height * map.tileheight

	return map, entities, levelWidth, levelHeight
end
