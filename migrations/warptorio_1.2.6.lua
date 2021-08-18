if(global.warptorio)then
table.deepmerge(global,global.warptorio)
global.warptorio=nil
end

if(not global.floor.factory)then

global.floor.factory=global.floor.b1
global.floor.boiler=global.floor.b2
global.floor.harvester=global.floor.b3
global.floor.b1=nil
global.floor.b2=nil
global.floor.b3=nil
global.floor.factory.name="factory"
global.floor.boiler.name="boiler"
global.floor.harvester.name="harvester"

for k,v in pairs(global.floor)do
	v.host=v.surface
	v.surface=nil
	v.key=v.name
	if(v.host and v.host.valid)then v.hostindex=v.host.index end
end

cache.init()

local function migratePart(tbl)
	tbl[1]=tbl.a tbl.a=nil
	tbl[2]=tbl.b tbl.b=nil
end

--error(serpent.block(global.Harvesters))
for k,v in pairs(global.Harvesters)do if(not v.key)then
	v.BEnergy=nil
	setmetatable(v,warptorio.HarvesterMeta)
	v.key=k
	if(v.a and v.a.valid)then v.a.destroy() end if(v.b and v.b.valid)then v.b.destroy() end
	v.a=nil v.b=nil
	if(v.comboA and v.comboA.valid)then v.comboA.destroy() end if(v.comboB and v.comboB.valid)then v.comboB.destroy() end
	v.comboA=nil v.comboB=nil
	v.combos={}
	v.loaders[1]=v.loaders.a v.loaders.a=nil
	v.loaders[2]=v.loaders.b v.loaders.b=nil
	v.pipes={{},{}}
	migratePart(v.dir)
	migratePart(v.loaderFilter)

	local gdata=warptorio.platform.harvesters[v.key]

	v.__init(v,gdata,true)


end end
--error(serpent.block(global.Harvesters))

local translateNames={
["b1"]="main_to_factory",
["b2"]="factory_to_harvester",
["b3"]="harvester_to_boiler",
["nw"]="main_tur_factory_nw",
["ne"]="main_tur_factory_ne",
["sw"]="main_tur_factory_sw",
["se"]="main_tur_factory_se",
}

for k,v in pairs(global.Teleporters)do if(not v.key)then
	setmetatable(v,warptorio.TeleporterMeta)
	v.key=translateNames[k] or k
	v.name=v.key
	v.a.destroy() v.b.destroy()
	v.a=nil v.b=nil

	global.Teleporters[v.key]=v
	v.points={{},{}}

	if(v.chests)then migratePart(v.chests) end
	v.chestcontents=v.chestcont v.chestcont=nil
	if(v.chestcontents)then migratePart(v.chestcontents) end
	migratePart(v.dir)
	migratePart(v.loaderFilter)
	migratePart(v.loaders)
	migratePart(v.pipes)
	--for i,e in pairs(v.sprites)do if(e and rendering.is_valid(e))then rendering.destroy(e) end end
	v.sprites=nil

	v.__init(v,v:Data(),false)


end end
for k,v in pairs(translateNames)do global.Teleporters[k]=nil end

--error(serpent.block(global.Rails))
for k,v in pairs(global.Rails)do if(not v.key)then
	setmetatable(v,warptorio.RailMeta)
	v.key=v.name
	for i,e in pairs(v.loaders)do e.destroy() end
	v.loaders={{},{},{},{}}
	v.chests[1]={}
	for i,e in pairs(v.chests)do if(i~=1)then table.insert(v.chests[1],e) v.chests[i]=nil end end

end end




--[[

global.Harvesters=nil
global.Teleporters=nil
global.Rails=nil



for k,v in pairs(g.Teleporters)do
	v.sprites=v.sprites or {}
	v:CheckSprites()
end
]]
end

game.print("Warptorio Migration 1.2.6")