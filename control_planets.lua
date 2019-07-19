local planet={} warptorio.Planets=planet

local resourceTypes={"coal","crude-oil","copper-ore","iron-ore","stone","uranium-ore"}
warptorio.OreTypes=resourceTypes
--["iron-ore"]={size=0},["copper-ore"]={size=0},["coal"]={size=0},["crude-oil"]={size=0},["uranium-ore"}={size=0},["stone"]={size=0}


-- --------
-- Regular Planets

planet.normal={ rng=20, name="A Normal Planet", desc="This world reminds you of home."} -- default

planet.average={ zone=1, rng=15, name="An Average Planet", desc="The usual critters and riches surrounds you, but you feel like something is missing.", -- remove 1-2 resources
	gen={autoplace_controls={}},
	fgen=function(t,b)
		local z,x=table.deepcopy(resourceTypes),{} for i=1,math.random(1,2),1 do local u=math.random(1,#z) x[i]=z[u] table.remove(z,u) end
		for k,v in pairs(x)do t.autoplace_controls[v]={size=0} game.print(v) end
		if(b or true)then local s=x[1] if(x[2])then s=s .. " and " .. x[2] .. " do" else s=s.. " does" end s=s.." not spawn on this planet"
			game.print(s) end
	end,
	spawn=function(f,b)


	end,
}

-- --------
-- Other Planets

planet.jungle={ zone=9, rng=3, name="A Jungle Planet", desc="A Jungle Planet Description",
	gen={autoplace_controls={["trees"]={frequency=2,size=1}}}
}

planet.barren={ zone=3, rng=4, name="A Barren Planet", desc="This world looks deserted and we appear to be safe. .. For now.",
	gen={
	starting_area = "none",
	cliff_settings = { cliff_elevation_0 = 1024 },
	default_enable_all_autoplace_controls = false,
	autoplace_settings = {
		decorative = { treat_missing_as_default = false },
		entity = { treat_missing_as_default = false },
		tile = { treat_missing_as_default = false, settings = {}, },
		},
	},
	fgen=function(t,b) local x=t.autoplace_settings.tile.settings local y={frequency="very-low",size=2}
		for i=1,3,1 do x["sand-"..i]=y end
		for i=1,7,1 do x["dirt-"..i]=y end
		x["dry-dirt"]=y  x["sand-decal"]=y x["sand-dune-decal"]=y
		if(b)then end
	end,
	spawn=function(f)
		f.daytime=0
		f.freeze_daytime=1
		f.peaceful_mode=1
		for k,v in pairs(f.find_entities_filtered{type="resource"})do v.destroy() end
	end,
}

planet.water={ zone=7, rng=5, name="An Ocean Planet", desc="There is water all around and seems to go on forever. The nearby fish that greet you fills you with determination.",
	gen={ starting_area="none",water=999999,default_enable_all_autoplace_controls=false,autoplace_settings={
		tile={treat_missing_as_default=false,settings={["water"]={frequency=5,size=5},["deepwater"]={frequency=5,size=5}}},
		entity={treat_missing_as_default=false,settings={["fish"]={frequency=5,size=5,richness=10}}},decorative = { treat_missing_as_default = false },
	}},
	spawn=function(f) end,
}


-- --------
-- Resource Specific Planets

planet.copper={ zone=8, rng=5, name="A Copper Planet", desc="The warp reactor surges with power and you feel static in the air. You are filled with determination.",
	gen={
		autoplace_controls={["copper-ore"]={frequency=4,size=2},
			["iron-ore"]={size=0},["coal"]={size=0},["crude-oil"]={size=0},["uranium-ore"]={size=0},["stone"]={size=0},
		},
	},
	spawn=function(f) for k,v in pairs(f.find_entities_filtered{type="resource"})do if(v.name~="copper-ore")then v.destroy() end end end
}


planet.iron={ zone=5, rng=5, name="An Iron Planet", desc="You land with a loud metal clang. The sparkle in the ground fills you with determination.",
	gen={
		autoplace_controls={["iron-ore"]={frequency=4,size=2},
			["copper-ore"]={size=0},["coal"]={size=0},["crude-oil"]={size=0},["uranium-ore"]={size=0},["stone"]={size=0},
		},
	},
	spawn=function(f) for k,v in pairs(f.find_entities_filtered{type="resource"})do if(v.name~="iron-ore")then v.destroy() game.print("iron") end end end,
}

planet.coal={ zone=7, rng=5, name="A Coal Planet", desc="A Coal Planet Description",
	gen={
		autoplace_controls={["coal"]={frequency=7,size=2},
			["iron-ore"]={size=0},["copper-ore"]={size=0},["crude-oil"]={size=0},["uranium-ore"]={size=0},["stone"]={size=0}
		},
	},
	spawn=function(f) for k,v in pairs(f.find_entities_filtered{type="resource"})do if(v.name~="coal")then v.destroy() end end end,
}

planet.uranium={ zone=15, rng=5, name="A Uranium Planet", desc="The warmth of this worlds green glow fills you with determination, but you probably shouldn't stay too long",
	gen={
		autoplace_controls={["uranium-ore"]={frequency=4,size=2},
			["iron-ore"]={size=0},["copper-ore"]={size=0},["coal"]={size=0},["crude-oil"]={size=0},["stone"]={size=0},
		},
	},
	spawn=function(f)
		for k,v in pairs(f.find_entities_filtered{type="resource"})do if(v.name~="uranium-ore")then v.destroy() end end

	end,
}

planet.oil={ zone=10, rng=5, name="An Oil Planet", desc="An Oil Planet Description",
	gen={
		autoplace_controls={["crude-oil"]={frequency=5,size=2},
			["iron-ore"]={size=0},["copper-ore"]={size=0},["coal"]={size=0},["stone"]={size=0},["uranium-ore"]={size=0}
		},
	},
	spawn=function(f)
		for k,v in pairs(f.find_entities_filtered{type="resource"})do if(v.name~="stone")then v.destroy() end end

	end,
}


planet.stone={ zone=15, rng=5, name="A Stone Planet", desc="A Stone Planet Description",
	gen={
		autoplace_controls={["stone"]={frequency=8,size=2},
			["iron-ore"]={size=0},["copper-ore"]={size=0},["coal"]={size=0},["crude-oil"]={size=0},["uranium-ore"]={size=0},["crude-oil"]={size=0},
		},
	},
	spawn=function(f)
		for k,v in pairs(f.find_entities_filtered{type="resource"})do if(v.name~="stone")then v.destroy() end end

	end,
}


-- --------
-- Biter Planets

planet.midnight={ zone=20,rng=5,name="A Planet Called Midnight", desc="Your hands disappear before your eyes as you are shrouded in darkness. This place seems dangerous.",
	gen={
		autoplace_controls={["enemy-base"]={frequency=2,size=2}},
	},
	spawn=function(f)
		f.daytime=0.5
		f.freeze_daytime=0
	end,
}


planet.biter={ zone=40,rng=5,name="A Biter Planet", desc="Within moments of warping in, your base is immediately under siege. We must survive until the next warp!",
	gen={
		starting_area=0.3,
		autoplace_controls={["enemy-base"]={frequency=8,size=8}},
	},
}




for k,v in pairs(planet)do v.key=k end






