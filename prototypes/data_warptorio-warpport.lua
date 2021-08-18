local rtint={r=0.2,g=0.2,b=1,a=0.8}

data:extend{

    {
      icons = { {icon="__base__/graphics/icons/roboport.png",tint=rtint} },
      icon_size = 64,
      name = "warptorio-warpport",
      order = "c[signal]-a[roboport]",
      place_result = "warptorio-warpport",
      stack_size = 10,
      subgroup = "logistic-network",
      type = "item"
    },

    {
      enabled = false,
      energy_required = 5,
      ingredients = {
        {
          "steel-plate",
          45
        },
        {
          "iron-gear-wheel",
          45
        },
        {
          "advanced-circuit",
          100
        },
	{"processing-unit",100},
	{"flying-robot-frame",100},
        {"roboport",10},
	{"warptorio-warponium-fuel",1}
      },
      name = "warptorio-warpport",
      result = "warptorio-warpport",
      type = "recipe"
    },


   {
      base = {
        layers = {
          { tint=rtint, scale = 1/2,
            filename = "__base__/graphics/entity/roboport/roboport-base.png",
            height = 135,
            hr_version = { tint=rtint,
              filename = "__base__/graphics/entity/roboport/hr-roboport-base.png",
              height = 277,
              scale = 0.5/2,
              shift = {
                0.0625/2,
                0.2421875/2
              },
              width = 228
            },
            shift = {
              0.5/2,
              0.25/2
            },
            width = 143
          },
          {
            draw_as_shadow = true, scale = 1/2,
            filename = "__base__/graphics/entity/roboport/roboport-shadow.png",
            height = 101,
            hr_version = {
              draw_as_shadow = true,
              filename = "__base__/graphics/entity/roboport/hr-roboport-shadow.png",
              height = 201,
              scale = 0.5/2,
              shift = {
                0.890625/2,
                0.6015625/2
              },
              width = 294
            },
            shift = {
              0.890625/2,
              0.6015625/2
            },
            width = 147
          }
        }
      },
      base_animation = { tint=rtint,
        animation_speed = 0.5, scale = 1/2,
        filename = "__base__/graphics/entity/roboport/roboport-base-animation.png",
        frame_count = 8,
        height = 31,
        hr_version = { tint=rtint,
          animation_speed = 0.5,
          filename = "__base__/graphics/entity/roboport/hr-roboport-base-animation.png",
          frame_count = 8,
          height = 59,
          priority = "medium",
          scale = 0.5/2,
          shift = {
            -0.5546875/2,
            -1.9140625/2
          },
          width = 83
        },
        priority = "medium",
        shift = {
          -0.53149999999999995/2,
          -1.9375/2
        },
        width = 42
      },
      base_patch = { tint=rtint, scale = 1/2,
        filename = "__base__/graphics/entity/roboport/roboport-base-patch.png",
        frame_count = 1,
        height = 50,
        hr_version = { tint=rtint,
          filename = "__base__/graphics/entity/roboport/hr-roboport-base-patch.png",
          frame_count = 1,
          height = 100,
          priority = "medium",
          scale = 0.5/2,
          shift = {
            0.046875/2,
            0.15625/2
          },
          width = 138
        },
        priority = "medium",
        shift = {
          0.03125/2,
          0.203125/2
        },
        width = 69
      },

      door_animation_down = { tint=rtint,
        filename = "__base__/graphics/entity/roboport/roboport-door-down.png",
        frame_count = 16,
        height = 22,
        hr_version = { tint=rtint,
          filename = "__base__/graphics/entity/roboport/hr-roboport-door-down.png",
          frame_count = 16,
          height = 41,
          priority = "medium",
          scale = 0.5/2,
          shift = {
            -0.0078125/2,
            -0.3046875/2
          },
          width = 97/2
        },
        priority = "medium",
        shift = {
          0.015625,
          -0.234375
        },
        width = 52
      },
      door_animation_up = { tint=rtint,
        filename = "__base__/graphics/entity/roboport/roboport-door-up.png",
        frame_count = 16,
        height = 20,
        hr_version = { tint=rtint,
          filename = "__base__/graphics/entity/roboport/hr-roboport-door-up.png",
          frame_count = 16,
          height = 38,
          priority = "medium",
          scale = 0.5/2,
          shift = {
            -0.0078125/2,
            -0.921875/2
          },
          width = 97
        },
        priority = "medium",
        shift = {
          0.015625/2,
          -0.890625/2
        },
        width = 52
      },

      charging_offsets = {
        {
          -1.5/2,
          -0.5/2
        },
        {
          1.5/2,
          -0.5/2
        },
        {
          1.5/2,
          1.5/2
        },
        {
          -1.5/2,
          1.5/2
        },

        { -- semicircles
          -1.5/3*2,
          1.5/3*2
        },
        {
          -1.5/3*2,
          1.5/3*2
        },
        {
          -1.5/3*2,
          1.5/3*2
        },
        {
          -1.5/3*2,
          1.5/3*2
        },
      },
      close_door_trigger_effect = {
        {
          sound = {
            filename = "__base__/sound/roboport-door.ogg",
            volume = 0.75
          },
          type = "play-sound"
        }
      },
      collision_box = {
        {
          -1.7/2,
          -1.7/2
        },
        {
          1.7/2,
          1.7/2
        }
      },

      default_available_construction_output_signal = {
        name = "signal-Z",
        type = "virtual"
      },
      default_available_logistic_output_signal = {
        name = "signal-X",
        type = "virtual"
      },
      default_total_construction_output_signal = {
        name = "signal-T",
        type = "virtual"
      },
      default_total_logistic_output_signal = {
        name = "signal-Y",
        type = "virtual"
      },



	charging_distance=2,
	robots_shrink_when_entering_and_exiting=true,
	charging_station_count=8,


      charge_approach_distance = 4,
      charging_energy = "2000kW",

      circuit_connector_sprites = nil,
      circuit_wire_connection_point = nil,
      circuit_wire_max_distance = 9,

      construction_radius = 55,
      corpse = "roboport-remnants",

      draw_construction_radius_visualization = true,
      draw_logistic_radius_visualization = true,
      dying_explosion = "medium-explosion",
      energy_source = {
        buffer_capacity = "500MJ",
        input_flow_limit = "25MW",
        type = "electric",
        usage_priority = "secondary-input"
      },
      energy_usage = "50kW",
      flags = {
        "placeable-player",
        "player-creation"
      },
      icons = { {icon="__base__/graphics/icons/roboport.png",tint=rtint}},
      icon_size = 64,
      logistics_radius = 25,
      material_slots_count = 4,
      robot_slots_count = 4,


      max_health = 500,
      minable = {
        mining_time = 0.1,
        result = "warptorio-warpport"
      },
      name = "warptorio-warpport",
      open_door_trigger_effect = {
        {
          sound = {
            filename = "__base__/sound/roboport-door.ogg",
            volume = 1
          },
          type = "play-sound"
        }
      },
      recharge_minimum = "40MJ",
      recharging_animation = {
        animation_speed = 0.5, tint=rtint,
        filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
        frame_count = 16,
        height = 35,
        priority = "high",
        scale = 1.5/2,
        width = 37
      },
      recharging_light = {
        color = {
          b = 1,
          g = 0.2,
          r = 0.2
        },
        intensity = 0.5,
        size = 6
      },
      request_to_open_door_timeout = 15,
      resistances = {
        {
          percent = 60,
          type = "fire"
        },
        {
          percent = 30,
          type = "impact"
        }
      },

      selection_box = {
        {
          -1,
          -1
        },
        {
          1,
          1
        }
      },
      spawn_and_station_height = -0.1,
      stationing_offset = {
        0,
        0
      },
      type = "roboport",
      vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
      },
      working_sound = {
        audible_distance_modifier = 0.5,
        max_sounds_per_type = 3,
        probability = 0.003333333333333333,
        sound = {
          filename = "__base__/sound/roboport-working.ogg",
          volume = 0.6
        }
      }
    }

}


