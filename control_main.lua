--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2

Script: control.lua
Purpose: control stuff


Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.


]]---------------------------------------

local planets=lib.planets

--[[ Warptorio Environment ]]--

warptorio=warptorio or {}
warptorio.Loaded=false

require("control_main_helpers")

warptorio.platform=require("control_platform_classic")
local platform=warptorio.platform


require("control_class_teleporter")
require("control_class_harvester")
require("control_class_rails")

warptorio.chatcmd={}
function warptorio.chatcmd.kill(ev)
	local ply=game.players[ev.player_index] local c=ply.character
	if(c and c.valid)then c.die(c.force,c) end
end
commands.add_command("kill","Suicides the player",warptorio.chatcmd.kill)


--[[ Warptorio custom events ]]--
-- Hook in on_load with
-- local eventdefs=remote.call("warptorio","get_events")
-- script.on_event(eventdefs["on_warp"],func() end)

events.register("on_warp") -- during Warpout()
events.register("on_post_warp") -- during Warpout()
events.register("warp_started") -- StartWarp()
events.register("warp_stopped") -- StopWarp()

events.register("harvester_deploy") -- ?
events.register("harvester_recall") -- ?

events.register("ability_used") -- ?




--[[ Warptorio Libraries ]]--


warptorio.ChestBeltPairs={{"loader","wooden-chest"},{"fast-loader","iron-chest"},{"express-loader","steel-chest"},
	{"express-loader",function(dir) return (dir=="output" and warptorio.setting("loaderchest_provider") or warptorio.setting("loaderchest_requester")) end},
}
warptorio.ChestBeltPairs[0]={"loader","wooden-chest"}
function warptorio.GetChest(dir) local lv=research.level("warptorio-logistics") local lvb=warptorio.ChestBeltPairs[lv] return (isstring(lvb[2]) and lvb[2] or lvb[2](dir)) end
function warptorio.GetBelt(dir) local lv=research.level("warptorio-logistics") local lvb=warptorio.ChestBeltPairs[lv] return (isstring(lvb[1]) and lvb[1] or lvb[1](dir)) end
--remotes.register("GetChest",warptorio.GetChest)
--remotes.register("GetBelt",warptorio.GetBelt)



--[[ Warptorio Platform ]]--

function warptorio.GetPlatform() return warptorio.platform end
function warptorio.GetCurrentSurface() return global.floor.main.host end
function warptorio.GetMainSurface() return global.floor.main.host end
function warptorio.GetHomeSurface() return global.floor.home and global.floor.home.host or nil end
function warptorio.GetMainPlanet() return planets.GetBySurface(warptorio.GetMainSurface()) end -- planetorio
function warptorio.GetHomePlanet() return planets.GetBySurface(warptorio.GetHomeSurface()) end -- planetorio

function warptorio.GetNamedSurfaces(tbl) local t={} for k,nm in pairs(tbl)do t[nm]=global.floor[nm].host end return t end
function warptorio.GetAllSurfaces() local t={} for nm,v in pairs(global.floor)do t[v.hostindex]=v.host end return t end
function warptorio.GetPlatformSurfaces() local t={} for nm,v in pairs(global.floor)do if(platform.floors[nm].empty==true)then t[v.hostindex]=v.host end end return t end


function warptorio.GetTeleporterSize(a,b,c,noproto) -- for clearing
	local x=1
	if(a and research.has("warptorio-logistics-1"))then x=x+2 end
	if(b and research.has("warptorio-dualloader-1"))then x=x+1 end
	if(c and research.has("warptorio-triloader"))then x=x+1 end
	return vector((x*2)+2,2)
end
function warptorio.GetTeleporterHazard(bMain,bFull) -- for hazard tiles
	local x=0
	bFull=(bFull==nil and true or bFull) -- has the tech, or -1
	local lgHas=research.has("warptorio-logistics-1")
	local dlHas=research.has("warptorio-dualloader-1")
	local tlHas=research.has("warptorio-triloader")
	local lgCan=research.can("warptorio-logistics-1")
	local dlCan=research.can("warptorio-dualloader-1")
	local tlCan=research.can("warptorio-triloader")

	if(lgCan or lgHas)then x=x+2 end

	if(bMain)then
		if(tlHas and dlHas)then x=x+2
		elseif(tlHas or dlHas)then x=x+1 if(bFull and ( (not tlHas and tlCan) or (not dlHas and dlCan) ) )then x=x+1 end
		elseif(bFull and (tlCan or dlCan))then x=x+1
		end
	else
		if(tlCan)then x=x+1 end
	end


	return vector((x*2)+2,2)
end

warptorio.EmptyGenSettings={default_enable_all_autoplace_controls=false,width=32*12,height=32*12,
	autoplace_settings={entity={treat_missing_as_default=false},tile={treat_missing_as_default=false},decorative={treat_missing_as_default=false}, }, starting_area="none",}

function warptorio.MakePlatformFloor(vt)
	local f=game.create_surface(vt.name,(vt.empty and warptorio.EmptyGenSettings or nil))
	if(vt.empty)then
		f.solar_power_multiplier=settings.global.warptorio_solar_multiplier.value
		f.daytime=0
		f.always_day=true
		f.request_to_generate_chunks({0,0},16)
		f.force_generate_chunk_requests()
		f.destroy_decoratives({})
		for k,v in pairs(f.find_entities())do entity.destroy(v) end
		local area=vector.area(vector(-32*8,-32*8),vector(32*8*2,32*8*2))
		vector.LayTiles("out-of-map",f,area)
	end
	local floor=cache.raise_surface(f)
	if(vt.init)then lib.call(vt.init,floor) end
	global.floor[vt.key]=floor
	return floor
end

function warptorio.GetPlatformFloor(vt) if(isstring(vt))then vt=warptorio.platform.floors[vt] end
	local floor
	if(vt.key=="main")then -- Special; nauvis / primary planet
		floor=global.floor.main if(not floor)then floor={key=vt.key,host=game.surfaces.nauvis,hostindex=1} global.floor.main=floor if(vt.init)then lib.call(vt.init,floor) end end
	elseif(vt.key=="home")then -- Special; homeworld
		floor=global.floor.home if(not floor)then floor={key=vt.key,host=game.surfaces.nauvis,hostindex=1} global.floor.home=floor end
	else
		floor=global.floor[vt.key] if(not floor)then floor=warptorio.MakePlatformFloor(vt) end
		floor.key=vt.key
	end
	return floor
end

function warptorio.ConstructFloor(fn,bhzd) warptorio.ConstructPlatform(platform.floors[fn],bhzd) end
function warptorio.ConstructFloorHazard(fn) warptorio.ConstructHazard(platform.floors[fn]) end

function warptorio.ConstructPlatformVoid(surf)
	local vt=warptorio.platform.floors["main"] if(vt.tile)then lib.call(vt.tile,surf,true) end
end
function warptorio.ConstructPlatform(vt,bhzd)
	if(isstring(vt))then vt=warptorio.platform.floors[vt] end
	local floor=warptorio.GetPlatformFloor(vt) if(floor)then
	if(vt.tile)then lib.call(vt.tile,floor.host) end
	if(bhzd and vt.hazard)then lib.call(vt.hazard,floor.host) end
end end

function warptorio.ConstructPlatforms(bhzd)
	local platform=warptorio.GetPlatform()
	for nm,vt in pairs(platform.floors)do warptorio.ConstructPlatform(vt,bhzd) end
end

function warptorio.ConstructHazard(vt)
	if(isstring(vt))then vt=warptorio.platform.floors[vt] end
	local floor=warptorio.GetPlatformFloor(vt)
	if(floor and vt.hazard)then lib.call(vt.hazard,floor.host) end
end

function warptorio.ConstructHazards()
	local platform=warptorio.GetPlatform()
	for nm,vt in pairs(platform.floors)do warptorio.ConstructHazard(vt) end
end

function warptorio.CheckFloorRadar(floor) if(research.has("warptorio-charting") and not isvalid(floor.radar))then
	floor.radar=entity.protect(entity.create(floor.host,"warptorio-invisradar",vector(-1,-1)),false,false)
end end


function warptorio.CheckPlatformSpecials(self)
	local platform=warptorio.platform
	local vfloor=platform.floors[self.key]
	if(not vfloor)then
		game.print("no vfloor error: " .. serpent.line(self))
	end
	local sp=vfloor.special if(not sp)then return end
	if(not sp.upgrade)then if(not research.has(sp.tech) or isvalid(self.SpecialEnt))then return end elseif(research.level(sp.tech)<1)then return end
	local protoname=sp.prototype
	local inv={}
	if(sp.upgrade)then protoname=protoname.."-"..research.level(sp.tech)
		if(isvalid(self.SpecialEnt) and self.SpecialEnt.name==protoname)then return elseif(isvalid(self.SpecialEnt))then inv=warptorio.DestroyPlatformSpecial(self) end
	end

	local f=self.host
	local efply={}
	local area=vector.square(vector(-0.5,-0.5),sp.size)
	local eft=f.find_entities_filtered{area=area}
	local rdr=false if(isvalid(self.radar))then rdr=true entity.destroy(self.radar) end
	for k,v in pairs(eft)do if(isvalid(v))then if(v.type=="character")then table.insert(efply,v) elseif(v~=self.radar)then entity.destroy(v) end end end

	local e=entity.protect(entity.create(f,protoname,vector(-0.5,-0.5)),false,false)
	self.SpecialEnt=e
	if(inv)then for k,v in pairs(inv)do e.get_module_inventory().insert{name=k,count=v} end end -- beacon modules. Close enough.
	warptorio.CheckFloorRadar(self)
	vector.cleanplayers(f,area)
	players.playsound("warp_in",f)
end

function warptorio.DestroyPlatformSpecial(self) local inv
	if(isvalid(self.SpecialEnt))then local x=self.SpecialEnt.get_module_inventory() if(x)then inv=x.get_contents() end entity.destroy(self.SpecialEnt) end
	self.SpecialEnt=nil return inv

end

function warptorio.InitPlatform()
	global.floor={}

	for nm,vt in pairs(warptorio.platform.floors)do
		local floor=warptorio.GetPlatformFloor(vt)
		if(floor)then
			warptorio.ConstructPlatform(vt,true)
		end
	end
end





--[[ Bootstrap Initialization and Migrations ]]--

events.on_init(function()
	events.raise_migrate()
	lib.planets.lua()
	warptorio.ValidateWarpBlacklist()
	--warptorio.HookNewGamePlus()
end)




function warptorio.ApplyMapSettings()
	local gmp=game.map_settings
	gmp.pollution.diffusion_ratio = 0.105
	gmp.pollution.pollution_factor = 0.0000001

	gmp.pollution.min_to_diffuse=15 -- default 15
	gmp.pollution.ageing=1.0 -- 1.0
	gmp.pollution.expected_max_per_chunk=250
	gmp.pollution.min_to_show_per_chunk=50
	gmp.pollution.pollution_restored_per_tree_damage=9
	gmp.pollution.enemy_attack_pollution_consumption_modifier=1.0

	gmp.enemy_evolution.destroy_factor=0.0002 -- default 0.002

	gmp.unit_group.min_group_gathering_time = 600
	gmp.unit_group.max_group_gathering_time = 2 * 600
	gmp.unit_group.max_unit_group_size = 200
	gmp.unit_group.max_wait_time_for_late_members = 2 * 360
	gmp.unit_group.settler_group_min_size = 1
	gmp.unit_group.settler_group_max_size = 1

	--gmp.enemy_expansion.max_expansion_cooldown = (gmp.enemy_expansion.min_expansion_cooldown*1.25)


end

events.on_config(function(ev) if(warptorio.Loaded)then return end
	lib.planets.lua()
	cache.validate("combinators")
	cache.validate("heat")
	cache.validate("power")
	cache.validate("loaderinput")
	cache.validate("loaderoutput")
	cache.validate("ldinputf")
	cache.validate("ldoutputf")

	global.warpzone=global.warpzone or 0
	global.time_spent_start_tick=global.time_spent_start_tick or game.tick
	global.time_passed=global.time_passed or 0

	global.warp_charge_time=global.warp_charge_time or 10
	global.warp_charge_start_tick=global.warp_charge_start_tick or 0
	global.warp_charging=global.warp_charging or 0
	global.warp_timeleft=global.warp_timeleft or 60*10
	global.warp_auto_time = global.warp_auto_time or 60*settings.global["warptorio_autowarp_time"].value
	global.warp_auto_end = global.warp_auto_end or 60*60*settings.global["warptorio_autowarp_time"].value
	global.warp_last=global.warp_last or game.tick
	global.abilities=global.abilities or {}
	global.ability_drain=global.ability_drain or settings.global["warptorio_ability_drain"].value

	global.pollution_amount = global.pollution_amount or 1.1
	global.pollution_expansion = global.pollution_expansion or 1.1
	global.ability_uses=global.ability_uses or 0
	global.ability_next=global.ability_next or 0
	global.radar_uses=global.radar_uses or 0

	warptorio.ApplyMapSettings()

	global.votewarp=global.votewarp or {} if(type(global.votewarp)~="table")then global.votewarp={} end
	warptorio.CheckVotewarps()

	-- todo: global.warp_blacklist={}
	warptorio.ValidateWarpBlacklist()

	--[[ more todo:
		for k,v in pairs(gwarptorio.Harvesters)do v.position=warptorio.platform.harvester[k] end
		for k,v in pairs(gwarptorio.Teleporters)do v.position=warptorio.Teleporters[k].position end
	]]

	global.Teleporters=global.Teleporters or {}
	global.Research=global.Research or {} -- todo remove this
	global.Turrets=global.Turrets or {}
	global.Rails=global.Rails or {}
	global.Harvesters=global.Harvesters or {}


	if(not global.floor)then warptorio.InitPlatform() end


	for k,v in pairs(global.Rails)do
		v:MakeRails()
	end
	for k,v in pairs(global.Teleporters)do
		v:CheckTeleporterPairs(true)
	end
	for k,v in pairs(global.Harvesters)do
		local gdata=warptorio.platform.harvesters[v.key]
		v.rank=warptorio.GetPlatformTechLevel(gdata.tech)
		v:CheckTeleporterPairs(true)
		v:Upgrade()
	end

	for k,v in pairs(warptorio.settings)do v() end

	-- todo: warptorio.ApplyMapSettings()
	for k,t in pairs(global.Harvesters)do
		table.merge(t,table.deepcopy(warptorio.platform.harvesters[t.key]))
		table.merge(t,table.deepcopy(warptorio.platform.HarvesterPointData))
	end

	warptorio.Loaded=true
end)

events.on_load(function()
	warptorio.HookNewGamePlus()
	if(global.Teleporters)then for k,v in pairs(global.Teleporters)do setmetatable(v,warptorio.TeleporterMeta) end end
	if(global.Harvesters)then for k,v in pairs(global.Harvesters)do setmetatable(v,warptorio.HarvesterMeta) end end
	if(global.Rails)then for k,v in pairs(global.Rails)do setmetatable(v,warptorio.RailMeta) end end
	--lib.planets.lua()
end)


--[[ Players Manager ]]--

function warptorio.CheckVotewarps() for k,v in pairs(global.votewarp)do if(isvalid(v) or not v.connected)then global.votewarp[k]=nil end end cache.updatemenu("hud","warpbtn") end


warptorio.teleDir={[0]={0,-1},[1]={1,-1},[2]={1,0},[3]={1,1},[4]={0,1},[5]={-1,1},[6]={-1,0},[7]={-1,-1}}
function warptorio.TeleportLogic(ply,e,tent)
	local w=ply.walking_state
	local ox=tent.position
	local x=e.position
	local mp=2 if(not ply.character)then mp=3 end
	--game.print(serpent.line(ply.vehicle.name))
	if(ply.driving)then
		local veh=ply.vehicle
		if(veh.type=="spider-vehicle")then
			local cp=ply.position local xd,yd=(x.x-cp.x),(x.y-cp.y)
			local vpos=vector(ox.x+xd*3,ox.y+yd*3)
			entity.safeteleport(ply,tent.surface,vpos)
			local cn=veh.clone{position=ply.position,surface=ply.surface,force=ply.force}
			veh.destroy()
			ply.driving=cn
		else
		local cp=ply.position local xd,yd=(x.x-cp.x),(x.y-cp.y) entity.safeteleport(veh,tent.surface,vector(ox.x+xd*3,ox.y+yd*3))
		end
	elseif(not w.walking)then
		local cp=ply.position local xd,yd=(x.x-cp.x),(x.y-cp.y) entity.safeteleport(ply,tent.surface,vector(ox.x+xd*mp,ox.y+yd*mp))
	else
		local td=warptorio.teleDir[w.direction] local tpe=ply entity.safeteleport(tpe,tent.surface,vector(ox.x+td[1]*mp,ox.y+td[2]*mp))
	end
	players.playsound("teleport",e.surface,e.position) players.playsound("teleport",tent.surface,tent.position)
end


cache.player({
	raise=function(cp) local ply=cp.host
		entity.safeteleport(ply,warptorio.GetMainSurface(),vector(0,-5))
		local hud=cache.force_menu("hud",ply)
	end,
	on_position=function(ply)
		local cp=cache.force_player(ply)
		if((cp.tprecent or 0)>game.tick)then return end
		local f=ply.surface
		local z=vector.square(ply.position,vector(0.8,0.8))
		if(ply.driving)then
			local bbox=ply.vehicle.bounding_box
			--game.print(serpent.line(bbox))
			bbox.left_top.x=bbox.left_top.x-0.8
			bbox.left_top.y=bbox.left_top.y-0.8
			bbox.right_bottom.x=bbox.right_bottom.x+0.8
			bbox.right_bottom.y=bbox.right_bottom.y+0.8
			z=bbox
		end

		local ents=f.find_entities_filtered{area=z,type="accumulator"} --todo
		for k,v in pairs(ents)do
			local tpg=cache.get_entity(v)
			if(tpg and isvalid(tpg.teleport_dest))then
				cp.tprecent=game.tick+10
				local tgate=tpg.teleport_dest
				warptorio.TeleportLogic(ply,v,tgate)
			end
		end
	end,
	on_create=function(ply)
		local cp=cache.raise_player(ply)
	end,
	on_join=function(ply)
		local menu=cache.force_menu("hud",ply)
		entity.safeteleport(ply,warptorio.GetMainSurface(),{0,-5})
	end,
	on_respawn=function(ply)
		local cf=warptorio.GetMainSurface() local gp=ply
		if(gp.surface~=cf)then local pos=cf.find_non_colliding_position("character",{0,-5},0,1,1) gp.teleport(pos,cf) end
	end,
	on_left=function(ply)
		if(global.votewarp[ply.index])then
			global.votewarp[ply.index]=nil
			cache.updatemenu("hud","warpbtn")
		end
	end,
	on_pre_removed=function(ply)
		local cp=cache.get_player(ply) if(cp)then
			cache.destroy_player(ply)
		end
	end,
	on_capsule=function(ply,ev)
		if(ev.item.name=="warptorio-townportal")then
			local p=game.players[ev.player_index]
			if(p and p.valid)then
				players.playsound("teleport",p.surface,p.position)
				entity.safeteleport(p,warptorio.GetMainSurface(),vector(0,-5))
				players.playsound("teleport",p.surface,p.position)
			end
		elseif(ev.item.name=="warptorio-homeportal" and warptorio.GetHomeSurface())then
			local p=game.players[ev.player_index]
			if(p and p.valid)then
				players.playsound("teleport",p.surface,p.position)
				entity.safeteleport(p,warptorio.GetHomeSurface(),vector(0,-5))
				players.playsound("teleport",p.surface,p.position)
			end
		end

	end,
})





--[[ Warptorio Cache Manager ]]--


 -- Pumps and resources cannot be cloned in warptorio
cache.type("offshore-pump",{ clone=function(e) e.destroy{raise_destroy=true} end, })
cache.type("resource",{ clone=function(e) e.destroy{raise_destroy=true} end, })

-- Simple globally balanced entities
cache.ent("warptorio-heatpipe",{ create=function(e) cache.insert("heat",e) end, destroy=function(e) cache.remove("heat",e) end })
cache.ent("warptorio-reactor",{ create=function(e) cache.insert("heat",e) end, destroy=function(e) cache.remove("heat",e) end })
cache.ent("warptorio-accumulator",{ create=function(e) cache.insert("power",e) end, destroy=function(e) cache.remove("power",e) end })

events.on_tick(1,0,"heattick",function(tick) entity.AutoBalanceHeat(cache.get("heat")) end)
events.on_tick(1,0,"powertick",function(tick) local t=cache.get("power")
	local g,c=0,0
	for k,v in pairs(t)do if(isvalid(v))then g=g+v.energy c=c+v.electric_buffer_size end end

	local egdrain=global.ability_drain
	local abc=0
	if(global.abilities.stabilizing)then
		abc=abc+1
	end
	if(global.abilities.accelerating)then
		abc=abc+1
	end
	if(global.abilities.scanning)then
		abc=abc+1
	end

	if(abc>0)then
		local gcost=c*egdrain*abc
		if(g>=gcost)then
			g=math.max(g-gcost,0)
			global.ability_drain=math.min(egdrain+(0.00000002*abc),0.25)
		else
			global.abilities.stabilizing=false global.abilities.scanning=false global.abilities.accelerating=false
		end
	end
	global.energycount=g global.energymax=c
	for k,v in pairs(t)do if(v.valid)then v.energy=g*(v.electric_buffer_size/c) end end
end)

-- Warptorio Combinators
cache.ent("warptorio-combinator",{
	create=function(e,ev) cache.insert("combinators",e) end,
	destroy=function(e,ev) cache.remove("combinators",e) end,
	update=function(e,ev) local cbh=e.get_or_create_control_behavior() for k,v in pairs(ev.signals)do cbh.set_signal(k,v) end end,
})
function warptorio.RefreshWarpCombinators() local sigs=warptorio.GetCombinatorSignals() cache.entcall("combinators","update",{signals=sigs}) end
function warptorio.GetCombinatorSignals() local tbl={} for k,v in pairs(warptorio.Signals)do tbl[k]={signal=v.signal,count=v.get()} end return tbl end
warptorio.Signals={} -- 18 max default
warptorio.Signals[1]={ signal={type="virtual",name="signal-W"},get=function() return (global.warp_charging>=1 and (global.warp_time_left or 10)/60 or (global.warp_charge_time or 10)) end}
warptorio.Signals[2]={ signal={type="virtual",name="signal-X"},get=function() return global.warp_charging or 0 end}
warptorio.Signals[3]={ signal={type="virtual",name="signal-A"},get=function() return global.warp_auto_end/60 end}
warptorio.Signals[4]={ signal={type="virtual",name="signal-L"},get=function() local hv=global.Harvesters.west return ((hv and hv.deployed) and 1 or 0) end}
warptorio.Signals[5]={ signal={type="virtual",name="signal-R"},get=function() local hv=global.Harvesters.east return ((hv and hv.deployed) and 1 or 0) end}
warptorio.Signals[6]={ signal={type="virtual",name="signal-P"},get=function() return global.time_passed end}

--[[ Warptorio Gui ]]--


--cache.updatemenu("hud","raise") -- to recreate the menu

function warptorio.RaiseHUD(v) local m=cache.get_menu("hud",v) if(not m)then cache.raise_menu("hud",v) else cache.call_menu("raise",m) end end
function warptorio.ResetHUD(p) if(not p)then for k,v in pairs(game.players)do warptorio.RaiseHUD(v) end else warptorio.RaiseHUD(p) end end
function warptorio.PlayerCanStartWarp(ply) return true end

function warptorio.ToolRecallHarvester(k,ply) if(not research.has("warptorio-harvester-"..k.."-1"))then return end
	local cn=("warptorio-harvestpad-"..k.."-"..research.level("warptorio-harvester-"..k))
	if(not ply or (ply and not ply.get_main_inventory().get_contents()[cn]))then ply.get_main_inventory().insert{name=cn,count=1} players.playsound("warp_in",ply.surface,ply.position) end
	local hv=global.Harvesters[k] if(hv and hv.deployed and isvalid(hv.b))then players.playsound("warp_in",hv.b.surface,hv.b.position) hv:Recall() hv:DestroyB() end
end
function warptorio.ToolRecallGate(ply) if(not research.has("warptorio-teleporter-portal"))then return end
	local t=global.Teleporters.offworld if(t)then
		if(t.b and t.b.valid)then players.playsound("warp_in",t.b.surface,t.b.position) t:DestroyLogsB() t:DestroyB() end
		local inv=ply.get_main_inventory()
		if(not inv.get_contents()["warptorio-teleporter-gate-0"])then inv.insert{name="warptorio-teleporter-gate-0",count=1} players.playsound("warp_in",ply.surface,ply.position) end
	end
end

cache.vgui("warptorio_toolbutton",{click=function(elm,ev) local menu=cache.get_menu("hud",elm.player_index) local b=menu.toolbar b.visible=not b.visible end})
cache.vgui("warptorio_tool_hv_west",{click=function(elm,ev) warptorio.ToolRecallHarvester("west",game.players[elm.player_index]) end})
cache.vgui("warptorio_tool_hv_east",{click=function(elm,ev) warptorio.ToolRecallHarvester("east",game.players[elm.player_index]) end})
cache.vgui("warptorio_tool_planet_gate",{click=function(elm,ev) warptorio.ToolRecallGate(game.players[elm.player_index]) end})


cache.vgui("warptorio_homeworld",{
	click=function(elm,ev) local menu=cache.get_menu("hud",elm.player_index)
		if(menu.hometmr<game.tick)then
			menu.hometmr=game.tick+(60*5)
			cache.call_menu("clocktick",menu)
		else
			global.homeworld=global.warpzone local f=global.floor.main.host global.floor.home.host=f global.floor.home.hostindex=f.index
			players.playsound("warp_in",global.floor.home.host) game.print("Homeworld Set.") menu.hometmr=0
			cache.call_menu("clocktick",menu)
		end
	end,
})

local HUD={} warptorio.HUD=HUD
function HUD.clocktick(menu) local ply=menu.host
	if(global.warp_charging>=1)then menu.charge_time.caption={"warptorio.warp-in",util.formattime(val or (global.warp_time_left or 0))}
	elseif(menu.charge_time)then menu.charge_time.caption={"warptorio.charge_time",util.formattime((global.warp_charge_time or 0)*60)}
	end

	menu.time_passed.caption={"warptorio.time_passed",util.formattime(global.time_passed or 0)}
	if(warptorio.IsAutowarpEnabled())then menu.autowarp.caption={"warptorio.autowarp-in",util.formattime(global.warp_auto_end)} else menu.autowarp.caption="" end

	menu.hometmr=menu.hometmr or 0
	if(menu.homeworld)then
		if(menu.hometmr>game.tick)then menu.homeworld.caption={"warptorio.confirm_homeworld",util.formattime(menu.hometmr-game.tick)}
		else menu.homeworld.caption={"warptorio.button_homeworld"}
		end
	end

	if(menu.energybar)then
		local cureng=global.energycount or 0
		local maxeng=math.max(global.energymax or 1,1)
		local energydif=cureng-(menu.last_energy or 0)
		menu.last_energy=cureng

		local egdrain=global.ability_drain*100*60
		local abc=0
		local r=menu.stabilizer
		if(r)then if(global.abilities.stabilizing)then abc=abc+1 r.caption={"warptorio-stabilize-on","-"..math.roundx(egdrain,2).."%/sec"} else r.caption={"warptorio-stabilize"} end end
		local r=menu.accelerator
		if(r)then if(global.abilities.accelerating)then abc=abc+1 r.caption={"warptorio-accel-on","-"..math.roundx(egdrain,2).."%/sec"} else r.caption={"warptorio-accel"} end end
		local r=menu.radar
		if(r)then if(global.abilities.scanning)then abc=abc+1 r.caption={"warptorio-radar-on","-"..math.roundx(egdrain,2).."%/sec"} else r.caption={"warptorio-radar"} end end


		menu.energybar_energy.caption=" "..string.energy_to_string(cureng) .. " "
		menu.energybar_energymax.caption=" "..string.energy_to_string(maxeng) .. " "

		menu.energybar_energybal.caption=" ("..(energydif>=1 and "+" or (energydif>0 and "+-" or ""))..string.energy_to_string(energydif) .. "/sec) "
		menu.energybar_energybal.style.font_color=(energydif>0 and {r=0,g=1,b=0} or (energydif<0 and {r=1,g=0,b=0} or {r=0.75,g=0.75,b=0.75}))

		menu.energybar.value=cureng/maxeng

		menu.energybar_energypct.caption=" "..math.roundx((cureng/maxeng)*100,2) .. "% "

		if(abc>0)then menu.energybar_energypctx.caption="-"..math.roundx(egdrain*abc,2).."%/sec" else menu.energybar_energypctx.caption="" end

	end

end


function HUD.raise(menu,ev) local ply=menu.host
	menu.frame=vgui.create(ply.gui.left,{name="warptorio_frame",type="flow",direction="vertical"})
	menu.frame.style.left_padding=4
	menu.row1=vgui.create(menu.frame,{name="warptorio_row1",type="flow",direction="horizontal"})
	menu.row2=vgui.create(menu.frame,{name="warptorio_row2",type="flow",direction="horizontal"})
	menu.row4=vgui.create(menu.frame,{name="warptorio_row4",type="flow",direction="horizontal"})
	menu.row3=vgui.create(menu.frame,{name="warptorio_row3",type="flow",direction="horizontal"})
	menu.row1.clear()
	menu.row2.clear()
	menu.row3.clear()
	menu.row4.clear()

	menu.warpbtn=vgui.create(menu.row1,{name="warptorio_warpbutton",type="button",caption={"warptorio.button-warp","-"}})
	if(research.has("warptorio-toolbar"))then menu.toolbtn=vgui.create(menu.row1,{name="warptorio_toolbutton",type="button",caption={"warptorio.toolbutton","-"}}) end
	if(research.level("warptorio-reactor")>=8)then
		menu.warptgt=vgui.create(menu.row1,{name="warptorio_warptarget",type="drop-down"})
		HUD.rebuild_warptargets(menu)
		HUD.warptarget(menu,{tgt=(sx==nil and "(Random)" or (sx=="home" and "(Homeworld)" or (sx=="(nauvis)" and "nauvis" or sx)))})
	end

	menu.time_passed=vgui.create(menu.row1,{name="warptorio_time_passed",type="label"})
	menu.charge_time=vgui.create(menu.row1,{name="warptorio_charge_time",type="label"})
	menu.warpzone=vgui.create(menu.row1,{name="warptorio_warpzone",type="label",caption="Warpzone: " .. global.warpzone or 0})
	menu.autowarp=vgui.create(menu.row1,{name="warptorio_autowarp",type="label"})

	if(research.has("warptorio-homeworld"))then menu.homeworld=vgui.create(menu.row1,{name="warptorio_homeworld",type="button",caption={"warptorio.button_homeworld"}}) end


	local hasabil=false
	if(research.has("warptorio-stabilizer"))then hasabil=true menu.stabilizer=vgui.create(menu.row2,{name="warptorio_stabilizer",type="button",caption={"warptorio-stabilize","-"}}) end
	if(research.has("warptorio-accelerator"))then hasabil=true menu.accelerator=vgui.create(menu.row2,{name="warptorio_accelerator",type="button",caption={"warptorio-accel","-"}}) end
	if(research.has("warptorio-charting"))then hasabil=true menu.radar=vgui.create(menu.row2,{name="warptorio_radar",type="button",caption={"warptorio-radar","-"}}) end
	if(hasabil)then
		menu.last_energy=menu.last_energy or 100
		local energydif=1000-menu.last_energy
		menu.energybar_label=vgui.create(menu.row4,{name="warptorio_energybar_label",type="label",caption={"warptorio.energybar","-"}})
		menu.energybar_energy=vgui.create(menu.row4,{name="warptorio_energybar_energy",type="label",caption=" 100kw "})
		menu.energybar_energy.style.font_color={r=0,g=1,b=0}

		menu.energybar_energydiv=vgui.create(menu.row4,{name="warptorio_energybar_energydiv",type="label",caption=" / "})

		menu.energybar_energymax=vgui.create(menu.row4,{name="warptorio_energybar_energymax",type="label",caption=" 0kw "})
		menu.energybar_energymax.style.font_color={r=0.25,g=1,b=1}


		menu.energybar_energybal=vgui.create(menu.row4,{name="warptorio_energybar_energybal",type="label",caption=" (+100.32MW/sec) "})
		menu.energybar_energybal.style.font_color=(energydif>0 and {r=0,g=1,b=0} or (energydif==0 and {r=1,g=1,b=0} or {r=1,g=0,b=0}))


		menu.energybar_energydivb=vgui.create(menu.row4,{name="warptorio_energybar_energydivb",type="label",caption=" | "})


		menu.energybar=vgui.create(menu.row4,{name="warptorio_time_passed",type="progressbar",value=0.3})
		menu.energybar.style.natural_width=250
		menu.energybar.style.top_padding=7
		menu.energybar.style.bottom_padding=7

		menu.energybar_energypcta=vgui.create(menu.row4,{name="warptorio_energybar_energypcta",type="label",caption=" | "})
		menu.energybar_energypct=vgui.create(menu.row4,{name="warptorio_energybar_energypct",type="label",caption="25%"})
		menu.energybar_energypct.style.font_color={r=1,g=1,b=1}
		menu.energybar_energypctx=vgui.create(menu.row4,{name="warptorio_energybar_energypctx",type="label",caption="-3%/sec"})
		menu.energybar_energypctx.style.font_color={r=1,g=0,b=0}



	end

	if(research.has("warptorio-toolbar"))then 
		menu.toolbar=vgui.create(menu.row3,{name="warptorio_toolframe",type="flow",direction="horizontal",visible=false})
		menu.toolbar.clear()
		menu.tool_harvester_west=vgui.create(menu.toolbar,{name="warptorio_tool_hv_west",type="sprite-button",sprite="entity/warptorio-harvestportal-1",tooltip={"warptorio.tool_hv_west","-"}})
		menu.tool_planet_gate=vgui.create(menu.toolbar,{name="warptorio_tool_planet_gate",type="sprite-button",sprite="item/warptorio-teleporter-gate-0",tooltip={"warptorio.tool_planet_gate","-"}})
		menu.tool_harvester_east=vgui.create(menu.toolbar,{name="warptorio_tool_hv_east",type="sprite-button",sprite="entity/warptorio-harvestportal-1",tooltip={"warptorio.tool_hv_east","-"}})
	end


	HUD.clocktick(menu)
	HUD.rebuild_warptargets(menu)
	local sx=global.planet_target

end

function HUD.rebuild_warptargets(menu,ev)
	if(menu.warptgt)then
	local tgl={"(Random)"}
	if(research.has("warptorio-homeworld"))then table.insert(tgl,"(Homeworld)") table.insert(tgl,"(Nauvis)") end
	if(research.has("warptorio-charting"))then for k,v in pairs(lib.planets.GetTemplates())do table.insert(tgl,v.key) end end
	menu.warptgt.items=tgl
	HUD.warptarget(menu,{tgt=global.planet_target})
	end
end
function HUD.warptarget(menu,ev) local ply=menu.host if(not menu.warptgt or ply.index==ev.ply)then return end
	local elm,items=menu.warptgt if(elm)then items=elm.items end if(not items)then return end
	for idx,kv in pairs(items)do if(type(kv)=="string" and kv:lower()==ev.tgt)then elm.selected_index=idx end end
end

function HUD.warpbtn(menu)
	local r=menu.warpbtn
	local ply=menu.host
	if(global.warp_charging>=1)then r.caption={"warptorio.warping","-"} r.enabled=false
	else local cx=table.Count(global.votewarp) local c=table.Count(game.connected_players) -- table.Count(game.non_afk_players)
		if(c>1)then
			local vcn=math.ceil(c*warptorio.setting("votewarp_multi"))
			if(global.votewarp[ply.index] and cx<vcn)then r.enabled=false else r.enabled=true end
			if(cx>0)then r.caption={"warptorio.button-votewarp-count",cx,vcn}
			else r.caption={"warptorio.button-votewarp","-"}
			end
		else r.enabled=true r.caption={"warptorio.button-warp","-"} menu.warpzone.caption={"warptorio.warpzone_label",global.warpzone or 0}
		end
	end
end

cache.menu("hud",HUD)



cache.vgui("warptorio_warptarget",{
selection_changed=function(elm,ev) local ply=game.players[elm.player_index]
	local s=elm.items[elm.selected_index] if(not s)then return end local sx=s:lower()
	local vt=(sx=="(random)" and nil or (sx=="(homeworld)" and "home" or (sx=="(nauvis)" and "nauvis" or sx)))
	if(vt~=global.planet_target)then global.planet_target=vt game.print({"warptorio.player_set_warp_target",ply.name,s}) cache.updatemenu("hud","warptarget",{ply=elm.player_index,tgt=sx}) end
end,
})

function warptorio.StartWarp()
	if(global.warp_charging<1)then
		events.vraise("warp_started")
		global.warp_charge_start_tick=game.tick
		global.warp_charging=1
		players.playsound("reactor-stabilized")
		cache.updatemenu("hud","warpbtn")
	end
end
function warptorio.StopWarp()
	if(global.warp_charging>0)then
		events.vraise("warp_stopped")
		global.warp_charging=0
		global.warp_charge_time=global.warp_time_left/60
		global.warp_charge_start_tick=0
	end
end
function warptorio.IsWarping() return global.warp_charging>0 end
cache.vgui("warptorio_warpbutton",{
click=function(elm,ev) local ply=game.players[elm.player_index] local menu=cache.get_menu("hud",elm.player_index)
	if(global.warp_charging<1)then local c=table.Count(game.connected_players) -- table.Count(game.non_afk_players)
		if(c>1 and warptorio.setting("votewarp_multi")>0)then --votewarp
			local vcn=math.ceil(c*warptorio.setting("votewarp_multi"))
			global.votewarp[ply.index]=ply
			local cx=table.Count(global.votewarp)
			if(vcn<=1 or cx>=vcn)then
				warptorio.StartWarp()
				game.print(ply.name .. " started the warpout procedure.")
			else
				players.playsound("teleport")
				game.print({"warptorio.player_want_vote_warp",ply.name,cx,vcn})
				cache.updatemenu("hud","warpbtn")
			end
		elseif(warptorio.PlayerCanStartWarp(ply))then
			global.warp_charge_start_tick = game.tick
			global.warp_charging = 1
			players.playsound("reactor-stabilized")
			cache.updatemenu("hud","warpbtn")
		else
			ply.print("You must be on the same planet as the platform to warp")
		end
	end
end,
})

cache.vgui("warptorio_stabilizer",{
click=function(elm,ev) local ply=game.players[elm.player_index] local menu=cache.get_menu("hud",elm.player_index)
	global.abilities.stabilizing= not global.abilities.stabilizing
end,
})
cache.vgui("warptorio_accelerator",{
click=function(elm,ev) local ply=game.players[elm.player_index] local menu=cache.get_menu("hud",elm.player_index)
	global.abilities.accelerating= not global.abilities.accelerating
end,
})
cache.vgui("warptorio_radar",{
click=function(elm,ev) local ply=game.players[elm.player_index] local menu=cache.get_menu("hud",elm.player_index)
	global.abilities.scanning= not global.abilities.scanning
end,
})




--[[ Warping stuff ]]--

function warptorio.ValidateWarpBlacklist()
end

local staticBlacklist={"highlight-box","big_brother-blueprint-radar","osp_repair_radius"}
function warptorio.GetWarpBlacklist()
	return staticBlacklist
end

-- OnEntCloned
events.on_event(defines.events.on_entity_cloned,function(ev)
	if(warptorio.IsCloning)then table.insert(warptorio.Cloned_Entities,{source=ev.source,destination=ev.destination}) end
	if(ev.source.type=="spider-vehicle")then
		for k,v in pairs(game.players)do local inv=v.get_main_inventory() if(inv)then
			for i=1,#inv,1 do local e=inv[i] if(e and e.valid_for_read and e.connected_entity==ev.source)then e.connected_entity=ev.destination end end
			local e=v.cursor_stack if(e and e.valid_for_read and e.connected_entity==ev.source)then e.connected_entity=ev.destination end
			if(v.driving and v.vehicle==ev.source)then
				entity.safeteleport(v,ev.destination.surface,ev.destination.position)
				v.driving=ev.destination
			end
		end end
	end
end)

function warptorio.CountPlatformEntities() return 5 end -- todo

function warptorio.Warpout(key)
	warptorio.IsWarping=true
	for k,v in pairs(global.Harvesters)do if(v.deployed)then v:Recall(true) end end

	local cp=warptorio.GetMainPlanet()
	local cf=warptorio.GetMainSurface()
	warptorio.WarpPreBuildPlanet(key)
	local f,w,frc=warptorio.WarpBuildPlanet(key)
	warptorio.WarpPostBuildPlanet(w)

	global.floor.main.host=f
	global.floor.main.hostindex=f.index

	warptorio.ConstructPlatform("main",true)

	events.vraise("on_warp",{newsurface=f,newplanet=w,oldsurface=cf,oldplanet=cp})
	if(cp and cp.on_warp)then lib.call(cp.on_warp,f,w,cf,cp) end

	warptorio.Warp(cf,f)
	warptorio.WarpPost(cf,f)

	-- reset pollution & biters
	game.forces["enemy"].evolution_factor=0
	global.pollution_amount=1.1
	global.pollution_expansion=1.1

	-- warp sound
	players.playsound("warp_in")


	warptorio.WarpFinished()
	events.vraise("on_post_warp",{newsurface=f,newplanet=w})
	if(w.postwarpout)then lib.call(w.postwarpout,{newsurface=f,newplanet=w}) end
	warptorio.IsWarping=false
end


function warptorio.WarpPreBuildPlanet(key)
	global.warp_charge=0
	global.warp_charging=0
	global.votewarp={}
	global.warp_last=game.tick

	global.warpzone=global.warpzone+1

	-- Warp chargetime cooldown math
	local cot=warptorio.CountPlatformEntities()

	local sgZone=warptorio.setting("warpcharge_zone")
	local sgZoneGain=warptorio.setting("warpcharge_zonegain")
	local sgMax=warptorio.setting("warpcharge_max")
	local sgFactor=warptorio.setting("warp_charge_factor")
	local sgMul=warptorio.setting("warpcharge_multi")

	global.warp_charge_time=math.min(10+ (cot/sgFactor) + (global.warpzone*sgMul) + (sgZoneGain*(math.min(global.warpzone,sgZone)/sgZone)*60), 60*sgMax)
	global.warp_time_left=60*global.warp_charge_time

	-- Autowarp timer math
	local rta=research.level("warptorio-reactor")
	global.warp_auto_time=60*warptorio.setting("autowarp_time")+60*10*rta
	global.warp_auto_end=game.tick+ global.warp_auto_time*60

	-- Abilities
	--global.ability_uses=0
	--global.radar_uses=0
	--global.ability_next=game.tick+60*60*warptorio.setting("ability_warp")

	global.ability_drain=warptorio.setting("ability_drain") or 0.00001
	global.abilities={}

	-- Update guis
	--if(research.has("warptorio-accelerator") or research.has("warptorio-charting") or research.has("warptorio-stabilizer"))then end --gui.uses() gui.cooldown()
	--if(warptorio.IsAutowarpEnabled())then gui.autowarp() end
	--gui.warpzone()
	cache.updatemenu("hud","warpbtn")


	-- packup old teleporter gate
	--local tp=global.Teleporters.offworld if(tp and tp:ValidB())then tp:DestroyB() tp:DestroyLogsB() end
	-- Recall harvester plates and players on them.
	--for k,v in pairs(global.Harvesters)do v:Recall(true) end

end


function warptorio.WarpBuildPlanet(key)
	local nplanet
	if(key)then
		nplanet=remote.call("planetorio","FromTemplate","warpzone_"..global.warpzone,key)
	else
		local vplanet=warptorio.GetMainPlanet()
		local lvl=research.level("warptorio-reactor")
		if(lvl>=8)then local wx=global.planet_target
			if(wx=="home" or wx=="nauvis")then if(research.has("warptorio-homeworld"))then local hf=(wx=="nauvis" and game.surfaces.nauvis or global.floor.home.host)
				if(warptorio.GetMainSurface()~=hf and math.random(1,100)<=warptorio.setting("warpchance"))then local hp=remote.call("planetorio","GetBySurface",hf) or {name="Nauvis"}
					game.print({"warptorio.successful_warp"}) game.print({"warptorio.home_sweet_home",hp.name})
					return hf,hp
				end
			end elseif(wx and math.random(1,100)<=warptorio.setting("warpchance"))then
				nplanet=remote.call("planetorio","FromTemplate","warpzone_"..global.warpzone,wx)
				if(nplanet)then game.print({"warptorio.successful_warp"}) end
			end
		end
		if(not nplanet)then nplanet=remote.call("planetorio","SimplePlanetRoll","warpzone_"..global.warpzone,{zone=global.warpzone,prevplanet=vplanet}) end -- planetorio, modifiers={{"",stuff}})
	end
	if(research.has("warptorio-charting") or not nplanet.planet.desc)then game.print(nplanet.planet.name) end
	if(nplanet.planet.desc)then game.print(nplanet.planet.desc) end
	return nplanet.surface,nplanet.planet,nplanet.force
end


function warptorio.WarpPostBuildPlanet(planet)
	if(planet.warp_multiply)then
		global.warp_charge_time=global.warp_charge_time*planet.warp_multiply
		global.warp_time_left=global.warp_time_left*planet.warp_multiply
	end
	--gui.charge_time()
end

function warptorio.Warp(cf,f) -- Find and clone entities to new surface
	--cf.find_entities()
	--cf.clone_entities{surface=f,entities=tbl}

	-- call to platform()


	if(global.Teleporters.offworld)then global.Teleporters.offworld:DestroyPointTeleporter(2) end

	local etbl,tpply=warptorio.platform.GetWarpables(cf,f) --{},{}
	for k,v in pairs(etbl)do if(not isvalid(v))then etbl[k]=nil end end

	local blacktbl={}
	for k,v in pairs(etbl)do if(table.HasValue(warptorio.GetWarpBlacklist(),v.name))then table.insert(blacktbl,v) etbl[k]=nil end end
	for k,v in pairs(etbl)do if(not v or not v.valid)then etbl[k]=nil end end

	-- find logistics networks and robots among entities to catch robots outside the platform
	if(settings.global["warptorio_robot_warping"].value==true)then
		local lgn={} for k,v in pairs(etbl)do if(v.type=="roboport")then local g=v.logistic_network if(g and g.valid)then table.insertExclusive(lgn,g) end end end
		for k,v in pairs(lgn)do for i,e in pairs(v.robots)do table.insertExclusive(etbl,e) end end
	end


	-- do the cloning
	warptorio.Cloned_Entities={}
	warptorio.IsCloning=true
	cf.clone_entities{entities=etbl,destination_offset={0,0},destination_surface=f} --,destination_force=game.forces.player}
	warptorio.IsCloning=false
	local new_ents=warptorio.Cloned_Entities
	warptorio.Cloned_Entities=nil

	-- AAI Vehicles
	if(remote.interfaces["aai-programmable-vehicles"])then local rmt="aai-programmable-vehicles"
		for k,v in pairs(new_ents)do if(isvalid(v.source) and isvalid(v.destination))then
			local sig=remote.call(rmt,"get_unit_by_entity",v.source) if(sig)then remote.call(rmt,"on_entity_deployed",{entity=v.destination,signals=sig.data}) end
		end end
	end

	--local clones={} for k,v in pairs(etbl)do if(v.valid)then table.insert(clones,v.clone{position=v.position,surface=f,force=v.force}) end end

	-- Recreate teleporter gate
	--if(global.Teleporters.offworld)then global.Teleporters.offworld:CheckTeleporterPairs() end

	-- Clean inventories
	for k,v in pairs(game.players)do if(v and v.valid)then local iv=v.get_main_inventory() if(iv)then for i,x in pairs(iv.get_contents())do
		if(i:sub(1,25)=="warptorio-teleporter-gate")then iv.remove{name=i,count=x} end
		if(i:sub(1,20)=="warptorio-harvestpad")then if(x>1)then iv.remove{name=i,count=(x-1)} end end
	end end end end

	-- do the player teleport
	for k,v in pairs(tpply)do v[1].teleport(f.find_non_colliding_position("character",{v[2][1],v[2][2]},0,1),f) end

	--// cleanup past entities
	
	for k,v in pairs(etbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end
	for k,v in pairs(blacktbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end
end

function warptorio.SurfaceIsWarpzone(f) local n=f.name
	local hw=warptorio.GetHomeSurface()
	local sf=(n:sub(1,9)=="warpsurf_") -- backwards compatability
	local zf=(n:sub(1,9)=="warpzone_")
	return (n~="nauvis" and (sf or zf) and f~=hw)
end

function warptorio.WarpFinished()
	local f=warptorio.GetMainSurface()

	--// delete abandoned surfaces
	for k,v in pairs(game.surfaces)do
		if( table_size(v.find_entities_filtered{type="character"})<1 and v~=f)then
			--if(n=="nauvis" and not global.nauvis_is_clear)then global.nauvis_is_clear=true v.clear(true) else
			if(warptorio.SurfaceIsWarpzone(v))then game.delete_surface(v) end
		end
	end

	--warptorio.CheckReactor()

end

function warptorio.WarpPost(cf,f)
	-- Recreate teleporter gate
	if(global.Teleporters.offworld)then global.Teleporters.offworld:CheckTeleporterPairs() end

	--// radar -- game.forces.player.chart(f,{lefttop={x=-256,y=-256},rightbottom={x=256,y=256}})

	--// build void
	--for k,v in pairs({"nw","ne","sw","se"})do local ug=research.level("turret-"..v) or -1 if(ug>=0)then vector.LayCircle("out-of-map",c,vector.circleEx(vector(cx[v].x+0.5,cx[v].y+0.5),math.floor(10+(ug*6)) )) end end
	--vector.LayTiles("out-of-map",c,marea)

	if(cf and cf.valid)then warptorio.ConstructPlatformVoid(cf) end
	

end




--[[ Remotes ]]--

warptorio.remote={}

require("control_main_remotes")

remote.add_interface("warptorio",warptorio.remote)
remote.add_interface("warptorio2",warptorio.remote)

