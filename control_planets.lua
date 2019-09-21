--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2

]]---------------------------------------
--[[ Environment ]]

local gwarptorio=setmetatable({},{__index=function(t,k) return global.warptorio[k] end,__newindex=function(t,k,v) global.warptorio[k]=v end})
local function PlanetRNG(name) return settings.startup["warptorio_planet_"..name].value end
local function ErrorNoHalt(s) game.print(s) end
warptorio=warptorio or {}


--[[ Helper Code - Planet Table Math for tile searching ]]

function table.GetMatchTable(t,n) local x={}
	if(istable(n))then for k,v in pairs(t)do if(table.HasMatchValue(n,v))then table.insert(x,v) end end
	else for i,v in pairs(t)do if(v:match(n))then table.insert(x,v) end end
	end return x
end
function table.HasValueMatch(t,u) for k,v in pairs(t)do if(v:match(u))then return v end end end
function table.HasMatchValue(t,u) for k,v in pairs(t)do if(u:match(v))then return v end end end


--[[ Nauvis Whitelist ]]--

local nauvis={} warptorio.nauvis=nauvis
nauvis.autoplace={"trees","enemy-base"} -- game.autoplace_control_prototypes
nauvis.resource={"iron-ore","copper-ore","stone","coal","uranium-ore","crude-oil"} -- game.autoplace_control_prototypes (resources edition)

nauvis.tile={ -- game.tile_prototypes (with autoplace)
"concrete","stone-path","tutorial-grid","refined-concrete","refined-hazard-concrete-left","refined-hazard-concrete-right","hazard-concrete-left","hazard-concrete-right",
"grass-1","grass-2","grass-3","grass-4","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7","dry-dirt","sand-1","sand-2","sand-3",
"red-desert-0","red-desert-1","red-desert-2","red-desert-3","lab-dark-1","lab-dark-2","lab-white","landfill","out-of-map","water","deepwater",
}

nauvis.noise={ -- game.noise_layer_prototypes (isn't used nor needed for planets)
"aux","brown-fluff","coal","copper-ore","crude-oil","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7","dry-dirt",
"elevation","elevation-persistence","enemy-base","fluff","garballo",
"grass-1","grass-2","grass-3","grass-4","grass1","grass2","green-fluff","iron-ore","moisture","pita","pita-mini",
"red-desert-0","red-desert-1","red-desert-2","red-desert-3","red-desert-decal","rocks",
"sand-1","sand-2","sand-3","sand-decal","sand-dune-decal","starting-area","stone","temperature",
"trees","trees-1","trees-10","trees-11","trees-12","trees-13","trees-14","trees-15","trees-2","trees-3","trees-4","trees-5","trees-6","trees-7","trees-8","trees-9",
"uranium-ore",}

nauvis.decor={ -- game.decorative_prototypes (with autoplace)
"brown-hairy-grass","green-hairy-grass","brown-carpet-grass",
"green-carpet-grass","green-small-grass","green-asterisk",
"brown-asterisk-mini","green-asterisk-mini","brown-asterisk",
"red-asterisk","dark-mud-decal","light-mud-decal","puberty-decal",
"red-desert-decal","sand-decal","sand-dune-decal","green-pita",
"red-pita","green-croton","red-croton","green-pita-mini","brown-fluff",
"brown-fluff-dry","green-desert-bush","red-desert-bush","white-desert-bush",
"garballo-mini-dry","garballo","green-bush-mini","lichen","rock-medium",
"rock-small","rock-tiny","big-ship-wreck-grass","sand-rock-medium","sand-rock-small","small-ship-wreck-grass"

}

nauvis.entities={ -- game.entity_prototypes (with autoplace)
"fish","tree-01","tree-02","tree-03","tree-04","tree-05","tree-09","tree-02-red","tree-07","tree-06","tree-06-brown",
"tree-09-brown","tree-09-red","tree-08","tree-08-brown","tree-08-red","dead-dry-hairy-tree","dead-grey-trunk",
"dead-tree-desert","dry-hairy-tree","dry-tree","rock-huge","rock-big","sand-rock-big","small-worm-turret",
"medium-worm-turret","big-worm-turret","behemoth-worm-turret","biter-spawner","spitter-spawner",
"crude-oil","coal","copper-ore","iron-ore","stone","uranium-ore",
}

local ab={} nauvis.alienbiome=ab nauvis.ab=ab
ab.tile={ -- tile-alias.lua -- mod compatability -_-
    ["grass-1"] = "vegetation-green-grass-1" ,
    ["grass-2"] = "vegetation-green-grass-2" ,
    ["grass-3"] = "vegetation-green-grass-3" ,
    ["grass-4"] = "vegetation-green-grass-4" ,
    ["dirt-1"] = "mineral-tan-dirt-1" ,
    ["dirt-2"] = "mineral-tan-dirt-2" ,
    ["dirt-3"] = "mineral-tan-dirt-1" ,
    ["dirt-4"] = "mineral-tan-dirt-2" ,
    ["dirt-5"] = "mineral-tan-dirt-3" ,
    ["dirt-6"] = "mineral-tan-dirt-5" ,
    ["dirt-7"] = "mineral-tan-dirt-4" ,
    ["dry-dirt"] = "mineral-tan-dirt-6" ,
    ["red-desert-0"] = "vegetation-olive-grass-2" ,
    ["red-desert-1"] = "mineral-brown-dirt-1" ,
    ["red-desert-2"] = "mineral-brown-dirt-5" ,
    ["red-desert-3"] = "mineral-brown-dirt-6" ,
    ["sand-1"] = "mineral-brown-sand-1" ,
    ["sand-2"] = "mineral-brown-sand-1" ,
    ["sand-3"] = "mineral-brown-sand-2" ,
    ["sand-4"] = "mineral-brown-sand-3" ,
	["water"]="water",
	["deepwater"]="deepwater",
	--["water-shallow"]="water-shallow",
}

ab.entities={ -- todo;

}

ab.decor={ -- todo;

}

--[[ Lookup Functions ]]--


function warptorio.GetAllResources() if(warptorio.AllResources)then return warptorio.AllResources end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(v.category=="resource")then table.insert(at,v.name) end end warptorio.AllResources=at return at end
function warptorio.GetModResources() if(warptorio.ModResources)then return warptorio.ModResources end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(v.category=="resource" and not table.HasValue(nauvis.resource,v.name))then table.insert(at,v.name) end end warptorio.ModResources=at return at end

function warptorio.CacheModTiles() if(warptorio.ModTiles)then return warptorio.ModTiles end local pt=game.tile_prototypes local at={}
	for k,v in pairs(pt)do if(v.autoplace_specification and not table.HasValue(nauvis.tile,v.name) and not table.HasValue(nauvis.alienbiome.tile,v.name) )then table.insert(at,v.name) end end warptorio.ModTiles=at return at end
function warptorio.CacheAllTiles() if(warptorio.AllTiles)then return warptorio.AllTiles end local pt=game.tile_prototypes local at={}
	for k,v in pairs(pt)do if(v.autoplace_specification)then table.insert(at,v.name) end end warptorio.AllTiles=at return at end

function warptorio.GetModTiles(n) local t=warptorio.CacheModTiles() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetNauvisTiles(n) local t,tn=nauvis.tile if(game.active_mods["alien-biomes"])then tn=t t=nauvis.alienbiome.tile end if(not n or n==true)then return t end
	if(tn)then
		local y,x={},table.GetMatchTable(tn,n)
		for k,v in pairs(x)do if(t[v])then table.insertExclusive(y,t[v]) end end
		return y
	end
	return table.GetMatchTable(t,n)
end
function warptorio.GetTiles(n) local t=warptorio.CacheAllTiles() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end


function warptorio.CacheModAutoplacers() if(warptorio.ModAutoplacers)then return warptorio.ModAutoplacers end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(not table.HasValue(nauvis.autoplace,v.name) and v.category~="resource")then table.insert(at,v.name) end end warptorio.ModAutoplacers=at return at end
function warptorio.CacheAllAutoplacers() if(warptorio.AllAutoplacers)then return warptorio.AllAutoplacers end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(v.category~="resource")then table.insert(at,v.name) end end warptorio.AllAutoplacers=at return at end

function warptorio.GetModAutoplacers(n) local t=warptorio.CacheModAutoplacers() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetNauvisAutoplacers(n) local t=nauvis.autoplace if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetAutoplacers(n) local t=warptorio.CacheAllAutoplacers() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end

function warptorio.CacheModDecoratives() if(warptorio.ModDecoratives)then return warptorio.ModDecoratives end local pt=game.decorative_prototypes local at={}
	for k,v in pairs(pt)do if(v.autoplace_specification and not table.HasValue(nauvis.decor,v.name) and not table.HasValue(nauvis.alienbiome.decor,v.name) )then
	table.insert(at,v.name) end end warptorio.ModDecoratives=at return at end
function warptorio.CacheAllDecoratives() if(warptorio.AllDecoratives)then return warptorio.AllDecoratives end local pt=game.decorative_prototypes local at={}
	for k,v in pairs(pt)do if(v.autoplace_specification)then table.insert(at,v.name) end end warptorio.AllDecoratives=at return at end

function warptorio.GetModDecoratives(n) local t=warptorio.CacheModDecoratives() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetNauvisDecoratives(n) local t=nauvis.decor if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetDecoratives(n) local t=warptorio.CacheAllDecoratives() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end

function warptorio.CacheModEntities() if(warptorio.ModEntities)then return warptorio.ModEntities end local pt=game.entity_prototypes local at={}
	for k,v in pairs(pt)do if(v.autoplace_specification and not table.HasValue(nauvis.entities,v.name))then table.insert(at,v.name) end end warptorio.ModEntities=at return at end
function warptorio.CacheAllEntities() if(warptorio.AllEntities)then return warptorio.AllEntities end local pt=game.entity_prototypes local at={}
	for k,v in pairs(pt)do if(v.autoplace_specification)then table.insert(at,v.name) end end warptorio.AllEntities=at return at end

function warptorio.GetModEntities(n) local t=warptorio.CacheModEntities() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetNauvisEntities(n) local t=nauvis.entities if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end
function warptorio.GetEntities(n) local t=warptorio.CacheAllEntities() if(not n or n==true)then return t else return table.GetMatchTable(t,n) end end


--[[ Planet Control Data ]]--


warptorio.Planets={} local pdata=warptorio.Planets -- planet data interface

local function PCR(f,z,r) return {frequency=f or 1,size=z or f or 1,richness=r or f or 1} end
local function PCRMul(a,b) if(type(b)=="table")then
	return {frequency=(a.frequency or 1)*(b.frequency or 1),size=(a.size or 1)*(b.size or 1),richness=(a.richness or 1)*(b.richness or 1)} else
	return {frequency=(a.frequency or 1)*(b or 1),size=(a.size or 1)*(b or 1),richness=(a.richness or 1)*(b or 1)}
end end
local function PCRAdd(a,b) if(type(b)=="table")then
	return {frequency=a.frequency+b.frequency,size=a.size+b.size,richness=a.richness+b.richness} else return {frequency=a.frequency+b,size=a.size+b,richness=a.richness+b}
end end

warptorio.PlanetModifiers={} local pmods=warptorio.PlanetModifiers

--[[ Basic Control Modifiers ]]--

pmods.water={ fgen=function(g,ev) g.water=ev return g end } -- {"water",10000}
pmods.biters={ fgen=function(g,ev) g.autoplace_controls["enemy-base"]=PCRMul(PCR(1),ev) return g end} -- {"biters",PCR(10,10,10)}
pmods.biters_multiply={ fgen=function(g,ev) g.autoplace_controls["enemy-base"]=PCRMul(g.autoplace_controls["enemy-base"] or PCR(1),ev) return g end} -- {"biters",PCR(10,10,10)}
pmods.biters_add={ fgen=function(g,ev) g.autoplace_controls["enemy-base"]=PCRAdd(g.autoplace_controls["enemy-base"] or PCR(1),ev) return g end} -- {"biters",PCR(10,10,10)}
pmods.biters_random={ fgen=function(g,ev) g.autoplace_controls["enemy-base"]= PCRMul( g.autoplace_controls["enemy-base"] or PCR(1),math.random(ev[1]*100,ev[2]*100)/100 ) return g end }

pmods.trees={ fgen=function(g,ev) g.autoplace_controls.trees=PCRMul(PCR(1),ev) return g end } -- {"trees",PCR(1)}
pmods.trees_multiply={ fgen=function(g,ev) g.autoplace_controls.trees= PCRMul(g.autoplace_controls.trees or PCR(1),ev) return g end }
pmods.trees_add={ fgen=function(g,ev) g.autoplace_controls.trees=PCRAdd(g.autoplace_controls.trees or PCR(1),ev) return g end }
pmods.trees_random={ fgen=function(g,ev) g.autoplace_controls.trees= PCRMul( g.autoplace_controls.trees or PCR(1),math.random(ev[1]*100,ev[2]*100)/100 ) return g end }

pmods.cliffs={ fgen=function(g,ev) g.cliff_settings=ev return g end } -- {"cliffs",{data here}}
pmods.starting_area={ fgen=function(g,ev) g.starting_area=ev return g end }
pmods.disable_all_defaults={gen={ default_enable_all_autoplace_controls=false,
	autoplace_settings={ decorative={treat_missing_as_default=false},entity={treat_missing_as_default=false},tile={treat_missing_as_default=false} }
}}

pmods.moisture={ fgen=function(g,ev) g.property_expression_names["moisture"]=ev return g end}
pmods.aux={ fgen=function(g,ev) g.property_expression_names["aux"]=ev return g end}
pmods.temperature={ fgen=function(g,ev) g.property_expression_names["temperature"]=ev return g end}
pmods.elevation={ fgen=function(g,ev) g.property_expression_names["elevation"]=ev return g end}
pmods.cliffiness={ fgen=function(g,ev) g.property_expression_names["cliffiness"]=ev return g end}
pmods.terrain_segmentation={ fgen=function(g,ev) g.terrain_segmentation=ev return g end}

pmods.property={ fgen=function(g,ev) g[ev[1]]=ev[2] end}

--[[ Basic Spawn Modifiers ]]--

pmods.daytime={ spawn=function(f,g,ev,r) ev=ev or {}
	if(ev.time)then f.daytime=ev.time end
	if(ev.random)then f.daytime=math.random(ev.random[1]*100,ev.random[2]*100)/100 end
	if(ev.freeze)then f.freeze_daytime=true end
end } -- {"daytime",{time=0,freeze=true}}


--[[ Resource Modifiers ]]--
-- todo: similar searching to other modifiers
-- todo: fluid-type, solid-type, and solid-requiring-liquid-type distinctions required.

pmods.resource_multiply_all={ fgen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=PCRMul(g.autoplace_controls[k] or PCR(1),ev) end return g end }
pmods.resource_multiply={ fgen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=PCRMul(g.autoplace_controls[k] or PCR(1),v) end return g end }
pmods.resource_multiply_random={
	fgen=function(g,ev) local x,t={},table.deepcopy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end for k,v in pairs(x)do
			g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev.value)
		end end
		return g,x
	end
} -- Multiply a random resource. {"resource_multiply_random",{ (count=1 or random=2), value=PCR(2)}}

pmods.resource_add_all={ fgen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[k]=PCRAdd(g.autoplace_controls[k] or PCR(1),ev) end return g end }
pmods.resource_add={ fgen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=PCRAdd(g.autoplace_controls[k] or PCR(1),v) end return g end }
pmods.resource_add_random={
	fgen=function(g,ev) local x,t={},table.deepcopy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
		for k,v in pairs(x)do g.autoplace_controls[v]=PCRAdd(g.autoplace_controls[v] or PCR(1),ev.value) end end
		return g,x
	end
} -- Add a random resource. {"resource_add_random",{ (count=1 or random=2), value=PCR(2)}}

pmods.resource_set_all={ fgen=function(g,ev) for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[v]=ev end return g end } -- {"resource_set_all",PCR(1,2,3)}
pmods.resource_set={ fgen=function(g,ev) for k,v in pairs(ev)do g.autoplace_controls[k]=v end return g end } -- {"resource_set",{ ["iron-ore"]=PCR(4,3,2) } }
pmods.resource_set_random={
	fgen=function(g,ev) local x,t={},table.deepcopy(warptorio.GetAllResources()) local c=math.min( (ev.count and ev.count or (ev.random and math.random(1,ev.random) or 1)), #t)
		if(c>0)then for i=1,c,1 do local u=math.random(1,#t) table.insert(x,table.remove(t,u)) end
			for k,v in pairs(x)do g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev.value) end end
		return g,x
	end
} -- Set a random resource. {"resource_set_random",{ (count=1 or random=2), value=PCR(0)}}


--[[ Decorative Modifiers ]]--
-- todo: similar decorative searching to autoplacement, entity and tile modifiers

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

pmods.decals_expr={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and v.name:match(ev[1]))then
		g.property_expression_names[v.name .. ":" .. ev[2]]=ev[3]
	end end return g end,
}
pmods.decals_expr_inv={
	fgen=function(g,ev) for k,v in pairs(game.decorative_prototypes)do if(v.autoplace_specification and not v.name:match(ev[1]))then
		g.property_expression_names[v.name .. ":" .. ev[2]]=ev[3]
	end end return g end,
}

--[[ Autoplacement Modifiers ]]--

pmods.autoplace={fgen=function(g,ev) for k,v in pairs(warptorio.GetAutoplacers(ev[1]))do g.autoplace_controls[v]=PCRMul(PCR(1),ev) end return g end,}
pmods.autoplace_multiply={fgen=function(g,ev) for k,v in pairs(warptorio.GetAutoplacers(ev[1]))do g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev[2]) end return g end,}
pmods.autoplace_expr={fgen=function(g,ev) for k,v in pairs(warptorio.GetAutoplacers(ev[1]))do g.property_expression_names[v..":"..ev[2]]=PCRMul(PCR(1),ev[3]) end return g end,}

pmods.autoplace_nauvis={fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisAutoplacers(ev[1]))do g.autoplace_controls[v]=PCRMul(PCR(1),ev[2]) end return g end,}
pmods.autoplace_nauvis_multiply={fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisAutoplacers(ev[1]))do g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev[2]) end return g end,}
pmods.autoplace_nauvis_expr={fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisAutoplacers(ev[1]))do g.property_expression_names[v..":"..ev[2]]=PCRMul(PCR(1),ev[3]) end return g end,}

pmods.autoplace_mod={fgen=function(g,ev) for k,v in pairs(warptorio.GetModAutoplacers(ev[1]))do g.autoplace_controls[v]=PCRMul(PCR(1),ev[2]) end return g end,}
pmods.autoplace_mod_multiply={fgen=function(g,ev) for k,v in pairs(warptorio.GetModAutoplacers(ev[1]))do g.autoplace_controls[v]=PCRMul(g.autoplace_controls[v] or PCR(1),ev[2]) end return g end,}
pmods.autoplace_mod_expr={fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisAutoplacers(ev[1]))do g.property_expression_names[v..":"..ev[2]]=PCRMul(PCR(1),ev[3]) end return g end,}

--[[ Entity Modifiers ]]--

pmods.entity={fgen=function(g,ev) for k,v in pairs(warptorio.GetEntities(ev[1]))do g.autoplace_settings.entity.settings[v]=PCRMul(PCR(1),ev[2]) end return g end,}
pmods.entity_multiply={fgen=function(g,ev) for k,v in pairs(warptorio.GetEntities(ev[1]))do g.autoplace_settings.entity.settings[v]=PCRMul(g.autoplace_settings.entity.settings[v] or PCR(1),ev[2]) end return g end,}
pmods.entity_expr={ fgen=function(g,ev) for k,v in pairs(warptorio.GetEntities(ev[1]))do g.property_expression_names[v .. ":" .. ev[2]]=ev[3] end return g end,}

pmods.entity_mod={fgen=function(g,ev) for k,v in pairs(warptorio.GetModEntities(ev[1]))do g.autoplace_settings.entity.settings[v]=PCRMul(PCR(1),ev[2]) end return g end,}
pmods.entity_mod_multiply={fgen=function(g,ev) for k,v in pairs(warptorio.GetModEntities(ev[1]))do g.autoplace_settings.entity.settings[v]=PCRMul(g.autoplace_settings.entity.settings[v] or PCR(1),ev[2]) end return g end,}
pmods.entity_mod_expr={ fgen=function(g,ev) for k,v in pairs(warptorio.GetModEntities(ev[1]))do g.property_expression_names[v .. ":" .. ev[2]]=ev[3] end return g end,}

pmods.entity_nauvis={fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisEntities(ev[1]))do g.autoplace_settings.entity.settings[v]=PCRMul(PCR(1),ev[2]) end return g end,}
pmods.entity_nauvis_multiply={fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisEntities(ev[1]))do g.autoplace_settings.entity.settings[v]=PCRMul(g.autoplace_settings.entity.settings[v] or PCR(1),ev[2]) end return g end,}
pmods.entity_nauvis_expr={ fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisEntities(ev[1]))do g.property_expression_names[v .. ":" .. ev[2]]=ev[3] end return g end,}

--[[ Tile Modifiers ]]--

pmods.tile_mod={ fgen=function(g,ev) for k,v in pairs(warptorio.GetModTiles(ev[1]))do g.autoplace_settings.tile.settings[v]=(ev[2]==true and {} or (ev[2]==false and nil or PCRMul(g.autoplace_settings.tile.settings[v] or PCR(1),ev[2]))) end return g end }
pmods.tile_nauvis={ fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisTiles(ev[1]))do g.autoplace_settings.tile.settings[v]=(ev[2]==true and {} or (ev[2]==false and nil or PCRMul(g.autoplace_settings.tile.settings[v] or PCR(1),ev[2]))) end return g end }
pmods.tile={ fgen=function(g,ev) for k,v in pairs(warptorio.GetTiles(ev[1]))do g.autoplace_settings.tile.settings[v]=(ev[2]==true and {} or (ev[2]==false and nil or PCRMul(g.autoplace_settings.tile.settings[v] or PCR(1),ev[2]))) end return g end }

pmods.tile_nauvis_expr={ fgen=function(g,ev) for k,v in pairs(warptorio.GetNauvisTiles(ev[1]))do g.property_expression_names["tile:"..v..":"..ev[2]]=ev[3] end return g end }
pmods.tile_mod_expr={ fgen=function(g,ev) for k,v in pairs(warptorio.GetModTiles(ev[1]))do g.property_expression_names["tile:"..v..":"..ev[2]]=ev[3] end return g end }
pmods.tile_expr={ fgen=function(g,ev) for k,v in pairs(warptorio.GetTiles(ev[1]))do g.property_expression_names["tile:"..v..":"..ev[2]]=ev[3] end return g end }


--[[ Nauvis Modifier -- Remove all other tiles, decorations, entities and autoplacers except nauvis ones ]]


pmods.nauvis={ -- remove mod tiles, decoratives and autoplacements
	fgen=function(g,ev) ev=ev or {}
		--[[if(ev.tiles~=false)then for k,v in pairs(warptorio.GetModTiles())do g.autoplace_settings.tile.settings[v]=g.autoplace_settings.tile.settings[v] or PCR(0) end end
		if(ev.decor~=false)then for k,v in pairs(warptorio.GetModDecoratives())do g.autoplace_settings.decorative.settings[v]=g.autoplace_settings.decorative[v] or PCR(0) end end
		if(ev.autop~=false)then for k,v in pairs(warptorio.GetModAutoplacers())do g.autoplace_controls[v]=g.autoplace_controls[v] or PCR(0) end end]]

		g.default_enable_all_autoplace_controls=false
		g.autoplace_settings.decorative.treat_missing_as_default=false
		g.autoplace_settings.entity.treat_missing_as_default=false
		g.autoplace_settings.tile.treat_missing_as_default=false

		if(ev.tiles~=false)then for k,v in pairs(warptorio.GetNauvisTiles(ev.tiles))do g.autoplace_settings.tile.settings[v]={} end end
		if(ev.decor~=false)then for k,v in pairs(warptorio.GetDecoratives(ev.decor))do g.autoplace_settings.decorative.settings[v]={} end end
		if(ev.ents~=false)then for k,v in pairs(warptorio.GetEntities(ev.ents))do g.autoplace_settings.entity.settings[v]={} end end
		if(ev.autoplace~=false)then for k,v in pairs(warptorio.GetNauvisAutoplacers(ev.autoplace))do g.autoplace_controls[v]={} end end
		if(ev.oremod~=false)then for k,v in pairs(warptorio.GetAllResources())do g.autoplace_controls[v]={} end end

		return g
	end
}


--[[ map_gen_settings Generator ]]--

warptorio.TileDefaults={}
function warptorio.TileDefault(n,b)
	warptorio.TileDefaults[n]=b
end

function warptorio.RegisterPlanet(p)
	warptorio.Planets[p.key]=table.deepcopy(p)
	if(game and warptorio.Loaded)then warptorio.ResetGui() end
end

function warptorio.CallPlanetEvent(p,n,ev,...)
	local x=p[n .. "_call"]
	if(x)then return remote.call(x[1],x[2],ev,...)
	elseif(p[n]~=nil)then return p[n](ev,...) end
end

local mapgen={} warptorio.Mapgen=mapgen

function warptorio.GeneratePlanetSettings(p,chart)
	local g=mapgen.EmptyTable()
	mapgen.ApplyModifiers(p,g,chart)
	return g
end

function warptorio.GeneratePlanetSurface(p,g,chart)
	local f=game.create_surface("warpsurf_"..gwarptorio.warpzone,g)
	warptorio.SetPlanetBySurface(f,p)

	if(p.modifiers)then for k,v in ipairs(p.modifiers)do
		local mod=warptorio.PlanetModifiers[v[1]]
		if(mod.spawn_call)then remote.call(mod.spawn_call[1],mod.spawn_call[2],v[2],chart)
		elseif(mod.spawn)then mod.spawn(f,g,v[2],r) end
	end end
	if(p.spawn_call)then
		local r=remote.call(p.spawn_call[1],p.spawn_call[2],f,g,chart)
	elseif(p.spawn)then p.spawn(f,g,chart)
	end

	if(not p.no_first_chunks)then f.request_to_generate_chunks({0,0},5) f.force_generate_chunk_requests() end

	return f
end

function warptorio.CheckPlanetControls(t) -- mod compatability -_-
	local pt=game.autoplace_control_prototypes
	if(game.active_mods["alien-biomes"])then warptorio.DoAlienBiomesTiles(t) end
	for k,v in pairs(t.autoplace_controls)do if(not pt[k])then t.autoplace_controls[k]=nil end end
end

function mapgen.EmptyTable()
	local t={
		seed=math.random(4294967295),
		autoplace_controls={},
		autoplace_settings={tile={settings={}},entity={settings={}},decorative={settings={}} },
		property_expression_names={},
	}
	for k,v in pairs(warptorio.TileDefaults)do if(v==false)then t.property_expression_names["tile:"..k..":probability"]=-1000000 end end
	return t
end

function mapgen.MergeSettings(g,gx)
	return table.deepmerge(g,gx)
end
function mapgen.ApplyModifiers(p,g,chart)
	if(p.modifiers)then for k,v in ipairs(p.modifiers)do
		local mod=warptorio.PlanetModifiers[v[1]]
		if(not mod)then error("Warptorio Planet Error (" .. p.key .. "): \"" .. v[1] .. "\" Modifier not found.") return g end
		if(mod.gen)then mapgen.MergeSettings(g,mod.gen) end
		if(mod.fgen_call)then
			local r=remote.call(mod.fgen_call[1],mod.fgen_call[2],g,v[2],chart) 
			if(not r)then ErrorNoHalt("Warptorio Planet Error (".. p.key .. "): Remote \"" .. mod.fgen_call[1] .. "\".\"" .. mod.fgen_call[2] .. "\" did not return anything") return g end
			mapgen.MergeSettings(g,r)
		elseif(mod.fgen)then --game.print("applying modifier: " .. v[1])
			mapgen.MergeSettings(g,mod.fgen(g,v[2],chart))
		end
	end end
	if(p.nauvis_multiply~=false)then
		local nvs=game.surfaces["nauvis"].map_gen_settings
		for k,v in pairs(nvs.autoplace_controls)do
			if(g.autoplace_controls[k])then g.autoplace_controls[k]=PCRMul(v,g.autoplace_controls[k]) end
		end
		if(g.starting_area)then g.starting_area=g.starting_area*(nvs.starting_area or 1) end
		if(g.water)then g.water=g.water*(nvs.water or 1) end
	end
	if(p.fgen_call)then
		mapgen.MergeSettings(g,remote.call(p.fgen_call[1],p.fgen_call[2],g))
	end
	return g
end


--[[ Planet Tables ]]--

warptorio.RegisterPlanet({
	key="normal", name="A Normal Planet", zone=0, rng=PlanetRNG("normal"),
	desc="This world reminds you of home.",
	modifiers={{"nauvis"}},
	gen=nil, -- The base planet map_gen_settings table

	tick_speed=nil, -- =(60*60*minutes) -- runs the tick calls every X ticks
	required_controls=nil, -- {"iron-ore"} -- Mod compatability: This planet REQUIRES a certain autoplace_control.
	required_tiles=nil, -- {"grass-1"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.tile
	required_ents=nil, -- {"enemy-base"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.entity
	required_decor=nil, -- {"shrub-x"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.decorative

	-- Call tables are used for remote interfaces: { {"remote_interface","remote_name"} }
	fgen_call=nil, -- Final function calls on map_gen_settings, behaving similar to a modifier function but planet specific.
	spawn_call=nil, -- Function calls after surface is created.
	warpout_call=nil, -- Function called upon warpout of this planet event{oldsurface=surface,oldplanet=planet_table,newsurface=surface,newplanet=planet_table}
	postwarpout_call=nil, -- Function called upon warpout of this planet event{oldsurface=surface,oldplanet=planet_table,newsurface=surface,newplanet=planet_table}

	-- Built-in event calls:
	on_built_entity_call=nil,
	on_robot_built_entity_call=nil,
	script_raised_built=nil,
	script_raised_revive=nil,
	on_chunk_generated_call=nil,
	on_chunk_deleted_call=nil,
	on_entity_died_call=nil,
	on_tick_call=nil,

	fgen=nil, -- function(map_gen_settings) end, -- planet modify function (warptorio internal)
	spawn=nil, -- function(surface_object, table_of_modifier_return_values) -- planet spawn function (warptorio internal)
	tick=nil, -- function(surface_object, event_variable) -- planet tick function (warptorio internal)
	chunk=nil, -- function(surface_object, event_variable) -- planet on_chunk_generated function (warptorio internal)
	warpout=nil, -- function(oldsurface,oldplanet,newsurface,newplanet) -- planet on warpout (warptorio internal)
	postwarpout=nil, -- function(oldsurface,oldplanet,newsurface,newplanet) -- planet on warpout (warptorio internal)
})

warptorio.RegisterPlanet({ key="uncharted", name="An Uncharted Planet", zone=1, rng=PlanetRNG("uncharted"), -- default nauvis generation (modded)
	desc="You prospect your surroundings and gaze at the stars, and you wonder if this world has ever had a name.",
})


warptorio.RegisterPlanet({ key="average", name="An Average Planet", zone=3,rng=PlanetRNG("average"),
	desc="The usual critters and riches surrounds you, but you feel like something is missing.",
	modifiers={{"nauvis"},{"resource_set_random",{random=2,value=0}}},
})

warptorio.RegisterPlanet({
	key="barren", name="A Barren Planet", zone=12, rng=PlanetRNG("barren"), warptime=0.5, nowater=true, rest=true,
	desc="This world looks deserted and we appear to be safe. .. For now.",
	modifiers={
		{"nauvis",{tiles={"dirt","sand"},ents={"rock"},decor={"rock"},autoplace=false}},
		{"water",0},
		{"rocks",PCR(2,2,1)},
		{"entity",{{"rock"},PCR(2,2,1)}},
	},
})

warptorio.RegisterPlanet({
	key="ocean", name="An Ocean Planet", zone=3, rng=PlanetRNG("ocean"), warptime=0.5, rest=true,
	desc="There is water all around and seems to go on forever. The nearby fish that greet you fills you with determination.",
	modifiers={
		{"nauvis",{tiles={"grass","water"},ents={"fish","tree","trunk"},autoplace={"tree"}}},
		{"rocks",0},
		{"trees",PCR(3.25,0.1,0.3)},
		{"entity",{"tree",PCR(3.25,0.1,0.3)}},
		{"water",100000},
		{"starting_area",0},
		{"entity",{"fish",8}}
	},
})

warptorio.RegisterPlanet({
	key="jungle", name="A Jungle Planet", zone=27, rng=PlanetRNG("jungle"), warptime=1, rest=true,
	desc="These trees might be enough to conceal your location from the natives. .. At least for a while.",
	modifiers={
		{"nauvis"},
		{"resource_set_all",0.5},
		{"trees",PCR(18,0.5,0.4)},
		{"entity",{"tree",PCR(26,0.55,0.4)}},
		{"starting_area",0.7},
		{"moisture",0.7},
		{"temperature",9},
		{"aux",0.1},
		{"daytime",{random={0,1}}},
	},
})

warptorio.RegisterPlanet({
	key="dwarf", name="A Dwarf Planet", zone=12, rng=PlanetRNG("dwarf"), warptime=1,
	desc="You are like a giant to the creatures of this planet. .. And to its natural resources.",
	modifiers={{"nauvis"},{"resource_set_all",0.35},{"biters",PCR(0.5,0.5,1)}},
})

warptorio.RegisterPlanet({
	key="rich", name="A Rich Planet", zone=60, rng=PlanetRNG("rich"), warptime=1,
	desc="A Rich Planet Description",
	modifiers={{"nauvis"},{"resource_set_all",PCR(4,2,1)},{"biters",PCR(1.25)}},
})

warptorio.RegisterPlanet({
	key="iron", name="An Iron Planet", zone=5, rng=PlanetRNG("res"), warptime=1,
	desc="You land with a loud metal clang. The sparkle in the ground fills you with determination.",
	modifiers={ {"nauvis"},{"resource_set_all",0.3},{"resource_set",{["iron-ore"]=PCR(4,2,1)}} },
	required_controls={"iron-ore"},
})

warptorio.RegisterPlanet({
	key="copper", name="A Copper Planet", zone=8, rng=PlanetRNG("res"), warptime=1,
	desc="The warp reactor surges with power and you feel static in the air. You are filled with determination.",
	modifiers={ {"nauvis"},{"resource_set_all",0.3},{"resource_set",{["copper-ore"]=PCR(4,2,1)}} },
	required_controls={"copper-ore"},
})

warptorio.RegisterPlanet({
	key="coal", name="A Coal Planet", zone=7, rng=PlanetRNG("res"), warptime=1,
	desc="The piles of raw fuel strewn about this world makes you wonder about the grand forest that once thrived here, a very long time ago.",
	modifiers={ {"nauvis"},{"resource_set_all",0.3},{"resource_set",{["coal"]=PCR(7,2,1)}} },
	required_controls={"coal"},
})

warptorio.RegisterPlanet({
	key="stone", name="A Stone Planet", zone=15, rng=PlanetRNG("res"), warptime=1,
	desc="This planet is like your jouney through warpspacetime. Stuck somewhere between a rock and a hard place.",
	modifiers={ {"nauvis"},{"resource_set_all",0.3},{"resource_set",{["stone"]=PCR(7,2,1)}} },
	required_controls={"stone"},
})

warptorio.RegisterPlanet({
	key="oil", name="An Oil Planet", zone=15, rng=PlanetRNG("res"), warptime=1,
	desc="This place has been a wellspring of life for millenia, but now they are just more fuel for your flamethrowers.",
	modifiers={ {"nauvis"},{"resource_set_all",0.3},{"resource_set",{["crude-oil"]=PCR(7,2,1)}},{"biters",PCR(1.15,1.15,1)} },
	required_controls={"crude-oil"},
})

warptorio.RegisterPlanet({
	key="uranium", name="A Uranium Planet", zone=30, rng=PlanetRNG("res"), warptime=1,
	desc="The warmth of this worlds green glow fills you with determination, but you probably shouldn't stay too long",
	modifiers={ {"nauvis"},{"resource_set_all",0.3},{"resource_set",{["uranium-ore"]=PCR(8,2,1)}},{"biters",PCR(1.35,1.35,1)} },
	required_controls={"uranium-ore"},
})

warptorio.RegisterPlanet({
	key="midnight", name="A Planet Called Midnight", zone=20, rng=PlanetRNG("midnight"), warptime=1.5, biter=true,
	desc="Your hands disappear before your eyes as you are shrouded in darkness. This place seems dangerous.",
	modifiers={ {"nauvis"},{"biters",PCR(2)},{"daytime",{time=0.5,freeze=true}} },
})

warptorio.RegisterPlanet({
	key="polluted", name="A Polluted Planet", zone=40, rng=PlanetRNG("polluted"), warptime=1.5, biter=true,
	desc="A heavy aroma of grease and machinery suddenly wafts over the platform and you wonder if you have been here before.",
	modifiers={ {"nauvis"},{"resource_set_all",0.75},{"biters",PCR(1.75)} },
	spawn=function(f,g,chart)
		for x=-5,5,1 do for y=-5,5,1 do f.pollute({x*32,y*32},200) end end
	end,
})

warptorio.RegisterPlanet({
	key="biter", name="A Biter Planet", zone=60, rng=PlanetRNG("biter"), warptime=1.2, biter=true,
	desc="Within moments of warping in, your factory is immediately under siege. We must survive until the next warp!",
	modifiers={ {"nauvis"},{"biters",PCR(8)},{"starting_area",0.3} },
})

warptorio.RegisterPlanet({
	key="rogue", name="A Rogue Planet", zone=100, rng=PlanetRNG("rogue"), warptime=1.25, nowater=true, biter=true,
	desc="Ah, just your usual barren wasteland, nothing to worry about. But something seems a little off.",
	modifiers={
		{"nauvis",{tiles={"dirt","sand"},decor={"rock"}}},
		{"resource_set_all",0},
		{"decor",PCR(0.1,0.1,0.1)},
		{"water",0},
		{"starting_area",1.8},
		{"biters",3},
		{"rocks",PCR(2,2,1)},
		{"entity",{{"rock"},PCR(2,2,1)}},

		{"trees",PCR(1.25,0.075,0.3)},
		{"entity",{"tree",PCR(1.25,0.075,0.3)}},
		{"daytime",{time=0.35,freeze=true}},
	},
})


--[[warptorio.RegisterPlanet({
	key="void", name="Warpspace Void", zone=50, rng=PlanetRNG("void"), warptime=1.75, nowater=true,
	desc="What on earth was that, where are we!? Something went wrong with the warp reactor and we are stranded in a vast nothingness.",
	modifiers={{"nauvis",{tiles={"dirt","sand"}}},{"water",0},{"starting_area",2.5},{"biters",3}},
})]]



