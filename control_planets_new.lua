



warptorio.PlanetData={} local pdata=warptorio.PlanetData -- planet data interface

function warptorio.RegisterPlanetInterface(n,planets) -- remote.call("warptorioplanets","register","my_mod_name",{"swamp"})
end


local function PCR(f,z,r) return {frequency=f or 1,size=z or f or 1,richness=r or f or 1} end
local function PCRMul(a,b) if(type(b)=="table")then
	return {frequency=a.frequency*b.frequency,size=a.size*b.size,richness=a.richness*b.richness} else return {frequency=a.frequency*b,size=a.size*b,richness=a.richness*b}
end end
local function PCRAdd(a,b) if(type(b)=="table")then
	return {frequency=a.frequency+b.frequency,size=a.size+b.size,richness=a.richness+b.richness} else return {frequency=a.frequency+b,size=a.size+b,richness=a.richness+b}
end end

warptorio.PlanetModifiers={} local pmods=warptorio.PlanetModifiers

--[[ Basic Control Modifiers ]]

pmods.water={ make_gen=function(g,ev) g.water_level=ev return g end } -- {"water",10000}
pmods.biters={ make_gen=function(g,ev) g.autoplace_controls.enemy_base=PCRMul(PCR(1),ev) return g end} -- {"biters",PCR(10,10,10)}
pmods.biters_multiply={ make_gen=function(g,ev) g.autoplace_controls.enemy_base=PCRMul(g.autoplace_controls.enemy_base or PCR(1),ev) return g end} -- {"biters",PCR(10,10,10)}
pmods.biters_add={ make_gen=function(g,ev) g.autoplace_controls.enemy_base=PCRAdd(g.autoplace_controls.enemy_base or PCR(1),ev) return g end} -- {"biters",PCR(10,10,10)}
pmods.biters_random={ make_gen=function(g,ev) g.autoplace_controls.enemy_base= PCRMul( g.autoplace_controls.enemy_base or PCR(1),math.random(ev[1]*100,ev[2]*100)/100 ) return g end }

pmods.trees={ make_gen=function(g,ev) g.autoplace_controls.trees=PCRMul(PCR(1),ev) return g end } -- {"trees",PCR(1)}
pmods.trees_multiply={ make_gen=function(g,ev) g.autoplace_controls.trees= PCRMul(g.autoplace_controls.trees or PCR(1)),ev) return g end }
pmods.trees_add={ make_gen=function(g,ev) g.autoplace_controls.trees= PCRAdd(g.autoplace_controls.trees or PCR(1)),ev) return g end }
pmods.trees_random={ make_gen=function(g,ev) g.autoplace_controls.trees= PCRMul( g.autoplace_controls.trees or PCR(1),math.random(ev[1]*100,ev[2]*100)/100 ) return g end }

pmods.cliffs={ make_gen=function(g,ev) g.cliffs=ev return g end } -- {"cliffs",{data here}}
pmods.starting_area={ make_gen=function(g,ev) g.starting_area=ev return g end }
pmods.disable_all_defaults={gen={ default_enable_all_autoplace_controls=false,
	autoplace_settings={ decorative={treat_missing_as_default=false},entity={treat_missing_as_default=false},tile={treat_missing_as_default=false} } }}


--[[ Basic Spawn Modifiers ]]

pmods.daytime={ spawn=function(f,g,ev,r) if(ev.time)then f.daytime=ev.time end if(ev.random)then f.daytime=math.random(ev.random[1]*100,ev.random[2]*100)/100 if(ev.freeze)then f.freezedaytime=true end end } -- {"daytime",{time=0,freeze=true}}


--[[ Resource Modifiers ]]

pmods.resource_multiply_all={ fgen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=PCRMul(g.autoplace_controls[k] or PCR(1),ev) end return g end }
pmods.resource_multiply={ fgen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=PCRMul(g.autoplace_controls[k] or PCR(1),v) end return g end }
pmods.resource_multiply_random={
	fgen=function(g,ev) local x,t={},table.copy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
		for k,v in pairs(x)do g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev.value) end end
		return g,x
	end
} -- Multiply a random resource. {"resource_multiply_random",{ (count=1 or random=2), value=PCR(2)}}

pmods.resource_add_all={ make_gen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=PCRAdd(g.autoplace_controls[k] or PCR(1),ev) end return g end }
pmods.resource_add={ make_gen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=PCRAdd(g.autoplace_controls[k] or PCR(1),v) end return g end }
pmods.resource_add_random={
	fgen=function(g,ev) local x,t={},table.copy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
		for k,v in pairs(x)do g.autoplace_controls[v]=PCRAdd(g.autoplace_controls[v] or PCR(1),ev.value) end end
		return g,x
	end
} -- Add a random resource. {"resource_add_random",{ (count=1 or random=2), value=PCR(2)}}

pmods.resource_set_all={ fgen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=ev end return g end } -- {"resource_set_all",PCR(1,2,3)}
pmods.resource_set={ fgen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=v end return g end } -- {"resource_set",{ ["iron-ore"]=PCR(4,3,2) } }
pmods.resource_set_random={
	fgen=function(g,ev) local x,t={},table.copy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
			for k,v in pairs(x)do g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev.value) end
		end end return g,x
	end
} -- Set a random resource. {"resource_set_random",{ (count=1 or random=2), value=PCR(0)}}


--[[ Decorative Modifiers ]]


pmods.rocks={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and v.name:match("rock"))then
		g.autoplace_settings.decorative.settings[v.name]=PCRMul(PCR(1),ev)
	end end return g end,
}
pmods.rocks_multiply={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and v.name:match("rock"))then
		g.autoplace_settings.decorative.settings[v.name]=PCRMul(g.autoplace_settings.decorative.settings[v.name] or PCR(1),ev)
	end end return g end,
}
pmods.decor={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and not v.name:match("rock"))then
		g.autoplace_settings.decorative.settings[v.name]=PCRMul(PCR(1),ev)
	end end return g end,
}
pmods.decor_multiply={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and not v.name:match("rock"))then
		g.autoplace_settings.decorative.settings[v.name]=PCRMul(g.autoplace_settings.decorative.settings[v.name] or PCR(1),ev)
	end end return g end,
}
pmods.decals={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and v.name:match(ev[1]))then
		g.autoplace_settings.decorative.settings[v.name]=PCRMul(PCR(1),ev[2])
	end end return g end,
}
pmods.decals_multiply={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and v.name:match(ev[1]))then
		g.autoplace_settings.decorative.settings[v.name]=PCRMul(g.autoplace_settings.decorative.settings[v.name] or PCR(1),ev[2])
	end end return g end,
}


--[[ Autoplacement Modifiers ]]

pmod.autoplace={
	fgen=function(g,ev) for k,v in pairs(game.autoplace_control_prototypes)do if(v.autoplace_specification and v.category~="resource")then
		g.autoplace_controls[v.name]=PCRMul(PCR(1),ev)
	end end return g end,
}
pmod.autoplace_multiply={
	fgen=function(g,ev) for k,v in pairs(game.autoplace_control_prototypes)do if(v.autoplace_specification and v.category~="resource")then
		g.autoplace_controls[v.name]=PCRMul(g.autoplace_controls[v.name] or PCR(1),ev)
	end end return g end,
}

--[[ Entity Modifiers ]]

pmod.entity={
	fgen=function(g,ev) for k,v in pairs(game.entity_prototypes)do if(v.autoplace_specification and v.name:match(ev[1]))then
		g.autoplace_settings.entity.settings[v.name]=PCRMul(PCR(1),ev[2])
	end end return g end,
}
pmod.entity_multiply={
	fgen=function(g,ev) for k,v in pairs(game.autoplace_control_prototypes)do if(v.autoplace_specification and v.name:match(ev[1]))then
		g.autoplace_settings.entity.settings[v.name]=PCRMul(g.autoplace_settings.entity.settings[v.name] or PCR(1),ev[2])
	end end return g end,
}


--[[ Tile Modifiers ]]

pmods.tile_mods={ fgen=function(g,ev) for k,v in pairs(warptorio.GetModTiles())do g.autoplace_settings.tile.settings[v]=PCRMul(g.autoplace_settings.tile.settings[v] or PCR(1),ev) end return g end }
pmods.tile_nauvis={ fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisTiles(ev[1]))do g.autoplace_settings.tile.settings[v]=PCRMul(g.autoplace_settings.tile.settings[v] or PCR(1),ev[2]) end return g end }
pmods.tile={ fgen=function(g,ev) for k,v in pairs(game.tile_prototypes)do
	if(v.autoplace_specification and v.name:match(ev[1]))then g.autoplace_settings.tile.settings[v.name]=PCRMul(g.autoplace_settings.tile.settings[v] or PCR(1),ev[2]) end return g end }

--[[ Nauvis-Only Modifier -- Remove all other tiles and decorations except nauvis ones ]]


pmods.nauvis={ -- remove mod tiles, decoratives and autoplacements
	fgen=function(g,ev) ev=ev or {}
		if(ev.tiles~=false)then for k,v in pairs(warptorio.GetModTiles())do g.autoplace_settings.tile.settings[v]=g.autoplace_settings.tile.settings[v] or PCR(0) end end
		if(ev.decor~=false)then for k,v in pairs(warptorio.GetModDecoratives())do g.autoplace_settings.decorative.settings[v]=g.autoplace_settings.decorative[v] or PCR(0) end end
		if(ev.autop~=false)then for k,v in pairs(warptorio.GetModAutoplacers())do g.autoplace_controls[v]=g.autoplace_controls[v] or PCR(0) end end
	end
}


local function PlanetRNG(name) return settings.startup["warptorio_planet_"..name].value end

warptorio.RegisterPlanet(planet)

local planet={
	key="normal", name="A Normal Planet", zone=0, rng=PlanetRNG("normal"),
	desc="This world reminds you of home.",
	modifiers={{"nauvis"}},
	gen=nil, -- The base planet map_gen_settings table

	tick_speed=nil, -- =(60*60*minutes) -- runs the tick calls every X ticks
	required_controls=nil, -- {"iron-ore"} -- Mod compatability: This planet REQUIRES a certain autoplace_control.
	required_tiles=nil, -- {"grass-1"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.tile
	required_ents=nil, -- {"enemy-base"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.entity
	required_decor=nil, -- {"shrub-x"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.decorative

	-- Call tables are used for remote interfaces: { {"remote_interface","remote_name",var_or_table} }
	modifier_call=nil, -- Adjust modifiers table
	modify_call=nil, -- Final function calls on map_gen_settings, behaving similar to a modifier function but planet specific.
	spawn_call=nil, -- Function calls after surface is created.
	tick_call=nil, -- Function calls per tick
	chunk_call=nil, -- Functions called when a chunk is generated on the planet

	modifier=nil, -- function(modifier_table) end, -- planet modifier modify function (warptorio internal)
	modify=nil, -- function(map_gen_settings) end, -- planet modify function (warptorio internal)
	spawn=nil, -- function(surface_object, table_of_modifier_return_values) -- planet spawn function (warptorio internal)
	tick=nil, -- function(surface_object, event_variable) -- planet tick function (warptorio internal)
	chunk=nil, -- function(surface_object, event_variable) -- planet on_chunk_generated function (warptorio internal)
}

local planet={  key="uncharted", name="An Uncharted Planet", zone=1, rng=PlanetRNG("uncharted"), -- default nauvis generation (modded)
	desc="You prospect your surroundings and gaze and the stars, and wonder if this world has ever had a name.",
}


local planet={ key="average", name="An Average Planet", zone=3,rng=PlanetRNG("average"),
	desc="The usual critters and riches surrounds you, but you feel like something is missing.",
	modifiers={{"nauvis"},{"resource_set_random",{random=2,value=0}}},
}

local planet={
	key="barren", name="A Barren Planet", zone=12, rng=PlanetRNG("barren"), warptime=0.5, nowater=true,
	desc="This world looks deserted and we appear to be safe. .. For now.",
	modifiers={{"nauvis",{decor=false}},{"resource_set_all",0},{"trees",0},{"shrubs",0},{"tile-nauvis",{"grass",0}},{"tile",{"water",0}},{"water",0}},
}

local planet={
	key="ocean", name="An Ocean Planet", zone=3, rng=PlanetRNG("ocean"), warptime=0.5,
	modifiers={{"nauvis"},{"resource_set_all",0},{"trees",0},{"shrubs",0},{"tile",{"sand",0}},{"tile",{"dirt",0}},{"water",1000},{"starting_area",0},{"entity",{"fish",8}}},
}

local planet={
	key="jungle", name="A Jungle Planet", zone=27, rng=PlanetRNG("jungle"), warptime=1,
	desc="These trees might be enough to conceal your location from the natives. .. At least for a while.",
	modifiers={{"nauvis"},{"resource_set_all",0.5},{"trees",2},{"daytime",{random={0,1}}},},
}
local planet={
	key="dwarf", name="A Dwarf Planet", zone=12, rng=PlanetRNG("dwarf"), warptime=1,
	desc="You are like a giant to the creatures of this planet. .. And to its natural resources.",
	modifiers={{"nauvis"},{"resource_set_all",0.5},{"biters",PCR(0.5,0.5,1)}},
}

local planet={
	key="rich", name="A Rich Planet", zone=60, rng=PlanetRNG("rich"), warptime=1,
	desc="A Rich Planet Description",
	modifiers={{"nauvis"},{"resource_set_all",PCR(4,2,1)},{"biters",PCR(1.25)}},
}

local planet={
	key="iron", name="An Iron Planet", zone=5, rng=PlanetRNG("iron"), warptime=1,
	desc="You land with a loud metal clang. The sparkle in the ground fills you with determination.",
	modifiers={ {"nauvis"},{"resource_set_all",0.25},{"resource_set",{["iron-ore"]=PCR(4,2,1)}} },
	required_controls={"iron-ore"},
}

local planet={
	key="copper", name="A Copper Planet", zone=8, rng=PlanetRNG("copper"), warptime=1,
	desc="The warp reactor surges with power and you feel static in the air. You are filled with determination.",
	modifiers={ {"nauvis"},{"resource_set_all",0.25},{"resource_set",{["copper-ore"]=PCR(4,2,1)}} },
	required_controls={"copper-ore"},
}

local planet={
	key="coal", name="A Coal Planet", zone=7, rng=PlanetRNG("coal"), warptime=1,
	desc="The piles of raw fuel strewn about this world makes you wonder about the grand forest that once thrived here, a very long time ago.",
	modifiers={ {"nauvis"},{"resource_set_all",0.25},{"resource_set",{["coal"]=PCR(7,2,1)}} },
	required_controls={"coal"},
}

local planet={
	key="stone", name="A Stone Planet", zone=15, rng=PlanetRNG("stone"), warptime=1,
	desc="This planet is like your jouney through warpspacetime. Stuck somewhere between a rock and a hard place.",
	modifiers={ {"nauvis"},{"resource_set_all",0.25},{"resource_set",{["crude-oil"]=PCR(7,2,1)}},{"biters",PCR(1.5,1.5,1)} },
	required_controls={"stone"},
}

local planet={
	key="oil", name="An Oil Planet", zone=15, rng=PlanetRNG("oil"), warptime=1,
	desc="This place has been a wellspring of life for millenia, but now they are just more fuel for your flamethrowers.",
	modifiers={ {"nauvis"},{"resource_set_all",0.25},{"resource_set",{["crude-oil"]=PCR(7,2,1)}},{"biters",PCR(1.5,1.5,1)} },
	required_controls={"crude-oil"},
}

local planet={
	key="uranium", name="A Uranium Planet", zone=30, rng=PlanetRNG("uranium"), warptime=1,
	desc="The warmth of this worlds green glow fills you with determination, but you probably shouldn't stay too long",
	modifiers={ {"nauvis"},{"resource_set_all",0.25},{"resource_set",{["uranium-ore"]=PCR(8,2,1)}},{"biters",PCR(1.5,1.5,1)} },
	required_controls={"uranium-ore"},
}

local planet={
	key="midnight", name="A Planet Called Midnight", zone=20, rng=PlanetRNG("midnight"), warptime=1.5,
	desc="Your hands disappear before your eyes as you are shrouded in darkness. This place seems dangerous.",
	modifiers={ {"nauvis"},{"biters",PCR(2)} },
}

local planet={
	key="polluted", name="A Polluted Planet", zone=40, rng=PlanetRNG("polluted"), warptime=1.5,
	desc="A heavy aroma of grease and machinery suddenly wafts over the platform and you wonder if you have been here before.",
	modifiers={ {"nauvis"},{"resource_set_all",0.75},{"biters",PCR(1.75)} },
	spawn=function(f,v)
		for x=-5,5,1 do for y=-5,5,1 do f.pollute({x*32,y*32},200) end end
	end,
}

local planet={
	key="biter", name="A Biter Planet", zone=60, rng=PlanetRNG("biter"), warptime=1,
	desc="Within moments of warping in, your factory is immediately under siege. We must survive until the next warp!",
	modifiers={ {"nauvis"},{"biters",PCR(8)} },
}

local planet={
	key="rogue", name="A Rogue Planet", zone=100, rng=PlanetRNG("barren"), warptime=0.5, nowater=true,
	desc="This world looks deserted and we appear to be safe. .. For now.",
	modifiers={{"nauvis",{decor=false}},{"resource_set_all",0},{"tile",{"grass",0}},{"tile",{"water",0}},{"water",0},{"starting_area",2.5},{"biters",3},},
}





