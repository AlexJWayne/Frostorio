data:extend(
  {
    {
      type = "reactor",
      name = "basic-heater",
      icon = "__base__/graphics/icons/nuclear-reactor.png",
      icon_size = 32,
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 1.5, result = "basic-heater"},
      max_health = 500,
      corpse = "big-remnants",
      consumption = "1MW", -- how quickly it burns fuel
      neighbour_bonus = 1,
      burner = {
        fuel_category = "chemical",
        effectivity = 1,
        fuel_inventory_size = 1,
        burnt_inventory_size = 1
      },
      collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
      selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
      --the collision box of a reactor is increased by this on the sides where it connects to another reactor:
      --neighbour_collision_increase = 0.25,
      lower_layer_picture = {
        filename = "__base__/graphics/entity/nuclear-reactor/reactor-pipes.png",
        width = 160,
        height = 160,
        shift = {-0.03125, -0.1875},
        hr_version = {
          filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-pipes.png",
          width = 320,
          height = 320,
          scale = 0.5,
          shift = {-0.03125, -0.1875}
        }
      },
      picture = {
        layers = {
          {
            filename = "__base__/graphics/entity/nuclear-reactor/reactor.png",
            width = 160,
            height = 160,
            shift = {-0.03125, -0.1875},
            hr_version = {
              filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor.png",
              width = 320,
              height = 320,
              scale = 0.5,
              shift = {-0.03125, -0.1875}
            }
          },
          {
            filename = "__base__/graphics/entity/nuclear-reactor/reactor-shadow.png",
            width = 263,
            height = 162,
            shift = {1.625, 0},
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-shadow.png",
              width = 525,
              height = 323,
              scale = 0.5,
              shift = {1.625, 0},
              draw_as_shadow = true
            }
          }
        }
      },
      working_light_picture = {
        filename = "__base__/graphics/entity/nuclear-reactor/reactor-lights-color.png",
        width = 160,
        height = 160,
        shift = {-0.03125, -0.1875},
        blend_mode = "additive",
        hr_version = {
          filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-lights-color.png",
          width = 320,
          height = 320,
          scale = 0.5,
          shift = {-0.03125, -0.1875},
          blend_mode = "additive"
        }
      },
      light = {intensity = 0.6, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.0, g = 1.0, b = 0.0}},
      heat_buffer = {
        max_temperature = 500,
        specific_heat = "250KJ", -- how much energy it takes to increase temperature one degree.
        max_transfer = "10MW",
        connections = {}
      },
      connection_patches_connected = {
        sheet = {
          filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches.png",
          width = 32,
          height = 32,
          variation_count = 12,
          hr_version = {
            filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-connect-patches.png",
            width = 64,
            height = 64,
            variation_count = 12,
            scale = 0.5
          }
        }
      },
      connection_patches_disconnected = {
        sheet = {
          filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches.png",
          width = 32,
          height = 32,
          variation_count = 12,
          y = 32,
          hr_version = {
            filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-connect-patches.png",
            width = 64,
            height = 64,
            variation_count = 12,
            y = 64,
            scale = 0.5
          }
        }
      },
      connection_patches = {
        north = {
          filename = "__base__/graphics/entity/nuclear-reactor/connection-patch-north.png",
          width = 160,
          height = 15,
          shift = util.by_pixel(0, -72.5)
        },
        east = {
          filename = "__base__/graphics/entity/nuclear-reactor/connection-patch-east.png",
          width = 15,
          height = 160,
          shift = util.by_pixel(72.5, 0)
        },
        south = {
          filename = "__base__/graphics/entity/nuclear-reactor/connection-patch-south.png",
          width = 160,
          height = 15,
          shift = util.by_pixel(0, 72.5)
        },
        west = {
          filename = "__base__/graphics/entity/nuclear-reactor/connection-patch-west.png",
          width = 15,
          height = 160,
          shift = util.by_pixel(-72.5, 0)
        }
      },
      vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
      meltdown_action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              repeat_count = 100,
              type = "create-trivial-smoke",
              smoke_name = "nuclear-smoke",
              offset_deviation = {{-1, -1}, {1, 1}},
              slow_down_factor = 1,
              starting_frame = 3,
              starting_frame_deviation = 5,
              starting_frame_speed = 0,
              starting_frame_speed_deviation = 5,
              speed_from_center = 0.5,
              speed_deviation = 0.2
            },
            {
              type = "create-entity",
              entity_name = "explosion"
            },
            {
              type = "damage",
              damage = {amount = 400, type = "explosion"}
            },
            {
              type = "create-entity",
              entity_name = "small-scorchmark",
              check_buildability = true
            },
            {
              type = "nested-result",
              action = {
                type = "area",
                target_entities = false,
                repeat_count = 2000,
                radius = 35,
                action_delivery = {
                  type = "projectile",
                  projectile = "atomic-bomb-wave",
                  starting_speed = 0.5
                }
              }
            }
          }
        }
      }
    }
  }
)

-- connections
-- {
--   position = {-2, -2},
--   direction = defines.direction.north
-- },
-- {
--   position = {0, -2},
--   direction = defines.direction.north
-- },
-- {
--   position = {2, -2},
--   direction = defines.direction.north
-- },
-- {
--   position = {2, -2},
--   direction = defines.direction.east
-- },
-- {
--   position = {2, 0},
--   direction = defines.direction.east
-- },
-- {
--   position = {2, 2},
--   direction = defines.direction.east
-- },
-- {
--   position = {2, 2},
--   direction = defines.direction.south
-- },
-- {
--   position = {0, 2},
--   direction = defines.direction.south
-- },
-- {
--   position = {-2, 2},
--   direction = defines.direction.south
-- },
-- {
--   position = {-2, 2},
--   direction = defines.direction.west
-- },
-- {
--   position = {-2, 0},
--   direction = defines.direction.west
-- },
-- {
--   position = {-2, -2},
--   direction = defines.direction.west
-- }
