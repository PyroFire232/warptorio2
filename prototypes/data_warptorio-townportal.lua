local rtint = { r = 0.4, g = 0.4, b = 1, a = 1 }
local rsc = 1.5

data:extend {
      {
            capsule_action = {
                  attack_parameters = { type = "stream", range = 0, cooldown = 10, ammo_category = "capsule",
                        ammo_type = { action = { action_deliver = { target_effects = { damage = { amount = -10, type = "physical" }, type = "damage" }, type = "instant" }, type = "direct" }, category = "capsule", target_type = "position" },
                  },
                  type = "use-on-self",
                  uses_stack = true,
            },
            icons = { { icon = "__warptorio2__/graphics/technology/earth.png", icon_size = 128, scale = 1 } },
            icon_size = 128,
            name = "warptorio-townportal",
            order = "zz",
            stack_size = 5,
            subgroup = "capsule",
            type = "capsule"
      },
      {
            enabled = false,
            ingredients = {
                  { type = "item", name = "advanced-circuit", amount = 10 },
                  { type = "item", name = "grenade",          amount = 10 },
                  { type = "item", name = "radar",            amount = 10 }
            },
            name = "warptorio-townportal",
            results = { { type = "item", name = "warptorio-townportal", amount = 1 } },
            type = "recipe"
      },
}

data:extend {
      {
            capsule_action = {
                  attack_parameters = { type = "stream", range = 0, cooldown = 10, ammo_category = "capsule",
                        ammo_type = { action = { action_deliver = { target_effects = { damage = { amount = -10, type = "physical" }, type = "damage" }, type = "instant" }, type = "direct" }, category = "capsule", target_type = "position" },
                  },
                  type = "use-on-self",
                  uses_stack = true,
            },
            icons = { { icon = "__warptorio2__/graphics/technology/earth.png", icon_size = 128, scale = 1, tint = rtint } },
            icon_size = 128,
            name = "warptorio-homeportal",
            order = "zz",
            stack_size = 5,
            subgroup = "capsule",
            type = "capsule"
      },


      {
            enabled = false,
            ingredients = {
                  { type = "item", name = "advanced-circuit", amount = 10 },
                  { type = "item", name = "grenade",          amount = 10 },
                  { type = "item", name = "radar",            amount = 10 }
            },
            name = "warptorio-homeportal",
            results = { { type = "item", name = "warptorio-homeportal", amount = 1 } },
            type = "recipe"
      },


}
