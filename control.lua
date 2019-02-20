local config = require("config")
local util = require("util")

-- {
--   {
--     entity, -- entity
--     cold_tiles, -- position[]
--     warm_tiles, -- position[]
--     ticks_to_freeze, -- number
--     ticks_to_melt, -- number
--   }
-- }
local thermal_entities = {}

-- When a heater is built, save it and store the tiles that can melt.
function on_build_thermal_entity(entity)
  if entity.temperature ~= nil then
    -- game.print("created a thermal building!")

    local tiles = util.get_tiles_near(entity.position, 10)
    local cold_tiles = {}
    local warm_tiles = {}

    for _, tile in pairs(tiles) do
      if util.has_value(config.cold_tile_names, tile.name) then
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
        ticks_to_melt = 60 / config.melt_tiles_per_second,
        ticks_to_freeze = 60 / config.freeze_tiles_per_second
      }
    )
  end
end

function on_remove_thermal_entity(entity)
  for i, thermal in ipairs(thermal_entities) do
    if thermal.entity == entity then
      thermal_entities[i].entity = nil
    end
  end
end

function melt_and_freeze_tiles()
  for i, thermal in ipairs(thermal_entities) do
    local entity = thermal.entity

    thermal.ticks_to_freeze = thermal.ticks_to_freeze - 1
    thermal.ticks_to_melt = thermal.ticks_to_melt - 1

    if thermal.ticks_to_melt <= 0 and entity and entity.temperature >= 90 and #thermal.cold_tiles > 0 then
      -- melt
      thermal.ticks_to_melt = 60 / config.melt_tiles_per_second
      local cold_tile_pos = thermal.cold_tiles[1]
      table.remove(thermal.cold_tiles, 1)
      table.insert(thermal.warm_tiles, 1, cold_tile_pos)
      game.surfaces[1].set_tiles({{name = "dirt-1", position = cold_tile_pos}})
    elseif thermal.ticks_to_freeze <= 0 and (not entity or entity.temperature < 85) and #thermal.warm_tiles > 0 then
      -- freeze
      thermal.ticks_to_freeze = 60 / config.freeze_tiles_per_second
      local warm_tile_pos = thermal.warm_tiles[1]
      table.remove(thermal.warm_tiles, 1)
      table.insert(thermal.cold_tiles, 1, warm_tile_pos)
      game.surfaces[1].set_tiles({{name = "frozen-snow-1", position = warm_tile_pos}})

      -- Entity is gone, and all tiles are fully frozen. Stop tracking it.
      if not entity and #thermal.warm_tiles == 0 then
        table.remove(thermal_entities, i)
      end
    end

    -- Cool down entities.
    if entity then
      entity.temperature = entity.temperature - config.cooling_per_second / 60
    end
  end
end

-- script.on_load(
--   function(event)
--     for _, entity in pairs(game.surfaces[1].find_entities_filtered()) do
--       on_build_thermal_entity(entity)
--     end
--   end
-- )

script.on_event(
  defines.events.on_built_entity,
  function(event)
    local entity = event.created_entity
    if entity.temperature ~= nil then
      on_build_thermal_entity(entity)
    end
  end
)

script.on_event(
  defines.events.on_player_mined_entity,
  function(event)
    on_remove_thermal_entity(event.entity)
  end
)

-- Melt snow and ice near heated objects
script.on_event(
  defines.events.on_tick,
  function(event)
    melt_and_freeze_tiles()
  end
)
