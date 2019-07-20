--require("technology/warp-technology")
require("sound/sound")

local function istable(t) return type(t)=="table" end

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

-- --------
-- Warp Tiles

local t=ExtendDataCopy("tile","tutorial-grid",{name="warp-tile",tint={r=0.6,g=0.6,b=0.7,a=1},decorative_removal_probability=1,walking_speed_modifier=1.6})

-- ----
-- Logistics

local t=ExtendDataCopy("pipe-to-ground","pipe-to-ground",{name="warptorio-logistics-pipe",fluid_box={base_area=50,pipe_connections={[2]={max_underground_distance=1}}},
	pictures={ left={ tint={r=0.8,g=0.8,b=1,a=1},hr_version={tint={r=0.8,g=0.8,b=1,a=1}},}, right={ tint={r=0.8,g=0.8,b=1,a=1},hr_version={{r=0.8,g=0.8,b=1,a=1}},}, },
},true)


-- --------
-- Warp Reactor

-- Fuel
data:extend{{type="fuel-category", name="warp"}}
ExtendDataCopy("item","uranium-fuel-cell",{name="warptorio-reactor-fuel-cell",fuel_category="warp",burnt_result="uranium-fuel-cell",fuel_value="4GJ",stack_size=50,
	icon_size=32,icons={ {icon="__base__/graphics/icons/uranium-fuel-cell.png",tint={r=1,g=0,b=0.1,a=0.8}}, }, })
ExtendDataCopy("recipe","uranium-fuel-cell",{name="warptorio-reactor-fuel-cell",enabled=false,result="warptorio-reactor-fuel-cell"})

-- The Reactor Itself
local t=ExtendDataCopy("reactor","nuclear-reactor",{name="warptorio-reactor",max_health=5000,neighbour_bonus=6,consumption="20MW",
	energy_source={fuel_category="warp"},heat_buffer={specific_heat="1MJ"}, light={ intensity=10, size=9.9, shift={0.0,0.0}, color={r=1.0,g=0.0,b=0.0} },
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

	collision_box={{-1.01,-1.01}, {1.01,1.01}}, selection_box={{-1.5,-1.5}, {1.5,1.5}},
	charge_cooldown=30, charge_light={intensity=0.3,size=7,color={r=1.0,g=1.0,b=1.0}},
	discharge_cooldown=60, discharge_light={intensity=0.7,size=7,color={r=1.0,g=1.0,b=1.0}},
	circuit_wire_connection_point=circuit_connector_definitions["accumulator"].points,
	circuit_connector_sprites=circuit_connector_definitions["accumulator"].sprites,
	circuit_wire_max_distance=default_circuit_wire_max_distance,
	default_output_signal={type="virtual", name="signal-A"},
	vehicle_impact_sound={ filename="__base__/sound/car-metal-impact.ogg", volume=0.65 },

	maximum_wire_distance=7.5,
	supply_area_distance=2.5,
	


	picture={ layers={
		[1]={	filename="__base__/graphics/entity/lab/lab.png", tint={r=0.6,g=0.6,b=1,a=0.6},
			width=98, height=87, frame_count=33, animation_speed=1/3, line_length=11, shift=util.by_pixel(0,1.5),
			hr_version={ filename="__base__/graphics/entity/lab/hr-lab.png", scale=0.5, tint={r=0.6,g=0.6,b=1,a=0.6},
				width=194, height=174, frame_count=33,animation_speed=1/3, line_length=11, shift=util.by_pixel(0, 1.5),
			},
		},
		[2]={	filename="__base__/graphics/entity/lab/lab-shadow.png", draw_as_shadow=true, scale=0.5,
			width=122, height=68, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(13,11),
			hr_version ={filename="__base__/graphics/entity/lab/hr-lab-shadow.png", draw_as_shadow=true, scale=0.5,
				width=242, height=136, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(13, 11),
			},
		},	
		[3]={	filename="__base__/graphics/entity/lab/lab-integration.png",
			width=122, height=81, frame_count=1, line_length=1, repeat_count=33, animation_speed=1/3, shift=util.by_pixel(0, 15.5),
			hr_version={ filename="__base__/graphics/entity/lab/hr-lab-integration.png", scale=0.5,
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
		[1]={ tint={r=0.8,g=0.8,b=1,a=1},
			filename="__base__/graphics/entity/electric-furnace/electric-furnace-base.png", priority="high", width=129, height=100, frame_count=1, shift={0.421875, 0},
			hr_version={ filename="__base__/graphics/entity/electric-furnace/hr-electric-furnace.png", tint={r=0.8,g=0.8,b=1,a=1},
				scale=0.5, priority="high", width=239, height=219, frame_count=1, shift=util.by_pixel(0.75, 5.75), 
			},
		},
		[2]={
			filename="__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png", draw_as_shadow=true,
			priority="high", width=129, height=100, frame_count=1, shift={0.421875,0},
			hr_version={	filename="__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
				priority="high", width=227, height=171, frame_count=1, draw_as_shadow=true, shift=util.by_pixel(11.25, 7.75), scale=0.5,
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
	base_picture={ tint={r=0.5,g=0.7,b=1,a=1}, }, animation={ tint={r=1,g=0.2,b=0.2,a=0.8}, },
	allowed_effects={"consumption","speed","pollution","productivity"},
	distribution_effectivity=1,
},true)
for i=2,50,1 do local xt=table.deepcopy(t) xt.name="warptorio-beacon-"..i xt.supply_area_distance=math.min(16+4*i,64) xt.module_specification.module_slots=i data:extend{xt} ExtendRecipeItem(xt) end


-- ----
-- Stabilizers
--[[ this stuff is stupid
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


-- ----
-- Warp Accelerator

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


-- --------
-- Technologies

local techPacks={red="automation-science-pack",green="logistic-science-pack",blue="chemical-science-pack",black="military-science-pack",
	purple="production-science-pack",yellow="utility-science-pack",white="space-science-pack"}

local function SciencePacks(x) local t={} for k,v in pairs(x)do table.insert(t,{techPacks[k],v}) end return t end
local function ExtendTech(t,d,s) local x=table.merge(t,d) if(s)then x.unit.ingredients=SciencePacks(s) end data:extend{x} return x end


-- ----
-- Warp Energy

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/nuclear-power.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-reactor-1",unit={count=100,time=30}, prerequisites={"automation"}}, {red=1})
ExtendTech(t,{name="warptorio-reactor-2",unit={count=200,time=30}, prerequisites={"warptorio-reactor-1"}}, {red=1})
ExtendTech(t,{name="warptorio-reactor-3",unit={count=300,time=30}, prerequisites={"warptorio-reactor-2"}}, {red=1})

-- ----
-- Sandbox Boosts

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/mining-productivity.png",tint={r=0.2,g=0.2,b=1,a=0.8}} },
	effects={ {type="mining-drill-productivity-bonus",modifier=0.1}}, }
ExtendTech(t,{name="warptorio-mining-prod-1",unit={count_formula="20*L",time=30},max_level=5}, {red=1})
ExtendTech(t,{name="warptorio-mining-prod-6",unit={count_formula="(20*L)-50",time=30},max_level=10,prerequisites={"warptorio-mining-prod-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-mining-prod-11",unit={count_formula="(20*L)-100",time=30},max_level=15,prerequisites={"warptorio-mining-prod-6","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-mining-prod-16",unit={count_formula="(20*L)-150",time=30},max_level=20,prerequisites={"warptorio-mining-prod-11","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-mining-prod-21",unit={count_formula="(20*L)-200",time=30},max_level=25,prerequisites={"warptorio-mining-prod-16","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )

local t={type="technology",upgrade=true,icon_size=32,icons={ {icon="__base__/graphics/icons/steel-axe.png",tint={r=0.2,g=0.2,b=1,a=0.8}} },
	effects={ {type="character-mining-speed",modifier=0.5}}, }
ExtendTech(t,{name="warptorio-axe-speed-1",unit={count_formula="20*L",time=30},max_level=5}, {red=1})
ExtendTech(t,{name="warptorio-axe-speed-6",unit={count_formula="(20*L)-50",time=30},max_level=10,prerequisites={"warptorio-axe-speed-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-axe-speed-11",unit={count_formula="(20*L)-100",time=30},max_level=15,prerequisites={"warptorio-axe-speed-6","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-axe-speed-16",unit={count_formula="(20*L)-150",time=30},max_level=20,prerequisites={"warptorio-axe-speed-11","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-axe-speed-21",unit={count_formula="(20*L)-200",time=30},max_level=25,prerequisites={"warptorio-axe-speed-16","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/inserter-capacity.png",tint={r=0.2,g=0.2,b=1,a=0.8}} },
	effects={ {type="stack-inserter-capacity-bonus",modifier=1}, {type="inserter-stack-size-bonus",modifier=1},} }
ExtendTech(t,{name="warptorio-inserter-cap-1",unit={count_formula="20*L",time=30},max_level=3}, {red=1})
ExtendTech(t,{name="warptorio-inserter-cap-4",unit={count_formula="(20*L)-50",time=30},max_level=6,prerequisites={"warptorio-inserter-cap-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-inserter-cap-7",unit={count_formula="(20*L)-100",time=30},max_level=10,prerequisites={"warptorio-inserter-cap-4","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-inserter-cap-11",unit={count_formula="(20*L)-150",time=30},max_level=13,prerequisites={"warptorio-inserter-cap-7","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-inserter-cap-14",unit={count_formula="(20*L)-200",time=30},max_level=16,prerequisites={"warptorio-inserter-cap-11","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )


local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/worker-robots-speed.png",tint={r=0.2,g=0.2,b=1,a=0.8}} },
	effects={ {type="worker-robot-speed",modifier=0.4},} }
ExtendTech(t,{name="warptorio-bot-speed-1",unit={count_formula="20*L",time=30},max_level=3,prerequisites={"robotics"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-bot-speed-4",unit={count_formula="(20*L)-50",time=30},max_level=6,prerequisites={"warptorio-bot-cap-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-bot-speed-7",unit={count_formula="(20*L)-100",time=30},max_level=10,prerequisites={"warptorio-bot-cap-4","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-bot-speed-11",unit={count_formula="(20*L)-150",time=30},max_level=13,prerequisites={"warptorio-bot-cap-7","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-bot-speed-14",unit={count_formula="(20*L)-200",time=30},max_level=16,prerequisites={"warptorio-bot-cap-11","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/worker-robots-storage.png",tint={r=0.2,g=0.2,b=1,a=0.8}} },
	effects={ {type="worker-robot-storage",modifier=1}, } }
ExtendTech(t,{name="warptorio-bot-cap-1",unit={count_formula="20*L",time=30},max_level=3,prerequisites={"robotics"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-bot-cap-4",unit={count_formula="(20*L)-50",time=30},max_level=6,prerequisites={"warptorio-bot-cap-1","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-bot-cap-7",unit={count_formula="(20*L)-100",time=30},max_level=10,prerequisites={"warptorio-bot-cap-4","chemical-science-pack"}}, {red=3,green=2,blue=1} )
ExtendTech(t,{name="warptorio-bot-cap-11",unit={count_formula="(20*L)-150",time=30},max_level=13,prerequisites={"warptorio-bot-cap-7","production-science-pack"}}, {red=4,green=3,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-bot-cap-14",unit={count_formula="(20*L)-200",time=30},max_level=16,prerequisites={"warptorio-bot-cap-11","utility-science-pack"}}, {red=5,green=4,blue=3,purple=2,yellow=1} )



local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/toolbelt.png",tint={r=0.2,g=0.2,b=1,a=0.8}} },
	effects={ {type="character-inventory-slots-bonus",modifier=10} }, }
ExtendTech(t,{name="warptorio-toolbelt-1",unit={count=70,time=30},prerequisites={}}, {red=1})
ExtendTech(t,{name="warptorio-toolbelt-2",unit={count=120,time=30},prerequisites={"warptorio-toolbelt-1","toolbelt","logistic-science-pack"}}, {red=2,green=1})
ExtendTech(t,{name="warptorio-toolbelt-3",unit={count=150,time=30},prerequisites={"warptorio-toolbelt-2","chemical-science-pack"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-toolbelt-4",unit={count=180,time=30},prerequisites={"warptorio-toolbelt-3","production-science-pack"}}, {red=3,green=2,blue=2,purple=1} )
ExtendTech(t,{name="warptorio-toolbelt-5",unit={count=200,time=30},prerequisites={"warptorio-toolbelt-4","utility-science-pack"}}, {red=4,green=3,blue=2,purple=2,yellow=1} )

-- ----
-- Platform Size

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/concrete.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-platform-size-1", unit={count=20,time=20}, prerequisites={}}, {red=1} )
ExtendTech(t,{name="warptorio-platform-size-2", unit={count=100,time=20}, prerequisites={"warptorio-platform-size-1"}}, {red=1} )
ExtendTech(t,{name="warptorio-platform-size-3", unit={count=120,time=40}, prerequisites={"warptorio-platform-size-2"}}, {red=2,green=1} )
ExtendTech(t,{name="warptorio-platform-size-4", unit={count=140,time=30}, prerequisites={"concrete","warptorio-platform-size-3"}}, {red=2,green=2} )
ExtendTech(t,{name="warptorio-platform-size-5", unit={count=160,time=30}, prerequisites={"warptorio-platform-size-4"}}, {red=3,green=3,blue=1} )
ExtendTech(t,{name="warptorio-platform-size-6", unit={count=200,time=30}, prerequisites={"warptorio-platform-size-5"}}, {red=3,green=3,blue=2} )
ExtendTech(t,{name="warptorio-platform-size-7", unit={count=300,time=30}, prerequisites={"warptorio-platform-size-6"}}, {red=4,green=3,blue=2,black=1,yellow=1} )


-- ----
-- Castle Ramps

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/stone-walls.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
for k,v in pairs({"nw","ne","se","sw"})do
ExtendTech(t,{name="warptorio-turret-"..v.."-0", unit={count=200,time=40}, prerequisites={"stone-walls"}}, {red=1,green=1,black=1} )
ExtendTech(t,{name="warptorio-turret-"..v.."-1", unit={count=300,time=40}, prerequisites={"warptorio-turret-"..v.."-0"}}, {red=1,green=1,black=1,blue=1,} )
ExtendTech(t,{name="warptorio-turret-"..v.."-2", unit={count=400,time=30}, prerequisites={"warptorio-turret-"..v.."-1"}}, {red=2,green=2,black=2,blue=1,purple=1} )
ExtendTech(t,{name="warptorio-turret-"..v.."-3", unit={count=500,time=40}, prerequisites={"warptorio-turret-"..v.."-2"}}, {red=3,green=3,black=3,blue=2,purple=2,yellow=1} )
end

-- ----
-- Factory Floor Upgrades

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/automation.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-factory-0",unit={count=30,time=20}, prerequisites={"automation","warptorio-platform-size-1"}}, {red=1})
ExtendTech(t,{name="warptorio-factory-1",unit={count=80,time=20}, prerequisites={"warptorio-factory-0"}}, {red=1})
ExtendTech(t,{name="warptorio-factory-2",unit={count=100,time=15}, prerequisites={"automation-2","warptorio-factory-1","warptorio-platform-size-2"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-factory-3",unit={count=140,time=20}, prerequisites={"electric-energy-distribution-1","warptorio-factory-2"}}, {red=2,green=2})
ExtendTech(t,{name="warptorio-factory-4",unit={count=200,time=25}, prerequisites={"warptorio-factory-3"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-factory-5",unit={count=240,time=20}, prerequisites={"warptorio-factory-4"}}, {red=2,green=2,blue=1,purple=1})
ExtendTech(t,{name="warptorio-factory-6",unit={count=290,time=20}, prerequisites={"warptorio-factory-5"}}, {red=2,green=2,blue=1,purple=2})
ExtendTech(t,{name="warptorio-factory-7",unit={count=350,time=20}, prerequisites={"warptorio-factory-6"}}, {red=1,green=3,blue=1,purple=3})


-- ----
-- Boiler Room Upgrades

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/fluid-handling.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-boiler-0",unit={count=50,time=30}, prerequisites={"steel-processing","warptorio-factory-0"}}, {red=1})
ExtendTech(t,{name="warptorio-boiler-1",unit={count=100,time=30}, prerequisites={"warptorio-boiler-0","fluid-handling"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-boiler-2",unit={count=140,time=30}, prerequisites={"warptorio-boiler-1","warptorio-platform-size-2"}}, {red=2,green=2})
ExtendTech(t,{name="warptorio-boiler-3",unit={count=180,time=30}, prerequisites={"warptorio-boiler-2"}}, {red=2,green=2,blue=1})
ExtendTech(t,{name="warptorio-boiler-4",unit={count=200,time=30}, prerequisites={"warptorio-boiler-3"}}, {red=2,green=2,blue=2})
ExtendTech(t,{name="warptorio-boiler-5",unit={count=250,time=30}, prerequisites={"warptorio-boiler-4"}}, {red=2,green=2,blue=3,purple=1})
ExtendTech(t,{name="warptorio-boiler-6",unit={count=300,time=30}, prerequisites={"warptorio-boiler-5"}}, {red=2,green=2,blue=3,purple=1,})
ExtendTech(t,{name="warptorio-boiler-7",unit={count=400,time=30}, prerequisites={"warptorio-boiler-6"}}, {red=3,green=2,blue=3,purple=2,yellow=1})

ExtendTech(t,{name="warptorio-boiler-water-1",upgrade=true,unit={count=700,time=30}, prerequisites={"warptorio-boiler-6"}}, {red=3,green=3,blue=2,purple=3,yellow=1})
ExtendTech(t,{name="warptorio-boiler-water-2",upgrade=true,unit={count=700,time=30}, prerequisites={"warptorio-boiler-7","warptorio-boiler-water-1"}}, {red=3,green=3,blue=2,purple=3,yellow=1})



-- ----
-- Logistics

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/logistics.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-logistics-1", unit={count=100,time=20}, prerequisites={"logistics","warptorio-factory-0"}}, {red=1} )
ExtendTech(t,{name="warptorio-logistics-2", unit={count=150,time=20}, prerequisites={"logistics-2","warptorio-logistics-1"}}, {red=1,green=1} )
ExtendTech(t,{name="warptorio-logistics-3", unit={count=150,time=20}, prerequisites={"logistics-3","warptorio-logistics-2"}}, {red=2,green=2,blue=1} )
ExtendTech(t,{name="warptorio-logistics-4", unit={count=150,time=20}, prerequisites={"logistic-system","warptorio-logistics-3"}}, {red=2,green=2,blue=1,yellow=1} )

--ExtendTech(t,{name="warptorio-duallogistics-1", unit={count=150,time=20}, prerequisites={"logistics-3","warptorio-logistics-3"}}, {red=2} )

-- ----
-- Energy Upgrades

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/electric-energy-acumulators.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-energy-1",unit={count=30,time=20}, prerequisites={"warptorio-factory-0"}}, {red=1})
ExtendTech(t,{name="warptorio-energy-2",unit={count=30,time=25}, prerequisites={"warptorio-energy-1"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-energy-3",unit={count=30,time=30}, prerequisites={"warptorio-energy-2"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-energy-4",unit={count=30,time=35}, prerequisites={"warptorio-energy-3"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-energy-5",unit={count=30,time=40}, prerequisites={"warptorio-energy-4"}}, {red=1,green=1})

-- ----
-- Teleporter

local t={type="technology",upgrade=true,icon_size=128,icons={ {icon="__base__/graphics/technology/research-speed.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-teleporter-0",unit={count=30,time=20}, prerequisites={"warptorio-factory-0","electronics",}}, {red=1})
ExtendTech(t,{name="warptorio-teleporter-1",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-0"}}, {red=1,green=1})
ExtendTech(t,{name="warptorio-teleporter-2",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-1"}}, {red=2,green=2,})
ExtendTech(t,{name="warptorio-teleporter-3",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-2"}}, {red=2,green=2,blue=1,})
ExtendTech(t,{name="warptorio-teleporter-4",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-3"}}, {red=2,green=2,blue=2,})
ExtendTech(t,{name="warptorio-teleporter-5",unit={count=30,time=20}, prerequisites={"warptorio-teleporter-4"}}, {red=2,green=3,blue=2,yellow=1})


-- ----
-- Beacon

local t={type="technology",upgrade=true,icon_size=32,icons={ {icon="__base__/graphics/icons/beacon.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-beacon-1",unit={count=100,time=20}, prerequisites={"warptorio-factory-2"}}, {red=3,green=2,blue=1})
ExtendTech(t,{name="warptorio-beacon-2",unit={count=150,time=20}, prerequisites={"warptorio-beacon-1"}}, {red=3,green=2,blue=1})
ExtendTech(t,{name="warptorio-beacon-3",unit={count_formula="150+10*L",time=20},max_level=17, prerequisites={"warptorio-beacon-2"}}, {red=4,green=2,blue=2,purple=1})


-- ----
-- Radar

local t={type="technology",icon_size=128,icons={ {icon="__base__/graphics/technology/radar.png",tint={r=0.2,g=0.2,b=1,a=0.8}} }, }
ExtendTech(t,{name="warptorio-radar-1",unit={count=300,time=15},prerequisites={"radar","chemical-science-pack","optics"}}, {red=1,green=1})



-- ----
-- Warp Armor
local t={type="technology",icon_size=128,icons={ {icon="__base__/graphics/technology/power-armor-mk2.png",tint={r=0.2,g=0.2,b=1,a=0.8}},},prerequisites={"power-armor-mk2"} }
ExtendTech(t,{name="warptorio-armor-1",unit={count=500,time=60},effects={{recipe="warptorio-armor",type="unlock-recipe"}}},{red=4,green=4,blue=4,black=5,yellow=2})


data:extend{{type="equipment-grid",name="warptorio-warparmor-grid",equipment_categories={"armor"},height=16,width=16}}
local t=ExtendDataCopy("armor","power-armor-mk2",{name="warptorio-armor",equipment_grid="warptorio-warparmor-grid",
	icon_size=32,icons={{icon="__base__/graphics/icons/power-armor-mk2.png",tint={r=0.2,g=0.2,b=1,a=0.8},}},inventory_size_bonus=100},false)

local t=ExtendDataCopy("recipe","power-armor-mk2",{name="warptorio-armor",enabled=true,ingredients={{"power-armor-mk2",5}},result="warptorio-armor"})
