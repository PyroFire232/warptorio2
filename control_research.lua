local gwarptorio=setmetatable({},{__index=function(t,k) return global.warptorio[k] end,__newindex=function(t,k,v) global.warptorio[k]=v end})

local function istable(x) return type(x)=="table" end
local function printx(m) for k,v in pairs(game.players)do v.print(m) end end
local function isvalid(v) return (v and v.valid) end
local function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end

-- -------
-- Upgrades

local upcs={} warptorio.UpgradeClass=upcs

function warptorio.DoUpgrade(ev) local up=ev.name local u=warptorio.Research[up] if(u)then game.print("doneresearch: " .. up .. ", " .. tostring(ev.level))
	if(type(u)=="table")then local lv=ev.level or 0 gwarptorio.Research[u[1]]=lv local c=warptorio.UpgradeClass[u[1]]
		if(u[3])then u[2](lv) elseif(c)then c(lv,u[2]) end -- (gwarptorio.Research[u[1]] or 0)+1
	elseif(type(u)=="function")then u(ev.level or 0) end
end end script.on_event(defines.events.on_research_finished,function(event) warptorio.DoUpgrade(event.research) end)

function warptorio.GetUpgrade(up) local u=warptorio.Research[u] if(u)then
	if(type(u)=="table")then local lv=gwarptorio.Research[u[1]] or 0 return lv,u[2] end
end end

upcs["platform-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.Floors.main m.OuterSize=n m:SetSize(m.OuterSize) warptorio.BuildPlatform() end
upcs["factory-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.Floors.b1 m:SetSize(n) warptorio.BuildB1() end
upcs["boiler-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.Floors.b2 m:SetSize(n) warptorio.BuildB2() end

upcs["teleporter-energy"]=function(lv) if(not gwarptorio.Teleporters.offworld)then warptorio.BuildPlatform() warptorio.TeleCls.offworld() end gwarptorio.Teleporters.offworld:UpgradeEnergy() end
upcs["factory-logistics"]=function(lv) warptorio.RebuildFloors() for k,v in pairs(gwarptorio.Teleporters)do v:UpgradeLogistics() end for k,v in pairs(gwarptorio.Rails)do v:DoMakes(true) end end
upcs["factory-energy"]=function(lv) local m=gwarptorio.Teleporters
	if(m.b1)then m.b1:UpgradeEnergy() end if(m.b2)then m.b2:UpgradeEnergy() end
	for k,v in pairs({"nw","ne","sw","se"}) do if(m[v])then m[v]:UpgradeEnergy() end end
end

upcs["factory-beacon"]=function(lv,f) local m=gwarptorio.Floors.b1 local inv={}
	if(m.beacon and m.beacon.valid)then inv=m.beacon.get_module_inventory().get_contents() end
	warptorio.cleanbbox(m:GetSurface(),-2,-2,3,3) m.beacon=warptorio.SpawnEntity(m:GetSurface(),"warptorio-beacon-"..lv,-1,-1) m.beacon.minable=false m.beacon.destructible=false
	for k,v in pairs(inv)do m.beacon.get_module_inventory().insert({name=k,count=v}) end
	warptorio.playsound("warp_in",m:GetSurface().name)
end

upcs["boiler-station"]=function(lv,f) local m=gwarptorio.Floors.b2
	if(m.station and m.station.valid)then return end
	warptorio.cleanbbox(m:GetSurface(),-2,-2,1,1) m.station=warptorio.SpawnEntity(m:GetSurface(),"warptorio-warpstation",-1,-1) m.station.minable=false m.station.destructible=false
	warptorio.playsound("warp_in",m:GetSurface().name)
end

local lvMsg={
	{"You first awoke with slight headache on this platform, and the only thing you feel sure of is that you need to rebuild your experiment to escape this dangerous world and return home.",
	"You cobble together some wires, switches and dials and attach it to the platform.",
	"Although you are unsure if you managed to achieve anything, you at least feel a bit more in control."},

	{"The memories of what happened begin to return to you. You were working on an experimental reactor that could distort and displace time and space.",
	"You recall your early experiments and proceed to replicate them with the crude resources you've found on your journey so far.",
	"The progress you feel you've made fills you with determination."},

	{"Ah yes, the experiment went bad! The Warp Reactor tore a rift in localized warpspace fabric casting you and the reactor into an alternate relative dimension in space.",
	"You hastily assemble the warp reactor control panel from memory, but then stop when you realize you need the reactor core before they can function.",
	"The feeling like you know what you need to do fills you with determination, if only you had the resources to do it."},

	{"Before the accident, you remember feeling excited about the endless applications of mastering the control of warpspace and became careless.",
	"You have finished building the reactor warpdis and rift core, but you are not going to make the same mistakes twice.",
	"Holding the pulsating warpdis in your hands fills you with determination.",},

	{"You think you know why your experiment went wrong, the warpdis must be unstable unless maintained by perfectly reversing the polarity inversely squared to the rift core's inter-subdimensional artron energy matrix.",
	"You ready the warpdis to rip the perfected materials you need directly out of warpspace.",
	"It's a risky strategy, but you believe this is your only chance to escape these savage alien infested worlds and get back to civilization.",},

	{"A loud clash of energy ripples over your warp platform as the reactor shifts into existence, and you know this technology will uplift your civilization beyond their imagination.",
	"You decide to continue your experiments with the warp reactor while you warp through world after world in search of home, if only you knew how to steer this boat.",
	"The Warp Reactor finally now in place fills you with determination."},

	{"You have developed a way to build a miniaturized warpdis connected to your reactors rift core, allowing the transfer of heat energy through warpspace",
	"You believe this may be further refined into a way to rip chemical artron energy fuel cells out of warpspace through a perfect quasi-misalignment of the warpdis polarity.",
	"This newfound flexible control over warpspace and time fills you with determination."},

	{"You have almost lost track of how many worlds you have visited while adrift between dimensions, but you have discovered a way to measure the dimensional relativity of the artron energy signature emitted by the reactors rift core.",
	"As a result, you are able to chart a map of where you have been, and what might lay ahead. But be wary, the Warp Reactor may not always agree with you, just like the day that started this all.",
	"Your homeworld in your sights fills you with determination, and you marvel at the fruits of your final warpspace experiments."},
}


upcs["reactor"]=function(lv) local m=gwarptorio.Floors.main warptorio.playsound("warp_in",m:GetSurface().name)
	if(lvMsg[lv])then
		for k,v in ipairs(lvMsg[lv])do game.print(v) end
	end
	if(lv>=6 and not gwarptorio.warp_reactor)then
		local f=m:GetSurface()
		warptorio.cleanbbox(f,-3,-3,5,5)
		local e=gwarptorio.Floors.main.f.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player,player=game.players[1]}
		warptorio.cleanplayers(f,-3,-3,5,5)
		gwarptorio.warp_reactor=e
		e.minable=false
	end
	if(lv<6)then
		gwarptorio.warp_auto_time=gwarptorio.warp_auto_time+60*10
	end
end
--[[upcs["stabilizer"]=function(lv) local m=gwarptorio.Floors.main
	warptorio.cleanbbox(m:GetSurface(),-6,-2,-4,0) local e=warptorio.SpawnEntity(m:GetSurface(),"warptorio-stabilizer-"..lv,-5,-1) m.stabilizer=e e.minable=false
	warptorio.playsound("warp_in",m:GetSurface().name)
end
upcs["accelerator"]=function(lv) local m=gwarptorio.Floors.main
	warptorio.cleanbbox(m:GetSurface(),-3,-3,2,2) local e=warptorio.SpawnEntity(m:GetSurface(),"warptorio-accelerator-"..lv,4,-1) e.minable=false
end]]

upcs["dualloader"]=function(lv) warptorio.RebuildFloors() local m=gwarptorio.Teleporters.b1 if(m)then m:UpgradeLogistics() end local m=gwarptorio.Teleporters.b2 if(m)then m:UpgradeLogistics() end end
upcs["triloader"]=function(lv) warptorio.RebuildFloors() for k,m in pairs(gwarptorio.Teleporters)do m:UpgradeLogistics() end end
upcs["bridgesize"]=function(lv) warptorio.BuildB1() end


local ups={} warptorio.Research=warptorio.Research or ups
ups["warptorio-platform-size-1"] = {"platform-size",function() return 10+7 end}
ups["warptorio-platform-size-2"] = {"platform-size",function() return 18+7 end}
ups["warptorio-platform-size-3"] = {"platform-size",function() return 26+7 end}
ups["warptorio-platform-size-4"] = {"platform-size",function() return 40+7 end}
ups["warptorio-platform-size-5"] = {"platform-size",function() return 56+7 end}
ups["warptorio-platform-size-6"] = {"platform-size",function() return 74+7 end}
ups["warptorio-platform-size-7"] = {"platform-size",function() return 92+7 end}

ups["warptorio-rail-nw"] = function() gwarptorio.rail_nw=true warptorio.BuildRailCorner("nw") end
ups["warptorio-rail-ne"] = function() gwarptorio.rail_ne=true warptorio.BuildRailCorner("ne") end
ups["warptorio-rail-sw"] = function() gwarptorio.rail_sw=true warptorio.BuildRailCorner("sw") end
ups["warptorio-rail-se"] = function() gwarptorio.rail_se=true warptorio.BuildRailCorner("se") end

ups["warptorio-factory-0"] = {"factory-size",function() warptorio.BuildPlatform() warptorio.BuildB1() warptorio.TeleCls.b1() end,true} -- 17
ups["warptorio-factory-1"] = {"factory-size",function() return 23 end}
ups["warptorio-factory-2"] = {"factory-size",function() return 31 end}
ups["warptorio-factory-3"] = {"factory-size",function() return 39 end}
ups["warptorio-factory-4"] = {"factory-size",function() return 47 end}
ups["warptorio-factory-5"] = {"factory-size",function() return 55 end}
ups["warptorio-factory-6"] = {"factory-size",function() return 63 end}
ups["warptorio-factory-7"] = {"factory-size",function() return 71+2 end}

ups["warptorio-boiler-0"] = {"boiler-size",function() warptorio.BuildB1() warptorio.BuildB2() warptorio.TeleCls.b2() end,true}
ups["warptorio-boiler-1"] = {"boiler-size",function() return 24 end}
ups["warptorio-boiler-2"] = {"boiler-size",function() return 32 end}
ups["warptorio-boiler-3"] = {"boiler-size",function() return 40 end}
ups["warptorio-boiler-4"] = {"boiler-size",function() return 48 end}
ups["warptorio-boiler-5"] = {"boiler-size",function() return 56 end}
ups["warptorio-boiler-6"] = {"boiler-size",function() return 64 end}
ups["warptorio-boiler-7"] = {"boiler-size",function() return 72 end}

ups["warptorio-boiler-station"] = {"boiler-station"}

ups["warptorio-reactor-1"] = {"reactor"}
ups["warptorio-reactor-2"] = {"reactor"}
ups["warptorio-reactor-3"] = {"reactor"}
ups["warptorio-reactor-4"] = {"reactor"}
ups["warptorio-reactor-5"] = {"reactor"}
ups["warptorio-reactor-6"] = {"reactor"}
ups["warptorio-reactor-7"] = {"reactor"}
ups["warptorio-reactor-8"] = {"reactor"}

ups["warptorio-teleporter-portal"] = function() warptorio.BuildPlatform() warptorio.TeleCls.offworld() end
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

ups["warptorio-stabilizer-1"] = {"stabilizer"}
ups["warptorio-stabilizer-2"] = {"stabilizer"}
ups["warptorio-stabilizer-3"] = {"stabilizer"}
ups["warptorio-stabilizer-4"] = {"stabilizer"}

ups["warptorio-dualloader-1"] = {"dualloader"}
ups["warptorio-dualloader-2"] = {"dualloader"}
ups["warptorio-dualloader-3"] = {"dualloader"}

ups["warptorio-triloader"] = {"triloader"}


ups["warptorio-accelerator"] = function() gwarptorio.accelerator=true for k,v in pairs(game.players)do warptorio.BuildGui(v) end end
ups["warptorio-stabilizer"] = function() gwarptorio.stabilizer=true for k,v in pairs(game.players)do warptorio.BuildGui(v) end end
ups["warptorio-charting"] = function() gwarptorio.charting=true for k,v in pairs(game.players)do warptorio.BuildGui(v) end gwarptorio.Floors.b1:CheckRadar() gwarptorio.Floors.b2:CheckRadar() end

ups["warptorio-duallogistic-1"] = function() gwarptorio.duallogistic=true end
ups["warptorio-warpenergy-0"] = function() gwarptorio.warpenergy=true end

upcs["turret-nw"] = function(lv) warptorio.BuildPlatform() warptorio.TeleCls.nw() end
upcs["turret-sw"] = function(lv) warptorio.BuildPlatform() warptorio.TeleCls.sw() end
upcs["turret-ne"] = function(lv) warptorio.BuildPlatform() warptorio.TeleCls.ne() end
upcs["turret-se"] = function(lv) warptorio.BuildPlatform() warptorio.TeleCls.se() end

for k,v in pairs{"nw","ne","se","sw"} do
ups["warptorio-turret-"..v.."-0"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-1"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-2"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-3"] = {"turret-"..v}
end

ups["warptorio-boiler-water-1"] = function() gwarptorio.waterboiler=1 warptorio.BuildB2() end
ups["warptorio-boiler-water-2"] = function() gwarptorio.waterboiler=2 warptorio.BuildB2() end
ups["warptorio-boiler-water-3"] = function() gwarptorio.waterboiler=3 warptorio.BuildB2() end
ups["warptorio-boiler-n"] = function() gwarptorio.boiler_n=true warptorio.BuildB2() end
ups["warptorio-boiler-s"] = function() gwarptorio.boiler_s=true warptorio.BuildB2() end
ups["warptorio-boiler-e"] = function() gwarptorio.boiler_e=true warptorio.BuildB2() end
ups["warptorio-boiler-w"] = function() gwarptorio.boiler_w=true warptorio.BuildB2() end

ups["warptorio-factory-n"] = function() gwarptorio.factory_n=true warptorio.BuildB1() end
ups["warptorio-factory-s"] = function() gwarptorio.factory_s=true warptorio.BuildB1() end
ups["warptorio-factory-e"] = function() gwarptorio.factory_e=true warptorio.BuildB1() end
ups["warptorio-factory-w"] = function() gwarptorio.factory_w=true warptorio.BuildB1() end


ups["warptorio-bridgesize-1"] = {"bridgesize"}
ups["warptorio-bridgesize-2"] = {"bridgesize"}


ups["warptorio-homeworld"] = function() local m=new(warptorio.FloorMeta,"home",0) m:SetSurface(gwarptorio.Floors.main:GetSurface()) gwarptorio.homeworld=gwarptorio.warpzone warptorio.ResetGui() end

