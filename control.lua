local config = require("config")
local util = require("util")

-- {
--   {
--     entity, -- entity
--     cold_tiles, -- position
--     warm_tiles, -- position
--     next_melt_in -- number
--   }
-- }
local thermal_entities = {}

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
        next_melt_in = 60 / config.fps * config.melt_tiles_per_second
      }
    )
  end
end

-- When a heater is built, save it and store the tiles that can melt.
script.on_event(
  defines.events.on_built_entity,
  function(event)
    local entity = event.created_entity
    if entity.temperature ~= nil then
      on_build_thermal_entity(entity)
    end
  end
)

-- Melt snow and ice near heated objects
script.on_event(
  defines.events.on_tick,
  function(event)
    if event.tick % (60 / config.fps) < 1 then
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

        entity.temperature = entity.temperature - config.cooling_per_second / config.fps
      end
    end
  end
)
