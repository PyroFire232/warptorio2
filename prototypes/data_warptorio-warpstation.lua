local rtint={r=0.4,g=0.4,b=1,a=1}

local rsc=1.5

data:extend{



--[[{
      icons = {{tint=rtint,icon="__base__/graphics/icons/substation.png"}},
      icon_size = 32,
      name = "warptorio-warpstation",
      order = "a[energy]-d[substation]",
      place_result = "warptorio-warpstation",
      stack_size = 50,
      subgroup = "energy-pipe-distribution",
      type = "item"
    },]]


{
      collision_box = {
        {
          -0.7*rsc,
          -0.7*rsc
        },
        {
          0.7*rsc,
          0.7*rsc
        }
      },
      connection_points = {
        {
          shadow = {
            copper = {
              4.25*rsc,
              0.25*rsc
            },
            green = {
              3.875*rsc,
              0.25*rsc
            },
            red = {
              4.71875*rsc,
              0.28125*rsc
            }
          },
          wire = {
            copper = {
              0,
              -2.6875*rsc
            },
            green = {
              -0.65625*rsc,
              -2.5625*rsc
            },
            red = {
              0.6875*rsc,
              -2.53125*rsc
            }
          }
        },
        {
          shadow = {
            copper = {
              4.15625*rsc,
              0.28125*rsc
            },
            green = {
              4.5*rsc,
              0.65625*rsc
            },
            red = {
              3.4375*rsc,
              -0.09375*rsc
            }
          },
          wire = {
            copper = {
              0*rsc,
              -2.65625*rsc
            },
            green = {
              0.46875*rsc,
              -2.1875*rsc
            },
            red = {
              -0.46875*rsc,
              -2.875*rsc
            }
          }
        },
        {
          shadow = {
            copper = {
              4.15625*rsc,
              0.28125*rsc
            },
            green = {
              3.96875*rsc,
              0.8125*rsc
            },
            red = {
              3.96875*rsc,
              -0.25*rsc
            }
          },
          wire = {
            copper = {
              0,
              -2.65625*rsc
            },
            green = {
              0,
              -2.0625*rsc
            },
            red = {
              0,
              -3.03125*rsc
            }
          }
        },
        {
          shadow = {
            copper = {
              4.15625*rsc,
              0.28125*rsc
            },
            green = {
              3.46875*rsc,
              0.625*rsc
            },
            red = {
              4.5*rsc,
              -0.09375*rsc
            }
          },
          wire = {
            copper = {
              0,
              -2.6875*rsc
            },
            green = {
              -0.46875*rsc,
              -2.21875*rsc
            },
            red = {
              0.46875*rsc,
              -2.875*rsc
            }
          }
        }
      },
      corpse = "substation-remnants",
      drawing_box = {
        {
          -1*rsc,
          -3*rsc
        },
        {
          1*rsc,
          1*rsc
        }
      },
      flags = {
        "placeable-neutral",
        "player-creation"
      },
      icon = "__base__/graphics/icons/substation.png",
      icon_size = 32,
      max_health = 200,
      maximum_wire_distance = 20,
      --[[minable = {
        mining_time = 0.1,
        result = "warptorio-warpstation"
      },]]
      order = "a[energy]-d[substation]",
      name = "warptorio-warpstation",
      pictures = {
        layers = {
          { tint=rtint, scale=rsc,
            direction_count = 4,
            filename = "__base__/graphics/entity/substation/substation.png",
            height = 136,
            hr_version = { tint=rtint,
              direction_count = 4,
              filename = "__base__/graphics/entity/substation/hr-substation.png",
              height = 270,
              priority = "high",
              scale = 0.5*rsc,
              shift = {
                0,
                -0.96875*rsc
              },
              width = 138
            },
            priority = "high",
            shift = {
              0,
              -0.96875*rsc
            },
            width = 70
          },
          { tint=rtint, scale=rsc,
            direction_count = 4,
            draw_as_shadow = true,
            filename = "__base__/graphics/entity/substation/substation-shadow.png",
            height = 52,
            hr_version = { tint=rtint,
              direction_count = 4,
              draw_as_shadow = true,
              filename = "__base__/graphics/entity/substation/hr-substation-shadow.png",
              height = 104,
              priority = "high",
              scale = 0.5*rsc,
              shift = {
                1.9375*rsc,
                0.3125*rsc
              },
              width = 370
            },
            priority = "high",
            shift = {
              1.9375*rsc,
              0.3125*rsc
            },
            width = 186
          }
        }
      },
      radius_visualisation_picture = {
        filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
        height = 12,
        priority = "extra-high-no-scale",
        width = 12
      },
      resistances = {
        {
          percent = 90,
          type = "fire"
        }
      },
      selection_box = {
        {
          -1*rsc,
          -1*rsc
        },
        {
          1*rsc,
          1*rsc
        }
      },
      supply_area_distance = 64,
      track_coverage_during_build_by_moving = true,
      type = "electric-pole",
      vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
      },
      working_sound = {
        apparent_volume = 1.5,
        audible_distance_modifier = 0.5,
        probability = 0.0055555555555555554,
        sound = {
          filename = "__base__/sound/substation.ogg"
        }
      }
    }



}