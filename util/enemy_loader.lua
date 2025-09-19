local enemyTypes = require("level.enemy_registry")

local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end


---@param levelIndex integer
---@param tileSize integer
---@param player Player
---@param world table
local function loadEnemies(levelIndex, tileSize, player, world)
	local path = 'level.enemy.level_' .. levelIndex
	local enemies = {}
	local enemiesData = require(path)

	for _,data in ipairs(enemiesData) do
		local EnemyClass = enemyTypes[data.type]
		if EnemyClass then
			local enemyData = copy(data)
			enemyData.x = data.x * tileSize
			enemyData.y = data.y * tileSize
			enemyData.world = world
			-- data.x, data.y = data.x * tileSize, data.y * tileSize
			-- give mask a ref to the player
			if data.type == "Mask" then
				print('loading player position')
				-- data.player = player
				enemyData.player = player
			end

			-- local enemy = EnemyClass(data)
			local enemy = EnemyClass(enemyData)
			table.insert(enemies, enemy)
		else
			error("Unknown enemy loaded")
		end
	end

	return enemies
end;

return loadEnemies