

local rtint={r=0.4,g=0.4,b=1,a=1}

-- atomic-bomb -- the ammo recipe

data:extend{

{
      enabled = false,
      energy_required = 50,
      ingredients = {
	{"atomic-bomb",1},{"warptorio-warponium-fuel-cell",1},{"warptorio-warponium-fuel",1}
      },
      name = "warptorio-atomic-bomb",
      result = "warptorio-atomic-bomb",
      type = "recipe"
    },

--["warptorio-atomic-bomb"] -- the ammo item
{
      ammo_type = {
        action = {
          action_delivery = {
            projectile = "warptorio-atomic-rocket",
            source_effects = {
              entity_name = "explosion-hit",
              type = "create-entity"
            },
            starting_speed = 0.05,
            type = "projectile"
          },
          type = "direct"
        },
        category = "rocket",
        cooldown_modifier = 3,
        range_modifier = 3,
        target_type = "position"
      },
      icons = { {icon="__base__/graphics/icons/atomic-bomb.png",tint={r=1,g=0.2,b=1,a=1}} },
      icon_size = 64,
      name = "warptorio-atomic-bomb",
      order = "d[rocket-launcher]-c[atomic-bomb]",
      stack_size = 10,
      subgroup = "ammo",
      type = "ammo"
    },


--["warptorio-atomic-bomb-wave"] -- the explosion effect
{
      acceleration = 0,
      action = {
        {
          action_delivery = {
            target_effects = {
              {
                entity_name = "warptorio-explosion",
                type = "create-entity"
              }
            },
            type = "instant"
          },
          type = "direct"
        },
        {
          action_delivery = {
            target_effects = {
              damage = {
                amount = 400,
                type = "explosion"
              },
              type = "damage"
            },
            type = "instant"
          },
          radius = 3,
          type = "area",
	force="enemy"
        }
      },
      animation = {
	tint=rtint,
        filename = "__core__/graphics/empty.png",
        frame_count = 1,
        height = 1,
        priority = "high",
        width = 1
      },
      flags = {
        "not-on-map"
      },
      name = "warptorio-atomic-bomb-wave",
      shadow = {
        filename = "__core__/graphics/empty.png",
        frame_count = 1,
        height = 1,
        priority = "high",
        width = 1
      },
      type = "projectile"
    },



--["warptorio-atomic-rocket"] = -- the projectile
{
      acceleration = 0.01,
      action = {
        action_delivery = {
          target_effects = {
            {
              offset_deviation = {
                {
                  -1,
                  -1
                },
                {
                  1,
                  1
                }
              },
              repeat_count = 100,
              smoke_name = "warptorio-nuclear-smoke",
              speed_from_center = 0.5,
              starting_frame = 3,
              starting_frame_deviation = 5,
              starting_frame_speed = 0,
              starting_frame_speed_deviation = 5,
              type = "create-trivial-smoke"
            },
            {
              entity_name = "warptorio-explosion",
              type = "create-entity"
            },
            {
              damage = {
                amount = 400,
                type = "explosion"
              },
              type = "damage",
            },
            {
              check_buildability = true,
              entity_name = "small-scorchmark",
              type = "create-entity"
            },
            {
              action = {
                action_delivery = {
                  projectile = "warptorio-atomic-bomb-wave",
                  starting_speed = 0.5,
                  type = "projectile"
                },
                radius = 35,
                repeat_count = 2000,
                target_entities = false,
                trigger_from_target = true,
                type = "area"
              },
              type = "nested-result"
            }
          },
          type = "instant"
        },
        type = "direct",
	force="enemy",
      },
      animation = { tint=rtint,
        filename = "__base__/graphics/entity/rocket/rocket.png",
        frame_count = 8,
        height = 35,
        line_length = 8,
        priority = "high",
        shift = {
          0,
          0
        },
        width = 9
      },
      flags = {
        "not-on-map"
      },
      light = {
        intensity = 0.8,
        size = 15
      },
      name = "warptorio-atomic-rocket",
      shadow = {
        filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
        frame_count = 1,
        height = 24,
        priority = "high",
        shift = {
          0,
          0
        },
        width = 7
      },
      smoke = {
        {
          deviation = {
            0.15,
            0.15
          },
          frequency = 1,
          name = "warptorio-smoke-fast",
          position = {
            0,
            1
          },
          slow_down_factor = 1,
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      },
      type = "projectile"
    },


--    ["smoke-fast"] = -- Additional smoke effects
{
      animation = { tint=rtint,
        animation_speed = 0.26666666666666665,
        filename = "__base__/graphics/entity/smoke-fast/smoke-fast.png",
        frame_count = 16,
        height = 50,
        priority = "high",
        width = 50
      },
      duration = 60,
      fade_away_duration = 60,
      name = "warptorio-smoke-fast",
      type = "trivial-smoke"
    },



--["nuclear-smoke"] = -- the smoke effect
{
      affected_by_wind = true,
      animation = { tint=rtint,
        animation_speed = 0.25,
        filename = "__base__/graphics/entity/smoke/smoke.png",
        flags = {
          "smoke"
        },
        frame_count = 60,
        height = 120,
        line_length = 5,
        priority = "high",
        shift = {
          -0.53125,
          -0.4375
        },
        width = 152
      },
      cyclic = true,
      duration = 120,
      end_scale = 1,
      fade_away_duration = 120,
      fade_in_duration = 0,
      name = "warptorio-nuclear-smoke",
      spread_duration = 0,
      start_scale = 0.5,
      type = "trivial-smoke"
    },


--    explosion =
{
animations = {
        {tint=rtint,
          animation_speed = 0.5,
          filename = "__base__/graphics/entity/explosion/explosion-1.png",
          frame_count = 17,
          height = 22,
          hr_version = {tint=rtint,
            animation_speed = 0.5,
            filename = "__base__/graphics/entity/explosion/hr-explosion-1.png",
            frame_count = 17,
            height = 42,
            line_length = 6,
            priority = "high",
            scale = 0.5,
            shift = {
              0.140625,
              0.1875
            },
            width = 48
          },
          line_length = 6,
          priority = "high",
          shift = {
            0.15625,
            0.1875
          },
          width = 26
        },
        {tint=rtint,
          animation_speed = 0.5,
          filename = "__base__/graphics/entity/explosion/explosion-3.png",
          frame_count = 17,
          height = 46,
          hr_version = {tint=rtint,
            animation_speed = 0.5,
            filename = "__base__/graphics/entity/explosion/hr-explosion-3.png",
            frame_count = 17,
            height = 88,
            line_length = 6,
            priority = "high",
            scale = 0.5,
            shift = {
              -0.03125,
              0.046875
            },
            width = 102
          },
          line_length = 6,
          priority = "high",
          shift = {
            -0.03125,
            0.0625
          },
          width = 52
        }
      },


      flags = {
        "not-on-map"
      },
      light = {
        color = {
          b = 1,
          g = 0.4,
          r = 0.4
        },
        intensity = 2,
        size = 30
      },
      name = "warptorio-explosion",
      smoke = "smoke-fast",
      smoke_count = 2,
      smoke_slow_down_factor = 1,
      sound = {
        aggregation = {
          max_count = 1,
          remove = true
        },
        variations = {
          {
            filename = "__base__/sound/small-explosion-1.ogg",
            volume = 0.75
          },
          {
            filename = "__base__/sound/small-explosion-2.ogg",
            volume = 0.75
          }
        }
      },
      type = "explosion"
    },



}