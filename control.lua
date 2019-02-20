local model = require("model")

script.on_event(
  defines.events.on_built_entity,
  function(event)
    model.add_thermal(event.created_entity)
  end
)

script.on_event(
  defines.events.on_player_mined_entity,
  function(event)
    model.remove_thermal(event.entity)
  end
)

-- Melt snow and ice near heated objects
script.on_event(
  defines.events.on_tick,
  function(event)
    model.on_tick()
  end
)
