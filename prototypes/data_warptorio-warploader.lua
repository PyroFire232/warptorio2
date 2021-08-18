local rtint={r=0.4,g=0.4,b=1,a=1}
data:extend{

	{ name="warptorio-warploader", type="item",subgroup="belt",
		stack_size=50,
		icon_size=64,icons={{tint=rtint,icon="__base__/graphics/icons/express-loader.png"}},
		order = "e[express-loader]-d[warptorio-warploader]",
		place_result="warptorio-warploader",
	},

	{ name="warptorio-warploader", type="recipe",category="crafting-with-fluid",enabled=false,energy_required=2,
		ingredients={ {"iron-gear-wheel",400},{"express-underground-belt",50},{"express-transport-belt",100},{"express-splitter",50},{amount=200,name="lubricant",type="fluid"} },
		result="warptorio-warploader",result_count=1,
	},
	


    {--["express-loader"] = 
	container_distance=0,
      animation_speed_coefficient = 32,
      belt_animation_set = {
        animation_set = { tint=rtint,
          direction_count = 20,
          filename = "__base__/graphics/entity/express-transport-belt/express-transport-belt.png",
          frame_count = 32,
          height = 64,
          hr_version = { tint=rtint,
            direction_count = 20,
            filename = "__base__/graphics/entity/express-transport-belt/hr-express-transport-belt.png",
            frame_count = 32,
            height = 128,
            priority = "extra-high",
            scale = 0.5,
            width = 128
          },
          priority = "extra-high",
          width = 64
        },
        east_index = 1,
        east_to_north_index = 5,
        east_to_south_index = 10,
        ending_east_index = 20,
        ending_north_index = 18,
        ending_south_index = 14,
        ending_west_index = 16,
        north_index = 3,
        north_to_east_index = 6,
        north_to_west_index = 8,
        south_index = 4,
        south_to_east_index = 9,
        south_to_west_index = 11,
        starting_east_index = 19,
        starting_north_index = 17,
        starting_south_index = 13,
        starting_west_index = 15,
        west_index = 2,
        west_to_north_index = 7,
        west_to_south_index = 12
      },
      collision_box = {
        {
          -0.4,
          -0.9
        },
        {
          0.4,
          0.9
        }
      },
      corpse = "small-remnants",
      fast_replaceable_group = "loader",
      filter_count = 5,
      flags = {
        "placeable-neutral",
        "player-creation",
        "fast-replaceable-no-build-while-moving"
      },
      icons = {{icon="__base__/graphics/icons/express-loader.png",tint=rtint}},
      icon_size = 32,
      max_health = 170,
      minable = {
        mining_time = 0.1,
        result = "warptorio-warploader"
      },
      name = "warptorio-warploader",
      resistances = {
        {
          percent = 60,
          type = "fire"
        }
      },
      selection_box = {
        {
          -0.5,
          -1
        },
        {
          0.5,
          1
        }
      },
      speed = 0.09375,
      structure = {
        direction_in = {
          sheet = { tint=rtint,
            filename = "__base__/graphics/entity/loader/loader-structure.png",
            height = 64,
            priority = "extra-high",
            width = 64
          }
        },
        direction_out = {
          sheet = { tint=rtint,
            filename = "__base__/graphics/entity/loader/loader-structure.png",
            height = 64,
            priority = "extra-high",
            width = 64,
            y = 64
          }
        }
      },
      type = "loader"
    },

}