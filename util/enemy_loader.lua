local enemyTypes = require("level.enemy_registry")

---@param levelIndex integer
---@param tileSize integer
local function loadEnemies(levelIndex, tileSize)
	local path = 'level.enemy.level_' .. levelIndex
	local enemies = {}
	local enemiesData = require(path)

	for _,data in ipairs(enemiesData) do
		local EnemyClass = enemyTypes[data.type]
		if EnemyClass then
			data.x, data.y = data.x * tileSize, data.y * tileSize
			local enemy = EnemyClass(data)
			table.insert(enemies, enemy)
		else
			error("Unknown enemy loaded")
		end
	end

	return enemies
end;

return loadEnemies