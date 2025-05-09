local platform={}
platform.name="classic"

--[[ Offsets and stuff ]]--

platform.railCorner={nw=vector(-35,-35),ne=vector(34,-35),sw=vector(-35,34),se=vector(34,34)}
platform.railOffset={nw=vector(0,0),ne=vector(-1,0),sw=vector(0,-1),se=vector(-1,-1)} --{nw=vector(-1,-1),ne=vector(0,-1),sw=vector(-1,0),se=vector(0,0)}
platform.railLoader={nw=vector.area(vector(2,0),vector(0,2)),sw=vector.area(vector(2,0),vector(0,-2)),ne=vector.area(vector(-2,0),vector(0,2)),se=vector.area(vector(-2,0),vector(0,-2))}

platform.letterOpposite={n=defines.direction.south,s=defines.direction.north,e=defines.direction.west,w=defines.direction.east}
platform.railLoaderPos={
	nw={vector(2,0),vector(2,-1),vector(0,2),vector(-1,2)},
	sw={vector(2,0),vector(2,-1),vector(0,-2),vector(-1,-2)},
	ne={vector(-2,0),vector(-2,-1),vector(0,2),vector(-1,2)},
	se={vector(-2,0),vector(-2,-1),vector(0,-2),vector(-1,-2)},
}

--platform.corner={nw=vector(-52,-52),ne=vector(50,-52),sw=vector(-52,50),se=vector(50,50)} -- old
platform.corner={nw=vector(-51.5,-51.5),ne=vector(50.5,-51.5),sw=vector(-51.5,50.5),se=vector(50.5,50.5)}

platform.side={north=vector(0,-52),south=vector(0,51),east=vector(51,0),west=vector(-52,0)}
--[[
local cirMaxWidth=128+8
local cirHeight=17 --64+4 --17 --
local vz=cirMaxWidth
--local ez=m.harvestSize or 10 -- harvester size max 47
local hvMax=47
local vzx=vz/2 local hvx=hvMax/2 local hvy=hvMax/8

local westPos=warptorio.platform.harvester.west --vector(-(vzx+(hvx-hvy))+0.5,-0.5)
local eastPos=warptorio.platform.harvester.east --vector(vzx+(hvx-hvy),-0.5)
]]
local hvSize=(128+8)/2
local hvMax=47
platform.harvester={}
platform.harvester.east=vector(85.5,-0.5) --hvSize+((hvMax/2)-(hvMax/8)),-0.5) -- 85.625
platform.harvester.west=vector(-86.5,-0.5) -- -(hvSize+((hvMax/2)-(hvMax/8)))+0.5,-0.5) -- -85.125 -- was -86


platform.corn={}
platform.corn.nw={x=-52,y=-52}
platform.corn.ne={x=50,y=-52}
platform.corn.sw={x=-52,y=50}
platform.corn.se={x=50,y=50}
platform.corn.north=-52
platform.corn.south=50
platform.corn.east=50
platform.corn.west=-51.5



--[[ Floors ]]--

platform.floors={}


-- Todo: Make teleporters and specials automatically do hazard tiles

--[[ Platform Technology Effects ]]--

platform.techs={}

-- General technologies

platform.techs.boiler_station={tech="warptorio-boiler-station",effect={special={"boiler"}},}
platform.techs.reactor={tech="warptorio-reactor",level_range={1,8},effect={reactor=true,special={"main"}}, }

platform.techs.tele_portal={tech="warptorio-teleporter-portal",effect={unlock_teleporters={"offworld"},},}
platform.techs.tele_energy={tech="warptorio-teleporter",level_range={1,5},effect={upgrade_energy={"offworld"},},}
platform.techs.energy={tech="warptorio-energy",level_range={1,5},effect={upgrade_energy=true},}
platform.techs.logistics={tech="warptorio-logistics",level_range={1,4},effect={upgrade_logistics=true},}
platform.techs.warp_beacon={tech="warptorio-beacon",level_range={1,10},effect={special={"factory"},},}

platform.techs.dualloader={tech="warptorio-dualloader-1",effect={upgrade_logistics=true},}
platform.techs.triloader={tech="warptorio-triloader",effect={upgrade_logistics=true},}

platform.techs.accelerator={tech="warptorio-accelerator",effect={ability="accelerator"},}
platform.techs.stabilizer={tech="warptorio-stabilizer",effect={ability="stabilizer"},}
platform.techs.charting={tech="warptorio-charting",effect={ability="charting",special={"factory","boiler"}},}


platform.techs.alt_combinator={tech="warptorio-alt-combinator",effect={do_combinators=true},}

platform.techs.homeworld={tech="warptorio-homeworld",effect={unlock_homeworld=true},}

platform.techs.toolbar={tech="warptorio-toolbar",effect={unlock_toolbar=true}}




-- Platform Surface Techs
platform.techs.size={tech="warptorio-platform-size",effect={retile={"main"}},
levels={
	[0]=8,
	[1]=10+7-1,
	[2]=18+7-1,
	[3]=26+7-1,
	[4]=40+7-1,
	[5]=56+7-1+2,
	[6]=74+7-1+2,
	[7]=92+7-1+4,
}}

platform.techs.railnw={tech="warptorio-rail-nw",effect={unlock_rails="nw"},}
platform.techs.railne={tech="warptorio-rail-ne",effect={unlock_rails="ne"},}
platform.techs.railsw={tech="warptorio-rail-sw",effect={unlock_rails="sw"},}
platform.techs.railse={tech="warptorio-rail-se",effect={unlock_rails="se"},}

platform.techs.turret_nw={tech="warptorio-turret-nw",first_effect={unlock_teleporters={"main_tur_factory_nw"}},effect={retile={"main","factory"}},level_range={0,3},}
platform.techs.turret_ne={tech="warptorio-turret-ne",first_effect={unlock_teleporters={"main_tur_factory_ne"}},effect={retile={"main","factory"}},level_range={0,3},}
platform.techs.turret_sw={tech="warptorio-turret-sw",first_effect={unlock_teleporters={"main_tur_factory_sw"}},effect={retile={"main","factory"}},level_range={0,3},}
platform.techs.turret_se={tech="warptorio-turret-se",first_effect={unlock_teleporters={"main_tur_factory_se"}},effect={retile={"main","factory"}},level_range={0,3},}


-- Factory Techs

platform.techs.factory_n={tech="warptorio-factory-n",effect={retile={"factory"}},}
platform.techs.factory_s={tech="warptorio-factory-s",effect={retile={"factory"}},}
platform.techs.factory_e={tech="warptorio-factory-e",effect={retile={"factory"}},}
platform.techs.factory_w={tech="warptorio-factory-w",effect={retile={"factory"}},}
platform.techs.bridgesize={tech="warptorio-bridgesize",level_range={1,2},effect={retile={"factory"}},}


platform.techs.factorysize={tech="warptorio-factory",effect={retile={"factory"}},
first_effect={rehazard={"main"},unlock_teleporters={"main_to_factory"},},
levels={
	[0]=19-1,
	[1]=23-1,
	[2]=31-1,
	[3]=39-1,
	[4]=47-1,
	[5]=55-1,
	[6]=63-1,
	[7]=71+2-1,
},
}


-- Boiler Techs

platform.techs.boiler_water={tech="warptorio-boiler-water",level_range={1,3},effect={retile={"boiler"},},}

platform.techs.boiler_n={tech="warptorio-boiler-n",effect={retile={"boiler"}},}
platform.techs.boiler_s={tech="warptorio-boiler-s",effect={retile={"boiler"}},}
platform.techs.boiler_e={tech="warptorio-boiler-e",effect={retile={"boiler"}},}
platform.techs.boiler_w={tech="warptorio-boiler-w",effect={retile={"boiler"}},}


platform.techs.boilersize={tech="warptorio-boiler",
first_effect={rehazard={"harvester"},unlock_teleporters={"harvester_to_boiler"}},
effect={retile={"boiler"}},
levels={
	[0]=18,
	[1]=24,
	[2]=32,
	[3]=40,
	[4]=48,
	[5]=56,
	[6]=64,
	[7]=72,
},
}


platform.techs.harvesterfloor={tech="warptorio-harvester-floor",effect={retile={"harvester"},unlock_teleporters={"factory_to_harvester"}},
}
platform.techs.harvestersize={tech="warptorio-harvester-size",effect={retile={"harvester"},}, -- oval sizes
levels={
	[0]=vector(19,17),
	[1]=vector(28,22),
	[2]=vector(36,26),
	[3]=vector(48,32),
	[4]=vector(74,40),
	[5]=vector(92,48),
	[6]=vector(112,56),
	[7]=vector(128+8,64),
},
}
platform.techs.harvester_west={tech="warptorio-harvester-west",effect={harvesters={"west"}},
levels={
	[1]=12,
	[2]=20,
	[3]=26,
	[4]=32,
	[5]=38,
},
}
platform.techs.harvester_east={tech="warptorio-harvester-east",effect={harvesters={"east"}},
levels={
	[1]=12,
	[2]=20,
	[3]=26,
	[4]=32,
	[5]=38,
},
}

--unused platform.techs.harvester_west_loader={tech="warptorio-harvester-west-loader",effect={harvesters={"west"}},}
--unused platform.techs.harvester_east_loader={tech="warptorio-harvester-east-loader",effect={harvesters={"east"}},}


--[[ Rails registers ]]--

platform.rails={}
local tpr={key="nw"} platform.rails[tpr.key]=tpr
tpr.railpos=platform.railCorner[tpr.key]+platform.railOffset[tpr.key]
tpr.chestpos=platform.railCorner[tpr.key] --+platform.railOffset[tpr.key]
tpr.floor="factory"
tpr.logs={false,true,true,false}

local tpr={key="ne"} platform.rails[tpr.key]=tpr
tpr.railpos=platform.railCorner[tpr.key]+platform.railOffset[tpr.key]
tpr.chestpos=platform.railCorner[tpr.key] --+platform.railOffset[tpr.key]
tpr.floor="factory"
tpr.logs={false,false,true,true}

local tpr={key="sw"} platform.rails[tpr.key]=tpr
tpr.railpos=platform.railCorner[tpr.key]+platform.railOffset[tpr.key]
tpr.chestpos=platform.railCorner[tpr.key] --+platform.railOffset[tpr.key]
tpr.floor="factory"
tpr.logs={true,true,false,false}

local tpr={key="se"} platform.rails[tpr.key]=tpr
tpr.railpos=platform.railCorner[tpr.key]+platform.railOffset[tpr.key]
tpr.chestpos=platform.railCorner[tpr.key] --+platform.railOffset[tpr.key]
tpr.floor="factory"
tpr.logs={true,false,false,true}




--[[ Teleporter registers ]]--

platform.teleporters={}

--[[ Offworld Teleporter ]]--

-- Offworld is special and has some special handling on its pair, e.g. the second pair doesn't get hazards and can be spawned freely because you can pick it up.
local tps={key="offworld"} platform.teleporters[tps.key]=tps
tps.logs=true -- this teleporter gains loaders on the first logistics upgrade
tps.dopipes=true -- this teleporter should be given pipes
tps.dualloader=false -- this teleporter gets an extra loader on the dualloader upgrade
tps.triloader=true -- this teleporter gets an extra loader on the triloader upgrade
tps.top=false -- this teleporter is a "top loader" used to determine loader direction via settings.
tps.circuit=false -- Should be false if the teleporter pair isn't in the same position.
tps.staticdir=false -- "up" or "down" if the logistics cannot have their direction changed with setting
tps.oneside=false -- If this teleporter is onesided, "left" or "right"
tps.rotated=false -- If true, this has logistics on top and bottom instead of left and right
tps.logiport=false -- Set to true if this is logistics only.
tps.energy="tele_energy" -- platform tech name

tps.pair={
	{floor="main",position=vector(-1,5),
		prototype="warptorio-teleporter",
	},
	{floor="main",position=vector(-1,8),
		prototype="warptorio-teleporter-gate",
		gate=true, -- Logistics spawning behaviour flag
		minable=true, -- Flag to pickup
		destructible=true, -- Can be destroyed
	}
}


--[[ Main Factory Teleporter ]]--

local tps={key="main_to_factory"} platform.teleporters[tps.key]=tps
tps.logs=true
tps.dopipes=true
tps.dualloader=true
tps.triloader=true
tps.top=true
tps.circuit=true
tps.staticdir=false
tps.oneside=false
tps.rotated=false
tps.logiport=false
tps.energy="energy"

tps.pair={
	{floor="main",position=vector(-1,-7),
		prototype="warptorio-underground",
		sprite_arrow="down",
		sprites={
			{sprite="technology/automation",target_offset={0,-0.25},x_scale=0.5,y_scale=0.5,tint={r=1,g=0.7,b=0.4,a=1}},
		},
	},
	{floor="factory",position=vector(-1,-7),
		prototype="warptorio-underground",
		sprite_arrow="up",
		sprites={
			{sprite="technology/concrete",target_offset={0,-0.25},x_scale=0.5,y_scale=0.5,tint={r=1,g=0.7,b=0.4,a=1}},
		},
	}
}

-- Main Turrets copy from Main Factory

local kdir="nw"
local key="main_tur_factory_"..kdir
local tpv=table.deepcopy(tps)
tpv.dualloader=false
tpv.top=true
tpv.triloader=true
tpv.circuit=true
tpv.key=key platform.teleporters[key]=tpv
tpv.pair[1].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[2].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[1].sprites=nil
tpv.pair[2].sprites=nil

local kdir="ne"
local key="main_tur_factory_"..kdir
local tpv=table.deepcopy(tps)
tpv.dualloader=false
tpv.top=true
tpv.triloader=true
tpv.circuit=true
tpv.key=key platform.teleporters[key]=tpv
tpv.pair[1].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[2].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[1].sprites=nil
tpv.pair[2].sprites=nil

local kdir="sw"
local key="main_tur_factory_"..kdir
local tpv=table.deepcopy(tps)
tpv.dualloader=false
tpv.triloader=true
tpv.circuit=true
tpv.top=false
tpv.key=key platform.teleporters[key]=tpv
tpv.pair[1].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[2].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[1].sprites=nil
tpv.pair[2].sprites=nil

local kdir="se"
local key="main_tur_factory_"..kdir
local tpv=table.deepcopy(tps)
tpv.dualloader=false
tpv.triloader=true
tpv.circuit=true
tpv.top=false
tpv.key=key platform.teleporters[key]=tpv
tpv.pair[1].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[2].position=platform.corner[kdir]-vector(0.5,0.5)
tpv.pair[1].sprites=nil
tpv.pair[2].sprites=nil


--[[ Factory to Harvester Teleporter ]]--

local tps={key="factory_to_harvester"} platform.teleporters[tps.key]=tps
tps.logs=true
tps.dopipes=true
tps.dualloader=true
tps.triloader=true
tps.top=false
tps.circuit=true
tps.staticdir=false
tps.oneside=false
tps.rotated=false
tps.logiport=false
tps.energy="energy"
tps.pair={
	{floor="factory",position=vector(-1,5),
		prototype="warptorio-underground",
		sprite_arrow="down",
		sprites={
			{sprite="technology/tank",target_offset={0,-0.25},x_scale=0.5,y_scale=0.5,tint={r=1,g=0.7,b=0.4,a=1}},
		},
	},
	{floor="harvester",position=vector(-1,5),
		prototype="warptorio-underground",
		sprite_arrow="up",
		sprites={
			{sprite="technology/automation",target_offset={0,-0.25},x_scale=0.5,y_scale=0.5,tint={r=1,g=0.7,b=0.4,a=1}},
		},
	}
}



--[[ Harvester to Boiler Teleporter ]]--

local tps={key="harvester_to_boiler"} platform.teleporters[tps.key]=tps
tps.logs=true
tps.dopipes=true
tps.dualloader=true
tps.triloader=true
tps.top=true
tps.circuit=true
tps.staticdir=false
tps.oneside=false
tps.rotated=false
tps.logiport=false
tps.energy="energy"
tps.pair={
	{floor="harvester",position=vector(-1,-7),
		prototype="warptorio-underground",
		sprite_arrow="down",
		sprites={
			{sprite="technology/fluid-handling",target_offset={0,-0.25},x_scale=0.5,y_scale=0.5,tint={r=1,g=0.7,b=0.4,a=1}}
		},
	},
	{floor="boiler",position=vector(-1,-7),
		prototype="warptorio-underground",
		sprite_arrow="up",
		sprites={
			
			{sprite="technology/tank",target_offset={0,-0.25},x_scale=0.5,y_scale=0.5,tint={r=1,g=0.7,b=0.4,a=1}}
		},
	}
}




--[[ Harvester registers ]]--

platform.HarvesterPointData={
	energy="energy",
	pair={
		{floor="harvester",prototype="warptorio-harvestportal",minable=true,destructible=false},
		{floor="main",prototype="warptorio-harvestportal",minable=true,destructible=true,gate=true},
	},
}

platform.harvesters={}

local hvs={key="west",position=platform.harvester.west}
hvs.energy="energy"
hvs.pad_prototype="warptorio-harvestpad-west"
hvs.prototype="warptorio-harvestportal"
hvs.tech="harvester_west" -- harvester size tech name, or..
hvs.fixed_level=nil -- If this harvester is a fixed level
hvs.logs=true
hvs.dualloader=true
hvs.triloader=true
hvs.dopipes=true
hvs.pipes_pattern="east" --{east={{2},{2,-2},{2,-2}},}
hvs.logs_pattern="east" --{east={{0},{0,-1},{0,-1,1}},} -- Which side the logistics are on. Yes you can have on all 4 sides.
hvs.combinator_pattern="west" -- Which side the combinator is on.

platform.harvesters.west=hvs

local hvs={key="east",position=platform.harvester.east}
hvs.energy="energy"
hvs.pad_prototype="warptorio-harvestpad-east"
hvs.prototype="warptorio-harvestportal"
hvs.tech="harvester_east"
hvs.fixed_level=nil
hvs.logs=true
hvs.dualloader=true
hvs.triloader=true
hvs.dopipes=true
hvs.pipes_pattern="west" --{west={{2},{2,-2},{2,-2}},}
hvs.logs_pattern="west" --{west={{0},{0,-1},{0,-1,1}},} -- Which side the logistics are on.
hvs.combinator_pattern="east" -- Which side the combinator is on. No patterns, dont put logistics over it.


platform.harvesters.east=hvs

-- No gigas yet


--[[ Homeworld ]]--

local floor={key="home"} -- Special key doesnt need a name
floor.empty=false
floor.radar=false
floor.special=nil
floor.migrate_tile=nil
platform.floors.home=floor



--[[ Main Floor (Planet Surface) ]]--

local floor={key="main"} -- Special key doesnt need a name
floor.empty=false
floor.radar=false
floor.special={tech="warptorio-reactor-6",prototype="warptorio-reactor",size=vector(4,4),destructible=true} --vector.clean(f,vector.square(vector(-0.5,-0.5),vector(5,5)))
floor.migrate_tile=nil -- A tile that will never appear during default tile & hazard placement, excluding harvesters (special handling on them). nil=no migration


function floor.get_sizes() local t={}
	t.size=warptorio.GetPlatformTechAmount("size") -- research.level etc
return t end


function floor.tile(f,b_void)
	local zt=floor.get_sizes()
	local z=zt.size or 8

	local tiler="warp-tile-concrete" if(b_void)then tiler="out-of-map" end

	local area=vector.square(vector(-0.5,-0.5),vector(z,z))
	vector.clearFiltered(f,area)
	vector.LayTiles(tiler,f,area)

	local rSize=research.level("warptorio-platform-size")
	local rLogs=research.level("warptorio-logistics")
	local rFacSize=research.level("warptorio-factory")
	local rTpGate=research.has("warptorio-teleporter-portal")

	for u,c in pairs(platform.corner)do
		local lvc=research.level("warptorio-turret-"..u.."")
		if(research.has("warptorio-turret-"..u.."-0"))then local rad=math.floor((10+lvc*6))
			for k,v in pairs(f.find_entities_filtered{type="character",force={game.forces.player,game.forces.enemy},invert=true,position=c,radius=rad/2})do entity.tryclean(v) end
			vector.LayCircle(tiler,f,vector.circleEx(c,rad))
		end
	end
end
function floor.hazard(f)
	local zt=floor.get_sizes()
	local z=zt.size or 8

	local area=vector.square(vector(-0.5,-0.5),vector(z,z))
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-1,-1),vector(4,4)))

	local rSize=research.level("warptorio-platform-size")
	--local rLogs=research.level("warptorio-logistics")
	local rFacSize=research.level("warptorio-factory")
	local rFac=research.has("warptorio-factory-0")
	local rTpGate=research.has("warptorio-teleporter-portal")

	if(rSize>0)then local ltm,ltp
		ltm=warptorio.GetTeleporterHazard(true,rFac)
		ltp=warptorio.GetTeleporterHazard(false,rTpGate)
		vector.LayTiles("hazard-concrete-left",f,vector.square(platform.teleporters["main_to_factory"].pair[1].position,ltm))
		vector.LayTiles("hazard-concrete-left",f,vector.square(platform.teleporters["offworld"].pair[1].position,ltp))
	end
	if(rSize>=6)then for k,v in pairs(platform.railCorner)do local o=platform.railOffset[k] vector.LayTiles("hazard-concrete-left",f,vector.square(v+o,vector(1,1))) end end -- trains

	for u,c in pairs(platform.corner)do
		local lvc=research.level("warptorio-turret-"..u.."")
		if(research.has("warptorio-turret-"..u.."-0"))then local rad=math.floor((10+lvc*6))
			vector.LayTiles("hazard-concrete-left",f,vector.square(c,warptorio.GetTeleporterHazard(false)))
		end
	end
end

function floor.technology(f) -- Check/re-apply technology-effects

end
platform.floors.main=floor


--[[ Factory Floor ]]--

local floor={key="factory",name="warptorio_factory"}
floor.empty=true
floor.radar=true
floor.special={tech="warptorio-beacon",upgrade=true,prototype="warptorio-beacon",size=vector(2,2)}
floor.migrate_tile="grass-1" -- A tile that will never appear during default tile & hazard placement, excluding harvesters (special handling on them). nil=no migration

function floor.get_sizes() local t={}
	t.size=warptorio.GetPlatformTechAmount("factorysize") -- research.level etc
return t end

function floor.tile(f)
	local zt=floor.get_sizes()
	local z=zt.size

	local area=vector.square(vector(-0.5,-0.5),vector(z,z))
	local rFacSize=research.level("warptorio-factory")
	local rBoiler=research.has("warptorio-boiler-1")
	local rLogs=research.level("warptorio-logistics")
	local rBridge=research.level("warptorio-bridgesize")
	vector.LayTiles("warp-tile-concrete",f,area)

	local rc={} for k in pairs(platform.corner)do local rclv=research.level("warptorio-turret-"..k) if(rclv>0 or research.has("warptorio-turret-"..k.."-0"))then rc[k]=rclv end end
	local zMainWidth=10+rBridge*2
	local zMainHeight=59+rBridge*2-2
	local zLeg=6+rBridge*4
	local whas=(rc.nw or rc.sw) local nhas=(rc.nw or rc.ne) local ehas=(rc.ne or rc.se) local shas=(rc.sw or rc.se)
	if(nhas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-0.5,platform.side.north.y/2),vector(zMainWidth,zMainHeight))) end
	if(shas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-0.5,platform.side.south.y/2-0.5),vector(zMainWidth,zMainHeight))) end
	if(ehas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/2-0.5,-0.5),vector(zMainHeight,zMainWidth))) end
	if(whas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/2,-0.5),vector(zMainHeight,zMainWidth))) end
	if(nhas and rc.nw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/2,platform.side.north.y),vector(zMainHeight,zLeg))) end
	if(nhas and rc.ne)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/2,platform.side.north.y),vector(zMainHeight,zLeg))) end
	if(shas and rc.sw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/2,platform.side.south.y-0.5),vector(zMainHeight,zLeg))) end
	if(shas and rc.se)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/2,platform.side.south.y-0.5),vector(zMainHeight,zLeg))) end
	if(ehas and rc.ne)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x-0.5,platform.side.north.y/2),vector(zLeg,zMainHeight))) end
	if(ehas and rc.se)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x-0.5,platform.side.south.y/2),vector(zLeg,zMainHeight))) end
	if(whas and rc.nw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x,platform.side.north.y/2),vector(zLeg,zMainHeight))) end
	if(whas and rc.sw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x,platform.side.south.y/2),vector(zLeg,zMainHeight))) end

	for k,c in pairs(platform.corner)do if(rc[k])then local zx=(10+rc[k]*6)
		vector.LayTiles("warp-tile-concrete",f,vector.square(c,vector(zx,zx))) vector.LayTiles("hazard-concrete-left",f,vector.square(c,warptorio.GetTeleporterHazard(false)))
	end end

	local zgWidth=128-16
	local zgHeight=96-12
	local zgLegHeight=17
	local zgLegWidth=10

	if(research.has("warptorio-factory-n"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.north+vector(-1,-zgLegHeight-zgHeight/2-1),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.north+vector(9-1,-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.north+vector(-9-1,-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(research.has("warptorio-factory-s"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.south+vector(-1,zgLegHeight+zgHeight/2),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.south+vector(9-1,zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.south+vector(-9-1,zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(research.has("warptorio-factory-w"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.west+vector(-zgLegHeight-zgHeight/2-1,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.west+vector(-zgLegHeight/2-1,9-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.west+vector(-zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end if(research.has("warptorio-factory-e"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.east+vector(zgLegHeight+zgHeight/2,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.east+vector(zgLegHeight/2-1,9-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.east+vector(zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end

end

function floor.hazard(f)
	local zt=floor.get_sizes()
	local z=zt.size
	local area=vector.square(vector(-0.5,-0.5),vector(z,z))
	local rFac=research.has("warptorio-factory-0")
	local rFacSize=research.level("warptorio-factory")
	local rBoiler=research.has("warptorio-boiler-1")
	local rHarv=research.has("warptorio-harvester-floor")
	local rLogs=research.level("warptorio-logistics")
	local rBridge=research.level("warptorio-bridgesize")

	if(rFacSize>=7)then for k,rv in pairs(platform.railOffset)do local rc=platform.railCorner[k] -- trains
		local rvx=platform.railLoader[k]
		vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x,rc.y),vector(1,1)))
		vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x+rvx[1][1],rc.y+rvx[1][2]),vector(1,1)))
		vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x+rvx[2][1],rc.y+rvx[2][2]),vector(1,1)))
	end end

	vector.LayTiles("hazard-concrete-left",f,vector.square(platform.teleporters["factory_to_harvester"].pair[1].position, -- factory to harvester
		(warptorio.GetTeleporterHazard(true,rHarv))
	))

	vector.LayTiles("hazard-concrete-left",f,vector.square(platform.teleporters["main_to_factory"].pair[1].position, -- planet to factory
		(warptorio.GetTeleporterHazard(true,rFac) )
	))
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-0.5,-0.5),vector(2,2)))
end

function floor.technology(f)

end
platform.floors.factory=floor



--[[ Harvester Floor ]]--

local floor={key="harvester",name="warptorio_harvester"}
floor.empty=true
floor.radar=false
floor.special=nil -- no special for harvester
floor.migrate_tile="grass-1" -- A tile that will never appear during default tile & hazard placement, excluding harvesters (special handling on them). nil=no migration


function floor.BuildHarvestCorner(f,cz,k,v) -- for giga harvesters unused
	if(research.has("warptorio-harvester-"..k.."-gate"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(v/3*2,vector(cz*1.25,cz*1.25)))
		vector.LayTiles("warptorio-red-concrete",f,vector.square(v/3*2,vector(cz,cz)))
		vector.LayTiles("hazard-concrete-left",f,vector.square((v/3*2),vector(2,2)))
	end 
end


function floor.get_sizes() local t={}
	t.size=16 -- research.level etc
	t.ovalsize=warptorio.GetPlatformTechAmount("harvestersize") or vector(22,17)
return t end

function floor.hazard(f)
	local zt=floor.get_sizes()
	local z=zt.size

	--local rLogs=research.level("warptorio-logistics")
	local rBoiler=research.has("warptorio-boiler-0")

	local bpair=platform.teleporters["factory_to_harvester"].pair
	local apair=platform.teleporters["harvester_to_boiler"].pair
	vector.LayTiles("hazard-concrete-left",f,vector.square(apair[1].position,(warptorio.GetTeleporterHazard(true,rBoiler)) )) -- harvester to boiler
	vector.LayTiles("hazard-concrete-left",f,vector.square(bpair[1].position,warptorio.GetTeleporterHazard(true))) -- factory to harvester
	--vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-1,-1),vector(2,2))) -- beacon
end

function floor.tile(f)
	local zt=floor.get_sizes()
	local z=zt.size


	local cirMaxWidth=128+8
	local cirHeight=17 --64+4 --17 --

	local minCir=vector(22,17)
	local maxCir=vector(128+8,64+4)
	local ovSize=vector(vector.getx(zt.ovalsize),vector.gety(zt.ovalsize)) -- vector(cirWidth,cirHeight)

	vector.LayCircle("warp-tile-concrete",f,vector.oval(vector(-1,-1),ovSize))


--[[ for 4 corners -- unfinished

	--local zx=(platform.side.east.x+platform.side.west.x)/3*2
	--vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/3*2,-1),vector(6,platform.side.south.y+3)))
	--vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/3*2,-1),vector(6,platform.side.south.y+3)))
	local cz=16
	for k,v in pairs(platform.corner)do warptorio.BuildHarvestCorner(cz,k,v) end
]]


end

function floor.technology(f)

end

floor.BuildHarvester={}
floor.BuildHarvester.west=function(f)
	local zt=floor.get_sizes()
	local z=zt.size

	local lvWest=research.level("warptorio-harvester-west")
	if(lvWest>0)then
		local ez=warptorio.GetHarvesterLevelSizeNum(lvWest)
		local vz=128+8 local hvMax=47 local vzx=vz/2 local hvx=hvMax/2 local hvy=hvMax/8
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1-vz/3,-1),vector(vz/2+(hvMax/2.5)-ez/2,4+((lvWest-1)*2 ))) ) -- west bridge
	end
end
floor.BuildHarvester.east=function(f)
	local zt=floor.get_sizes()
	local z=zt.size



	local lvEast=research.level("warptorio-harvester-east")
	if(lvEast>0)then
		local ez=warptorio.GetHarvesterLevelSizeNum(lvEast)
		local vz=128+8 local hvMax=47 local vzx=vz/2 local hvx=hvMax/2 local hvy=hvMax/8
		local vecSize=vector( (vz/2+(hvMax/2.5)-ez/2),4+((lvEast-1)*2))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1+vz/3,-1), vecSize)) -- east bridge
	end
end

platform.floors.harvester=floor






--[[ Boiler Floor ]]--

local floor={key="boiler",name="warptorio_boiler"}
floor.empty=true
floor.radar=true
floor.special={tech="warptorio-boiler-station",prototype="warptorio-warpstation",size=vector(2,2)}
floor.migrate_tile="grass-1" -- A tile that will never appear during default tile & hazard placement, excluding harvesters (special handling on them). nil=no migration

function floor.get_sizes() local t={}
	t.size=warptorio.GetPlatformTechAmount("boilersize") or 17 -- research.level etc
	--error(serpent.block(warptorio.platform.techs.boilersize))
return t end

function floor.hazard(f)
	local zt=floor.get_sizes()
	local z=zt.size

	local rBoiler=research.level("warptorio-boiler")
	local rLogs=research.level("warptorio-logistics")
	local rWater=research.level("warptorio-boiler-water")

	vector.LayTiles("hazard-concrete-left",f,vector.square(platform.teleporters["harvester_to_boiler"].pair[1].position,warptorio.GetTeleporterHazard(true) )) -- Boiler entry
	--vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b2.position,warptorio.GetTeleporterHazard(true))) -- next level
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-1,-1),vector(2,2))) -- beacon
end
function floor.tile(f)
	local zt=floor.get_sizes()
	local z=zt.size

	local rBoiler=research.level("warptorio-boiler")
	local rLogs=research.level("warptorio-logistics")
	local rWater=research.level("warptorio-boiler-water")

	local zf=z/3
	local zfx=math.floor(zf) + (zf%2==0 and 0 or 1)
	vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-0.5,-0.5),vector(zfx*2,(z*2))))
	vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-0.5,-0.5),vector((z*2),zfx*2)))

	if(rWater>0)then
		local zx=(rWater*2)
		local vx=zfx+zx/2+1
		vector.LayTiles("deepwater",f,vector.square(vector(-0.5,-0.5)+vector(vx,vx),vector(zx,zx))) -- se
		vector.LayTiles("deepwater",f,vector.square(vector(-0.5,-0.5)+vector(-vx,vx),vector(zx,zx))) -- sw
		vector.LayTiles("deepwater",f,vector.square(vector(-0.5,-0.5)+vector(-vx,-vx),vector(zx,zx))) -- nw
		vector.LayTiles("deepwater",f,vector.square(vector(-0.5,-0.5)+vector(vx,-vx),vector(zx,zx))) -- ne
	end
	local rgNorth=research.has("warptorio-boiler-n")
	local rgSouth=research.has("warptorio-boiler-s")
	local rgEast=research.has("warptorio-boiler-e")
	local rgWest=research.has("warptorio-boiler-w")

	local zgWidth=96
	local zgHeight=64
	local zgLegHeight=12
	local zgLegWidth=10

	if(rgNorth)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,-z-zgLegHeight-(zgHeight/2)-1),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(9-1,-z-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-9-1,-z-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(rgSouth)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,z+zgLegHeight+(zgHeight/2)-1),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(9-1,z+zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-9-1,z+zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(rgEast)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(z+zgLegHeight+(zgHeight/2)-1,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(z+zgLegHeight/2-1,9-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(z+zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end if(rgWest)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-z-zgLegHeight-(zgHeight/2)-1,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-z-zgLegHeight/2-1,9-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-z-zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end

end


function floor.technology(f)

end
platform.floors.boiler=floor





--[[ Empty surface cache ]]--

cache.surface("platform_factory",{
	raise=function(self) local f=self.host

		-- size=16
	end,
})

cache.surface("platform_harvester",{
	raise=function(self) local f=self.host
		f.solar_power_multiplier=settings.global.warptorio_solar_multiplier.value
		f.daytime=0
		f.always_day=true
		f.request_to_generate_chunks({0,0},16)
		f.force_generate_chunk_requests()
		f.destroy_decoratives({})
		for k,v in pairs(f.find_entities())do entity.destroy(v) end
		local area=vector.area(vector(-32*8,-32*8),vector(32*8*2,32*8*2))
		vector.LayTiles("out-of-map",f,area)
		-- size=16
	end,
})

cache.surface("platform_boiler",{
	raise=function(self) local f=self.host
		f.solar_power_multiplier=settings.global.warptorio_solar_multiplier.value
		f.daytime=0
		f.always_day=true
		f.request_to_generate_chunks({0,0},16)
		f.force_generate_chunk_requests()
		f.destroy_decoratives({})
		for k,v in pairs(f.find_entities())do entity.destroy(v) end
		local area=vector.area(vector(-32*8,-32*8),vector(32*8*2,32*8*2))
		vector.LayTiles("out-of-map",f,area)
		-- size=16
	end,
})



--[[ General Platform Stuff ]]--

function platform.PositionInPlatform(f,pos) local gf=global.floor
	if(f==gf.factory.surface)then return true
	elseif(f==gf.boiler.surface)then return true
	elseif(f==gf.harvester.surface)then return true
	end
	-- Do overworld checks here

end

function platform.GetWarpables(c,cf)
	-- warptorio.IsWarping=true
	--local m=global.floor.main
	--local c=m.host
	local mt=platform.floors.main.get_sizes()

	local marea=vector.square(vector.pos({-0.5,-0.5}),vector(mt.size,mt.size))

	-- find entities and players to copy/transfer to new surface
	local tpply={} local cx=platform.corn
	local etbl={}
	for k,v in pairs(c.find_entities_filtered{type={"car","character","player"},invert=true,area=marea})do
		local biterwarp=(warptorio.setting("biter_warping")==false)
		if(v.type=="spider-vehicle")then
			--local drv=v.get_driver() if(isvalid(drv))then drv.driving=nil v.set_driver(nil) end
			table.insert(etbl,v)
		elseif(v.type=="item-entity" or v.type=="character-corpse" or v.last_user or v.force.name=="player" or (biterwarp and v.force.name=="enemy"))then
			table.insert(etbl,v)
		end
	end

	-- find players to teleport to new platform
	for k,v in pairs(game.players)do if(not v.driving)then if(v.character==nil or (v.surface==c and vector.inarea(v.position,marea)))then
		table.insert(tpply,{v,vector.pos(v.position)})
	end end end

	-- find cars to teleport to new platform
	for k,v in pairs(c.find_entities_filtered{type={"car","tank"},area=marea})do if((v.surface==c and vector.inarea(v.position,marea)))then
		table.insert(tpply,{v,vector.pos(v.position)})
	end end

	-- find entities/players on the corners
	for k,v in pairs({"nw","ne","sw","se"})do local ugName="turret-"..v local rHas=research.has("warptorio-"..ugName.."-0") if(rHas)then local ug=research.level("warptorio-"..ugName)
		local etc=cf.find_entities_filtered{position={cx[v].x+0.5,cx[v].y+0.5},radius=math.floor(10+ug*6)/2} for a,e in pairs(etc)do e.destroy() end -- clean new platform corner

		local etp=c.find_entities_filtered{type="character",position={cx[v].x+0.5,cx[v].y+0.5},radius=(10+(ug*6))/2} -- find corner players
		for a,e in pairs(etp)do if(e.player and e.player.character~=nil and not e.driving)then table.insert(tpply,{e.player,{e.position.x,e.position.y}}) end end

		local etp=c.find_entities_filtered{type={"car","tank"},position={cx[v].x+0.5,cx[v].y+0.5},radius=(10+(ug*6))/2} -- find corner cars
		for a,e in pairs(etp)do table.insert(tpply,{e,{e.position.x,e.position.y}}) end

		local et=c.find_entities_filtered{type={"car","character","tank"},invert=true,position={cx[v].x+0.5,cx[v].y+0.5},radius=math.floor((10+ug*6)/2)-(1e-6)} -- find corner ents
		for k,v in pairs(et)do if(v.last_user or v.force.name=="player" or (biterwarp and v.force.name=="enemy"))then
			table.insertExclusive(etbl,v)
		end end

	end end

	return etbl,tpply
end






return platform


