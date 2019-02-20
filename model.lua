local util = require("util")
local config = require("config")

-- {
--   entity,
--   tiles = {
--     position,
--     weight,
--   }
-- }
local thermal_entities = {}

-- {
--   position = {
--     temperature, -- number
--     heat_index, -- int
--   }
-- }
local temps = {}

-- Main state object.
local model = {
  thermal_entities = thermal_entities,
  temps = temps
}

function model.on_tick()
  for _, thermal in pairs(thermal_entities) do
    local entity = thermal.entity
    if entity and entity.valid then
      if entity.temperature then
        model.heat_tiles(thermal)
      end
    end
  end

  model.update_tile_states()
end

--
function model.heat_tiles(thermal)
  local entity = thermal.entity
  if entity.temperature > 100 then
    for _, tile in pairs(thermal.tiles) do
      model.heat_tile(tile.position, config.tile_rate.heat, tile.weight)
    end
  end
end

--
function model.heat_tile(position, amount, weight)
  if not temps[position] then
    temps[position] = {
      temperature = math.random(0, 9),
      heat_index = 1
    }
  end

  local tile = temps[position]
  amount = amount * weight
  amount = amount * (1 - tile.temperature / 100 / 2)

  tile.temperature = tile.temperature + amount * weight
end

function model.update_tile_states()
  for position, tile in pairs(temps) do
    tile.temperature = tile.temperature + config.tile_rate.cool

    local heat_index = math.floor(tile.temperature / 10)
    if heat_index < 1 then
      heat_index = 1
    elseif heat_index > 6 then
      heat_index = 6
    end

    if heat_index ~= tile.heat_index then
      tile.heat_index = heat_index
      game.surfaces[1].set_tiles {
        {
          name = config.heat_state_names[heat_index],
          position = position
        }
      }
    end

    if tile.temperature > 100 then
      tile.temperature = 100
    elseif tile.temperature <= 0 then
      temps[position] = nil
    end
  end
end

--
function model.add_thermal(entity)
  local radius = 40

  if entity.temperature ~= nil then
    local all_tiles = util.get_tiles_near(entity.position, radius)
    local tiles = {}

    for _, tile in pairs(all_tiles) do
      local distance = util.distance(tile.position, entity.position)
      local weight = 1 - distance / radius

      if weight * config.tile_rate.heat > -config.tile_rate.cool then
        table.insert(
          tiles,
          {
            position = tile.position,
            weight = weight
          }
        )
      end
    end

    table.insert(
      thermal_entities,
      {
        entity = entity,
        tiles = tiles
      }
    )
  end
end

function model.remove_thermal(entity)
  for i, thermal in ipairs(thermal_entities) do
    if thermal.entity == entity then
      table.remove(thermal_entities, i)
      break
    end
  end
end

return model
