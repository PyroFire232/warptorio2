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
local function ExtendRecipeItemFix(t) t.order=t.order or "warptorio" end
local function ExtendDataCopy(a,b,x,ri,tx) local t=MakeDataCopy(a,b,x) if(tx)then for k,v in pairs(tx)do if(v==false)then t[k]=nil else t[k]=v end end end if(ri)then ExtendRecipeItemFix(t) end data:extend{t} return t end


local techPacks={red="automation-science-pack",green="logistic-science-pack",blue="chemical-science-pack",black="military-science-pack",
	purple="production-science-pack",yellow="utility-science-pack",white="space-science-pack"}

local function SciencePacks(x) local t={} for k,v in pairs(x)do table.insert(t,{techPacks[k],v}) end return t end
local function ExtendTech(t,d,s) local x=table.merge(t,d) if(s)then x.unit.ingredients=SciencePacks(s) end data:extend{x} return x end


-- --------
-- Basic Teleporter
--
-- Most other teleporters are based off this one



local t={
	name="warptorio-teleporter-0",
	type="accumulator",
	max_health=500,
	energy_source={type="electric",usage_priority="tertiary",buffer_capacity="2MJ",input_flow_limit="200kW",output_flow_limit="200kW"},
	icon_size=64,
	icons={{icon="__base__/graphics/icons/lab.png",tint={r=0.6,g=0.6,b=1,a=0.6}}},

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
	--minable={mining_time=10,result="warptorio-teleporter-0"},

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
ExtendRecipeItemFix(t)
data:extend{t}


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
	icon_size=32,
	icons={{icon="__base__/graphics/icons/electric-furnace.png",tint={r=0.8,g=0.8,b=1,a=1}}},
	icon=false,
})

local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-1",energy_source={buffer_capacity="10MJ",input_flow_limit="500MW",output_flow_limit="500MW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-2",energy_source={buffer_capacity="50MJ",input_flow_limit="1GW",output_flow_limit="1GW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-3",energy_source={buffer_capacity="100MJ",input_flow_limit="2GW",output_flow_limit="2GW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-4",energy_source={buffer_capacity="500MJ",input_flow_limit="5GW",output_flow_limit="5GW"},},true)
local t=ExtendDataCopy("accumulator","warptorio-underground-0",{name="warptorio-underground-5",energy_source={buffer_capacity="1GJ",input_flow_limit="20GW",output_flow_limit="20GW"},},true)



-- Do icon based stairs





-- ----
-- Warp Accumulator

local rtint={r=0.4,g=0.4,b=1,a=1}
local t=ExtendDataCopy("accumulator","accumulator",{name="warptorio-accumulator",
	energy_source={ type="electric", usage_priority="tertiary", emissions_per_minute=5,
		input_flow_limit="5GW", output_flow_limit="5GW", buffer_capacity="1GJ",
	},
	picture={layers={ {tint=rtint,hr_version={tint=rtint},} }},
	minable={mining_time=2,result="warptorio-accumulator"},

	icons={{icon="__base__/graphics/icons/accumulator.png",tint=rtint,icon_size=64,}},
},false,{icon=false})
local name="warptorio-accumulator"
local item=table.deepcopy( data.raw.item.accumulator )
item.name=name item.place_result=name
item.icons={{icon="__base__/graphics/icons/accumulator.png",tint=rtint}}
item.icon=nil
local recipe=table.deepcopy( data.raw.recipe["accumulator"] )
recipe.enabled=false recipe.name=name recipe.result=name
recipe.ingredients={{"accumulator",10},{"solar-panel",10},{"advanced-circuit",20},{"processing-unit",50},{"battery",50},{"nuclear-reactor",1}}
data:extend{item,recipe}

local t={type="technology",upgrade=true,icon_size=128,icons={
	{icon="__base__/graphics/technology/electric-energy-acumulators.png",tint={r=0.3,g=0.3,b=1,a=1},priority="low",icon_size=256,},
}, }
ExtendTech(t,{name="warptorio-accumulator",unit={count=1000,time=5},effects={{recipe="warptorio-accumulator",type="unlock-recipe"}},
	prerequisites={"warptorio-energy-4","warptorio-teleporter-4","production-science-pack"}}, {red=1,green=1,blue=1,purple=1})











