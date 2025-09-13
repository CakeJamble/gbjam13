return function()
	local dir = "level/map"
	local maps = {}

	local files = love.filesystem.getDirectoryItems(dir)

	for _,file in ipairs(files) do
		if file:match("%.lua$") then
			local name = file:gsub("%.lua$", "")
			local fp = dir .. "/" .. name
			local success, map = pcall(require, fp)
			if success and type(map) == "table" then
				-- maps[name] = map
				table.insert(maps, map)
			else
				error("Failed to load map:", file)
			end
		end
	end

	return maps
end;