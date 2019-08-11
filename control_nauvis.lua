--[[

















						-_-
























game.tile_prototypes:

--"water-green","water-mud","water-shallow","deepwater-green",

game.autoplace_control_prototypes:


game.noise_layer_prototypes:


-- game.decorative_prototypes, but with alien biomes on:
"brown-hairy-grass=,green-hairy-grass","hairy-grass-blue","hairy-grass-green","hairy-grass-mauve","hairy-grass-olive","hairy-grass-orange",
"hairy-grass-purple","hairy-grass-red","hairy-grass-turquoise","hairy-grass-violet","hairy-grass-yellow","brown-carpet-grass","carpet-grass-blue",
"carpet-grass-green","carpet-grass-mauve","carpet-grass-olive","carpet-grass-orange","carpet-grass-purple","carpet-grass-red","carpet-grass-turquoise",
"carpet-grass-violet","carpet-grass-yellow","green-carpet-grass","green-small-grass","small-grass-blue","small-grass-green","small-grass-mauve",
"small-grass-olive","small-grass-orange","small-grass-purple","small-grass-red","small-grass-turquoise","small-grass-violet","small-grass-yellow",
"asterisk-blue","asterisk-green","asterisk-mauve","asterisk-olive","asterisk-orange","asterisk-purple","asterisk-red","asterisk-turquoise",
"asterisk-violet","asterisk-yellow","cane-cluster","cane-single","green-asterisk","brown-asterisk-mini","asterisk-mini-blue","asterisk-mini-green",
"asterisk-mini-mauve","asterisk-mini-olive","asterisk-mini-orange","asterisk-mini-purple","asterisk-mini-red","asterisk-mini-turquoise",
"asterisk-mini-violet","asterisk-mini-yellow","green-asterisk-mini","brown-asterisk","red-asterisk","crater1-large","crater1-large-rare",
"crater2-medium","crater3-huge","crater4-small","lava-decal-blue","lava-decal-green","lava-decal-orange","lava-decal-purple","puddle-decal",
"wetland-decal","dark-mud-decal","light-mud-decal","puberty-decal","red-desert-decal","sand-decal","sand-decal-black","sand-decal-purple",
"sand-decal-red","sand-decal-tan","sand-decal-volcanic","sand-decal-white","sand-dune-decal","sand-dune-decal-aubergine","sand-dune-decal-beige",
"sand-dune-decal-black","sand-dune-decal-brown","sand-dune-decal-cream","sand-dune-decal-dustyrose","sand-dune-decal-grey","sand-dune-decal-purple",
"sand-dune-decal-red","sand-dune-decal-tan","sand-dune-decal-violet","sand-dune-decal-white","stone-decal-black","stone-decal-purple","stone-decal-red",
"stone-decal-tan","stone-decal-volcanic","stone-decal-white","green-pita","pita-blue","pita-green","pita-mauve","pita-olive","pita-orange","pita-purple",
"pita-red","pita-turquoise","pita-violet","pita-yellow","red-pita","croton-blue","croton-green","croton-mauve","croton-olive","croton-orange",
"croton-purple","croton-red","croton-turquoise","croton-violet","croton-yellow","green-croton","red-croton","green-pita-mini","pita-mini-blue",
"pita-mini-green","pita-mini-mauve","pita-mini-olive","pita-mini-orange","pita-mini-purple","pita-mini-red","pita-mini-turquoise","pita-mini-violet",
"pita-mini-yellow","brown-fluff","brown-fluff-dry","flower-bush-blue-pink","flower-bush-green-pink","flower-bush-green-yellow","flower-bush-red-blue",
"desert-bush-blue","desert-bush-green","desert-bush-mauve","desert-bush-olive","desert-bush-orange","desert-bush-purple","desert-bush-red",
"desert-bush-turquoise","desert-bush-violet","desert-bush-yellow","green-desert-bush","red-desert-bush","white-desert-bush","garballo-mini-dry",
"garballo","bush-mini-blue","bush-mini-green","bush-mini-mauve","bush-mini-olive","bush-mini-orange","bush-mini-purple","bush-mini-red",
"bush-mini-turquoise","bush-mini-violet","bush-mini-yellow","green-bush-mini","lichen","rock-medium","rock-medium-aubergine","rock-medium-beige",
"rock-medium-black","rock-medium-brown","rock-medium-cream","rock-medium-dustyrose","rock-medium-grey","rock-medium-purple","rock-medium-red",
"rock-medium-tan","rock-medium-violet","rock-medium-volcanic","rock-medium-white","rock-small","rock-small-aubergine","rock-small-beige",
"rock-small-black","rock-small-brown","rock-small-cream","rock-small-dustyrose","rock-small-grey","rock-small-purple","rock-small-red",
"rock-small-tan","rock-small-violet","rock-small-volcanic","rock-small-white","rock-tiny","rock-tiny-aubergine","rock-tiny-beige",
"rock-tiny-black","rock-tiny-brown","rock-tiny-cream","rock-tiny-dustyrose","rock-tiny-grey","rock-tiny-purple","rock-tiny-red","rock-tiny-tan",
"rock-tiny-violet","rock-tiny-volcanic","rock-tiny-white","big-ship-wreck-grass","sand-rock-medium","sand-rock-medium-black","sand-rock-medium-purple",
"sand-rock-medium-red","sand-rock-medium-tan","sand-rock-medium-white","sand-rock-small","sand-rock-small-black","sand-rock-small-purple",
"sand-rock-small-red","sand-rock-small-tan","sand-rock-small-white","small-ship-wreck-grass",


]]


local gwarptorio=setmetatable({},{__index=function(t,k) return global.warptorio[k] end,__newindex=function(t,k,v) global.warptorio[k]=v end})
local nauvis={} warptorio.nauvis=nauvis
nauvis.autoplace_controls={"iron-ore","copper-ore","stone","coal","uranium-ore","crude-oil","trees","enemy-base"}
nauvis.resource={"iron-ore","copper-ore","stone","coal","uranium-ore","crude-oil"}

nauvis.tile={
"concrete","deepwater","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7","dry-dirt",
"grass-1","grass-2","grass-3","grass-4","hazard-concrete-left","hazard-concrete-right",
"lab-dark-1","lab-dark-2","lab-white","landfill","out-of-map",
"red-desert-0","red-desert-1","red-desert-2","red-desert-3",
"refined-concrete","refined-hazard-concrete-left","refined-hazard-concrete-right",
"sand-1","sand-2","sand-3","stone-path","tutorial-grid",
"warp-tile-concrete","water",
}

nauvis.noise={
"aux","brown-fluff","coal","copper-ore","crude-oil","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7","dry-dirt",
"elevation","elevation-persistence","enemy-base","fluff","garballo",
"grass-1","grass-2","grass-3","grass-4","grass1","grass2","green-fluff","iron-ore","moisture","pita","pita-mini",
"red-desert-0","red-desert-1","red-desert-2","red-desert-3","red-desert-decal","rocks",
"sand-1","sand-2","sand-3","sand-decal","sand-dune-decal","starting-area","stone","temperature",
"trees","trees-1","trees-10","trees-11","trees-12","trees-13","trees-14","trees-15","trees-2","trees-3","trees-4","trees-5","trees-6","trees-7","trees-8","trees-9",
"uranium-ore",
}


nauvis.alienbiomes={ -- tile-alias.lua -- mod compatability -_-
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
}
for k,v in pairs{'rock-huge','rock-big','rock-medium','rock-small','rock-tiny'}do nauvis.alienbiomes[v]=v.."-white" end
for k,v in pairs{"sand-rock-tiny","sand-rock-small","sand-rock-medium","sand-rock-big","sand-rock-huge"}do nauvis.alienbiomes[v]=v.."-white" end


warptorio.alienBiomes=false
function warptorio.DoAlienBiomesTiles(x)
	if(not x.autoplace_settings)then x.autoplace_settings={} end
	if(not x.autoplace_settings.tile)then x.autoplace_settings.tile={settings={}} end
	if(not x.autoplace_settings.decorative)then x.autoplace_settings.decorative={settings={}} end
	if(not x.autoplace_settings.entity)then x.autoplace_settings.entity={settings={}} end
	for k,v in pairs(warptorio.GetModTiles())do if(not x.autoplace_settings.tile.settings[v])then x.autoplace_settings.tile.settings[v]={frequency=0,size=0} end end
	for k,v in pairs(warptorio.GetModAutoplacements())do if(not x.autoplace_settings.decorative.settings[v])then x.autoplace_settings.decorative.settings[v]={frequency=0,size=0} end end
	for k,v in pairs(warptorio.GetModNoise())do if(not x.autoplace_settings.decorative.settings[v])then x.autoplace_settings.decorative.settings[v]={frequency=0,size=0} end end
	for k,v in pairs(x.autoplace_settings.tile.settings)do
		if(nauvis.alienbiomes[k])then x.autoplace_settings.tile.settings[nauvis.alienbiomes[k]]=v x.autoplace_settings.tile.settings[k]={frequency=0,size=0} end
	end
	for k,v in pairs(x.autoplace_settings.entity.settings)do
		if(nauvis.alienbiomes[k])then x.autoplace_settings.entity.settings[nauvis.alienbiomes[k]]=v x.autoplace_settings.entity.settings[k]={frequency=0,size=0} end
	end
	return x
end

function warptorio.GetModTiles() if(warptorio.ModTiles)then return warptorio.ModTiles end local pt=game.tile_prototypes local at={}
	if(warptorio.alienBiomes)then game.print("Alien Biomes Detected") end
	for k,v in pairs(pt)do if(v.autoplace_specification and not table.HasValue(nauvis.tile,v.name) and (not warptorio.alienBiomes or not table.HasValue(nauvis.alienbiomes,v.name)) )then
		table.insert(at,v.name)
	end end
	warptorio.ModTiles=at return at
end
function warptorio.GetAllResources() if(warptorio.AllResources)then return warptorio.AllResources end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(v.category=="resource")then table.insert(at,v.name) end end warptorio.AllResources=at return at
end
function warptorio.GetModResources() if(warptorio.ModResources)then return warptorio.ModResources end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(v.category=="resource" and not table.HasValue(nauvis.autoplace_controls,v.name))then table.insert(at,v.name) end end warptorio.ModResources=at return at
end
function warptorio.GetModAutoplacements() if(warptorio.ModAutoplacements)then return warptorio.ModAutoplacements end local pt=game.autoplace_control_prototypes local at={}
	for k,v in pairs(pt)do if(not table.HasValue(nauvis.autoplace_controls,v.name) and v.category~="resource")then table.insert(at,v.name) end end warptorio.ModAutoplacements=at return at
end
function warptorio.GetModNoise() if(warptorio.ModNoise)then return warptorio.ModNoise end local pt=game.noise_layer_prototypes local at={}
	for k,v in pairs(pt)do if(not table.HasValue(nauvis.noise,v.name))then table.insert(at,v.name) end end warptorio.ModNoise=at return at
end



function istable(v) return type(v)=="table" end
function table.Print(t,f,j) local s="" for k,v in pairs(t)do s=s..tostring(k).."=" if(j)then s=s..j(v) elseif(istable(v) and not f)then s=s .. " {" .. table.Print(v) .. "}\n" else s=s.."="..tostring((f and f(v) or v)).."," end end return s end
local function istable(v) return type(v)=="table" end

function warptorio.OverrideNauvis(bClear)
	local f=table.deepcopy(game.surfaces[1].map_gen_settings)
	for k,v in pairs(warptorio.GetModAutoplacements())do
		if(v and not table.HasValue(nauvis.resource,v))then
			f.autoplace_controls[v]={frequency=0,size=0,richness=0}
		end
	end
	f.autoplace_settings={tile={settings={}},decorative={settings={}}}
	for k,v in pairs(warptorio.GetModTiles())do f.autoplace_settings.tile.settings[v]={frequency=0,size=0} end
	for k,v in pairs(warptorio.GetModAutoplacements())do f.autoplace_settings.decorative.settings[v]={frequency=0,size=0} end
	for k,v in pairs(warptorio.GetModNoise())do f.autoplace_settings.decorative.settings[v]={frequency=0,size=0} end
	
	game.surfaces[1].map_gen_settings=f

	if(bClear)then
		local nvs=game.surfaces[1]
		--game.surfaces[1].clear(true)
		--for v in nvs.get_chunks() do nvs.delete_chunk{v.x,v.y} end
		--nvs.request_to_generate_chunks({0,0},32)
		--nvs.force_generate_chunk_requests()
		--local n=10 game.forces.player.chart(game.surfaces[1],{lefttop={x=-n,y=-n},rightbottom={x=n,y=n}})
	end
end

--/c  
