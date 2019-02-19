local ice_tiles = {
  "frozen-snow-0",
  "frozen-snow-1",
  "frozen-snow-2",
  "frozen-snow-3",
  "frozen-snow-4",
  "frozen-snow-5",
  "frozen-snow-6",
  "frozen-snow-7",
  "frozen-snow-8",
  "frozen-snow-9"
}
local fps = 60
local melt_tiles_per_second = 2
local cooling_per_second = 0.5

-- {
--   {
--     entity, -- entity
--     cold_tiles, -- position
--     warm_tiles, -- position
--     next_melt_in -- number
--   }
-- }
local thermal_entities = {}

-- local function get_reactors()
--   return game.surfaces[1].find_entities_filtered {type = "reactor"}
-- end

local function get_tiles_near(position, radius)
  local area = {
    left_top = {position.x - radius, position.y - radius},
    right_bottom = {position.x + radius, position.y + radius}
  }
  local tiles = game.surfaces[1].find_tiles_filtered {area = area}

  return tiles
end

-- Return the squared distance between two positions.
local function sq_distance(a, b)
  return math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2)
end

local function has_value(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

-- Return the closest tile to position in an array of tiles, that is no more than max away.
local function get_closest_tile(tiles, position, max)
  if #tiles == 0 then
    return nil
  end

  max = math.pow(max, 2)
  local closest
  for _, tile in pairs(tiles) do
    local distance = sq_distance(tile.position, position)
    if distance <= max and (closest == nil or distance < closest.distance) then
      closest = {tile = tile, distance = distance}
    end
  end

  if closest then
    return closest.tile
  end
end

-- local function enable_warm_assemblers(position)
--   local surface = game.surfaces[1]
--   local assemblers = surface.find_entities_filtered {type = "assembling-machine", position = position}
--   for _, assembler in pairs(assemblers) do
--     local area = assembler.bounding_box
--     local tiles = surface.get_tiles
--     assembler.active = true
--   end
-- end

-- Find all heaters, cool them down a bit and melt snow if they are at max temperature.
local function update_heaters()
  local reactors = get_reactors()

  for _, entity in pairs(get_reactors()) do
    if entity.temperature ~= nil then
      if entity.temperature >= 200 then
        local tiles = get_cold_tiles_near(entity.position, 7)
        local tile = get_closest_tile(tiles, entity.position, 7)
        if tile then
          game.surfaces[1].set_tiles({{name = "dirt-1", position = tile.position}})
          enable_warm_assemblers(tile.position)
        end
      end

      entity.temperature = entity.temperature - cooling_per_second / fps
    end
  end
end

-- -- Disable cold assemblers
-- local function check_assemblers()
--   local assemblers = game.surfaces[1].find_entities_filtered {type = "assembling-machine"}
-- end

script.on_event(
  defines.events.on_built_entity,
  function(event)
    local entity = event.created_entity
    if entity.temperature ~= nil then
      -- game.print("created a thermal building!")

      local tiles = get_tiles_near(entity.position, 6)
      local cold_tiles = {}
      local warm_tiles = {}

      for _, tile in pairs(tiles) do
        if has_value(ice_tiles, tile.name) then
          table.insert(cold_tiles, tile.position)
        else
          table.insert(warm_tiles, tile.position)
        end
      end

      table.insert(
        thermal_entities,
        {
          entity = entity,
          cold_tiles = cold_tiles,
          warm_tiles = warm_tiles,
          next_melt_in = 60 / fps * melt_tiles_per_second
        }
      )
    end
  end
)

-- Melt snow and ice near heated objects
script.on_event(
  defines.events.on_tick,
  function(event)
    if event.tick % (60 / fps) < 1 then
      -- update_heaters()
      -- check_assemblers()

      for _, thermal in pairs(thermal_entities) do
        local entity = thermal.entity
        if entity.temperature >= 50 and #thermal.cold_tiles > 0 then
          local cold_tile_pos = thermal.cold_tiles[1]
          table.remove(thermal.cold_tiles, 1)
          table.insert(thermal.warm_tiles, cold_tile_pos)
          game.surfaces[1].set_tiles({{name = "dirt-1", position = cold_tile_pos}})
        end

        entity.temperature = entity.temperature - cooling_per_second / fps
      end
    end
  end
)
