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
	i.flags={"hidden"}
	data:extend{i,r}
end

local function ExtendDataCopy(a,b,x,ri,tx) local t=MakeDataCopy(a,b,x) if(tx)then for k,v in pairs(tx)do if(v==false)then t[k]=nil else t[k]=v end end end
	if(ri)then ExtendRecipeItem(t) elseif(ri==false)then t.order=t.order or "warptorio" end
	data:extend{t} return t
end


local techPacks={red="automation-science-pack",green="logistic-science-pack",blue="chemical-science-pack",black="military-science-pack",
	purple="production-science-pack",yellow="utility-science-pack",white="space-science-pack"}

local function SciencePacks(x) local t={} for k,v in pairs(x)do table.insert(t,{techPacks[k],v}) end return t end
local function ExtendTech(t,d,s) local x=table.merge(t,d) if(s)then x.unit.ingredients=SciencePacks(s) end data:extend{x} return x end



--for k,v in pairs{"nw","sw","se","ne","west","east"}do
local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-harvestportal-0",
	minable={mining_time=5,result="warptorio-harvestportal-1"},energy_source={buffer_capacity="5MJ",input_flow_limit="500kW",output_flow_limit="500kW"}},false)

local t=ExtendDataCopy("accumulator","warptorio-teleporter-0",{name="warptorio-harvestportal-1",
	minable={mining_time=5,result="warptorio-harvestportal-1"},energy_source={buffer_capacity="10MJ",input_flow_limit="500MW",output_flow_limit="500MW"}},true)
local t=ExtendDataCopy("accumulator","warptorio-harvestportal-1",{name="warptorio-harvestportal-2",energy_source={buffer_capacity="50MJ",input_flow_limit="1GW",output_flow_limit="1GW"}},false)
local t=ExtendDataCopy("accumulator","warptorio-harvestportal-1",{name="warptorio-harvestportal-3",energy_source={buffer_capacity="100MJ",input_flow_limit="2GW",output_flow_limit="2GW"}},false)
local t=ExtendDataCopy("accumulator","warptorio-harvestportal-1",{name="warptorio-harvestportal-4",energy_source={buffer_capacity="500MJ",input_flow_limit="5GW",output_flow_limit="5GW"}},false)
local t=ExtendDataCopy("accumulator","warptorio-harvestportal-1",{name="warptorio-harvestportal-5",energy_source={buffer_capacity="1GJ",input_flow_limit="20GW",output_flow_limit="20GW"}},false)

--end



-- Credit to factorissimo2

local F = "__warptorio2__";

require("circuit-connector-sprites")

local function cwc0()
	return {shadow = {red = {0,0},green = {0,0}}, wire = {red = {0,0},green = {0,0}}}
end
local function cc0()
	return get_circuit_connector_sprites({0,0},nil,1)
end
local function blank()
	return {
		filename = "__base__/graphics/terrain/lab-tiles/lab-dark-2.png",
		priority = "high",
		width = 1,
		height = 1,
	}
end
local function ablank()
	return {
		filename = "__base__/graphics/terrain/lab-tiles/lab-dark-2.png",
		priority = "high",
		width = 1,
		height = 1,
		frame_count = 1,
	}
end
local rtint={r=0.6,g=0.6,b=0.8,a=1}


local function makePortal(suffix, visible, sprite,size,vorder,btag)
	local name = "warptorio-harvestpad-" .. suffix
	local localised_name = {"entity-name.warptorio-harvestpad-" .. suffix}
	local result_name = "warptorio-harvestpad-" .. suffix
	local item_flags
	if visible then item_flags = {} else item_flags = {"hidden"} end
	return {
		{
			type = "storage-tank",
			name = name,
			localised_name = localised_name,
			icons = {{icon="__base__/graphics/icons/lab.png",tint=rtint,}},
			icon_size = 64,
			flags = {"player-creation"},
			minable = {mining_time = 5, result = result_name, count = 1},
			max_health = 2000,
			corpse = "big-remnants",
			collision_box = {{-size, -size}, {size, size}},
			selection_box = {{-size, -size}, {size, size}},
			collision_mask={"item-layer","object-layer","water-tile"},
			vehicle_impact_sound = { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
			pictures = {
				picture = {
					sheet = {
						filename = sprite, tint={r=1,g=1,b=1,a=0.3},
						frames = 1,
						width = 32,
						height = 32,scale=size*2,
						shift = {0, 0},
					},
				},
				fluid_background = blank(),
				window_background = blank(),
				flow_sprite = blank(),
				gas_flow = ablank(),
			},
			window_bounding_box = {{0,0},{0,0}},
			fluid_box = {
				base_area = 1,
				pipe_covers = pipecoverspictures(),
				pipe_connections = {},
			},
			flow_length_in_ticks = 1,
			circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
			circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
			circuit_wire_max_distance = 0,
			map_color = {r = 0.8, g = 0.7, b = 0.55},
		},
		{
			flags={"hidden"},
			type = (btag and "item-with-tags" or "item"),
			name = name,
			localised_name = localised_name,
			icons = {{icon="__base__/graphics/icons/lab.png",tint=rtint,}},
			icon_size = 64,
			flags = item_flags,
			subgroup = "storage",
			order = (vorder or "a-a"),
			place_result = name,
			stack_size = 1
		}
	};
end

data:extend(makePortal("nw",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-c"))
data:extend(makePortal("sw",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-f"))
data:extend(makePortal("ne",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-d"))
data:extend(makePortal("se",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-e"))



data:extend(makePortal("west-1",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(12-1)/2,"a-a1"))
data:extend(makePortal("west-2",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-a2"))
data:extend(makePortal("west-3",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(26-1)/2,"a-a3"))
data:extend(makePortal("west-4",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(32-1)/2,"a-a4"))
data:extend(makePortal("west-5",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(38-1)/2,"a-a5"))
data:extend(makePortal("west-6",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(46-1)/2,"a-a6"))

data:extend(makePortal("east-1",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(12-1)/2,"a-b1"))
data:extend(makePortal("east-2",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-b2"))
data:extend(makePortal("east-3",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(26-1)/2,"a-b3"))
data:extend(makePortal("east-4",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(32-1)/2,"a-b4"))
data:extend(makePortal("east-5",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(38-1)/2,"a-b5"))
data:extend(makePortal("east-6",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(46-1)/2,"a-b6"))

data:extend(makePortal("tag-1",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(12-1)/2,"a-c1",true))
data:extend(makePortal("tag-2",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(20-1)/2,"a-c2",true))
data:extend(makePortal("tag-3",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(26-1)/2,"a-c3",true))
data:extend(makePortal("tag-4",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(32-1)/2,"a-c4",true))
data:extend(makePortal("tag-5",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(38-1)/2,"a-c5",true))
data:extend(makePortal("tag-6",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",(46-1)/2,"a-c6",true))


--data:extend(makePortal("giga-west",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",16.5))
--data:extend(makePortal("giga-east",true,"__base__/graphics/terrain/lab-tiles/lab-dark-2.png",16.5))





