-- Ensure snow and ice only in map generation.
for name, tile in pairs(data.raw.tile) do
  if (string.find(name, "snow") == nil and string.find(name, "ice") == nil and string.find(name, "water") == nil) then
    data.raw.tile[name].autoplace = nil
  end
end
