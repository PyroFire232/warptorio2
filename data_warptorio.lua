local function istable(t) return type(t) == "table" end
local function rgb(r, g, b, a)
	a = a or 255
	return { r = r / 255, g = g / 255, b = b / 255, a = a / 255 }
end

function table.deepmerge(s, t)
	for k, v in pairs(t) do
		if (istable(v) and s[k] and istable(s[k])) then
			table.deepmerge(
				s[k], v)
		else
			s[k] = v
		end
	end
end

function table.merge(s, t)
	local x = {}
	for k, v in pairs(s) do x[k] = v end
	for k, v in pairs(t) do x[k] = v end
	return x
end

local function MakeDataCopy(a, b, x)
	local t = table.deepcopy(data.raw[a][b])
	if (x) then table.deepmerge(t, x) end
	return t
end
local function ExtendRecipeItem(t)
	local r = table.deepcopy(data.raw.recipe["nuclear-reactor"])
	r.enabled = false
	r.name = t.name
	r.ingredients = { { type = "item", name = "steel-plate", amount = 1 } }
	r.results = { { type = "item", name = t.name, amount = 1 } }
	local i = table.deepcopy(data.raw.item["nuclear-reactor"])
	i.name = t.name
	i.place_result = t.name
	data:extend { i, r }
end
local function ExtendRecipeItemFix(t) t.order = t.order or "warptorio" end
local function ExtendDataCopy(a, b, x, ri, tx)
	local t = MakeDataCopy(a, b, x)
	if (tx) then for k, v in pairs(tx) do if (v == false) then t[k] = nil else t[k] = v end end end
	if (ri) then ExtendRecipeItemFix(t) end
	data:extend { t }
	return t
end

local function ExtendCopyRecipe(src, name)
	local r = table.deepcopy(data.raw.recipe[src])
	r.enabled = false
	r.name = name
	r.ingredients = { { type = "item", name = "steel-plate", amount = 1 } }
	r.results = { { type = "item", name = name, amount = 1 } }
	local i = table.deepcopy(data.raw.recipe[src])
	i.name = name
	i.place_result = name
	data:extend { i, r }
end

local techPacks = {
	red = "automation-science-pack",
	green = "logistic-science-pack",
	blue = "chemical-science-pack",
	black = "military-science-pack",
	purple = "production-science-pack",
	yellow = "utility-science-pack",
	white = "space-science-pack"
}

local function SciencePacks(x)
	local t = {}
	for k, v in pairs(x) do table.insert(t, { techPacks[k], v }) end
	return t
end
local function ExtendTech(t, d, s)
	local x = table.merge(t, d)
	if (s) then x.unit.ingredients = SciencePacks(s) end
	data:extend { x }
	return x
end

--[[
local t=ExtendDataCopy("electric-pole","small-electric-pole",{name="warptorio-electric-pole",
	pictures={layers={[1]={tint={r=0.6,g=0.6,b=1,a=1},hr_version={tint={r=0.6,g=0.6,b=1,a=1}} }, }},
},true)
]]


-- --------
-- vonNeumann compatability. It's base game stuff anyway. Perhaps expand on this later

-- data.raw.lab["crash-site-lab-repaired"].minable={mining_time=3,result="crash-site-lab-repaired"}
-- data.raw.container["crash-site-chest-1"].minable={mining_time=3,result="crash-site-chest-1"}
-- data.raw.container["crash-site-chest-2"].minable={mining_time=3,result="crash-site-chest-2"}
-- data.raw["assembling-machine"]["crash-site-assembling-machine-1-repaired"].minable={mining_time=3,result="crash-site-assembling-machine-1-repaired"}
-- data.raw["assembling-machine"]["crash-site-assembling-machine-2-repaired"].minable={mining_time=3,result="crash-site-assembling-machine-2-repaired"}


-- --------
-- Warp Tiles

-- purple tiles
local t = ExtendDataCopy("tile", "tutorial-grid",
	{ name = "warp-tile-concrete", tint = { r = 0.6, g = 0.6, b = 0.7, a = 1 }, layer = 99, decorative_removal_probability = 1, walking_speed_modifier = 1.6, map_color = { r = 0.2, g = 0.1, b = 0.25, a = 1 } })

-- orange tiles
local t = ExtendDataCopy("tile", "tutorial-grid",
	{ name = "warptorio-red-concrete", tint = { r = 1, g = 0.5, b = 0, a = 0.25 }, layer = 67, decorative_removal_probability = 1, walking_speed_modifier = 1.5, map_color = { r = 0.2, g = 0.1, b = 0, a = 1 } })

-- --------
-- Invisiradar
local rtint = { r = 0.4, g = 0.4, b = 1, a = 1 }
local rvtint = { scale = 0.5 / 3, tint = { r = 1, g = 1, b = 1, a = 0 }, shift = { 0.03125 / 3, -0.5 / 3 } }
local r = ExtendDataCopy("radar", "radar", {
	name = "warptorio-invisradar",
	icons = { { icon = "__base__/graphics/icons/radar.png", tint = rtint } },
	integration_patch = rvtint,
	pictures = { layers = { rvtint, rvtint } },
}, true, {
	energy_source = { type = "void" },
	energy_per_nearby_scan = "10kJ",
	energy_per_sector = "200kJ",
	energy_usage = "1kW",
	icon = false,
	max_distance_of_nearby_sector_revealed = 5,
	max_distance_of_sector_revealed = 18,
	collision_box = { { -1.2 / 3, -1.2 / 3 }, { 1.2 / 3, 1.2 / 3 } },
	selection_box = { { -1.5 / 3, -1.5 / 3 }, { 1.5 / 3, 1.5 / 3 } },
})


-- --------
-- Loot Chest

local rtint = { r = 0.4, g = 0.4, b = 1, a = 1 }
local t = ExtendDataCopy("container", "wooden-chest", {
	name = "warptorio-lootchest",
	inventory_size = 8,
	icons = { { icon = "__base__/graphics/icons/wooden-chest.png", tint = rtint } },
	picture = { layers = { [1] = { tint = rtint }, } },
}, true, { icon = false, minable = { mining_time = 0.1 } })


-- --------
-- Carebear Chest

local rtint = rgb(255, 20, 147)
local t = ExtendDataCopy("container", "wooden-chest", {
	name = "warptorio-carebear-chest",
	inventory_size = 99,
	icons = { { icon = "__base__/graphics/icons/wooden-chest.png", tint = rtint } },
	picture = { layers = { [1] = { tint = rtint }, } },
}, true, { icon = false, minable = { mining_time = 10 } })


-- ----
-- Logistics

--[[
local rtint={r=0.5,g=0.5,b=1,a=1}
local rtintpic={tint=rtint,hr_version={tint=rtint}}
local rctint={r=0.39,g=0,b=0,a=1}
local rtintcov={layers={ [1]={tint=rctint,hr_version={tint=rctint}} }}
local t=ExtendDataCopy("pipe-to-ground","pipe-to-ground",{name="warptorio-logistics-pipe",fluid_box={base_area=5,pipe_connections={[2]={max_underground_distance=-1}}},
	pictures={ left=rtintpic, right=rtintpic,up=rtintpic,down=rtintpic },
	pipe_covers={ east={layers={ [1]={tint=rctint,hr_version={tint=rctint}} }}, north=rtintcov, south=rtintcov, west=rtintcov,}
},true)
]]

-- --------
-- Warp Reactor

-- Fuel
data:extend { { type = "fuel-category", name = "warp" } }

ExtendDataCopy("item", "uranium-fuel-cell",
	{
		name = "warptorio-warponium-fuel-cell",
		fuel_category = "warp",
		burnt_result = "uranium-fuel-cell",
		fuel_value = "32GJ",
		stack_size = 50,
		icon_size = 64,
		icons = { { icon = "__base__/graphics/icons/uranium-fuel-cell.png", tint = { r = 1, g = 0.2, b = 1, a = 0.8 } }, },
	}, false, { icon = false })

ExtendDataCopy("recipe", "uranium-fuel-cell",
	{ name = "warptorio-warponium-fuel-cell", enabled = false, results = { { type = "item", name = "warptorio-warponium-fuel-cell", amount = 1 } } },
	false,
	{
		ingredients = { { type = "item", name = "uranium-fuel-cell", amount = 5 } },
		icon_size = 64,
		icons = { { icon = "__base__/graphics/icons/uranium-fuel-cell.png", tint = { r = 1, g = 0.2, b = 1, a = 0.8 } }, },
	}, false, { icon = false })

ExtendDataCopy("item", "nuclear-fuel", {
	name = "warptorio-warponium-fuel",
	fuel_category = "chemical",
	fuel_acceleration_multiplier = 5,
	fuel_value = "7GJ",
	stack_size = 1,
	fuel_top_speed_multiplier = 1.25,
	icon_size = 64,
	icons = { { icon = "__base__/graphics/icons/nuclear-fuel.png", tint = { r = 1, g = 0.2, b = 1, a = 0.8 } }, },
}, false, { icon = false })

ExtendDataCopy("recipe", "nuclear-fuel",
	{ name = "warptorio-warponium-fuel", enabled = false, results = { { type = "item", name = "warptorio-warponium-fuel", amount = 1 } } },
	false,
	{
		ingredients = { { type = "item", name = "warptorio-warponium-fuel-cell", amount = 1 }, { type = "item", name = "nuclear-fuel", amount = 1 } },
		icon = false,
		icon_size = 64,
		icons = { { icon = "__base__/graphics/icons/nuclear-fuel.png", tint = { r = 1, g = 0.2, b = 1, a = 0.8 } }, },
	})


-- The Reactor Itself
local t = ExtendDataCopy("reactor", "nuclear-reactor",
	{
		name = "warptorio-reactor",
		max_health = 5000,
		neighbour_bonus = 12,
		consumption = "160MW",
		energy_source = { fuel_categories = { "warp" } },
		heat_buffer = { specific_heat = "1MJ", max_temperature = 1000 },
		light = { intensity = 10, size = 9.9, shift = { 0.0, 0.0 }, color = { r = 1.0, g = 0.0, b = 0.0 } },
		working_light_picture = { filename = "__base__/graphics/entity/nuclear-reactor/reactor-lights-color.png", tint = { r = 1, g = 0.4, b = 0.4, a = 1 },
		},
		picture = {
			layers = {
				[1] = { tint = { r = 0.8, g = 0.8, b = 1, a = 1 } },
			}
		},
	}, true)


-- -------------------------------------------------------------------------
-- Technologies


-- ----
-- Warp Roboport

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	effects = { { recipe = "warptorio-warpport", type = "unlock-recipe" } },
	icons = {
		{ icon = "__base__/graphics/entity/roboport/roboport-base.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_size = 220, scale = 0.25 },
	},
}
ExtendTech(t,
	{ name = "warptorio-warpport", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-logistics-4", "warptorio-reactor-8", "space-science-pack" } },
	{ red = 1, green = 1, black = 1, blue = 1, purple = 1, yellow = 1, white = 1 })


-- ----
-- Warp Nuke

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/atomic-bomb.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{
		name = "warptorio-warpnuke",
		unit = { count = 1000, time = 5 },
		effects = { { recipe = "warptorio-atomic-bomb", type = "unlock-recipe" } },
		prerequisites = { "atomic-bomb", "warptorio-reactor-8", "space-science-pack" }
	}, { red = 1, green = 1, black = 1, blue = 1, purple = 1, yellow = 1, white = 1 })


-- ----
-- Warp Module

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/module.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{
		name = "warptorio-warpmodule",
		unit = { count = 3000, time = 60 },
		prerequisites = { "warptorio-reactor-8", "space-science-pack", "efficiency-module-3" },
		effects = { { recipe = "warptorio-warpmodule", type = "unlock-recipe" } },
	}, { red = 1, green = 1, black = 1, blue = 1, purple = 1, yellow = 1, white = 1 })

data:extend { { type = "module-category", name = "warpivity" } }
local t = {
	type = "module",
	category = "warpivity",
	name = "warptorio-warpmodule",
	stack_size = 50,
	subgroup = "module",
	tier = 4,
	localised_description = { "item-description.warptorio-warpmodule" },
	limitation_message_key = "production-module-usable-only-on-intermediates",
	effect = { consumption = 0.6, pollution = 0.05, productivity = 0.1, speed = 0.35 },
	icon_size = 64,
	icons = { { icon = "__base__/graphics/icons/speed-module-3.png", tint = { r = 0.2, g = 0.2, b = 1, a = 1 } } },
}
data:extend { t }

data:extend { { type = "recipe", results = { { type = "item", name = "warptorio-warpmodule", amount = 1 } }, name = "warptorio-warpmodule", enabled = false, energy_required = 60,
	ingredients = {
		{ type = "item", name = "speed-module-3",        amount = 50 },
		{ type = "item", name = "productivity-module-3", amount = 50 },
		{ type = "item", name = "efficiency-module-3",   amount = 50 },
		{ type = "item", name = "advanced-circuit",      amount = 200 },
		{ type = "item", name = "processing-unit",       amount = 200 },
		{ type = "item", name = "low-density-structure", amount = 10 }
	},
} }


-- ----
-- Warp Reactor

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/engine.png",        tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t, { name = "warptorio-reactor-1", unit = { count = 50, time = 5 }, prerequisites = {} }, { red = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/electronics.png",   tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{ name = "warptorio-reactor-2", unit = { count = 75, time = 10 }, prerequisites = { "warptorio-reactor-1", "logistic-science-pack" } },
	{ red = 1, green = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png",    tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/advanced-circuit.png", tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{ name = "warptorio-reactor-3", unit = { count = 100, time = 15 }, prerequisites = { "warptorio-reactor-2", "military-science-pack" } },
	{ red = 1, green = 2, black = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png",   tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/processing-unit.png", tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{ name = "warptorio-reactor-4", unit = { count = 200, time = 20 }, prerequisites = { "warptorio-reactor-3", "rocketry" } },
	{ red = 2, green = 2, black = 1, })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/explosives.png",    tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{ name = "warptorio-reactor-5", unit = { count = 250, time = 25 }, prerequisites = { "warptorio-reactor-4", "chemical-science-pack" } },
	{ red = 1, green = 3, black = 1, blue = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/atomic-bomb.png",   tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, }
	},
	localised_description = { "technology-description.warptorio-reactor-6" }
}
ExtendTech(t,
	{ name = "warptorio-reactor-6", unit = { count = 300, time = 30 }, effects = { { recipe = "warptorio-townportal", type = "unlock-recipe" } }, prerequisites = { "warptorio-reactor-5", "uranium-processing", "robotics" } },
	{ red = 5, black = 5 }) -- reactor module

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png",              tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/kovarex-enrichment-process.png", tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{ name = "warptorio-reactor-7", unit = { count = 500, time = 40 }, effects = { { recipe = "warptorio-heatpipe", type = "unlock-recipe" }, { recipe = "warptorio-warponium-fuel-cell", type = "unlock-recipe" } }, prerequisites = { "nuclear-power", "warptorio-reactor-6" } },
	{ red = 1, green = 1, black = 1, blue = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__warptorio2__/graphics/technology/earth.png",   tint = { r = 0.8, g = 0.8, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high" }
	},
	localised_description = { "technology-description.warptorio-reactor-8" }
}
ExtendTech(t,
	{ name = "warptorio-reactor-8", unit = { count = 1000, time = 60 }, prerequisites = { "warptorio-reactor-7", "warptorio-charting", "warptorio-accelerator", "warptorio-stabilizer", "warptorio-kovarex" } },
	{ red = 1, green = 1, black = 1, blue = 1, purple = 1, yellow = 1 }) -- steering



-- ----
-- Reactor Abilities

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/battery.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-stabilizer", unit = { count = 400, time = 30 }, prerequisites = { "warptorio-reactor-6", "military-3", "circuit-network" } },
	{ red = 1, green = 1, black = 1, blue = 1 }) -- stabilizer

local t = { type = "technology", upgrade = false, icon_size = 128, icons = { { icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4, icon_size = 256, } }, }
t.icons = { { icon = "__base__/graphics/technology/engine.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } }
ExtendTech(t,
	{ name = "warptorio-accelerator", unit = { count = 400, time = 30 }, prerequisites = { "warptorio-reactor-6", "military-3", "circuit-network" } },
	{ red = 1, green = 1, black = 1, blue = 1 }) -- accelerator

local t = { type = "technology", upgrade = false, icon_size = 128, icons = { { icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4, icon_size = 256, } }, }
t.icons = { { icon = "__base__/graphics/technology/radar.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } }
ExtendTech(t,
	{ name = "warptorio-charting", unit = { count = 400, time = 30 }, prerequisites = { "warptorio-reactor-6", "military-3", "circuit-network" } },
	{ red = 1, green = 1, black = 1, blue = 1 }) -- charting


local t = {
	type = "technology",
	upgrade = true,
	icons = {
		{ icon = "__warptorio2__/graphics/technology/earth.png", tint = { r = 0.8, g = 0.8, b = 1, a = 1 }, scale = 0.375, priority = "low", icon_size = 128 }
	},
}
ExtendTech(t,
	{ name = "warptorio-homeworld", unit = { count = 5000, time = 30 }, effects = { { recipe = "warptorio-homeportal", type = "unlock-recipe" } }, prerequisites = { "warptorio-reactor-8", "space-science-pack" } },
	{ red = 1, green = 1, black = 1, blue = 1, purple = 1, yellow = 1, white = 1 })


-- ----
-- Warponium Fuel

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/nuclear-power.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/rocket-fuel.png",   tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, },
	},
	effects = { { recipe = "warptorio-warponium-fuel", type = "unlock-recipe" } },
}
ExtendTech(t,
	{ name = "warptorio-kovarex", unit = { count = 1000, time = 15 }, prerequisites = { "warptorio-reactor-7", "kovarex-enrichment-process" } },
	{ red = 1, green = 1, black = 1, blue = 1, purple = 1 }) -- Kovarex


-- ----
-- Boiler Warp Substation

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/electric-energy-distribution-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/fluid-handling.png",                 tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, scale = 0.25,     shift = { 16, 16 }, priority = "high", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-station", unit = { count = 500, time = 10 }, prerequisites = { "electric-energy-distribution-2", "warptorio-boiler-0", "production-science-pack" } },
	{ red = 1, blue = 1, green = 1, purple = 1 })


-- ----
-- Warp Energy Pipe

local rtint = { tint = { r = 0.3, g = 0.3, b = 1, a = 1 } }

--[[
local pipe_sprites={corner_left_down={{rtint},{rtint},{rtint},{rtint},{rtint}},corner_left_up={{rtint},{rtint},{rtint},{rtint},{rtint},{rtint}},
	corner_right_down={{rtint},{rtint},{rtint},{rtint},{rtint},{rtint}},corner_right_up={{rtint},{rtint},{rtint},{rtint},{rtint},{rtint}},
	cross={{rtint}},ending_down={{rtint}},ending_left={{rtint}},ending_right={{rtint}},ending_up={{rtint}},single={{rtint}},
	straight_horizontal={{rtint},{rtint},{rtint},{rtint},{rtint},{rtint}},straight_vertical={{rtint},{rtint},{rtint},{rtint},{rtint},{rtint}},
	t_down={{rtint}},t_left={{rtint}},t_right={{rtint}},t_up={{rtint}},}

local t=ExtendDataCopy("heat-pipe","heat-pipe",{name="warptorio-heatpipe",connection_sprites=pipe_sprites,heat_glow_sprites=pipe_sprites,
	max_temperature=5000,
	max_transfer="5GW",
	specific_heat="1MJ",
	icon_size=64,icons={ {icon="__base__/graphics/icons/heat-pipe.png",tint={r=0.3,g=0.3,b=1,a=1},hr_version={tint={r=0.3,g=0.3,b=1,a=1}} } }
})]]

local pipe_icon = { { icon = "__base__/graphics/icons/heat-pipe.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 64 } }
local t = ExtendDataCopy("recipe", "heat-pipe",
	{ name = "warptorio-heatpipe", results = { { type = "item", name = "warptorio-heatpipe", amount = 1 } }, ingredients = { { type = "item", name = "processing-unit", amount = 200 }, { type = "item", name = "heat-pipe", amount = 50 } }, enabled = false, energy_required = 30, })
local t = ExtendDataCopy("item", "heat-pipe", {
	name = "warptorio-heatpipe",
	place_result = "warptorio-heatpipe",
	icon_size = 64,
	icons = pipe_icon,
})

-- ----
-- Sandbox Boosts

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = { { icon = "__base__/graphics/technology/mining-productivity.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "mining-drill-productivity-bonus", modifier = 0.1 } },
}
ExtendTech(t, { name = "warptorio-mining-prod-1", unit = { count_formula = "20*L", time = 30 }, max_level = 5 },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-mining-prod-6", unit = { count_formula = "(20*L)+50", time = 40 }, max_level = 10, prerequisites = { "warptorio-mining-prod-1", "logistic-science-pack" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-mining-prod-11", unit = { count_formula = "(20*L)+100", time = 50 }, max_level = 15, prerequisites = { "warptorio-mining-prod-6", "chemical-science-pack" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-mining-prod-16", unit = { count_formula = "(20*L)+150", time = 60 }, max_level = 20, prerequisites = { "warptorio-mining-prod-11", "production-science-pack" } },
	{ red = 3, green = 3, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-mining-prod-21", unit = { count_formula = "(20*L)+200", time = 60 }, max_level = 25, prerequisites = { "warptorio-mining-prod-16", "utility-science-pack" } },
	{ red = 3, green = 3, blue = 2, purple = 1, yellow = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 64,
	icons = { { icon = "__base__/graphics/technology/steel-axe.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "character-mining-speed", modifier = 0.5 } },
}
ExtendTech(t,
	{ name = "warptorio-axe-speed-1", unit = { count_formula = "50*L", time = 30 }, prerequisites = { "steel-axe", "warptorio-reactor-1" }, max_level = 2 },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-axe-speed-3", unit = { count_formula = "(50*L)+50", time = 30 }, max_level = 4, prerequisites = { "warptorio-axe-speed-1", "logistic-science-pack" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-axe-speed-5", unit = { count_formula = "(50*L)+100", time = 30 }, max_level = 6, prerequisites = { "warptorio-axe-speed-3", "chemical-science-pack" } },
	{ red = 1, green = 1, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-axe-speed-7", unit = { count_formula = "(50*L)+150", time = 30 }, max_level = 8, prerequisites = { "warptorio-axe-speed-5", "production-science-pack" } },
	{ red = 1, green = 1, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-axe-speed-9", unit = { count_formula = "(50*L)+200", time = 30 }, max_level = 10, prerequisites = { "warptorio-axe-speed-7", "utility-science-pack" } },
	{ red = 1, green = 1, blue = 1, purple = 1, yellow = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = { { icon = "__base__/graphics/technology/inserter-capacity.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "bulk-inserter-capacity-bonus", modifier = 1 }, { type = "inserter-stack-size-bonus", modifier = 1 }, }
}
ExtendTech(t,
	{ name = "warptorio-inserter-cap-1", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-reactor-1", "fast-inserter" }, },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-inserter-cap-2", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-inserter-cap-1", "logistic-science-pack" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-inserter-cap-3", unit = { count = 250, time = 30 }, prerequisites = { "warptorio-inserter-cap-2", "chemical-science-pack" } },
	{ red = 3, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-inserter-cap-4", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-inserter-cap-3", "production-science-pack" } },
	{ red = 4, green = 3, blue = 2, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-inserter-cap-5", unit = { count = 350, time = 30 }, prerequisites = { "warptorio-inserter-cap-4", "utility-science-pack" } },
	{ red = 5, green = 4, blue = 3, purple = 2, yellow = 1 })


local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = { { icon = "__base__/graphics/technology/worker-robots-speed.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "worker-robot-speed", modifier = 0.35 }, }
}
ExtendTech(t,
	{ name = "warptorio-bot-speed-1", unit = { count = 120, time = 30 }, prerequisites = { "robotics", "warptorio-reactor-2" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-speed-2", unit = { count = 180, time = 30 }, prerequisites = { "warptorio-bot-speed-1", "logistic-robotics" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-speed-3", unit = { count = 250, time = 30 }, prerequisites = { "warptorio-bot-speed-2", "chemical-science-pack" } },
	{ red = 3, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-speed-4", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-bot-speed-3", "production-science-pack" } },
	{ red = 4, green = 3, blue = 2, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-speed-5", unit = { count = 350, time = 30 }, prerequisites = { "warptorio-bot-speed-4", "utility-science-pack" } },
	{ red = 5, green = 4, blue = 3, purple = 2, yellow = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = { { icon = "__base__/graphics/technology/worker-robots-storage.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "worker-robot-storage", modifier = 1 }, }
}
ExtendTech(t,
	{ name = "warptorio-bot-cap-1", unit = { count = 120, time = 30 }, prerequisites = { "robotics", "warptorio-reactor-2" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-cap-2", unit = { count = 180, time = 30 }, prerequisites = { "warptorio-bot-cap-1", "construction-robotics" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-cap-3", unit = { count = 250, time = 30 }, prerequisites = { "warptorio-bot-cap-2", "chemical-science-pack" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-cap-4", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-bot-cap-3", "production-science-pack" } },
	{ red = 3, green = 3, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-bot-cap-5", unit = { count = 350, time = 30 }, prerequisites = { "warptorio-bot-cap-4", "utility-science-pack" } },
	{ red = 3, green = 3, blue = 2, purple = 1, yellow = 1 })


local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = { { icon = "__base__/graphics/technology/physical-projectile-damage-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "turret-attack", modifier = 0.15, turret_id = "gun-turret" }, { ammo_category = "bullet", modifier = 0.15, type = "ammo-damage" }, { ammo_category = "shotgun-shell", modifier = 0.2, type = "ammo-damage" } }
}
ExtendTech(t,
	{ name = "warptorio-physdmg-1", unit = { count = 250, time = 30 }, prerequisites = { "warptorio-reactor-1", "physical-projectile-damage-1" } },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-physdmg-2", unit = { count = 250, time = 30 }, prerequisites = { "warptorio-reactor-2", "warptorio-physdmg-1", "physical-projectile-damage-2" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-physdmg-3", unit = { count = 350, time = 30 }, prerequisites = { "warptorio-reactor-3", "warptorio-physdmg-2", "physical-projectile-damage-3" } },
	{ red = 3, green = 2, black = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = { { icon = "__base__/graphics/technology/toolbelt.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } },
	effects = { { type = "character-inventory-slots-bonus", modifier = 10 } },
}
ExtendTech(t,
	{ name = "warptorio-toolbelt-1", unit = { count = 70, time = 30 }, prerequisites = { "warptorio-reactor-1" } },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-toolbelt-2", unit = { count = 120, time = 30 }, prerequisites = { "warptorio-toolbelt-1", "toolbelt", "logistic-science-pack" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-toolbelt-3", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-toolbelt-2", "chemical-science-pack" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-toolbelt-4", unit = { count = 180, time = 30 }, prerequisites = { "warptorio-toolbelt-3", "production-science-pack" } },
	{ red = 3, green = 2, blue = 2, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-toolbelt-5", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-toolbelt-4", "utility-science-pack" } },
	{ red = 4, green = 3, blue = 2, purple = 2, yellow = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icons = {
		{ icon = "__warptorio2__/graphics/technology/earth.png", tint = { r = 0.7, g = 0.7, b = 1, a = 1 }, shift = { 0, 0 }, scale = 0.375,   priority = "medium", icon_size = 128 },
		{ icon = "__base__/graphics/technology/steel-axe.png",   tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_size = 256, scale = 0.125 },
	},
	effects = {
		{ type = "character-reach-distance",          modifier = 1 },
		{ type = "character-build-distance",          modifier = 1 },
		{ type = "character-item-drop-distance",      modifier = 1 },
		{ type = "character-resource-reach-distance", modifier = 1 },
	},
}
ExtendTech(t, { name = "warptorio-reach-1", unit = { count = 50, time = 30 }, prerequisites = { "warptorio-reactor-1" } },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-reach-2", unit = { count = 100, time = 30 }, prerequisites = { "warptorio-reach-1", "logistic-science-pack" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-reach-3", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-reach-2", "chemical-science-pack" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-reach-4", unit = { count = 180, time = 30 }, prerequisites = { "warptorio-reach-3", "production-science-pack" } },
	{ red = 3, green = 2, blue = 2, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-reach-5", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-reach-4", "utility-science-pack" } },
	{ red = 4, green = 3, blue = 2, purple = 2, yellow = 1 })


local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/exoskeleton-equipment.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, },
	},
	effects = {
		{ type = "character-running-speed", modifier = 0.1 },
	},
}
ExtendTech(t,
	{ name = "warptorio-striders-1", unit = { count = 150, time = 20 }, prerequisites = { "warptorio-reactor-1" }, upgrade = false },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-striders-2", unit = { count = 300, time = 20 }, prerequisites = { "warptorio-reactor-2", "modular-armor", "warptorio-striders-1" }, upgrade = false },
	{ red = 1, green = 1 })



-- ----
-- Platform Size

local t = { type = "technology", upgrade = true, icon_size = 128, icons = { { icon = "__base__/graphics/technology/concrete.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } }, }
ExtendTech(t, { name = "warptorio-platform-size-1", unit = { count = 70, time = 20 }, prerequisites = {} }, { red = 1 })
ExtendTech(t,
	{ name = "warptorio-platform-size-2", unit = { count = 120, time = 20 }, prerequisites = { "warptorio-platform-size-1", "warptorio-reactor-1" } },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-platform-size-3", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-platform-size-2", "logistic-science-pack" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-platform-size-4", unit = { count = 200, time = 30 }, prerequisites = { "concrete", "warptorio-platform-size-3" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-platform-size-5", unit = { count = 120, time = 30 }, prerequisites = { "chemical-science-pack", "warptorio-platform-size-4" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-platform-size-6", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-platform-size-5", "solar-energy", "production-science-pack" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-platform-size-7", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-platform-size-6", "utility-science-pack" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })


-- ----
-- Train Stops


for v, w in pairs({ nw = { -38, -38 }, ne = { 38, -38 }, se = { 38, 38 }, sw = { -38, 38 } }) do
	local t = {
		type = "technology",
		upgrade = false,
		icon_size = 128,
		icons = {
			{ icon = "__base__/graphics/technology/railway.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "low",       icon_mipmaps = 4, icon_size = 256,   scale = 0.375 },
			{ icon = "__base__/graphics/technology/railway.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   shift = { w[1], w[2] }, scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
		},
	}

	ExtendTech(t,
		{ name = "warptorio-rail-" .. v, unit = { count = 500, time = 30 }, prerequisites = { "railway", "warptorio-platform-size-6", "warptorio-factory-7" } },
		{ red = 1, green = 1, black = 1, blue = 1, purple = 1, yellow = 1 })
end


-- ----
-- Castle Ramps


for v, w in pairs({ nw = { -38, -38 }, ne = { 38, -38 }, se = { 38, 38 }, sw = { -38, 38 } }) do
	local t = {
		type = "technology",
		upgrade = true,
		icon_size = 128,
		icons = {
			{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   priority = "low",       icon_mipmaps = 4, icon_size = 256,   scale = 0.4 },
			{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, shift = { w[1], w[2] }, scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
		},
	}
	ExtendTech(t,
		{ name = "warptorio-turret-" .. v .. "-0", upgrade = false, unit = { count = 100, time = 30 }, prerequisites = { "gate", "warptorio-factory-0" } },
		{ red = 1, green = 1 })
	ExtendTech(t,
		{ name = "warptorio-turret-" .. v .. "-1", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-turret-" .. v .. "-0", "military-science-pack", } },
		{ red = 2, green = 1, black = 1, })
	ExtendTech(t,
		{ name = "warptorio-turret-" .. v .. "-2", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-turret-" .. v .. "-1", "chemical-science-pack" } },
		{ red = 2, green = 1, black = 1, blue = 1 })
	ExtendTech(t,
		{ name = "warptorio-turret-" .. v .. "-3", unit = { count = 300, time = 40 }, prerequisites = { "warptorio-turret-" .. v .. "-2", "production-science-pack" } },
		{ red = 2, green = 2, black = 1, blue = 1, purple = 1 })
end

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   priority = "low",     icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, shift = { 32, 32 },   scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, shift = { -32, -32 }, scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, shift = { -32, 32 },  scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/stone-wall.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, shift = { 32, -32 },  scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{
		name = "warptorio-bridgesize-1",
		unit = { count = 500, time = 40 },
		prerequisites = { "warptorio-turret-nw-0", "warptorio-turret-ne-0", "warptorio-turret-se-0", "warptorio-turret-sw-0" },
		unit = { count = 200, time = 40 }
	}, { red = 1, green = 1, black = 1 })
ExtendTech(t,
	{
		name = "warptorio-bridgesize-2",
		unit = { count = 500, time = 40 },
		prerequisites = { "warptorio-bridgesize-1", "warptorio-turret-nw-1", "warptorio-turret-ne-1", "warptorio-turret-se-1", "warptorio-turret-sw-1", "low-density-structure" },
		unit = { count = 400, time = 40 }
	}, { red = 1, green = 1, black = 1, blue = 1 })

-- ----
-- Factory Floor Upgrades

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/automation-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{
		name = "warptorio-factory-0",
		unit = { count = 80, time = 20 },
		prerequisites = { "automation", "warptorio-platform-size-1" },
		upgrade = false,
		localised_name = { "technology-name.warptorio-factory" },
		localised_description = { "technology-description.warptorio-factory-floor" },
	}, { red = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/automation-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",     tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 16, 16 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-factory-1", unit = { count = 120, time = 20 }, prerequisites = { "warptorio-factory-0", "steel-processing" } },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-factory-2", unit = { count = 150, time = 20 }, prerequisites = { "electric-energy-distribution-1", "advanced-material-processing", "automation-2", "warptorio-factory-1" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-factory-3", unit = { count = 180, time = 20 }, prerequisites = { "warptorio-factory-2", "sulfur-processing" } },
	{ red = 2, green = 2 })
ExtendTech(t,
	{ name = "warptorio-factory-4", unit = { count = 220, time = 20 }, prerequisites = { "warptorio-factory-3", "chemical-science-pack", "modules" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-factory-5", unit = { count = 250, time = 20 }, prerequisites = { "warptorio-factory-4", "advanced-material-processing-2" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-factory-6", unit = { count = 300, time = 20 }, prerequisites = { "warptorio-factory-5", "automation-3" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-factory-7", unit = { count = 350, time = 20 }, prerequisites = { "warptorio-factory-6", "utility-science-pack", "effect-transmission" } },
	{ red = 2, green = 3, blue = 1, purple = 1, yellow = 1 })

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/automation-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",     tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 0, -24 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-factory-n", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-factory-7", "space-science-pack", "warptorio-bridgesize-2" } },
	{ red = 3, green = 2, blue = 3, purple = 2, yellow = 1, white = 1 })
local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/automation-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",     tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 0, 24 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-factory-s", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-factory-7", "space-science-pack", "warptorio-bridgesize-2" } },
	{ red = 3, green = 2, blue = 3, purple = 2, yellow = 1, white = 1 })
local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/automation-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",     tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 24, 0 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-factory-e", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-factory-7", "space-science-pack", "warptorio-bridgesize-2" } },
	{ red = 3, green = 2, blue = 3, purple = 2, yellow = 1, white = 1 })
local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/automation-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",     tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { -24, 0 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-factory-w", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-factory-7", "space-science-pack", "warptorio-bridgesize-2" } },
	{ red = 3, green = 2, blue = 3, purple = 2, yellow = 1, white = 1 })

-- ----
-- Boiler Room Upgrades

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{
		name = "warptorio-boiler-0",
		unit = { count = 100, time = 30 },
		prerequisites = { "steel-processing", "warptorio-harvester-floor" },
		upgrade = false,
		localised_name = { "technology-name.warptorio-boiler" },
		localised_description = { "technology-description.warptorio-boiler-floor" },
	}, { red = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",       tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 16, 16 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-1", unit = { count = 100, time = 30 }, prerequisites = { "warptorio-boiler-0", "fluid-handling" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-boiler-2", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-boiler-1", "flammables" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-boiler-3", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-boiler-2", "battery" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-boiler-4", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-boiler-3", "chemical-science-pack" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-boiler-5", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-boiler-4", "production-science-pack" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-boiler-6", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-boiler-5", "nuclear-fuel-reprocessing" } },
	{ red = 2, green = 2, blue = 1, purple = 1, })
ExtendTech(t,
	{ name = "warptorio-boiler-7", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-boiler-6", "utility-science-pack" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })


local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   priority = "low",    icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/oil-gathering.png",  tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 16, 16 }, scale = 0.25,    icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-water-1", upgrade = true, unit = { count = 500, time = 30 }, prerequisites = { "warptorio-boiler-3", "landfill" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-boiler-water-2", upgrade = true, unit = { count = 1000, time = 40 }, prerequisites = { "warptorio-boiler-5", "warptorio-boiler-water-1" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })

ExtendTech(t,
	{ name = "warptorio-boiler-water-3", upgrade = true, unit = { count = 2000, time = 50 }, prerequisites = { "warptorio-boiler-water-2", "space-science-pack" } },
	{ red = 1, green = 1, blue = 1, purple = 1, yellow = 1, white = 1 })

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",       tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 0, -24 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-n", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-boiler-7", "space-science-pack" } },
	{ red = 3, green = 2, blue = 2, purple = 2, yellow = 1, white = 1 })

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",       tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 0, 24 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-s", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-boiler-7", "space-science-pack" } },
	{ red = 3, green = 2, blue = 2, purple = 2, yellow = 1, white = 1 })
local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",       tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 24, 0 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-e", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-boiler-7", "space-science-pack" } },
	{ red = 3, green = 2, blue = 2, purple = 2, yellow = 1, white = 1 })
local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/fluid-handling.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png",       tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { -24, 0 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-boiler-w", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-boiler-7", "space-science-pack" } },
	{ red = 3, green = 2, blue = 2, purple = 2, yellow = 1, white = 1 })




-- ----
-- Harvester Size

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/tank.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, }
	},
}
ExtendTech(t,
	{ name = "warptorio-harvester-floor", unit = { count = 100, time = 30 }, prerequisites = { "fast-inserter", "warptorio-factory-0" }, upgrade = false },
	{ red = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 256,
	icons = {
		{ icon = "__base__/graphics/technology/tank.png",     tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__base__/graphics/technology/concrete.png", tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, shift = { 16, 16 }, scale = 0.25,    icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-harvester-size-1", unit = { count = 100, time = 30 }, prerequisites = { "warptorio-harvester-floor", "oil-processing" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-harvester-size-2", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-harvester-size-1", "bulk-inserter" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-harvester-size-3", unit = { count = 200, time = 30 }, prerequisites = { "warptorio-harvester-size-2", "mining-productivity-1" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-harvester-size-4", unit = { count = 250, time = 30 }, prerequisites = { "warptorio-harvester-size-3", "chemical-science-pack" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-harvester-size-5", unit = { count = 300, time = 30 }, prerequisites = { "warptorio-harvester-size-4", "production-science-pack", "mining-productivity-2" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-harvester-size-6", unit = { count = 350, time = 30 }, prerequisites = { "warptorio-harvester-size-5", "nuclear-fuel-reprocessing" } },
	{ red = 2, green = 2, blue = 1, purple = 1, })
ExtendTech(t,
	{ name = "warptorio-harvester-size-7", unit = { count = 400, time = 30 }, prerequisites = { "warptorio-harvester-size-6", "utility-science-pack", "mining-productivity-3" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })


for v, w in pairs({ east = { 24, 0 }, west = { -24, 0 } }) do
	local odr = (v == "east" and "a-b" or "a-a")
	local t = {
		type = "technology",
		upgrade = true,
		icon_size = 256,
		icons = {
			{ icon = "__base__/graphics/technology/tank.png",     tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   priority = "low",       icon_mipmaps = 4, icon_size = 256, },
			{ icon = "__base__/graphics/technology/concrete.png", tint = { r = 1, g = 0.7, b = 0.4, a = 0.9 }, shift = { w[1], w[2] }, scale = 0.25,     priority = "high", icon_mipmaps = 4, icon_size = 256, },
		},
	}
	--ExtendTech(t,{name="warptorio-harvester-"..v.."-gate",upgrade=false, unit={count=150,time=25}, prerequisites={"warptorio-harvester-floor"}}, {red=1,green=1} )

	ExtendTech(t,
		{ name = "warptorio-harvester-" .. v .. "-1", order = odr, unit = { count = 150, time = 25 }, prerequisites = { "warptorio-harvester-floor" }, localised_description = { "technology-description.warptorio-harvester-" .. v .. "-gate" } },
		{ red = 1, green = 1, })
	ExtendTech(t,
		{ name = "warptorio-harvester-" .. v .. "-2", order = odr, unit = { count = 200, time = 25 }, prerequisites = { "warptorio-harvester-" .. v .. "-1", "mining-productivity-1", "military-science-pack" } },
		{ red = 2, green = 1, black = 1 })
	ExtendTech(t,
		{ name = "warptorio-harvester-" .. v .. "-3", order = odr, unit = { count = 300, time = 25 }, prerequisites = { "warptorio-harvester-" .. v .. "-2", "mining-productivity-2" } },
		{ red = 2, green = 2, black = 1, blue = 1 })
	ExtendTech(t,
		{ name = "warptorio-harvester-" .. v .. "-4", order = odr, unit = { count = 400, time = 25 }, prerequisites = { "warptorio-harvester-" .. v .. "-3", "nuclear-fuel-reprocessing" } },
		{ red = 2, green = 2, black = 1, blue = 1, purple = 1 })
	ExtendTech(t,
		{ name = "warptorio-harvester-" .. v .. "-5", order = odr, unit = { count = 500, time = 25 }, prerequisites = { "warptorio-harvester-" .. v .. "-4", "mining-productivity-3" } },
		{ red = 2, green = 2, black = 1, blue = 1, purple = 1, yellow = 1 })
end

--[[ todo
for v,w in pairs({nw={-38,-38},ne={38,-38},se={38,38},sw={-38,38}})do
local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/tank.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low",icon_mipmaps=4,icon_size=256,},
	{icon="__base__/graphics/technology/concrete.png",tint={r=1,g=0.7,b=0.4,a=0.9},shift={w[1],w[2]},scale=0.45,priority="high",icon_mipmaps=4,icon_size=256,},
}, }
ExtendTech(t,{name="warptorio-harvester-"..v.."",upgrade=false, unit={count=1000,time=40}, prerequisites={"warptorio-harvester-size-7","warptorio-reactor-8","space-science-pack"}}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1,white=1} )
end
]]

-- ----
-- Logistics

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/logistics-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-logistics-1", unit = { count = 100, time = 20 }, prerequisites = { "logistics", "warptorio-factory-0" }, upgrade = false },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-logistics-2", unit = { count = 200, time = 20 }, prerequisites = { "logistics-2", "warptorio-logistics-1" } },
	{ red = 2, green = 1 })
ExtendTech(t,
	{ name = "warptorio-logistics-3", unit = { count = 300, time = 20 }, prerequisites = { "logistics-3", "warptorio-logistics-2" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-logistics-4", unit = { count = 400, time = 20 }, prerequisites = { "logistic-system", "warptorio-logistics-3" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/logistics-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low",    icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/logistics-2.png", tint = { r = 1, g = 1, b = 0.7, a = 0.9 }, shift = { -14, 12 }, scale = 0.2,      priority = "medium", icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/logistics-3.png", tint = { r = 1, g = 1, b = 0.7, a = 0.9 }, shift = { 14, 12 },  scale = 0.2,      priority = "medium", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-dualloader-1", unit = { count = 500, time = 20 }, prerequisites = { "logistics-2", "warptorio-logistics-1" } },
	{ red = 1, green = 1 })
--ExtendTech(t,{name="warptorio-dualloader-2", unit={count=1000,time=15}, prerequisites={"logistics-2","warptorio-dualloader-1"}}, {red=2,green=1} )
--ExtendTech(t,{name="warptorio-dualloader-3", unit={count=1000,time=20}, prerequisites={"logistics-3","warptorio-dualloader-2","production-science-pack"}}, {red=3,green=2,blue=1,purple=1} )
t.upgrade = false

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/logistics-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low",    icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/logistics-1.png", tint = { r = 1, g = 1, b = 0.7, a = 0.9 }, shift = { -16, -6 }, scale = 0.2,      priority = "medium", icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/logistics-2.png", tint = { r = 1, g = 1, b = 0.7, a = 0.9 }, shift = { 16, -6 },  scale = 0.2,      priority = "medium", icon_mipmaps = 4, icon_size = 256, },
		{ icon = "__base__/graphics/technology/logistics-3.png", tint = { r = 1, g = 1, b = 0.7, a = 0.9 }, shift = { 0, 16 },   scale = 0.2,      priority = "medium", icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-triloader", unit = { count = 1000, time = 30 }, prerequisites = { "warptorio-dualloader-1", "chemical-science-pack" } },
	{ red = 1, green = 1, blue = 1 })



-- ----
-- Warp Loader

local t = {
	type = "technology",
	upgrade = false,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/logistics-1.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, priority = "low", icon_mipmaps = 4,   icon_size = 256, },
		{ icon = "__warptorio2__/graphics/technology/earth.png", tint = { r = 0.8, g = 0.8, b = 1, a = 1 }, scale = 1,        shift = { 32, 32 }, priority = "high", icon_size = 128, scale = 0.5 }
	},
	effects = { { recipe = "warptorio-warploader", type = "unlock-recipe" } },
}
ExtendTech(t,
	{ name = "warptorio-warploader", unit = { count = 10000, time = 60 }, prerequisites = { "warptorio-armor", "warptorio-warpmodule", "warptorio-warpnuke", "warptorio-warpport" } },
	{ red = 1, green = 1, blue = 1, purple = 1, yellow = 1, white = 1 })



-- ----
-- Energy Upgrades

local t = { type = "technology", upgrade = true, icon_size = 128, icons = { { icon = "__base__/graphics/technology/electric-energy-acumulators.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } }, }
ExtendTech(t,
	{ name = "warptorio-energy-1", unit = { count = 30, time = 20 }, prerequisites = { "warptorio-factory-0" }, upgrade = false },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-energy-2", unit = { count = 100, time = 25 }, prerequisites = { "warptorio-energy-1", "electric-energy-distribution-1" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-energy-3", unit = { count = 150, time = 30 }, prerequisites = { "warptorio-energy-2", "advanced-circuit" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-energy-4", unit = { count = 200, time = 35 }, prerequisites = { "warptorio-energy-3", "electric-energy-distribution-2", "processing-unit" } },
	{ red = 1, green = 1, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-energy-5", unit = { count = 250, time = 40 }, prerequisites = { "warptorio-energy-4", "utility-science-pack", "production-science-pack" } },
	{ red = 1, green = 1, blue = 1, purple = 1, yellow = 1 })

-- ----
-- Teleporter

local t = { type = "technology", upgrade = true, icon_size = 128, icons = { { icon = "__base__/graphics/technology/research-speed.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, } }, }
ExtendTech(t,
	{ name = "warptorio-teleporter-portal", unit = { count = 50, time = 20 }, prerequisites = { "warptorio-factory-0", "electronics", }, upgrade = false },
	{ red = 1 })
ExtendTech(t,
	{ name = "warptorio-teleporter-1", unit = { count = 100, time = 20 }, prerequisites = { "warptorio-teleporter-portal", "electric-energy-distribution-1" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-teleporter-2", unit = { count = 150, time = 20 }, prerequisites = { "warptorio-teleporter-1", "advanced-circuit" } },
	{ red = 2, green = 2, })
ExtendTech(t,
	{ name = "warptorio-teleporter-3", unit = { count = 200, time = 20 }, prerequisites = { "warptorio-teleporter-2", "electric-energy-distribution-2", "processing-unit" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-teleporter-4", unit = { count = 250, time = 20 }, prerequisites = { "warptorio-teleporter-3", "nuclear-power" } },
	{ red = 2, green = 2, blue = 2, })
ExtendTech(t,
	{ name = "warptorio-teleporter-5", unit = { count = 300, time = 20 }, prerequisites = { "warptorio-teleporter-4", "utility-science-pack", "production-science-pack" } },
	{ red = 2, green = 3, blue = 2, purple = 1, yellow = 1 })


-- ----
-- Beacon


local t = { type = "technology", upgrade = true, icon_size = 64, icons = { { icon = "__base__/graphics/icons/beacon.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 } } }, }
ExtendTech(t,
	{ name = "warptorio-beacon-1", unit = { count = 300, time = 20 }, prerequisites = { "modules", "warptorio-factory-0" }, upgrade = false },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-2", unit = { count = 400, time = 20 }, prerequisites = { "warptorio-beacon-1", "speed-module", "productivity-module", "efficiency-module" } },
	{ red = 1, green = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-3", unit = { count = 500, time = 20 }, prerequisites = { "warptorio-beacon-2", "speed-module-2", "productivity-module-2", "efficiency-module-2" } },
	{ red = 2, green = 2, blue = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-4", unit = { count = 600, time = 20 }, prerequisites = { "warptorio-beacon-3", "speed-module-3", "productivity-module-3", "efficiency-module-3" } },
	{ red = 2, green = 2, blue = 1, purple = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-5", unit = { count = 700, time = 20 }, prerequisites = { "warptorio-beacon-4", "utility-science-pack" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-6", unit = { count = 800, time = 20 }, prerequisites = { "warptorio-beacon-5" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-7", unit = { count = 1000, time = 20 }, prerequisites = { "warptorio-beacon-6" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-8", unit = { count = 1200, time = 20 }, prerequisites = { "warptorio-beacon-7" } },
	{ red = 2, green = 2, blue = 1, purple = 1, yellow = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-9", unit = { count = 1500, time = 20 }, prerequisites = { "warptorio-beacon-8", "space-science-pack" } },
	{ red = 3, green = 3, blue = 2, purple = 1, yellow = 1, white = 1 })
ExtendTech(t,
	{ name = "warptorio-beacon-10", unit = { count = 2000, time = 20 }, prerequisites = { "warptorio-beacon-9" } },
	{ red = 3, green = 3, blue = 2, purple = 2, yellow = 2, white = 1 })

--[[ unused
local t={type="technology",upgrade=true,icon_size=64,icons={ {icon="__base__/graphics/icons/beacon.png",tint={r=0.3,g=0.3,b=1,a=1}} }, }
ExtendTech(t,{name="warptorio-beacon-1",unit={count=300,time=20}, prerequisites={"modules","warptorio-factory-0"},upgrade=false}, {red=1,green=1})
ExtendTech(t,{name="warptorio-beacon-2",unit={count=500,time=20}, prerequisites={"warptorio-beacon-1","speed-module","productivity-module","efficiency-module"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-beacon-3",unit={count=300,time=20}, prerequisites={"warptorio-beacon-2","speed-module-2","productivity-module-2","efficiency-module-2"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-beacon-4",unit={count=500,time=20}, prerequisites={"warptorio-beacon-3","speed-module-3","productivity-module-3","efficiency-module-3"}}, {red=2,green=2,blue=1,purple=1})
ExtendTech(t,{name="warptorio-beacon-5",unit={count_formula="250+50*L",time=20},max_level=10, prerequisites={"warptorio-beacon-4","utility-science-pack"}}, {red=2,green=2,blue=1,purple=1,yellow=1})
ExtendTech(t,{name="warptorio-beacon-11",unit={count=5,time=1}, prerequisites={"warptorio-beacon-5"}}, {red=5,green=5,blue=5,purple=5,white=5})
ExtendTech(t,{name="warptorio-beacon-12",unit={count=5,time=1}, prerequisites={"warptorio-beacon-11"}}, {red=2,green=5,blue=5,purple=5,white=5})
]]


-- ----
-- Warp Beacon

local t = ExtendDataCopy("beacon", "beacon", {
	name = "warptorio-beacon-1",
	supply_area_distance = 16,
	module_slots = 1,
	base_picture = { tint = { r = 0.5, g = 0.7, b = 1, a = 1 }, },
	animation = { tint = { r = 1, g = 0.2, b = 0.2, a = 1 }, },
	allowed_effects = { "consumption", "speed", "pollution", "productivity" },
	distribution_effectivity = 1,
}, true)
for i = 2, 10, 1 do
	local xt = table.deepcopy(t)
	xt.name = "warptorio-beacon-" .. i
	xt.supply_area_distance = math.min(16 + 8 * i, 64)
	xt.module_slots = i
	data:extend { xt }
end

-- ----
-- Radar

--[[
local t={type="technology",icon_size=128,icons={ {icon="__base__/graphics/technology/radar.png",tint={r=0.3,g=0.3,b=1,a=1},icon_mipmaps=4,icon_size=256,} }, }
ExtendTech(t,{name="warptorio-radar-1",unit={count=300,time=15},prerequisites={"radar","chemical-science-pack","optics"}}, {red=1,green=1})
]]


-- ----
-- Warp Armor
local t = { type = "technology", icon_size = 128, icons = { { icon = "__base__/graphics/technology/power-armor-mk2.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_size = 256 }, }, prerequisites = { "power-armor-mk2", "warptorio-reactor-8", "space-science-pack", } }
ExtendTech(t,
	{ name = "warptorio-armor", unit = { count = 1000, time = 60 }, effects = { { recipe = "warptorio-armor", type = "unlock-recipe" } } },
	{ red = 4, green = 4, blue = 4, black = 5, yellow = 2, white = 1 })


data:extend { { type = "equipment-grid", name = "warptorio-warparmor-grid", equipment_categories = { "armor" }, height = 16, width = 16 } }
local t = ExtendDataCopy("armor", "power-armor-mk2", {
	name = "warptorio-armor",
	equipment_grid = "warptorio-warparmor-grid",
	icon_size = 64,
	icons = { { icon = "__base__/graphics/icons/power-armor-mk2.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, } },
	inventory_size_bonus = 100
}, false)

local t = ExtendDataCopy("recipe", "power-armor-mk2",
	{
		name = "warptorio-armor",
		enabled = false,
		ingredients = {
			{ type = "item", name = "power-armor-mk2",               amount = 1 },
			{ type = "item", name = "power-armor",                   amount = 1 },
			{ type = "item", name = "modular-armor",                 amount = 1 },
			{ type = "item", name = "heavy-armor",                   amount = 1 },
			{ type = "item", name = "light-armor",                   amount = 1 },
			{ type = "item", name = "warptorio-warponium-fuel-cell", amount = 10 },
		},
		results = {
			{ type = "item", name = "warptorio-armor", amount = 1 }
		}
	})



-- ----
-- Warp Combinators

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/circuit-network.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 }, icon_mipmaps = 4, icon_size = 256, },
		--{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={32,32},scale=0.5,icon_mipmaps=4,icon_size=256,},
	},
	effects = {
		{ recipe = "warptorio-combinator", type = "unlock-recipe" },
	},
}
ExtendTech(t,
	{ name = "warptorio-combinator", unit = { count = 50, time = 20 }, prerequisites = { "circuit-network", "chemical-science-pack" } },
	{ red = 1, green = 1, blue = 1 })

local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/circuit-network.png", tint = { r = 0.3, g = 0.3, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__base__/graphics/technology/tank.png",            tint = { r = 0.7, g = 0.7, b = 1, a = 0.9 }, priority = "medium", shift = { 32, 32 }, scale = 0.25, icon_mipmaps = 4, icon_size = 256, },
	},
}
ExtendTech(t,
	{ name = "warptorio-alt-combinator", unit = { count = 50, time = 20 }, prerequisites = { "circuit-network", "production-science-pack", "warptorio-harvester-east-1", "warptorio-harvester-west-1" } },
	{ red = 1, green = 1, blue = 1, purple = 1 })



-- ----
-- Warp Toolbar


local t = {
	type = "technology",
	upgrade = true,
	icon_size = 128,
	icons = {
		{ icon = "__base__/graphics/technology/toolbelt.png",    tint = { r = 0.4, g = 0.4, b = 1, a = 1 },   icon_mipmaps = 4,    icon_size = 256, },
		{ icon = "__warptorio2__/graphics/technology/earth.png", tint = { r = 0.8, g = 0.8, b = 1, a = 0.9 }, priority = "medium", shift = { 32, 32 }, icon_size = 128, scale = 0.5 },
	},
}
ExtendTech(t, {
		name = "warptorio-toolbar",
		unit = { count = 2000, time = 20 },
		prerequisites = { "space-science-pack", "warptorio-toolbelt-5", "warptorio-reach-5", "warptorio-harvester-east-5", "warptorio-harvester-west-5", "warptorio-teleporter-5", "warptorio-striders-2" },
	},
	{ red = 1, green = 1, blue = 1, purple = 1, black = 1, yellow = 1, white = 1 }
)
