



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

--[[ Basic Modifiers ]]

pmods.water={ make_gen=function(g,ev) g.water_level=ev return g end } -- {"water",10000}
pmods.biters={ make_gen=function(g,ev) g.autoplace_controls.enemy_base=ev or PCR(0) return g end} -- {"biters",PCR(10,10,10)}
pmods.trees={ make_gen=function(g,ev) g.autoplace_controls.trees=ev return g end } -- {"trees",PCR(1)}
pmods.cliffs={ make_gen=function(g,ev) g.cliffs=ev return g end } -- {"cliffs",{data here}}
pmods.starting_area={ make_gen=function(g,ev) g.starting_area=ev return g end } -- {"starting_area",size}
pmods.disable_all_defaults={gen={ default_enable_all_autoplace_controls=false,
	autoplace_settings={ decorative={treat_missing_as_default=false},entity={treat_missing_as_default=false},tile={treat_missing_as_default=false} } }}


--[[ Basic Spawn Modifiers ]]

pmods.daytime={ spawn=function(f,g,ev,r) f.daytime=ev.time if(ev.freeze)then f.freezedaytime=true end end } -- {"daytime",{time=0,freeze=true}}


--[[ Resource Modifiers ]]

pmods.resource_multiply_all={ make_gen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=PCRMul(g.autoplace_controls[k] or PCR(1),ev) end return g end }
pmods.resource_multiply={ make_gen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=PCRMul(g.autoplace_controls[k] or PCR(1),v) end return g end }
pmods.resource_multiply_random={
	make_gen=function(g,ev) local x,t={},table.copy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
		for k,v in pairs(x)do vg.autoplace_controls[v]=PCRMul(vg.autoplace_controls[v] or PCR(1),ev.value) end end
		return x
	end
} -- Multiply a random resource. {"resource_multiply_random",{ (count=1 or random=2), value=PCR(2)}}

pmods.resource_add_all={ make_gen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=PCRAdd(g.autoplace_controls[k] or PCR(1),ev) end return g end }
pmods.resource_add={ make_gen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=PCRAdd(g.autoplace_controls[k] or PCR(1),v) end return g end }
pmods.resource_add_random={
	make_gen=function(g,ev) local x,t={},table.copy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
		for k,v in pairs(x)do vg.autoplace_controls[v]=PCRAdd(vg.autoplace_controls[v] or PCR(1),ev.value) end end
		return x
	end
} -- Add a random resource. {"resource_add_random",{ (count=1 or random=2), value=PCR(2)}}

pmods.resource_set_all={ make_gen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=ev end return g end } -- {"resource_set_all",PCR(1,2,3)}
pmods.resource_set={ make_gen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=v end return g end } -- {"resource_set",{ ["iron-ore"]=PCR(4,3,2) } }
pmods.resource_set_random={
	make_gen=function(g,ev) local x,t={},table.copy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end for k,v in pairs(x)do vg.autoplace_controls[v]=ev.value end end return x
	end
} -- Set a random resource. {"resource_set_random",{ (count=1 or random=2), value=PCR(0)}}


--[[ Decorative & Entity Modifiers ]]

pmods.no_rocks={
	gen={
		
	},
	make_gen_event=nil,
	make_gen=nil,
}

pmods.no_shrubs={

}

pmods.no_decor_mods={

}

pmods.no_tile_mods={
	gen=nil,
	make_gen_event=nil,
	make_gen=function(g,ev)
		for k,v in pairs(warptorio.GetModTiles())do
			g.autoplace_settings.tile.settings[v]=PCR(0)
		end
	end,
}

pmods.no_tile_grass={

}

pmods.no_tile_dirt={

}

pmods.no_tile_drydirt={

}



local function PlanetRNG(name) return settings.startup["warptorio_planet_"..name].value end


local planet={
	key="normal", name="A Normal Planet", zone=0, rng=PlanetRNG("normal"),
	desc="This world reminds you of home.",
	modify_call=nil, -- {{"remote_name",vars},{"remote_name",vars}}
	modify={{"nauvis_biters"},{"nauvis_tiles"}},

	spawn_call=nil, -- {"remote_name",vars}
	spawn=nil,
}

local planet={
	key="average", name="An Average Planet", zone=2,rng=PlanetRNG("average"),
	desc="The usual critters and riches surrounds you, but you feel like something is missing.",
	modify_event=nil,
	modify={"resource_missing"},
	tileset={"nauvis"},
	gen=nil,
	make_gen_event=nil,
	make_gen=nil,
	spawn_event=nil,
	spawn=nil,
}

local planet={
	key="barren", name="A Barren Planet", zone=0, rng=PlanetRNG("barren"),
	modifiers={"no_resources","no_trees"},
	tileset={"barren"},
	gen=nil,
	make_gen_event=nil,
	make_gen=function(g,ev)
		return g
	end,
}
warptorio.RegisterPlanet(planet)