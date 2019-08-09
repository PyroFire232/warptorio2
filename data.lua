--require("technology/warp-technology")
require("sound/sound")
require("data_warptorio-heatpipe")
require("data_warptorio-warpport")
require("data_warptorio-logistics-pipe")
require("data_warptorio-warpstation")
require("data_warpnuke")
require("data_warptorio-warploader")

local function istable(t) return type(t)=="table" end
local function rgb(r,g,b,a) a=a or 255 return {r=r/255,g=g/255,b=b/255,a=a/255} end

function table.deepmerge(s,t) for k,v in pairs(t)do if(istable(v) and s[k] and istable(s[k]))then table.deepmerge(s[k],v) else s[k]=v end end end
function table.merge(s,t) local x={} for k,v in pairs(s)do x[k]=v end for k,v in pairs(t)do x[k]=v end return x end
local function MakeDataCopy(a,b,x) local t=table.deepcopy(data.raw[a][b]) if(x)then table.deepmerge(t,x) end return t end
local function ExtendRecipeItem(t)
	local r=table.deepcopy(data.raw.recipe["nuclear-reactor"])
	r.enabled=false r.name=t.name r.ingredients={{"steel-plate",1}} r.result=t.name
	local i=table.deepcopy(data.raw.item["nuclear-reactor"])
	i.name=t.name i.place_result=t.name
	data:extend{i,r}
end
local function ExtendDataCopy(a,b,x,ri,tx) local t=MakeDataCopy(a,b,x) if(tx)then for k,v in pairs(tx)do t[k]=v end end data:extend{t} if(ri)then ExtendRecipeItem(t) end return t end


local techPacks={red="automation-science-pack",green="logistic-science-pack",blue="chemical-science-pack",black="military-science-pack",
	purple="production-science-pack",yellow="utility-science-pack",white="space-science-pack"}

local function SciencePacks(x) local t={} for k,v in pairs(x)do table.insert(t,{techPacks[k],v}) end return t end
local function ExtendTech(t,d,s) local x=table.merge(t,d) if(s)then x.unit.ingredients=SciencePacks(s) end data:extend{x} return x end





-- --------
-- Warp Tiles

local t=ExtendDataCopy("tile","tutorial-grid",{name="warp-tile-concrete",tint={r=0.6,g=0.6,b=0.7,a=1},decorative_removal_probability=1,walking_speed_modifier=1.6,map_color={r=0.2,g=0.1,b=0.25,a=1}})

-- --------
-- Invisiradar
local rtint={r=0.4,g=0.4,b=1,a=1}
local rvtint={scale=1/3,tint={r=1,g=1,b=1,a=0},hr_version={scale=0.5/3,tint={r=1,g=1,b=1,a=0}}}
local r=ExtendDataCopy("radar","radar",{name="warptorio-invisradar",
	icon=false,icons={{icon="__base__/graphics/icons/radar.png",tint=rtint}},integration_patch=rvtint,pictures={layers={rvtint,rvtint}},
},true,{energy_per_nearby_scan="10kJ",energy_per_sector="200kJ",energy_usage="1kW",
	max_distance_of_nearby_sector_revealed=5,max_distance_of_sector_revealed=18,
	collision_box={{-1.2/3,-1.2/3},{1.2/3,1.2/3}},selection_box={{-1.5/3,-1.5/3},{1.5/3,1.5/3}},
})


-- --------
-- Loot Chest

local rtint={r=0.4,g=0.4,b=1,a=1}
local t=ExtendDataCopy("container","wooden-chest",{name="warptorio-lootchest",inventory_size=8,
	icon=false,icons={{icon="__base__/graphics/icons/wooden-chest.png",tint=rtint}},
	picture={layers={ [1]={tint=rtint,hr_version={tint=rtint}}, }},
},true,{minable={mining_time=0.1}})


-- --------
-- Carebear Chest

local rtint=rgb(255,20,147)
local t=ExtendDataCopy("container","wooden-chest",{name="warptorio-carebear-chest",inventory_size=99,
	icon=false,icons={{icon="__base__/graphics/icons/wooden-chest.png",tint=rtint}},
	picture={layers={ [1]={tint=rtint,hr_version={tint=rtint}}, }},
},true,{minable={mining_time=0.1}})



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
data:extend{{type="fuel-category", name="warp"}}

ExtendDataCopy("item","uranium-fuel-cell",{name="warptorio-warponium-fuel-cell",fuel_category="warp",burnt_result="uranium-fuel-cell",fuel_value="24GJ",stack_size=50,
	icon=false,icon_size=32,icons={ {icon="__base__/graphics/icons/uranium-fuel-cell.png",tint={r=1,g=0.2,b=1,a=0.8}}, }, })

ExtendDataCopy("recipe","uranium-fuel-cell",{name="warptorio-warponium-fuel-cell",enabled=false,result="warptorio-warponium-fuel-cell",result_count=1},false,
	{ingredients={{"uranium-fuel-cell",8}},
	icon=false,icon_size=32,icons={ {icon="__base__/graphics/icons/uranium-fuel-cell.png",tint={r=1,g=0.2,b=1,a=0.8}}, },
})

ExtendDataCopy("item","nuclear-fuel",{name="warptorio-warponium-fuel",fuel_category="chemical",
	fuel_acceleration_multiplier=5,fuel_value="7GJ",stack_size=1,fuel_top_speed_multiplier=1.25,
	icon=false,icon_size=32,icons={ {icon="__base__/graphics/icons/nuclear-fuel.png",tint={r=1,g=0.2,b=1,a=0.8}}, },
})

ExtendDataCopy("recipe","nuclear-fuel",{name="warptorio-warponium-fuel",enabled=false,result="warptorio-warponium-fuel",result_count=1},false,
	{ingredients={{"warptorio-warponium-fuel-cell",1},{"nuclear-fuel",1}},
	icon=false,icon_size=32,icons={ {icon="__base__/graphics/icons/nuclear-fuel.png",tint={r=1,g=0.2,b=1,a=0.8}}, },
})


-- The Reactor Itself
local t=ExtendDataCopy("reactor","nuclear-reactor",{name="warptorio-reactor",max_health=5000,neighbour_bonus=12,consumption="20MW",
	energy_source={fuel_category="warp"},heat_buffer={specific_heat="4MJ",max_temperature=1000}, light={ intensity=10, size=9.9, shift={0.0,0.0}, color={r=1.0,g=0.0,b=0.0} },
	working_light_picture={ filename="__base__/graphics/entity/nuclear-reactor/reactor-lights-grayscale.png", tint={r=1,g=0.4,b=0.4,a=1},
		hr_version={ filename="__base__/graphics/entity/nuclear-reactor/hr-reactor-lights-grayscale.png", tint={r=1,g=0.4,b=0.4,a=1}, },
	},
	picture={layers={
		[1]={ tint={r=0.8,g=0.8,b=1,a=1}, hr_version={ tint={r=0.8,g=0.8,b=1,a=1}, }, },
	}},
},true)


-- --------
-- Basic Teleporter
--
-- Most other teleporters are based off this one

local t=ExtendDataCopy("electric-pole","small-electric-pole",{name="warptorio-electric-pole",
	pictures={layers={[1]={tint={r=0.6,g=0.6,b=1,a=1},hr_version={tint={r=0.6,g=0.6,b=1,a=1}} }, }},
},true)


local t={
	name="warptorio-teleporter-0",
	type="accumulator",
	max_health=500,
	energy_source={type="electric",usage_priority="tertiary",buffer_capacity="2MJ",input_flow_limit="200kW",output_flow_limit="200kW"},

	collision_box={{-1.01/0.9,-1.01/0.9}, {1.01/0.9,1.01/0.9}}, selection_box={{-1.5/0.9,-1.5/0.9}, {1.5/0.9,1.5/0.9}},
	charge_cooldown=30, charge_light={intensity=0.3,size=7,color={r=1.0,g=1.0,b=1.0}},
	discharge_cooldown=60, discharge_light={intensity=0.7,size=7,color={r=1.0,g=1.0,b=1.0}},
	circuit_wire_connection_point=circuit_connector_definitions["accumulator"].points,
	circuit_connector_sprites=circuit_connector_definitions["accumulator"].sprites,
	circuit_wire_max_distance=default_circuit_wire_max_distance,
	default_output_signal={type="virtual", name="signal-A"},
	vehicle_impact_sound={ filename="__base__/sound/car-metal-impact.ogg", volume=0.65 },
      repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
	maximum_wire_distance=7.5,
	supply_area_distance=2.5,
	


	picture={ layers={
		[1]={	filename="__base__/graphics/entity/lab/lab.png", tint={r=0.6,g=0.6,b=1,a=0.6},
			width=98, height=87, frame_count=33, animation_speed=1/3, line_length=11, shift=util.by_pixel(0,1.5), scale=0.9,
			hr_version={ filename="__base__/graphics/entity/lab/hr-lab.png", scale=0.45, tint={r=0.6,g=0.6,b=1,a=0.6},
				width=194, height=174, frame_count=33,animation_speed=1/3, line_length=11, shift=util.by_pixel(0, 1.5),
			},
		},
		[2]={	filename="__base__/graphics/entity/lab/lab-shadow.png", draw_as_shadow=true, scale=0.9,
			width=122, height=68, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(13,11),
			hr_version ={filename="__base__/graphics/entity/lab/hr-lab-shadow.png", draw_as_shadow=true, scale=0.45,
				width=242, height=136, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(13, 11),
			},
		},	
		[3]={	filename="__base__/graphics/entity/lab/lab-integration.png", scale=0.9,
			width=122, height=81, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(0, 15.5),
			hr_version={ filename="__base__/graphics/entity/lab/hr-lab-integration.png", scale=0.45,
				width=242, height=162, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(0, 15.5),
			},
		},
	}},		
}
data:extend{t}
ExtendRecipeItem(t)

local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-teleporter-1",energy_source={buffer_capacity="4MJ",input_flow_limit="2MW",output_flow_limit="2MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-teleporter-2",energy_source={buffer_capacity="8MJ",input_flow_limit="20MW",output_flow_limit="20MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-teleporter-3",energy_source={buffer_capacity="16MJ",input_flow_limit="200MW",output_flow_limit="200MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-teleporter-4",energy_source={buffer_capacity="32MJ",input_flow_limit="2000MW",output_flow_limit="2000MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-teleporter-5",energy_source={buffer_capacity="64MJ",input_flow_limit="20000MW",output_flow_limit="20000MW"}},true)

-- --------
-- Teleporter Gate

local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-teleporter-gate-0",minable={mining_time=2,result="warptorio-teleporter-gate-0"},
	picture={layers={[1]={ tint={r=1,g=0.8,b=0.8,a=0.6}, hr_version={tint={r=1,g=0.8,b=0.8,a=0.6}}, } }}, })
local t=ExtendDataCopy("recipe","lab",{name="warptorio-teleporter-gate-0",enabled=false})
local t=ExtendDataCopy("item","lab",{name="warptorio-teleporter-gate-0",place_result="warptorio-teleporter-gate-0",
	icons={{ icon="__base__/graphics/icons/lab.png", tint={r=1,g=0.6,b=0.6,a=0.6}, }}, })

local t=ExtendDataCopy("accumulator","warptorio-teleporter-gate-0",{name="warptorio-teleporter-gate-1",energy_source={buffer_capacity="4MJ",input_flow_limit="2MW",output_flow_limit="2MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-gate-0",{name="warptorio-teleporter-gate-2",energy_source={buffer_capacity="8MJ",input_flow_limit="20MW",output_flow_limit="20MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-gate-0",{name="warptorio-teleporter-gate-3",energy_source={buffer_capacity="16MJ",input_flow_limit="200MW",output_flow_limit="200MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-gate-0",{name="warptorio-teleporter-gate-4",energy_source={buffer_capacity="32MJ",input_flow_limit="2GW",output_flow_limit="2GW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-teleporter-gate-0",{name="warptorio-teleporter-gate-5",energy_source={buffer_capacity="64MJ",input_flow_limit="20GW",output_flow_limit="20GW"}},true)

-- ----
-- Stairways

local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-underground-0",energy_source={buffer_capacity="2MJ",input_flow_limit="5MW",output_flow_limit="5MW"},},true,{
	picture={layers={
		[1]={ tint={r=0.8,g=0.8,b=1,a=1}, scale=0.9,
			filename="__base__/graphics/entity/electric-furnace/electric-furnace-base.png", priority="high", width=129, height=100, frame_count=1, shift={0.421875/2, 0},
			hr_version={ filename="__base__/graphics/entity/electric-furnace/hr-electric-furnace.png", tint={r=0.8,g=0.8,b=1,a=1},
				scale=0.45, priority="high", width=239, height=219, frame_count=1, shift=util.by_pixel(0.75, 5.75), 
			},
		},
		[2]={
			filename="__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png", draw_as_shadow=true, scale=0.9,
			priority="high", width=129, height=100, frame_count=1, shift={0.421875,0},
			hr_version={	filename="__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
				priority="high", width=227, height=171, frame_count=1, draw_as_shadow=true, shift=util.by_pixel(11.25, 7.75), scale=0.45,
			},
		},
	}},
})

local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-1",energy_source={buffer_capacity="10MJ",input_flow_limit="500MW",output_flow_limit="500MW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-2",energy_source={buffer_capacity="50MJ",input_flow_limit="1GW",output_flow_limit="1GW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-3",energy_source={buffer_capacity="100MJ",input_flow_limit="2GW",output_flow_limit="2GW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-4",energy_source={buffer_capacity="500MJ",input_flow_limit="5GW",output_flow_limit="5GW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-5",energy_source={buffer_capacity="1GJ",input_flow_limit="20GW",output_flow_limit="20GW"},},true)

-- ----
-- Warp Beacon

local t=ExtendDataCopy("beacon","beacon",{name="warptorio-beacon-1",supply_area_distance=16,module_specification={module_slots=1},
	base_picture={ tint={r=0.5,g=0.7,b=1,a=1}, }, animation={ tint={r=1,g=0.2,b=0.2,a=1}, },
	allowed_effects={"consumption","speed","pollution","productivity"},
	distribution_effectivity=1,
},true)
for i=2,10,1 do local xt=table.deepcopy(t) xt.name="warptorio-beacon-"..i xt.supply_area_distance=math.min(16+8*i,64) xt.module_specification.module_slots=i data:extend{xt} ExtendRecipeItem(xt) end


-- ----
-- Warp Accumulator

local rtint={r=0.4,g=0.4,b=1,a=1}
local t=ExtendDataCopy("accumulator","accumulator",{name="warptorio-accumulator",
	energy_source={ type="electric", usage_priority="tertiary", emissions_per_minute=5,
		input_flow_limit="5GW", output_flow_limit="5GW", buffer_capacity="1GJ",
	},
	picture={layers={ {tint=rtint,hr_version={tint=rtint}} }},
},true)

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/electric-energy-acumulators.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
}, }
ExtendTech(t,{name="warptorio-accumulator",unit={count=1000,time=5},effects={{recipe="warptorio-accumulator",type="unlock-recipe"}},
	prerequisites={"warptorio-energy-4","warptorio-teleporter-4","production-science-pack"}}, {red=1,green=1,blue=1,purple=1})


--[[ unused
local entity=table.deepcopy(data.raw.accumulator["accumulator"]) entity.name="warptorio-stabilizer-1"
entity.picture.layers[1].tint={r=0.8, g=0.8, b=1, a=1}
entity.picture.layers[1].hr_version.tint={r=0.8, g=0.8, b=1, a=1}
entity.energy_source={
	type="electric",
	buffer_capacity="500MJ",
	usage_priority="tertiary",
	input_flow_limit="500kW",
	output_flow_limit="0kW",
	emissions_per_minute=5
}
recipe_item_entity_extend(entity)

local entity=table.deepcopy(data.raw.accumulator["warptorio-stabilizer-1"]) entity.name="warptorio-stabilizer-2"
entity.energy_source.buffer_capacity="5GJ"
entity.energy_source.input_flow_limit="1000kW"
recipe_item_entity_extend(entity)

local entity=table.deepcopy(data.raw.accumulator["warptorio-stabilizer-1"]) entity.name="warptorio-stabilizer-3"
entity.energy_source.buffer_capacity="50GJ"
entity.energy_source.input_flow_limit="2500kW"
recipe_item_entity_extend(entity)

local entity=table.deepcopy(data.raw.accumulator["warptorio-stabilizer-1"]) entity.name="warptorio-stabilizer-4"
entity.energy_source.buffer_capacity="500GJ"
entity.energy_source.input_flow_limit="5000kW"
recipe_item_entity_extend(entity)

]]

-- ----
-- Warp Accelerator
--[[ unused

--warp accelerator
local entity=table.deepcopy(data.raw.accumulator["accumulator"])
entity.name="warptorio-accelerator-0"
entity.picture.layers[1].tint={r=1, g=0.8, b=0.8, a=1}
entity.picture.layers[1].hr_version.tint={r=1, g=0.8, b=0.8, a=1}
entity.energy_source =
{
  type="electric",
  buffer_capacity="5MJ",
  usage_priority="tertiary",
  input_flow_limit="5GW",
  output_flow_limit="0GW"
}

recipe_item_entity_extend(entity)
]]


-- -------------------------------------------------------------------------
-- Technologies


-- ----
-- Warp Roboport

local t={type="technology",upgrade=true,icon_size=128,effects={{recipe="warptorio-warpport",type="unlock-recipe"}},icons={
	{icon="__base__/graphics/entity/roboport/roboport-base.png",tint={r=0.3,g=0.3,b=1,a=1},scale=0.75,priority="low"},
}, }
ExtendTech(t,{name="warptorio-warpport",unit={count=1000,time=5}, prerequisites={"warptorio-logistics-4","warptorio-reactor-8","space-science-pack"}}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1,white=1})


-- ----
-- Warp Nuke

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/atomic-bomb.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
}, }
ExtendTech(t,{name="warptorio-warpnuke",unit={count=1000,time=5},effects={{recipe="warptorio-atomic-bomb",type="unlock-recipe"}},
	prerequisites={"atomic-bomb","warptorio-reactor-8","space-science-pack"}}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1,white=1})


-- ----
-- Warp Module

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/module.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
}, }
ExtendTech(t,{name="warptorio-warpmodule",unit={count=3000,time=5}, prerequisites={"warptorio-reactor-8","space-science-pack","effectivity-module-3"},
	effects={{recipe="warptorio-warpmodule",type="unlock-recipe"}},}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1,white=1})

data:extend{{type="module-category",name="warpivity"}}
local t={type="module",category="warpivity",name="warptorio-warpmodule",stack_size=50,subgroup="module",tier=4,localised_description={"item-description.warptorio-warpmodule"},
	effect={ consumption={bonus=0.6},pollution={bonus=0.05},productivity={bonus=0.04},speed={bonus=0.35} },
	icon_size=32,icons={ {icon="__base__/graphics/icons/speed-module-3.png",tint={r=0.2,g=0.2,b=1,a=1}} },
}
data:extend{t}

data:extend{{type="recipe",result="warptorio-warpmodule",name="warptorio-warpmodule",enabled=false,energy_required=60,
	ingredients={{"speed-module-3",50},{"productivity-module-3",50},{"effectivity-module-3",50},{"advanced-circuit",200},{"processing-unit",200},{"low-density-structure",10}},
}}


-- ----
-- Warp Energy

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/demo/analyse-ship.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"},
}, }
ExtendTech(t,{name="warptorio-reactor-1",unit={count=50,time=5}, prerequisites={}}, {red=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/demo/basic-electronics.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-2",unit={count=50,time=5}, prerequisites={"warptorio-reactor-1","logistic-science-pack"}}, {red=1,green=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/advanced-electronics.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-3",unit={count=50,time=5}, prerequisites={"warptorio-reactor-2","military-science-pack"}}, {red=1,green=2,black=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/advanced-electronics-2.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-4",unit={count=50,time=5}, prerequisites={"warptorio-reactor-3","rocketry"}}, {red=2,green=2,black=1,})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/explosives.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-5",unit={count=50,time=5}, prerequisites={"warptorio-reactor-4","chemical-science-pack"}}, {red=1,green=3,black=1,blue=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/atomic-bomb.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-6",unit={count=100,time=90}, prerequisites={"warptorio-reactor-5","uranium-processing","robotics"}}, {red=5,black=5}) -- reactor module

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/kovarex-enrichment-process.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-7",unit={count=1000,time=30}, effects={{recipe="warptorio-heatpipe",type="unlock-recipe"},{recipe="warptorio-warponium-fuel-cell",type="unlock-recipe"}}, prerequisites={"nuclear-power","warptorio-reactor-6"}}, {red=1,green=1,black=1,blue=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__warptorio2__/graphics/technology/earth.png",tint={r=0.8,g=0.8,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
}, }
ExtendTech(t,{name="warptorio-reactor-8",unit={count=1000,time=30}, prerequisites={"warptorio-reactor-7","warptorio-charting","warptorio-accelerator","warptorio-stabilizer","warptorio-kovarex","rocket-control-unit"}}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1}) -- steering



-- ----
-- Reactor Abilities

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/battery.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
}, }
ExtendTech(t,{name="warptorio-stabilizer",unit={count=400,time=30}, prerequisites={"warptorio-reactor-6","military-3","circuit-network"}}, {red=1,green=1,black=1,blue=1}) -- stabilizer

local t={type="technology",upgrade=false,icon_size=128,icons={ {icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"} }, }
t.icons={ {icon="__base__/graphics/technology/engine.png",tint={r=0.3,g=0.3,b=1,a=1}} }
ExtendTech(t,{name="warptorio-accelerator",unit={count=400,time=30}, prerequisites={"warptorio-reactor-6","military-3","circuit-network"}}, {red=1,green=1,black=1,blue=1}) -- accelerator

local t={type="technology",upgrade=false,icon_size=128,icons={ {icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"} }, }
t.icons={ {icon="__base__/graphics/technology/radar.png",tint={r=0.3,g=0.3,b=1,a=1}} }
ExtendTech(t,{name="warptorio-charting",unit={count=400,time=30}, prerequisites={"warptorio-reactor-6","military-3","circuit-network"}}, {red=1,green=1,black=1,blue=1}) -- charting


local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__warptorio2__/graphics/technology/earth.png",tint={r=0.8,g=0.8,b=1,a=1},priority="low"}
}, }
ExtendTech(t,{name="warptorio-homeworld",unit={count=5000,time=30}, prerequisites={"warptorio-reactor-8","space-science-pack"}}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1,white=1})


-- ----
-- Warponium Fuel

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/rocket-fuel.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"},
	},
	effects={{recipe="warptorio-warponium-fuel",type="unlock-recipe"}},
}
ExtendTech(t,{name="warptorio-kovarex",unit={count=1000,time=15}, prerequisites={"warptorio-reactor-7","kovarex-enrichment-process"}}, {red=1,green=1,black=1,blue=1,purple=1}) -- Kovarex


-- ----
-- Boiler Warp Substation

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/electric-energy-distribution.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.7,g=0.7,b=1,a=1},scale=0.5,shift={32,32},priority="high"},
}, }
ExtendTech(t,{name="warptorio-boiler-station",unit={count=500,time=10}, prerequisites={"electric-energy-distribution-2","warptorio-boiler-0","production-science-pack"}}, {red=1,blue=1,green=1,purple=1})


-- ----
-- Warp Energy Pipe

local rtint={tint={r=0.3,g=0.3,b=1,a=1},hr_version={tint={r=0.3,g=0.3,b=1,a=1}}}

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
	icon_size=32,icons={ {icon="__base__/graphics/icons/heat-pipe.png",tint={r=0.3,g=0.3,b=1,a=1},hr_version={tint={r=0.3,g=0.3,b=1,a=1}} } }
})]]

local pipe_icon={ {icon="__base__/graphics/icons/heat-pipe.png",tint={r=0.3,g=0.3,b=1,a=1},hr_version={tint={r=0.3,g=0.3,b=1,a=1}} } }
local t=ExtendDataCopy("recipe","heat-pipe",{name="warptorio-heatpipe",result="warptorio-heatpipe",ingredients={{"processing-unit",200},{"heat-pipe",50}}, enabled=false,energy_required=30, })
local t=ExtendDataCopy("item","heat-pipe",{name="warptorio-heatpipe",place_result="warptorio-heatpipe",
	icon_size=32,icons=pipe_icon,
})

-- ----
-- Sandbox Boosts

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/mining-productivity.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="mining-drill-productivity-bonus",modifier=0.1}}, }
ExtendTech(t,{name="warptorio-mining-prod-1",unit={count_formula="20*L",time=30},max_level=5}, {red=1})
ExtendTech(t,{name="warptorio-mining-prod-6",unit={count_formula="(20*L)-50",time=30},max_level=10,prerequisites={"warptorio-mining-prod-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-mining-prod-11",unit={count_formula="(20*L)-100",time=30},max_level=15,prerequisites={"warptorio-mining-prod-6","chemical-science-pack"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-mining-prod-16",unit={count_formula="(20*L)-150",time=30},max_level=20,prerequisites={"warptorio-mining-prod-11","production-science-pack"}}, {red=3,green=3,blue=1,purple=1} )
ExtendTech(t,{name="warptorio-mining-prod-21",unit={count_formula="(20*L)-200",time=30},max_level=25,prerequisites={"warptorio-mining-prod-16","utility-science-pack"}}, {red=3,green=3,blue=2,purple=1,yellow=1} )

local t={type="technology",upgrade=true,icon_size=32,icons={ {icon="__base__/graphics/icons/steel-axe.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="character-mining-speed",modifier=0.5}}, }
ExtendTech(t,{name="warptorio-axe-speed-1",unit={count_formula="50*L",time=30,prerequisites={"steel-axe"},},max_level=2}, {red=1})
ExtendTech(t,{name="warptorio-axe-speed-3",unit={count_formula="(50*L)",time=30},max_level=4,prerequisites={"warptorio-axe-speed-1","logistic-science-pack"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-axe-speed-5",unit={count_formula="(50*L)",time=30},max_level=6,prerequisites={"warptorio-axe-speed-3","chemical-science-pack"}}, {red=1,green=1,blue=1} )
ExtendTech(t,{name="warptorio-axe-speed-7",unit={count_formula="(50*L)",time=30},max_level=8,prerequisites={"warptorio-axe-speed-5","production-science-pack"}}, {red=1,green=1,blue=1,purple=1} )
ExtendTech(t,{name="warptorio-axe-speed-9",unit={count_formula="(50*L)",time=30},max_level=10,prerequisites={"warptorio-axe-speed-7","utility-science-pack"}}, {red=1,green=1,blue=1,purple=1,yellow=1} )

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/inserter-capacity.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="stack-inserter-capacity-bonus",modifier=1}, {type="inserter-stack-size-bonus",modifier=1},} }
ExtendTech(t,{name="warptorio-inserter-cap-1",unit={count=350,time=30}}, {red=1})
ExtendTech(t,{name="warptorio-inserter-cap-2",unit={count=350,time=30},prerequisites={"warptorio-inserter-cap-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-inserter-cap-3",unit={count=350,time=30},prerequisites={"warptorio-inserter-cap-2","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-inserter-cap-4",unit={count=350,time=30},prerequisites={"warptorio-inserter-cap-3","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-inserter-cap-5",unit={count=350,time=30},prerequisites={"warptorio-inserter-cap-4","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )


local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/worker-robots-speed.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="worker-robot-speed",modifier=0.35},} }
ExtendTech(t,{name="warptorio-bot-speed-1",unit={count=350,time=30},prerequisites={"robotics"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-bot-speed-2",unit={count=350,time=30},prerequisites={"warptorio-bot-speed-1","logistic-robotics"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-bot-speed-3",unit={count=350,time=30},prerequisites={"warptorio-bot-speed-2","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-bot-speed-4",unit={count=350,time=30},prerequisites={"warptorio-bot-speed-3","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-bot-speed-5",unit={count=350,time=30},prerequisites={"warptorio-bot-speed-4","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/worker-robots-storage.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="worker-robot-storage",modifier=1}, } }
ExtendTech(t,{name="warptorio-bot-cap-1",unit={count=150,time=30},prerequisites={"robotics"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-bot-cap-2",unit={count=200,time=30},prerequisites={"warptorio-bot-cap-1","construction-robotics"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-bot-cap-3",unit={count=250,time=30},prerequisites={"warptorio-bot-cap-2","chemical-science-pack"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-bot-cap-4",unit={count=300,time=30},prerequisites={"warptorio-bot-cap-3","production-science-pack"}}, {red=3,green=3,blue=1,purple=1} )
ExtendTech(t,{name="warptorio-bot-cap-5",unit={count=350,time=30},prerequisites={"warptorio-bot-cap-4","utility-science-pack"}}, {red=3,green=3,blue=2,purple=1,yellow=1} )


local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/physical-projectile-damage-1.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="turret-attack",modifier=0.15,turret_id="gun-turret"},{ammo_category="bullet",modifier=0.15,type="ammo-damage"},{ammo_category="shotgun-shell",modifier=0.2,type="ammo-damage"} } }
ExtendTech(t,{name="warptorio-physdmg-1",unit={count=300,time=30},prerequisites={"warptorio-reactor-1","physical-projectile-damage-1"}}, {red=1})
ExtendTech(t,{name="warptorio-physdmg-2",unit={count=300,time=30},prerequisites={"warptorio-reactor-2","warptorio-physdmg-1","physical-projectile-damage-2"}}, {red=2,green=1} )
ExtendTech(t,{name="warptorio-physdmg-3",unit={count=400,time=30},prerequisites={"warptorio-reactor-3","warptorio-physdmg-2","physical-projectile-damage-3"}}, {red=3,green=2,black=1} )

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/toolbelt.png",tint={r=0.3,g=0.3,b=1,a=1}} },
	effects={ {type="character-inventory-slots-bonus",modifier=10} }, }
ExtendTech(t,{name="warptorio-toolbelt-1",unit={count=70,time=30},prerequisites={}}, {red=1})
ExtendTech(t,{name="warptorio-toolbelt-2",unit={count=120,time=30},prerequisites={"warptorio-toolbelt-1","toolbelt","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-toolbelt-3",unit={count=150,time=30},prerequisites={"warptorio-toolbelt-2","chemical-science-pack"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-toolbelt-4",unit={count=180,time=30},prerequisites={"warptorio-toolbelt-3","production-science-pack"}}, {red=3,green=2,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-toolbelt-5",unit={count=200,time=30},prerequisites={"warptorio-toolbelt-4","utility-science-pack"}}, {red=4,green=3,blue=2,purple=2,yellow=1} )

local t={type="technology",upgrade=true,icons={
	{icon="__warptorio2__/graphics/technology/earth.png",tint={r=0.7,g=0.7,b=1,a=1},shift={0,0},scale=0.375,priority="medium",icon_size=128},
	{icon="__base__/graphics/icons/steel-axe.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low",icon_size=32},
	},
	effects={ {type="character-reach-distance",modifier=1} },
}
ExtendTech(t,{name="warptorio-reach-1",unit={count=70,time=30},prerequisites={}}, {red=1})
ExtendTech(t,{name="warptorio-reach-2",unit={count=120,time=30},prerequisites={"warptorio-reach-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-reach-3",unit={count=150,time=30},prerequisites={"warptorio-reach-2","chemical-science-pack"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-reach-4",unit={count=180,time=30},prerequisites={"warptorio-reach-3","production-science-pack"}}, {red=3,green=2,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-reach-5",unit={count=200,time=30},prerequisites={"warptorio-reach-4","utility-science-pack"}}, {red=4,green=3,blue=2,purple=2,yellow=1} )


-- ----
-- Platform Size

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/concrete.png",tint={r=0.3,g=0.3,b=1,a=1}} }, }
ExtendTech(t,{name="warptorio-platform-size-1", unit={count=80,time=20}, prerequisites={}}, {red=1} )
ExtendTech(t,{name="warptorio-platform-size-2", unit={count=120,time=20}, prerequisites={"warptorio-platform-size-1"}}, {red=1} )
ExtendTech(t,{name="warptorio-platform-size-3", unit={count=150,time=40}, prerequisites={"warptorio-platform-size-2","logistic-science-pack"}}, {red=1,green=1} )
ExtendTech(t,{name="warptorio-platform-size-4", unit={count=250,time=30}, prerequisites={"concrete","warptorio-platform-size-3"}}, {red=1,green=1} )
ExtendTech(t,{name="warptorio-platform-size-5", unit={count=120,time=30}, prerequisites={"chemical-science-pack","warptorio-platform-size-4"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-platform-size-6", unit={count=150,time=30}, prerequisites={"warptorio-platform-size-5","solar-energy","production-science-pack"}}, {red=2,green=2,blue=1,purple=1} )
ExtendTech(t,{name="warptorio-platform-size-7", unit={count=150,time=30}, prerequisites={"warptorio-platform-size-6","utility-science-pack"}}, {red=2,green=2,blue=1,purple=1,yellow=1} )


-- ----
-- Train Stops


for v,w in pairs({nw={-38,-38},ne={38,-38},se={38,38},sw={-38,38}})do
local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/railway.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/railway.png",tint={r=0.7,g=0.7,b=1,a=0.9},shift={w[1],w[2]},scale=0.45,priority="high"},
}, }

ExtendTech(t,{name="warptorio-rail-"..v, unit={count=500,time=40}, prerequisites={"railway","warptorio-platform-size-6","warptorio-factory-7"}}, {red=1,green=1,black=1,blue=1,purple=1,yellow=1} )
end


-- ----
-- Castle Ramps


for v,w in pairs({nw={-38,-38},ne={38,-38},se={38,38},sw={-38,38}})do
local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.7,g=0.7,b=1,a=0.9},shift={w[1],w[2]},scale=0.45,priority="high"},
}, }
ExtendTech(t,{name="warptorio-turret-"..v.."-0",upgrade=false, unit={count=150,time=40}, prerequisites={"gates","military-science-pack","warptorio-factory-0"}}, {red=1,green=1,black=1} )
ExtendTech(t,{name="warptorio-turret-"..v.."-1", unit={count=300,time=40}, prerequisites={"warptorio-turret-"..v.."-0","land-mine"}}, {red=2,green=1,black=1,} )
ExtendTech(t,{name="warptorio-turret-"..v.."-2", unit={count=400,time=30}, prerequisites={"warptorio-turret-"..v.."-1","chemical-science-pack"}}, {red=2,green=1,black=1,blue=1} )
ExtendTech(t,{name="warptorio-turret-"..v.."-3", unit={count=500,time=40}, prerequisites={"warptorio-turret-"..v.."-2","production-science-pack"}}, {red=2,green=2,black=1,blue=1,purple=1} )
end

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.7,g=0.7,b=1,a=0.9},shift={38,38},scale=0.45,priority="high"},
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.7,g=0.7,b=1,a=0.9},shift={-38,-38},scale=0.45,priority="high"},
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.7,g=0.7,b=1,a=0.9},shift={-38,38},scale=0.45,priority="high"},
	{icon="__base__/graphics/technology/stone-walls.png",tint={r=0.7,g=0.7,b=1,a=0.9},shift={38,-38},scale=0.45,priority="high"},
}, }
ExtendTech(t,{name="warptorio-bridgesize-1",unit={count=700,time=40},prerequisites={"warptorio-turret-nw-0","warptorio-turret-ne-0","warptorio-turret-se-0","warptorio-turret-sw-0"},
		unit={count=200,time=40}},{red=1,green=1,black=1})
ExtendTech(t,{name="warptorio-bridgesize-2",unit={count=700,time=40},prerequisites={"warptorio-bridgesize-1","warptorio-turret-nw-1","warptorio-turret-ne-1","warptorio-turret-se-1","warptorio-turret-sw-1","low-density-structure"},
		unit={count=400,time=40}},{red=1,green=1,black=1,blue=1})

-- ----
-- Factory Floor Upgrades

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/automation.png",tint={r=0.3,g=0.3,b=1,a=1}}
}, }
ExtendTech(t,{name="warptorio-factory-0",unit={count=80,time=20}, prerequisites={"automation","warptorio-platform-size-1"}, upgrade=false}, {red=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/automation.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={32,32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-factory-1",unit={count=120,time=20}, prerequisites={"warptorio-factory-0","steel-processing"}}, {red=1})
ExtendTech(t,{name="warptorio-factory-2",unit={count=150,time=15}, prerequisites={"electric-energy-distribution-1","advanced-material-processing","automation-2","warptorio-factory-1"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-factory-3",unit={count=180,time=20}, prerequisites={"warptorio-factory-2","sulfur-processing"}}, {red=2,green=2})
ExtendTech(t,{name="warptorio-factory-4",unit={count=220,time=25}, prerequisites={"warptorio-factory-3","chemical-science-pack","modules"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-factory-5",unit={count=250,time=20}, prerequisites={"warptorio-factory-4","advanced-material-processing-2"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-factory-6",unit={count=300,time=20}, prerequisites={"warptorio-factory-5","automation-3"}}, {red=2,green=2,blue=1,purple=1})
ExtendTech(t,{name="warptorio-factory-7",unit={count=350,time=20}, prerequisites={"warptorio-factory-6","utility-science-pack","effect-transmission"}}, {red=2,green=3,blue=1,purple=1,yellow=1})

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/automation.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={0,-32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-factory-n",unit={count=1000,time=30}, prerequisites={"warptorio-factory-7","space-science-pack","warptorio-bridgesize-2"}}, {red=3,green=2,blue=3,purple=2,yellow=1,white=1})
local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/automation.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={0,32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-factory-s",unit={count=1000,time=30}, prerequisites={"warptorio-factory-7","space-science-pack","warptorio-bridgesize-2"}}, {red=3,green=2,blue=3,purple=2,yellow=1,white=1})
local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/automation.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={32,0},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-factory-e",unit={count=1000,time=30}, prerequisites={"warptorio-factory-7","space-science-pack","warptorio-bridgesize-2"}}, {red=3,green=2,blue=3,purple=2,yellow=1,white=1})
local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/automation.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={-32,0},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-factory-w",unit={count=1000,time=30}, prerequisites={"warptorio-factory-7","space-science-pack","warptorio-bridgesize-2"}}, {red=3,green=2,blue=3,purple=2,yellow=1,white=1})

-- ----
-- Boiler Room Upgrades

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1}}
}, }
ExtendTech(t,{name="warptorio-boiler-0",unit={count=100,time=30}, prerequisites={"steel-processing","warptorio-factory-0"},upgrade=false}, {red=1})

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={32,32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-boiler-1",unit={count=100,time=30}, prerequisites={"warptorio-boiler-0","fluid-handling"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-boiler-2",unit={count=200,time=30}, prerequisites={"warptorio-boiler-1","flammables"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-boiler-3",unit={count=300,time=30}, prerequisites={"warptorio-boiler-2","laser","electric-engine"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-boiler-4",unit={count=150,time=30}, prerequisites={"warptorio-boiler-3","chemical-science-pack"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-boiler-5",unit={count=200,time=30}, prerequisites={"warptorio-boiler-4","production-science-pack"}}, {red=2,green=2,blue=1,purple=1})
ExtendTech(t,{name="warptorio-boiler-6",unit={count=300,time=30}, prerequisites={"warptorio-boiler-5","nuclear-fuel-reprocessing"}}, {red=2,green=2,blue=1,purple=1,})
ExtendTech(t,{name="warptorio-boiler-7",unit={count=300,time=30}, prerequisites={"warptorio-boiler-6","utility-science-pack"}}, {red=2,green=2,blue=1,purple=1,yellow=1})


local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/oil-gathering.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={32,32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-boiler-water-1",upgrade=true,unit={count=500,time=30}, prerequisites={"warptorio-boiler-6","landfill"}}, {red=2,green=2,blue=1,purple=1})
ExtendTech(t,{name="warptorio-boiler-water-2",upgrade=true,unit={count=500,time=30}, prerequisites={"warptorio-boiler-7","warptorio-boiler-water-1"}}, {red=2,green=2,blue=1,purple=1,yellow=1})

ExtendTech(t,{name="warptorio-boiler-water-3",upgrade=true,unit={count=2000,time=30}, prerequisites={"warptorio-boiler-water-2","space-science-pack"}}, {red=1,green=1,blue=1,purple=1,yellow=1,white=1})

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={0,-32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-boiler-n",unit={count=1000,time=30}, prerequisites={"warptorio-boiler-7","space-science-pack"}}, {red=3,green=2,blue=2,purple=2,yellow=1,white=1})

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={0,32},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-boiler-s",unit={count=1000,time=30}, prerequisites={"warptorio-boiler-7","space-science-pack"}}, {red=3,green=2,blue=2,purple=2,yellow=1,white=1})
local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={32,0},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-boiler-e",unit={count=1000,time=30}, prerequisites={"warptorio-boiler-7","space-science-pack"}}, {red=3,green=2,blue=2,purple=2,yellow=1,white=1})
local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.3,g=0.3,b=1,a=1}},
	{icon="__base__/graphics/technology/concrete.png",tint={r=0.7,g=0.7,b=1,a=0.9},priority="medium",shift={-32,0},scale=0.5},
}, }
ExtendTech(t,{name="warptorio-boiler-w",unit={count=1000,time=30}, prerequisites={"warptorio-boiler-7","space-science-pack"}}, {red=3,green=2,blue=2,purple=2,yellow=1,white=1})


-- ----
-- Logistics

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/logistics.png",tint={r=0.3,g=0.3,b=1,a=1}},
	},
}
ExtendTech(t,{name="warptorio-logistics-1", unit={count=100,time=20}, prerequisites={"logistics","warptorio-factory-0"},upgrade=false}, {red=1} )
ExtendTech(t,{name="warptorio-logistics-2", unit={count=200,time=20}, prerequisites={"logistics-2","warptorio-logistics-1"}}, {red=2,green=1} )
ExtendTech(t,{name="warptorio-logistics-3", unit={count=300,time=20}, prerequisites={"logistics-3","warptorio-logistics-2"}}, {red=2,green=2,blue=1,purple=1} )
ExtendTech(t,{name="warptorio-logistics-4", unit={count=400,time=20}, prerequisites={"logistic-system","warptorio-logistics-3"}}, {red=2,green=2,blue=1,purple=1,yellow=1} )

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/logistics.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/logistics.png",tint={r=1,g=1,b=0.7,a=0.9},shift={24,24},scale=0.4,priority="medium"},
	{icon="__base__/graphics/technology/logistics.png",tint={r=1,g=1,b=0.7,a=0.9},shift={-24,24},scale=0.4,priority="medium"},
	},
}
ExtendTech(t,{name="warptorio-dualloader-1", unit={count=1000,time=10}, prerequisites={"logistics-2","warptorio-logistics-1"}}, {red=1,green=1} )
--ExtendTech(t,{name="warptorio-dualloader-2", unit={count=1000,time=15}, prerequisites={"logistics-2","warptorio-dualloader-1"}}, {red=2,green=1} )
--ExtendTech(t,{name="warptorio-dualloader-3", unit={count=1000,time=20}, prerequisites={"logistics-3","warptorio-dualloader-2","production-science-pack"}}, {red=3,green=2,blue=1,purple=1} )
t.upgrade=false

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/logistics.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__base__/graphics/technology/logistics.png",tint={r=1,g=1,b=0.7,a=0.9},shift={-28,-12},scale=0.4,priority="medium"},
	{icon="__base__/graphics/technology/logistics.png",tint={r=1,g=1,b=0.7,a=0.9},shift={28,-12},scale=0.4,priority="medium"},
	{icon="__base__/graphics/technology/logistics.png",tint={r=1,g=1,b=0.7,a=0.9},shift={0,32},scale=0.4,priority="high"},
	},
}
ExtendTech(t,{name="warptorio-triloader", unit={count=10000,time=10}, prerequisites={"warptorio-logistics-1"}}, {red=1} )



-- ----
-- Warp Loader

local t={type="technology",upgrade=false,icon_size=128,icons={
	{icon="__base__/graphics/technology/logistics.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low"},
	{icon="__warptorio2__/graphics/technology/earth.png",tint={r=0.8,g=0.8,b=1,a=1},scale=0.5,shift={32,32},priority="high"}
	}, effects={ {recipe="warptorio-warploader",type="unlock-recipe"} },
}
ExtendTech(t,{name="warptorio-warploader", unit={count=10000,time=10}, prerequisites={"warptorio-armor","warptorio-warpmodule","warptorio-warpnuke","warptorio-warpport"}}, {red=1,green=1,blue=1,purple=1,yellow=1,white=1} )



-- ----
-- Energy Upgrades

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/electric-energy-acumulators.png",tint={r=0.3,g=0.3,b=1,a=1}} }, }
ExtendTech(t,{name="warptorio-energy-1",unit={count=30,time=20}, prerequisites={"warptorio-factory-0"},upgrade=false}, {red=1})
ExtendTech(t,{name="warptorio-energy-2",unit={count=100,time=25}, prerequisites={"warptorio-energy-1","electric-energy-distribution-1"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-energy-3",unit={count=150,time=30}, prerequisites={"warptorio-energy-2","advanced-electronics"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-energy-4",unit={count=200,time=35}, prerequisites={"warptorio-energy-3","electric-energy-distribution-2","advanced-electronics-2"}}, {red=1,green=1,blue=1})
ExtendTech(t,{name="warptorio-energy-5",unit={count=250,time=40}, prerequisites={"warptorio-energy-4","utility-science-pack","production-science-pack"}}, {red=1,green=1,blue=1,purple=1,yellow=1})

-- ----
-- Teleporter

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/research-speed.png",tint={r=0.3,g=0.3,b=1,a=1}} }, }
ExtendTech(t,{name="warptorio-teleporter-0",unit={count=30,time=20}, prerequisites={"warptorio-factory-0","electronics",},upgrade=false}, {red=1})
ExtendTech(t,{name="warptorio-teleporter-1",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-0","electric-energy-distribution-1"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-teleporter-2",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-1","advanced-electronics"}}, {red=2,green=2,})
ExtendTech(t,{name="warptorio-teleporter-3",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-2","electric-energy-distribution-2","advanced-electronics-2"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-teleporter-4",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-3","nuclear-power"}}, {red=2,green=2,blue=2,})
ExtendTech(t,{name="warptorio-teleporter-5",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-4","utility-science-pack","production-science-pack"}}, {red=2,green=3,blue=2,purple=1,yellow=1})


-- ----
-- Beacon

local t={type="technology",upgrade=true,icon_size=32,icons={ {icon="__base__/graphics/icons/beacon.png",tint={r=0.3,g=0.3,b=1,a=1}} }, }
ExtendTech(t,{name="warptorio-beacon-1",unit={count=300,time=20}, prerequisites={"modules","warptorio-factory-0"},upgrade=false}, {red=1,green=1})
ExtendTech(t,{name="warptorio-beacon-2",unit={count=500,time=20}, prerequisites={"warptorio-beacon-1","speed-module","productivity-module","effectivity-module"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-beacon-3",unit={count=300,time=20}, prerequisites={"warptorio-beacon-2","speed-module-2","productivity-module-2","effectivity-module-2"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-beacon-4",unit={count=500,time=20}, prerequisites={"warptorio-beacon-3","speed-module-3","productivity-module-3","effectivity-module-3"}}, {red=2,green=2,blue=1,purple=1})
ExtendTech(t,{name="warptorio-beacon-5",unit={count_formula="250+50*L",time=20},max_level=10, prerequisites={"warptorio-beacon-4","utility-science-pack"}}, {red=2,green=2,blue=1,purple=1,yellow=1})


-- ----
-- Radar

--[[
local t={type="technology",icon_size=128,icons={ {icon="__base__/graphics/technology/radar.png",tint={r=0.3,g=0.3,b=1,a=1}} }, }
ExtendTech(t,{name="warptorio-radar-1",unit={count=300,time=15},prerequisites={"radar","chemical-science-pack","optics"}}, {red=1,green=1})
]]


-- ----
-- Warp Armor
local t={type="technology",icon_size=128,icons={ {icon="__base__/graphics/technology/power-armor-mk2.png",tint={r=0.3,g=0.3,b=1,a=1}},},prerequisites={"power-armor-mk2","warptorio-reactor-8","space-science-pack"} }
ExtendTech(t,{name="warptorio-armor",unit={count=1000,time=60},effects={{recipe="warptorio-armor",type="unlock-recipe"}}},{red=4,green=4,blue=4,black=5,yellow=2,white=1})


data:extend{{type="equipment-grid",name="warptorio-warparmor-grid",equipment_categories={"armor"},height=16,width=16}}
local t=ExtendDataCopy("armor","power-armor-mk2",{name="warptorio-armor",equipment_grid="warptorio-warparmor-grid",
	icon_size=32,icons={{icon="__base__/graphics/icons/power-armor-mk2.png",tint={r=0.3,g=0.3,b=1,a=1},}},inventory_size_bonus=100},false)

local t=ExtendDataCopy("recipe","power-armor-mk2",{name="warptorio-armor",enabled=false,ingredients={{"power-armor-mk2",5},{"power-armor",5},{"modular-armor",5},{"heavy-armor",5},{"light-armor",5}},result="warptorio-armor"})
