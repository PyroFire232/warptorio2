local gwarptorio=setmetatable({},{__index=function(t,k) return global.warptorio[k] end,__newindex=function(t,k,v) global.warptorio[k]=v end})

local function istable(x) return type(x)=="table" end
local function printx(m) for k,v in pairs(game.players)do v.print(m) end end
local function isvalid(v) return (v and v.valid) end
local function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end

-- -------
-- Upgrades

local upcs={} warptorio.UpgradeClass=upcs

function warptorio.DoUpgrade(ev) local up=ev.name local u=warptorio.Research[up] if(u)then --game.print("doneresearch: " .. up .. ", " .. tostring(ev.level))
	if(type(u)=="table")then local lv=ev.level or 0 gwarptorio.Research[u[1]]=lv local c=warptorio.UpgradeClass[u[1]]
		if(u[3])then u[2](lv) elseif(c)then c(lv,u[2]) end -- (gwarptorio.Research[u[1]] or 0)+1
	elseif(type(u)=="function")then u(ev.level or 0) end
end end script.on_event(defines.events.on_research_finished,function(event) warptorio.DoUpgrade(event.research) warptorio.BuildHazards() end)

function warptorio.GetUpgrade(up) local u=warptorio.Research[u] if(u)then
	if(type(u)=="table")then local lv=gwarptorio.Research[u[1]] or 0 return lv,u[2] end
end end

upcs["platform-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.floor.main m.size=n warptorio.BuildPlatform(true) end
upcs["factory-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.floor.b1 m.size=n warptorio.BuildB1(true) end
upcs["boiler-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.floor.b2 m.size=n warptorio.BuildB2(true) end
upcs["harvester-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.floor.b3 m.ovalsize=n warptorio.BuildB3(true) end
upcs["harvester-east-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.floor.b3 local hv=gwarptorio.Harvesters.east
	if(not hv)then warptorio.Harvesters.east:Warpin() end hv=gwarptorio.Harvesters.east
	hv.next_size=n hv:Upgrade() --m.harvest_east=n
	
--[[	local brc=false if(hv and hv.deployed)then brc=hv.deploy_position hv:Recall() end
	warptorio.BuildB3(true) warptorio.Harvesters.east:Warpin()
	if(brc)then hv:Deploy(warptorio.GetPlanetSurface(),brc) end]]
end
upcs["harvester-west-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.floor.b3 local hv=gwarptorio.Harvesters.west
	if(not hv)then warptorio.Harvesters.west:Warpin() end hv=gwarptorio.Harvesters.west
	hv.next_size=n hv:Upgrade() -- m.harvest_west=n
--[[	local brc=false if(hv and hv.deployed)then brc=hv.deploy_position hv:Recall() end
	warptorio.BuildB3(true) warptorio.Harvesters.west:Warpin()
	if(brc)then hv:Deploy(warptorio.GetPlanetSurface(),brc) end]]
end

--upcs["harvester-west-loader"]=function(lv,f) local hv=gwarptorio.Harvesters.west if(hv)then hv:SpawnLogs() end end
--upcs["harvester-east-loader"]=function(lv,f) local hv=gwarptorio.Harvesters.east if(hv)then hv:SpawnLogs() end end

upcs["teleporter-energy"]=function(lv) if(not gwarptorio.Teleporters.offworld)then warptorio.BuildPlatform(true) warptorio.Teleporters.offworld:Warpin() else warptorio.BuildPlatform(true) gwarptorio.Teleporters.offworld:UpgradeEnergy() end end
upcs["factory-logistics"]=function(lv) warptorio.RebuildFloors(true)
	for k,v in pairs(gwarptorio.Teleporters)do v:UpgradeLogistics() end
	for k,v in pairs(gwarptorio.Rails)do v:DoMakes(true) end
	for k,v in pairs(gwarptorio.Harvesters)do v:UpgradeLogistics() end
end
upcs["factory-energy"]=function(lv) local m=gwarptorio.Teleporters
	if(m.b1)then m.b1:UpgradeEnergy() end if(m.b2)then m.b2:UpgradeEnergy() end if(m.b3)then m.b3:UpgradeEnergy() end
	for k,v in pairs({"nw","ne","sw","se"}) do if(m[v])then m[v]:UpgradeEnergy() end end
	for k,v in pairs({"nw","ne","sw","se"})do if(m[v])then m[v]:UpgradeEnergy() end end
	for k,v in pairs(gwarptorio.Harvesters)do v:UpgradeEnergy() end
end

upcs["factory-beacon"]=function(lv,f) local m=gwarptorio.floor.b1
	m:CheckSpecial()
--[[	local inv={}
	if(m.beacon and m.beacon.valid)then inv=m.beacon.get_module_inventory().get_contents() end
	vector.clean(m.surface,vector.area(vector(-2,-2),vector(3,3))) m.beacon=entity.protect(entity.create(m.surface,"warptorio-beacon-"..lv,vector(-1,-1)))
	for k,v in pairs(inv)do m.beacon.get_module_inventory().insert({name=k,count=v}) end
	players.playsound("warp_in",m.surface)]]
end

upcs["boiler-station"]=function(lv,f) local m=gwarptorio.floor.b2
	m:CheckSpecial()
--[[	if(m.station and m.station.valid)then return end
	vector.clean(m.surface,vector.area(vector(-2,-2),vector(1,1))) m.station=entity.protect(entity.create(m.surface,"warptorio-warpstation",vector(-1,-1)))
	players.playsound("warp_in",m.surface)]]
end



upcs["reactor"]=function(lv) local m=gwarptorio.floor.main players.playsound("warp_in",m.surface)
	for i=1,3,1 do for x,ply in pairs(game.players)do ply.print{"warptorio_lore."..lv.."_"..i} end end
	if(lv>=6 and not gwarptorio.warp_reactor)then warptorio.CheckReactor()
		--local f=m.surface
		--vector.clean(f,vector.area(vector(-3,-3),vector(5,5)))
		--local e=gwarptorio.floor.main.surface.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player,player=game.players[1]}
		--vector.cleanplayers(f,vector.area(vector(-3,-3),vector(5,5)))
		--gwarptorio.warp_reactor=e
		--e.minable=false
	end
	if(lv<6)then
		gwarptorio.warp_auto_time=gwarptorio.warp_auto_time+60*10
	end

	if(lv>=8)then warptorio.ResetGui() end
end
--[[upcs["stabilizer"]=function(lv) local m=gwarptorio.floor.main
	warptorio.cleanbbox(m.surface,-6,-2,-4,0) local e=warptorio.SpawnEntity(m.surface,"warptorio-stabilizer-"..lv,-5,-1) m.stabilizer=e e.minable=false
	warptorio.playsound("warp_in",m.surface.name)
end
upcs["accelerator"]=function(lv) local m=gwarptorio.floor.main
	warptorio.cleanbbox(m.surface,-3,-3,2,2) local e=warptorio.SpawnEntity(m.surface,"warptorio-accelerator-"..lv,4,-1) e.minable=false
end]]

upcs["dualloader"]=function(lv) warptorio.RebuildFloors(true)
	for k,v in pairs(gwarptorio.Teleporters)do if(k=="b1" or k=="b2" or k=="b3")then v:UpgradeLogistics() end end
	for k,v in pairs(gwarptorio.Harvesters)do v:UpgradeLogistics() end
end
upcs["triloader"]=function(lv) warptorio.RebuildFloors(true) for k,m in pairs(gwarptorio.Teleporters)do m:UpgradeLogistics() end for k,v in pairs(gwarptorio.Harvesters)do v:UpgradeLogistics() end end
upcs["bridgesize"]=function(lv) warptorio.BuildB1(true) end


local ups={} warptorio.Research=warptorio.Research or ups
ups["warptorio-platform-size-1"] = {"platform-size",function() return 10+7-1 end}
ups["warptorio-platform-size-2"] = {"platform-size",function() return 18+7-1 end}
ups["warptorio-platform-size-3"] = {"platform-size",function() return 26+7-1 end}
ups["warptorio-platform-size-4"] = {"platform-size",function() return 40+7-1 end}
ups["warptorio-platform-size-5"] = {"platform-size",function() return 56+7-1+2 end}
ups["warptorio-platform-size-6"] = {"platform-size",function() return 74+7-1+2 end}
ups["warptorio-platform-size-7"] = {"platform-size",function() return 92+7-1+4 end}

ups["warptorio-rail-nw"] = function() gwarptorio.rail_nw=true warptorio.BuildRailCorner("nw") end
ups["warptorio-rail-ne"] = function() gwarptorio.rail_ne=true warptorio.BuildRailCorner("ne") end
ups["warptorio-rail-sw"] = function() gwarptorio.rail_sw=true warptorio.BuildRailCorner("sw") end
ups["warptorio-rail-se"] = function() gwarptorio.rail_se=true warptorio.BuildRailCorner("se") end

ups["warptorio-factory-0"] = {"factory-size",function() warptorio.BuildPlatform(true) warptorio.BuildB1(true) warptorio.Teleporters.b1:Warpin() end,true} -- 17
ups["warptorio-factory-1"] = {"factory-size",function() return 23-1 end}
ups["warptorio-factory-2"] = {"factory-size",function() return 31-1 end}
ups["warptorio-factory-3"] = {"factory-size",function() return 39-1 end}
ups["warptorio-factory-4"] = {"factory-size",function() return 47-1 end}
ups["warptorio-factory-5"] = {"factory-size",function() return 55-1 end}
ups["warptorio-factory-6"] = {"factory-size",function() return 63-1 end}
ups["warptorio-factory-7"] = {"factory-size",function() return 71+2-1 end}

ups["warptorio-boiler-0"] = {"boiler-size",function() warptorio.BuildB2(true) warptorio.BuildB3(true) warptorio.Teleporters.b3:Warpin() end,true}
ups["warptorio-boiler-1"] = {"boiler-size",function() return 24 end}
ups["warptorio-boiler-2"] = {"boiler-size",function() return 32 end}
ups["warptorio-boiler-3"] = {"boiler-size",function() return 40 end}
ups["warptorio-boiler-4"] = {"boiler-size",function() return 48 end}
ups["warptorio-boiler-5"] = {"boiler-size",function() return 56 end}
ups["warptorio-boiler-6"] = {"boiler-size",function() return 64 end}
ups["warptorio-boiler-7"] = {"boiler-size",function() return 72 end}

ups["warptorio-harvester-floor"] = function() warptorio.BuildB1(true) warptorio.BuildB3(true) warptorio.Teleporters.b2:Warpin() end -- default {19,17}, max {vector(128+8,64+4)}
ups["warptorio-harvester-size-1"] = {"harvester-size",function() return {x=28,y=22} end}
ups["warptorio-harvester-size-2"] = {"harvester-size",function() return {x=36,y=26} end}
ups["warptorio-harvester-size-3"] = {"harvester-size",function() return {x=48,y=32} end}
ups["warptorio-harvester-size-4"] = {"harvester-size",function() return {x=74,y=40} end}
ups["warptorio-harvester-size-5"] = {"harvester-size",function() return {x=92,y=48} end}
ups["warptorio-harvester-size-6"] = {"harvester-size",function() return {x=112,y=56} end}
ups["warptorio-harvester-size-7"] = {"harvester-size",function() return {x=128+8,y=64} end}

ups["warptorio-harvester-west-1"] = {"harvester-west-size",function() return 12 end}
ups["warptorio-harvester-west-2"] = {"harvester-west-size",function() return 20 end}
ups["warptorio-harvester-west-3"] = {"harvester-west-size",function() return 26 end}
ups["warptorio-harvester-west-4"] = {"harvester-west-size",function() return 32 end}
ups["warptorio-harvester-west-5"] = {"harvester-west-size",function() return 38 end}

ups["warptorio-harvester-east-1"] = {"harvester-east-size",function() return 12 end}
ups["warptorio-harvester-east-2"] = {"harvester-east-size",function() return 20 end}
ups["warptorio-harvester-east-3"] = {"harvester-east-size",function() return 26 end}
ups["warptorio-harvester-east-4"] = {"harvester-east-size",function() return 32 end}
ups["warptorio-harvester-east-5"] = {"harvester-east-size",function() return 38 end}

ups["warptorio-harvester-east-loader"] = {"harvester-east-loader"}
ups["warptorio-harvester-west-loader"] = {"harvester-west-loader"}

ups["warptorio-boiler-station"] = {"boiler-station"}

ups["warptorio-reactor-1"] = {"reactor"}
ups["warptorio-reactor-2"] = {"reactor"}
ups["warptorio-reactor-3"] = {"reactor"}
ups["warptorio-reactor-4"] = {"reactor"}
ups["warptorio-reactor-5"] = {"reactor"}
ups["warptorio-reactor-6"] = {"reactor"}
ups["warptorio-reactor-7"] = {"reactor"}
ups["warptorio-reactor-8"] = {"reactor"}

ups["warptorio-teleporter-portal"] = function() warptorio.BuildPlatform(true) warptorio.Teleporters.offworld:Warpin() end
ups["warptorio-teleporter-1"] = {"teleporter-energy"}
ups["warptorio-teleporter-2"] = {"teleporter-energy"}
ups["warptorio-teleporter-3"] = {"teleporter-energy"}
ups["warptorio-teleporter-4"] = {"teleporter-energy"}
ups["warptorio-teleporter-5"] = {"teleporter-energy"}

ups["warptorio-energy-1"] = {"factory-energy"}
ups["warptorio-energy-2"] = {"factory-energy"}
ups["warptorio-energy-3"] = {"factory-energy"}
ups["warptorio-energy-4"] = {"factory-energy"}
ups["warptorio-energy-5"] = {"factory-energy"}

ups["warptorio-logistics-1"] = {"factory-logistics"}
ups["warptorio-logistics-2"] = {"factory-logistics"}
ups["warptorio-logistics-3"] = {"factory-logistics"}
ups["warptorio-logistics-4"] = {"factory-logistics"}

ups["warptorio-beacon-1"] = {"factory-beacon"}
ups["warptorio-beacon-2"] = {"factory-beacon"}
ups["warptorio-beacon-3"] = {"factory-beacon"}
ups["warptorio-beacon-4"] = {"factory-beacon"}
ups["warptorio-beacon-5"] = {"factory-beacon"}
ups["warptorio-beacon-6"] = {"factory-beacon"}
ups["warptorio-beacon-7"] = {"factory-beacon"}
ups["warptorio-beacon-8"] = {"factory-beacon"}
ups["warptorio-beacon-9"] = {"factory-beacon"}
ups["warptorio-beacon-10"] = {"factory-beacon"}

ups["warptorio-stabilizer-1"] = {"stabilizer"}
ups["warptorio-stabilizer-2"] = {"stabilizer"}
ups["warptorio-stabilizer-3"] = {"stabilizer"}
ups["warptorio-stabilizer-4"] = {"stabilizer"}

ups["warptorio-dualloader-1"] = {"dualloader"}
ups["warptorio-dualloader-2"] = {"dualloader"}
ups["warptorio-dualloader-3"] = {"dualloader"}

ups["warptorio-triloader"] = {"triloader"}


ups["warptorio-accelerator"] = function() gwarptorio.accelerator=true for k,v in pairs(game.players)do warptorio.MakeGui(v) end end
ups["warptorio-stabilizer"] = function() gwarptorio.stabilizer=true for k,v in pairs(game.players)do warptorio.MakeGui(v) end end
ups["warptorio-charting"] = function() gwarptorio.charting=true for k,v in pairs(game.players)do warptorio.MakeGui(v) end gwarptorio.floor.b1:CheckRadar() gwarptorio.floor.b2:CheckRadar() end

ups["warptorio-toolbar"] = function() warptorio.ResetGui() end

ups["warptorio-duallogistic-1"] = function() gwarptorio.duallogistic=true end
ups["warptorio-warpenergy-0"] = function() gwarptorio.warpenergy=true end

upcs["turret-nw"] = function(lv) warptorio.BuildPlatform(true) warptorio.BuildB1(true) warptorio.Teleporters.nw:Warpin() end
upcs["turret-sw"] = function(lv) warptorio.BuildPlatform(true) warptorio.BuildB1(true) warptorio.Teleporters.sw:Warpin() end
upcs["turret-ne"] = function(lv) warptorio.BuildPlatform(true) warptorio.BuildB1(true) warptorio.Teleporters.ne:Warpin() end
upcs["turret-se"] = function(lv) warptorio.BuildPlatform(true) warptorio.BuildB1(true) warptorio.Teleporters.se:Warpin() end

for k,v in pairs{"nw","ne","se","sw"} do
ups["warptorio-turret-"..v.."-0"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-1"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-2"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-3"] = {"turret-"..v}
end

ups["warptorio-boiler-water-1"] = function() gwarptorio.waterboiler=1 warptorio.BuildB2(true) end
ups["warptorio-boiler-water-2"] = function() gwarptorio.waterboiler=2 warptorio.BuildB2(true) end
ups["warptorio-boiler-water-3"] = function() gwarptorio.waterboiler=3 warptorio.BuildB2(true) end
ups["warptorio-boiler-n"] = function() gwarptorio.boiler_n=true warptorio.BuildB2(true) end
ups["warptorio-boiler-s"] = function() gwarptorio.boiler_s=true warptorio.BuildB2(true) end
ups["warptorio-boiler-e"] = function() gwarptorio.boiler_e=true warptorio.BuildB2(true) end
ups["warptorio-boiler-w"] = function() gwarptorio.boiler_w=true warptorio.BuildB2(true) end

ups["warptorio-factory-n"] = function() gwarptorio.factory_n=true warptorio.BuildB1(true) end
ups["warptorio-factory-s"] = function() gwarptorio.factory_s=true warptorio.BuildB1(true) end
ups["warptorio-factory-e"] = function() gwarptorio.factory_e=true warptorio.BuildB1(true) end
ups["warptorio-factory-w"] = function() gwarptorio.factory_w=true warptorio.BuildB1(true) end

ups["warptorio-alt-combinator"]=function() for k,v in pairs(gwarptorio.Harvesters)do v:CheckCombo() end end


ups["warptorio-bridgesize-1"] = {"bridgesize"}
ups["warptorio-bridgesize-2"] = {"bridgesize"}


ups["warptorio-homeworld"] = function() local m=new(warptorio.FloorMeta,"home") m.surface=gwarptorio.floor.main.surface gwarptorio.homeworld=gwarptorio.warpzone warptorio.ResetGui() end

