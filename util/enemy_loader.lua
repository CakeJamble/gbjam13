local enemyTypes = require("level.enemy_registry")

---@param levelIndex integer
---@param tileSize integer
---@param player Player
local function loadEnemies(levelIndex, tileSize, player)
	local path = 'level.enemy.level_' .. levelIndex
	local enemies = {}
	local enemiesData = require(path)

	for _,data in ipairs(enemiesData) do
		local EnemyClass = enemyTypes[data.type]
		if EnemyClass then
			data.x, data.y = data.x * tileSize, data.y * tileSize

			-- give mask a ref to the player
			if data.type == "Mask" then
				print('loading player position')
				data.player = player
			end

			local enemy = EnemyClass(data)
			table.insert(enemies, enemy)
		else
			error("Unknown enemy loaded")
		end
	end

	return enemies
end;

return loadEnemies