-- Recursively walk through directories to build a table of sfx
---@param dir string
---@param t table Container of sfx
---@param sourceType string static or stream
local function loadAudio(dir, t, sourceType)
  local items = love.filesystem.getDirectoryItems(dir)
  for _, item in ipairs(items) do
      local fp = dir .. "/" .. item
      local info = love.filesystem.getInfo(fp)

      if info.type == "file" then
          local name = item:match("(.+)%..+$")
          local ext  = item:match("^.+(%..+)$")

          if name and (ext == ".wav" or ext == ".ogg" or ext == ".mp3") then
              t[name] = t[name] or {}
              local src = love.audio.newSource(fp, sourceType or "static")
              table.insert(t[name], src)
          end
      elseif info.type == "directory" then
          t[item] = {}
          loadAudio(fp, t[item], sourceType)
      end
  end
end;

return loadAudio