--[[ Todo list ]] --

--[[
function warptorio.CountEntities() local c=0 for k,v in pairs(gwarptorio.floor)do if(v.surface and v.surface.valid and k~="main" and k~="home")then
	c=c+table_size(v.surface.find_entities())
end end return c end -- used in warpout

function warptorio.BlueprintEntityIsBlacklisted(e) if(warptorio.EntityIsPlatform(e))then return true end return false end
function warptorio.on_player_setup_blueprint.generic(ev)
	if(settings.global.warptorio_no_blueprint.value)then return end
	local mp=ev.mapping if(not mp)then return end local bpe=mp.get() local ply=game.players[ev.player_index]
	local cst=ply.blueprint_to_setup if(not cst or not cst.valid_for_read)then cst=ply.cursor_stack end if(not cst or not cst.valid_for_read)then return end
	local ents=cst.get_blueprint_entities()
	if(ents)then for k,v in pairs(ents)do if(warptorio.BlueprintEntityIsBlacklisted(bpe[v.entity_number]))then ents[k]=nil end end cst.set_blueprint_entities(ents) end
end


function warptorio.PlanetEntityIsPlatform(e) local r --=(e.name:sub(1,9)=="warptorio") if(r)then return true end
	for k,v in pairs(gwarptorio.Rails)do if(table.HasValue(v.rails,e))then return true end end
	for k,v in pairs{gwarptorio.Teleporters.offworld,gwarptorio.Teleporters.b1}do if(v:ManagesEntity(e))then return true end end
end
function warptorio.EntityIsPlatform(e) local r --=(e.name:sub(1,9)=="warptorio") if(r)then return true end
	for k,v in pairs(gwarptorio.Rails)do if(v:ManagesEntity(e))then return true end end
	for k,v in pairs(gwarptorio.Teleporters)do if(v:ManagesEntity(e))then return true end end
	for k,v in pairs(gwarptorio.Harvesters)do if(v:ManagesEntity(e))then return true end end
	for k,v in pairs(gwarptorio.floor)do if(v:ManagesEntity(e))then return true end end
	return false
end
]]

--[[ TODO

function warptorio.MigrateTileFloor(floor,buildfunc) local f=floor.surface
	vector.LayTiles("grass-1",f,vector.square(vector(-1,-1),vector(512,512)))
	buildfunc()
	local tcs={}
	for k,v in pairs(f.find_tiles_filtered{name="grass-1"})do table.insert(tcs,{name="out-of-map",position=v.position}) end
	f.set_tiles(tcs,true)
end
function warptorio.MigrateHarvesterFloor()
	warptorio.BuildB3()
	local rLogs=game.forces.player.technologies["warptorio-logistics-1"].researched
	for k,v in pairs(storage.warptorio.Harvesters)do local f,pos v:DestroyLogs()
		if(v.deployed)then f,pos=v.b.surface,v.deploy_position v:Recall() end
		v:DestroyA() v:DestroyB() v:Warpin() if(rLogs)then v:SpawnLogs() end v:Upgrade()
	end
end
function warptorio.MigrateTiles() if(warptorio.tilesAreMigrated)then return end warptorio.tilesAreMigrated = true
	local flv=gwarptorio.floor.b1 if(flv)then warptorio.MigrateTileFloor(flv,warptorio.BuildB1) end
	local flv=gwarptorio.floor.b2 if(flv)then warptorio.MigrateTileFloor(flv,warptorio.BuildB2) end
	local flv=gwarptorio.floor.b3 if(flv)then warptorio.MigrateTileFloor(flv,warptorio.MigrateHarvesterFloor) end
	warptorio.ValidateCache()
	warptorio.BuildPlatform()
end



function warptorio.init.floors(bhzd)
	if(not gwarptorio.floor)then gwarptorio.floor={} end
	local m=gwarptorio.floor.main if(not m)then m=new(FLOOR,"main",8) m.surface=game.surfaces["nauvis"] end
	local m=gwarptorio.floor.b1 if(not m)then m=new(FLOOR,"b1",16) m:MakeEmptySurface() end
	local m=gwarptorio.floor.b2 if(not m)then m=new(FLOOR,"b2",17) m:MakeEmptySurface() end
	local m=gwarptorio.floor.b3 if(not m)then m=new(FLOOR,"b3",17) m.ovalsize={x=19,y=17} m:MakeEmptySurface() end
	warptorio.BuildPlatform(bhzd)
	warptorio.BuildB1(bhzd)
	warptorio.BuildB2(bhzd)
	warptorio.BuildB3(bhzd)
end
function warptorio.RebuildFloors(bhzd) warptorio.init.floors(bhzd) end


function warptorio.BuildHazards() warptorio.BuildPlatformHazard() warptorio.BuildB1Hazard() warptorio.BuildB2Hazard() warptorio.BuildB3Hazard() end



function warptorio.BuildPlatformHazard()

end

function warptorio.BuildPlatform(bhzd)

	if(bhzd~=true)then warptorio.BuildPlatformHazard() end

	players.playsound("warp_in",f)
end


function warptorio.CheckReactor()
	local m=gwarptorio.floor.main
	local rlv=research.level("warptorio-reactor") -- gwarptorio.Research["reactor"] or 0
	if(rlv>=6 and (not gwarptorio.warp_reactor or not gwarptorio.warp_reactor.valid))then
		local f=m.surface
		vector.clean(f,vector.square(vector(-0.5,-0.5),vector(5,5)))
		local e=f.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player,player=game.players[1]}
		vector.cleanplayers(f,vector.square(vector(-0.5,-0.5),vector(5,5)))
		gwarptorio.warp_reactor=e
		e.minable=false
	end
end




]] --




--[[ Settings ]] --
function warptorio.setting(n) return settings.global["warptorio_" .. n].value end

warptorio.settings = {}
local setter = warptorio.settings

function setter.warptorio_autowarp_disable() warptorio.ResetHUD() end

function setter.warptorio_autowarp_always() warptorio.ResetHUD() end

function setter.warptorio_water() warptorio.EarlyWater(settings.global["warptorio_water"].value) end

function setter.warptorio_carebear() warptorio.Carebear(settings.global["warptorio_carebear"].value) end

function setter.warptorio_solar_multiplier()
	warptorio.SolarMultiplier(settings.global["warptorio_solar_multiplier"]
		.value)
end

function setter.warptorio_loaderchest_provider() warptorio.LoaderChestChanged(true) end

function setter.warptorio_loaderchest_requester() warptorio.LoaderChestChanged(false) end

function setter.warptorio_loader_top() warptorio.LoaderSideChanged(true) end

function setter.warptorio_loader_bottom() warptorio.LoaderSideChanged(false) end

function setter.warptorio_combinator_offset() warptorio.CombinatorOffsetChanged() end

function setter.warptorio_hide_sprites()
	for k, v in pairs(storage.Teleporters) do
		v:CheckPointSprites(1)
		v:CheckPointSprites(2)
	end
end

function warptorio.CombinatorOffsetChanged()
	for k, v in pairs(storage.Harvesters) do
		v:DestroyCombos()
		v:CheckCombo()
	end
end

function warptorio.LoaderChestChanged(bprovider)
end

function warptorio.LoaderSideChanged(btop)
	for k, v in pairs(storage.Teleporters) do
		local g = v:Data().top
		if ((btop and g) or (not btop and not g)) then
			v:DestroyPointLogistics(1)
			v:DestroyPointLogistics(2)
			v:CheckTeleporterPairs(true)
		end
	end
end

function warptorio.SolarMultiplier(x)
	for k, v in pairs(warptorio.GetPlatformSurfaces()) do v.solar_power_multiplier = x end
end

warptorio.carebearItems = {
	["stone"] = 20,
	["coal"] = 20,
	["iron-plate"] = 20,
	["copper-plate"] = 20,
	["electronic-circuit"] = 10,
	["iron-gear-wheel"] = 10,
	["wooden-chest"] = 4,
	["transport-belt"] = 10,
	["underground-belt"] = 2,
	["splitter"] = 1,
	["burner-mining-drill"] = 2,
	["assembling-machine-1"] = 2,
	["small-electric-pole"] = 5,
	["steam-engine"] = 1,
	["boiler"] = 1,
	["gun-turret"] = 4,
	["uranium-rounds-magazine"] = 50,
	["piercing-rounds-magazine"] = 200,
	["firearm-magazine"] = 400,
}
function warptorio.Carebear(b)
	if (b and not storage.carebear) then
		storage.carebear = true
		local e = storage.floor.main.host.create_entity { name = "warptorio-carebear-chest", position = { -1, -1 }, force = game.forces.player }
		local inv = e.get_inventory(defines.inventory.chest)
		for k, v in pairs(warptorio.carebearItems) do inv.insert { name = k, count = v } end
	end
end

function warptorio.EarlyWater(b)
	if (b and not storage.earlywater) then
		storage.earlywater = true
		game.forces.player.technologies["warptorio-boiler-water-1"].researched = true
	end
end

function warptorio.OnModSettingChanged(ev)
	local p = ev.player_index
	local s = ev.setting
	local st = ev.setting_type
	if (warptorio.settings[s]) then warptorio.settings[s](ev) end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, warptorio.OnModSettingChanged)


function warptorio.IsAutowarpEnabled()
	return warptorio.setting("autowarp_disable") ~= true and
		(not research.has("warptorio-reactor-6") or warptorio.setting("autowarp_always"))
end

function warptorio.HookNewGamePlus()
	if (remote.interfaces["newgameplus"]) then
		if (not warptorio.newgameplus) then
			warptorio.newgameplus = true
			local ngp = remote.call("newgameplus", "get_on_technology_reset_event")
			if (ngp) then script.on_event(ngp, warptorio.OnPreNewGame) end
			local ngp = remote.call("newgameplus", "get_on_post_new_game_plus_event")
			if (ngp) then script.on_event(ngp, warptorio.OnPostNewGame) end
		end
	end
end

--[[ Loot Chest ]] --


warptorio.LootItems = {
	["roboport"] = 4,
	["construction-robot"] = 10,
	["logistic-robot"] = 20,
	["passive-provider-chest"] = 10,
	["requester-chest"] = 10,
	["buffer-chest"] = 10,
	["wooden-chest"] = 20,
	["iron-chest"] = 20,
	["steel-chest"] = 20,
	["storage-tank"] = 10,
	["wood"] = 100,
	["stone"] = 100,
	["iron-plate"] = 400,
	["iron-gear-wheel"] = 300,
	["steel-plate"] = 200,
	["copper-plate"] = 300,
	["copper-cable"] = 400,
	["electronic-circuit"] = 200,
	["advanced-circuit"] = 100,
	["processing-unit"] = 50,
	["big-electric-pole"] = 25,
	["medium-electric-pole"] = 25,
	["small-electric-pole"] = 25,
	["substation"] = 15,
	["landfill"] = 100,
	["pipe"] = 200,
	["pipe-to-ground"] = 50,
	["express-transport-belt"] = 100,
	["fast-transport-belt"] = 200,
	["transport-belt"] = 300,
	["express-underground-belt"] = 15,
	["fast-underground-belt"] = 20,
	["underground-belt"] = 25,
	["accumulator"] = 10,
	["steam-engine"] = 10,
	["nuclear-reactor"] = 2,
	["heat-exchanger"] = 10,
	["heat-pipe"] = 25,
	["steam-turbine"] = 10,
	["chemical-plant"] = 10,
	["assembling-machine-1"] = 15,
	["assembling-machine-2"] = 15,
	["assembling-machine-3"] = 15,
	["inserter"] = 30,
	["fast-inserter"] = 20,
	["bulk-inserter"] = 15,
	["warptorio-atomic-bomb"] = 1,
	["warptorio-warponium-fuel-cell"] = 2,
	["warptorio-warponium-fuel"] = 1,
	["gun-turret"] = 10,
	["uranium-rounds-magazine"] = 100,
	["firearm-magazine"] = 400,
	["piercing-rounds-magazine"] = 200,
	["atomic-bomb"] = 2,
}

function warptorio.GetPossibleLoot()
	local lt = {}
	for k, v in pairs(warptorio.LootItems) do
		local r = game.forces.player.recipes[k]
		if (not r or (r and r.enabled == true)) then lt[k] = v end
	end
	return lt
end

function warptorio.LootTable(mn, mx, cDist, cStack)
	local lt = warptorio.GetPossibleLoot()
	local t, u, k, vDist, vStack = {}
	for i = 1, math.random(mn or 1, mx or 5), 1 do
		u, k = table.Random(lt)
		vDist, vStack = math.min((cDist or 850) / 1700, 1), math.random((cStack or 20), 100) / 100
		t[k] = math.max(math.ceil(u * vDist * vStack), 1)
	end
	return t
end

function warptorio.SpawnLootChest(f, pos, varg)
	pos = vector(pos)
	varg = varg or {}
	local e = f.create_entity { name = "warptorio-lootchest", position = pos, force = game.forces.player, raise_built = true }
	if (not isvalid(e)) then return false end
	local lt = warptorio.LootTable(varg.min or 1, varg.max or 5, varg.dist or vector.length(pos), varg.stack or 20)
	local inv = e.get_inventory(defines.inventory.chest)
	for k, v in pairs(lt) do inv.insert { name = k, count = v } end
	return e
end

function warptorio.ChunkLootChest(ev)
	if (settings.global["warptorio_no_lootchest"].value == true or math.random(1, settings.global["warptorio_lootchest_chance"].value) > 1) then return end
	local f = ev.surface
	if (not (f.name == "nauvis" or f == warptorio.GetMainSurface())) then return end
	local a = ev.area
	local x, y = math.random(a.left_top.x, a.right_bottom.x), math.random(a.left_top.y, a.right_bottom.y)
	local dist = math.sqrt(math.abs(x ^ 2) + math.abs(y ^ 2))
	if (dist >= settings.global["warptorio_lootchest_distance"].value) then
		warptorio.SpawnLootChest(f, { x, y })
	end
end

events.on_event(defines.events.on_chunk_generated, warptorio.ChunkLootChest)



--[[ Tick Functions ]] --


function warptorio.ClockTick(tick)
	local donewarp = false
	if (storage.warp_charging == 1) then
		storage.warp_time_left = (60 * storage.warp_charge_time) - (tick - storage.warp_charge_start_tick)
		if (storage.warp_time_left <= 0) then
			warptorio.Warpout()
			donewarp = true
		end
	end
	storage.time_passed = tick - storage.warp_last
	--gui.time_passed()
	--gui.charge_time()

	if (not donewarp and warptorio.IsAutowarpEnabled()) then
		storage.warp_auto_end = (60 * storage.warp_auto_time) - (tick - storage.warp_last)
		if (storage.warp_auto_end <= 0) then
			warptorio.Warpout()
			donewarp = true
		end
	end

	cache.updatemenu("hud", "clocktick")
	--gui.autowarp()
	--gui if(research.has("warptorio-charting") or research.has("warptorio-accelerator") or research.has("warptorio-stabilizer"))then warptorio.derma.cooldown() end
	--gui if(storage.homeworld)then warptorio.derma.homeworld() end

	warptorio.RefreshWarpCombinators()


	--events.vraise("ticktime",{warp_left=storage.warp_time_left,auto_left=warptorio.IsAutowarpEnabled() and storage.warp_auto_end or false, donewarp=donewarp})
end

events.on_tick(60, 0, "clock", warptorio.ClockTick)


function warptorio.ChargeCountdownTick(tick)
	if (storage.warp_charging < 1 and storage.warp_charge_time > 30) then
		local r = (780) - (research.level("warptorio-reactor") * 60)
		if (tick % r == 0) then storage.warp_charge_time = math.max(storage.warp_charge_time - 1, 30) end -- 60t*13s=780t
	end
end

events.on_tick(60, 0, "charge_countdown", warptorio.ChargeCountdownTick)

function warptorio.WarpAlarmTick(tick)
	if ((storage.warp_charging == 1 and storage.warp_time_left <= 3600) or (warptorio.IsAutowarpEnabled() and storage.warp_auto_end <= 3600)) then
		players.playsound("warp_alarm")
	end
end

events.on_tick(120, 1, "warpalarm", warptorio.WarpAlarmTick)

function warptorio.PollutionTick(tick)
	if (tick % (warptorio.setting("pollution_tickrate") * 60) ~= 0) then return end
	local f = warptorio.GetMainSurface()
	if (not isvalid(f)) then return end
	local stb = storage.abilities.stabilizing
	local vpol = 0
	if (warptorio.setting("pollution_disable") ~= true) then
		vpol = storage.pollution_amount
		storage.pollution_amount = math.min(
			vpol + (vpol ^ warptorio.setting("pollution_exponent")) *
			(stb and 0.05 or warptorio.setting("pollution_multiplier")), 1000000)
	end

	for k, v in pairs(warptorio.GetPlatformSurfaces()) do
		vpol = vpol + v.get_total_pollution()
		v.clear_pollution()
	end
	if (vpol > 0) then
		f.pollute({ -1, -1 }, vpol * (stb and 0.05 or 1)) -- todo; pollute to teleporters and harvesters *0.125
	end
end

events.on_tick(60, 0, "pollution", warptorio.PollutionTick)

events.on_tick(60, 0, "radar_ability", function(tick)
	local rdr = storage.abilities.scanning
	if (not rdr) then return end
	local rdrt = storage.abilities.scantick or 0
	local rdrg = storage.abilities.scanzone or 0
	rdrt = rdrt + 1
	storage.abilities.scantick = rdrt
	if (rdrt < 3 + rdrg) then return end
	rdrt = 0
	storage.abilities.scantick = 0


	storage.abilities.scanzone = rdrg + 1
	local f = warptorio.GetMainSurface()
	game.forces.player.chart(f,
		{ lefttop = { x = -64 - 32 * rdrg, y = -64 - 32 * rdrg }, rightbottom = { x = 64 + 32 * rdrg, y = 64 + 32 * rdrg } })
	players.playsound("reactor-stabilized", f)
end)


function warptorio.BiterTick(tick)
	if (warptorio.setting("biter_wave_disable") == true or tick % (warptorio.setting("pollution_tickrate") * 60) ~= 0) then return end
	storage.pollution_expansion = math.min(
		storage.pollution_expansion * settings.global["warptorio_biter_expansion"].value,
		60 * 60 * settings.global["warptorio_biter_redux"].value)
	game.map_settings.enemy_expansion.min_expansion_cooldown = math.max(
		(60 * 60 * settings.global["warptorio_biter_min"].value) - storage.pollution_expansion, 60 * 60 * 1)
	game.map_settings.enemy_expansion.max_expansion_cooldown = math.max(
		((60 * 60 * settings.global["warptorio_biter_max"].value) - storage.pollution_expansion) + 1, 60 * 60 * 1)
	--game.print("pol: " .. game.map_settings.enemy_expansion.min_expansion_cooldown)
	local pt = (storage.time_passed / 60) / 60
	if (pt > settings.global["warptorio_biter_wavestart"].value) then
		pt = pt - settings.global["warptorio_biter_wavestart"].value
		local el = math.ceil(pt * settings.global["warptorio_biter_wavesize"].value)
		local erng = math.ceil(pt * settings.global["warptorio_biter_waverng"].value)
		local bmax = settings.global["warptorio_biter_wavesizemax"].value
		if (bmax > 0) then el = math.min(el, bmax) end
		if (math.random(1, math.max(math.min(settings.global["warptorio_biter_wavemax"].value - erng, settings.global["warptorio_biter_wavemin"].value), 1)) <= 1) then
			local f = storage.floor.main.host
			f.set_multi_command { command = { type = defines.command.attack_area, destination = { 0, 0 }, radius = 128 }, unit_count = el }
		end
	end
end

events.on_tick(60, 0, "biters", warptorio.BiterTick)


--[[
-- Old ability buttons
wderma.stabilizer=derma.GuiControl("warptorio_stabilizer","button")
function wderma.stabilizer:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.stabilizer:update(p) local r=self:get(p) r.caption={"warptorio.button_stabilizer"} end
function wderma.stabilizer:click(p)
	if(game.tick<(storage.ability_next or 0) or not research.has("warptorio-stabilizer"))then return end
	warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value,settings.global["warptorio_ability_cooldown"].value)
	warptorio.raise_event("ability_used",{player=p,ability="stabilizer",use_num=storage.ability_uses})
	game.forces["enemy"].evolution_factor=0
	storage.pollution_amount = 1.25
	storage.pollution_expansion = 1.5
	local f=warptorio.GetMainSurface()
	f.clear_pollution()
	if(storage.warp_reactor and isvalid(storage.warp_reactor))then f.set_multi_command{command={type=defines.command.flee, from=storage.warp_reactor}, unit_count=1000, unit_search_distance=500} end
	players.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Stabilized")
end

wderma.accelerator=derma.GuiControl("warptorio_accelerator","button")
function wderma.accelerator:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.accelerator:update(p) local r=self:get(p) r.caption={"warptorio.button_accelerator"} end
function wderma.accelerator:click(p)
	if(game.tick<(gwarptorio.ability_next or 0) or gwarptorio.warp_charge_time<=10)then return end
	warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value,settings.global["warptorio_ability_cooldown"].value)
	warptorio.raise_event("ability_used",{player=p,ability="accelerator",use_num=gwarptorio.ability_uses})

	gwarptorio.warp_charge_time=math.max(math.ceil(gwarptorio.warp_charge_time^0.75),10)
	if(gwarptorio.warp_charging~=1)then warptorio.derma.charge_time() end --,gwarptorio.warp_charge_time*60) end

	local f=warptorio.GetMainSurface()
	players.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Accelerated")
end

wderma.radar=derma.GuiControl("warptorio_radar","button")
function wderma.radar:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.radar:update(p) local r=self:get(p) r.caption={"warptorio.button_radar"} end
function wderma.radar:click(p)
	if(game.tick<(gwarptorio.ability_next or 0))then return end
	warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value/1.25,settings.global["warptorio_ability_cooldown"].value*0.6)
	--warptorio.derma.radar()
	local n=gwarptorio.radar_uses+1 gwarptorio.radar_uses=n
	warptorio.raise_event("ability_used",{player=p,ability="radar",use_num=gwarptorio.ability_uses,radar_num=n})

	local f=warptorio.GetMainSurface()
	game.forces.player.chart(f,{lefttop={x=-64-128*n,y=-64-128*n},rightbottom={x=64+128*n,y=64+128*n}})
	players.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Scanner Sweep")
end
]]


--[[ Class Cache ]] --


local tpCache = {}
function tpCache.raise(obj, cls, entkey, pth, vi)
	obj.cls = cls
	obj.entkey = entkey
	obj.pth = pth
	obj.vi = vi
end

function tpCache.unraise(obj, b_noraise)
	local gv = storage[obj.cls][obj.entkey]
	--gv:DestroyPointTeleporter(obj.vi)
end

function tpCache.create(e, ev)
	cache.insert("power", e)
end

function tpCache.clone(e, ev)
	local obj = cache.get_entity(ev.source)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		gv:DestroyPointSprites(obj.vi)
		local nv = cache.force_entity(e, obj.cls, obj.entkey, obj.pth, obj.vi)
		cache.destroy_entity(obj, true)
		gv[nv.pth][nv.vi].ent = e
		gv:CheckPointSprites(nv.vi)

		local gvoe = gv[nv.pth][nv.vi == 1 and 2 or 1].ent
		local gvoc = cache.get_entity(gvoe)
		if (gvoc) then
			gvoc.teleport_dest = e
			nv.teleport_dest = gvoe
		end
		if (gv:Data().circuit) then gv:ConnectCircuit() end
	end
end

function tpCache.destroy(e, ev)
	cache.remove("power", e)
	local obj = cache.get_entity(e)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		--gv:DestroyPointTeleporter(obj.vi)
		--gv:DestroyPointLogistics(obj.vi)
		cache.destroy(obj)
	end
end

local tpgateCache = table.deepcopy(tpCache)
function tpgateCache.built(e, ev)
	local obj = cache.force_entity(e, "Teleporters", "offworld", "points", 2)

	if (obj) then
		local ef = e.surface
		local t = storage.Teleporters["offworld"]
		local gv = storage[obj.cls][obj.entkey]
		if (gv:ValidB()) then
			entity.destroy(gv.points[2].ent)
			game.print({ "warptorio.max-one-teleporter-error" })
		end

		--if(ef~=warptorio.GetMainSurface())then game.print("Teleporter Logistics only functions on the Planet") return end
		--[[if(ef.count_entities_filtered{area=t:GetLogisticsArea(e.position),collision_mask={"object-layer"}} >1)then
			game.print("Unable to place teleporter logistics, something is in the way!")

			gv[obj.pth][obj.vi].ent=e
			gv:CheckTeleporterPairs()
			return
		end]]
		local gve = gv[obj.pth][obj.vi]
		gve.ent = e
		gv:CheckPointLogistics(2, e.position)
		if (gve.energy) then
			e.energy = gve.energy
			gve.energy = nil
		end
		gv:CheckTeleporterPairs()
	end
end

function tpgateCache.destroy(e, ev)
	cache.remove("power", e)
	local obj = cache.get_entity(e)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		--gv:DestroyPointTeleporter(obj.vi)
		gv:DestroyPointLogistics(obj.vi)
		cache.destroy(obj)
	end
end

local tpharvCache = table.deepcopy(tpCache)

function tpharvCache.destroy(e, ev)
	cache.remove("power", e)
	local obj = cache.get_entity(e)
	if (obj and not obj.dead) then
		obj.dead = true
		local gv = storage[obj.cls][obj.entkey]
		cache.destroy(obj)
		gv:Recall()
	end
end

tpharvCache.died = tpharvCache.destroy

function tpharvCache.mined(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		for x, y in pairs(ev.buffer.get_contents()) do ev.buffer.remove({ name = y.name, count = y.count }) end
		local cn = (gv:Data().pad_prototype .. "-" .. research.level("warptorio-harvester-" .. obj.entkey))
		if (not ply or (ply and not ply.get_main_inventory().get_contents()[cn])) then ev.buffer.insert { name = cn, count = 1 } end
		local hv = storage.Harvesters[obj.entkey]
		if (not hv.deployed) then hv:Recall() else hv:CheckTeleporterPairs() end
	end
end

--[[
function tpharvCache.clone(e,ev)
	local obj=cache.get_entity(ev.source)
	if(obj)then
		local gv=storage[obj.cls][obj.entkey]
		gv:DestroyPointSprites(obj.vi)
		local nv=cache.force_entity(e,obj.cls,obj.entkey,obj.pth,obj.vi)
		cache.destroy_entity(obj,true)
		gv[nv.pth][nv.vi].ent=e
		gv:CheckPointSprites(nv.vi)

		local gvoe=gv[nv.pth][nv.vi==1 and 2 or 1].ent
		local gvoc=cache.get_entity(gvoe)
		if(gvoc)then gvoc.teleport_dest=e nv.teleport_dest=gvoe end
		if(gv:Data().circuit)then gv:ConnectCircuit() end
	end
end
]]

function tpharvCache.clone(e, ev)
	local obj = cache.get_entity(ev.source)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		gv:DestroyPointSprites(obj.vi)
		local ovi = (obj.vi == 1 and 2 or 1)

		local nv = cache.force_entity(e, obj.cls, obj.entkey, obj.pth, ovi)
		--cache.destroy_entity(obj,true)
		--gv:DestroyPointTeleporter(obj.vi)
		gv[nv.pth][ovi].ent = e
		e.energy = 0

		local gvoe = gv[nv.pth][obj.vi].ent
		local gvoc = cache.get_entity(gvoe)
		if (gvoc) then
			gvoc.teleport_dest = e
			nv.teleport_dest = gvoe
		end
		--gv:CheckTeleporterPairs()
	end
end

local tppadWestCache = {}
function tppadWestCache.built(e, ev)
	local f = e.surface
	if (f ~= warptorio.GetMainSurface()) then return end
	local pos = e.position
	entity.destroy(e)
	local hv = storage.Harvesters["west"]
	if (hv) then hv:Deploy(f, pos) end
end

local tppadEastCache = {}
function tppadEastCache.built(e, ev)
	local f = e.surface
	if (f ~= warptorio.GetMainSurface()) then return end
	local pos = e.position
	entity.destroy(e)
	local hv = storage.Harvesters["east"]
	if (hv) then hv:Deploy(f, pos) end
end

for k, v in pairs { "warptorio-harvestportal", "warptorio-harvestpad-west", "warptorio-harvestpad-east" } do
	for i = 0, 8, 1 do cache.ent(v .. "-" .. i, tpharvCache) end
end
for i = 0, 8, 1 do cache.ent("warptorio-harvestpad-west-" .. i, tppadWestCache) end
for i = 0, 8, 1 do cache.ent("warptorio-harvestpad-east-" .. i, tppadEastCache) end



cache.ent("warptorio-teleporter", tpCache)
cache.ent("warptorio-teleporter-gate", tpgateCache)
cache.ent("warptorio-underground", tpCache)
for i = 0, 8, 1 do
	cache.ent("warptorio-teleporter-gate-" .. i, tpgateCache)
	cache.ent("warptorio-teleporter-" .. i, tpCache)
	cache.ent("warptorio-underground-" .. i, tpCache)
end


local loaderCache = {}
function loaderCache.raise(obj, cls, entkey, pth, vi, vid)
	obj.cls = cls
	obj.entkey = entkey
	obj.pth = pth
	obj.vi = vi
	obj.vid = vid
end

function loaderCache.unraise(obj)
	local gv = storage[obj.cls][obj.entkey]
	--gv[obj.pth][obj.vi][obj.vid]=nil
end

function loaderCache.clone(e, ev)
	local obj = cache.get_entity(ev.source)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		local nv = cache.force_entity(e, obj.cls, obj.entkey, obj.pth, obj.vi, obj.vid)
		cache.destroy_entity(obj, true)
		gv[nv.pth][nv.vi][nv.vid] = e
	end
end

function loaderCache.destroy(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then cache.destroy(obj) end
end

function loaderCache.rotate(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		if (obj.cls == "Rails") then
			gv.dir = e.loader_type
			gv:Rotate()
		else
			gv.dir[obj.vi][obj.vid] = e.loader_type
			gv.dir[(obj.vi == 1 and 2 or 1)][obj.vid] = string.opposite_loader[e.loader_type]
			local de = gv.loaders[(obj.vi == 1 and 2 or 1)][obj.vid]
			if (isvalid(de)) then de.loader_type = string.opposite_loader[e.loader_type] end
			if (gv.chests) then gv:SwapLoaderChests(obj.vid) end
		end
	end
end

cache.ent("loader", loaderCache)
cache.ent("fast-loader", loaderCache)
cache.ent("express-loader", loaderCache)


local pipeCache = {}
function pipeCache.raise(obj, cls, key, pth, vi, vid)
	obj.cls = cls
	obj.entkey = key
	obj.pth = pth
	obj.vi = vi
	obj.vid = vid
end

function pipeCache.unraise(obj)
	local gv = storage[obj.cls][obj.entkey]
	--gv[obj.pth][vi][vid]=nil
end

function pipeCache.clone(e, ev)
	local obj = cache.get_entity(ev.source)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		local nv = cache.force_entity(e, obj.cls, obj.entkey, obj.pth, obj.vi, obj.vid)
		cache.destroy_entity(obj, true)
		gv[nv.pth][nv.vi][nv.vid] = e
	end
end

function pipeCache.destroy(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then cache.destroy(obj) end
end

cache.ent("warptorio-logistics-pipe", pipeCache)


local gpipeCache = {} -- Global pipe cache to clean warppipes

function gpipeCache.destroy(e, ev)
	for k, v in pairs(storage.Teleporters) do v:CheckEmptyPipes() end
end

cache.type("pipe", gpipeCache)
cache.type("pipe-to-ground", gpipeCache)


local chestCache = {}
function chestCache.raise(obj, cls, key, pth, vi, vid)
	obj.cls = cls
	obj.entkey = key
	obj.pth = pth
	obj.vi = vi
	obj.vid = vid
end

function chestCache.unraise(obj)
	--local gv=storage[obj.cls][obj.entkey]
	--gv[obj.pth][vi][vid]=nil
end

function chestCache.clone(e, ev)
	local obj = cache.get_type("types", ev.source.type, ev.source)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		local nv = cache.get_raise_type("types", e.type, e, obj.cls, obj.entkey, obj.pth, obj.vi, obj.vid)
		gv[nv.pth][nv.vi][nv.vid] = e
		--cache.destroy(obj,true)
	end
end

function chestCache.destroy(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then cache.destroy(obj) end
end

cache.type("container", chestCache)
cache.type("logistic-container", chestCache)


local comboCache = {}
function comboCache.raise(obj, cls, key, pth, vi)
	obj.cls = cls
	obj.entkey = key
	obj.pth = pth
	obj.vi = vi
end

function comboCache.unraise(obj)
	local gv = storage[obj.cls][obj.entkey]
	--gv[obj.pth][vi][vid]=nil
end

function comboCache.clone(e, ev)
	local obj = cache.get_entity(ev.source)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		local nv = cache.force_entity(e, obj.cls, obj.entkey, obj.pth, obj.vi)
		cache.destroy_entity(obj, true)
		gv[nv.pth][nv.vi] = e
	end
end

function comboCache.destroy(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then
		local gv = storage[obj.cls][obj.entkey]
		--gv[obj.vi][obj.vid]=nil
		cache.destroy_entity(obj)
	end
end

cache.ent("warptorio-alt-combinator", comboCache)


-- string.opposite_loader[e.loader_type]
local warploader = {}

function warploader.dofilters(e)
	local tp = e.loader_type
	local lanes = { e.get_transport_line(1), e.get_transport_line(2) }
	for k, v in pairs(storage.warploaders.outputf) do for i = 1, 2, 1 do table.RemoveByValue(v, lanes[i]) end end
	if (tp ~= "output") then --if(tp=="input")then
		for i = 1, 2, 1 do table.RemoveByValue(storage.warploaders.output, lanes[i]) end
		for i = 1, 2, 1 do table.insertExclusive(storage.warploaders.input, lanes[i]) end
	else --if(tp=="output")then
		local ct = storage.warploaders.outputf
		local hf = false
		for i = 1, 5, 1 do
			local f = e.get_filter(i)
			if (f) then
				hf = true
				ct[f] = ct[f] or {}
				for a = 1, 2, 1 do table.insertExclusive(ct[f], lanes[a]) end
			end
		end
		if (hf) then
			for i = 1, 2, 1 do table.RemoveByValue(storage.warploaders.output, lanes[i]) end
		else
			for a = 1, 2, 1 do table.insertExclusive(storage.warploaders.output, lanes[a]) end
		end
		for a = 1, 2, 1 do table.RemoveByValue(storage.warploaders.input, lanes[a]) end
	end
end

function warploader.built(e, ev)
	storage.warploaders = storage.warploaders or {}
	storage.warploaders.input = storage.warploaders.input or {}
	storage.warploaders.output = storage.warploaders.output or {}
	storage.warploaders.outputf = storage.warploaders.outputf or {}
	storage.warploaders.outputf_next = storage.warploaders.outputf_next or {}

	warploader.dofilters(e)
end

function warploader.rotate(e, ev)
	warploader.dofilters(e)
end

function warploader.destroy(e, ev)
	local obj = cache.get_entity(e)
	if (obj) then cache.destroy(obj) end
	local un = e.unit_number
	local tp = e.loader_type
	local wpg = storage.warploaders
	local lanes = { e.get_transport_line(1), e.get_transport_line(2) }
	if (tp == "output") then
		local hf = false
		for i = 1, 5, 1 do
			if (e.get_filter(i)) then
				hf = true
				break
			end
		end
		if (hf) then
			for k, v in pairs(wpg.outputf) do for i = 1, 2, 1 do table.RemoveByValue(v, lanes[i]) end end
		else
			for i = 1, 2, 1 do table.RemoveByValue(wpg.output, lanes[i]) end
		end
	else
		for i = 1, 2, 1 do table.RemoveByValue(wpg.input, lanes[i]) end
	end
end

function warploader.settings_pasted(e) warploader.dofilters(e) end

function warploader.gui_closed(e) warploader.dofilters(e) end

cache.ent("warptorio-warploader", warploader)

function warptorio.InsertWarpLane(cv, item_name)
	if (cv.can_insert_at_back()) then
		cv.insert_at_back({ name = item_name, count = 1 })
		return true
	end
	return false
end

function warptorio.NextWarploader(tbl, key)
	local k, v = next(tbl, key)
	if (not k and not v) then
		return next(tbl, nil)
	end
	return k, v
end

function warptorio.DistributeLoaderLine(line)
	local inv = line.get_contents()
	for item_name, item_count in pairs(inv) do
		if (warptorio.OutputWarpLoader(item_count.name, item_count.count)) then
			line.remove_item { name = item_count.name, count = 1 }
			return true
		end
	end
end

function warptorio.OutputWarpLoader(cv, c)
	local wpg = storage.warploaders

	local ins = false
	if (wpg.outputf[cv]) then
		local wpfnext = wpg.outputf_next[cv]
		local coutf = wpg.outputf[cv]
		for k, v in pairs(coutf) do
			local rk, rv = warptorio.NextWarploader(coutf, wpfnext)
			wpfnext = rk
			if (rv and warptorio.InsertWarpLane(rv, cv)) then
				ins = true
				break
			end
		end
		wpg.outputf_next[cv] = wpfnext
		if (ins) then return true end
	end
	local wpnext = wpg.output_next
	local cout = wpg.output
	for k, v in pairs(cout) do
		local rk, rv = warptorio.NextWarploader(cout, wpnext)
		wpnext = rk
		if (rv and warptorio.InsertWarpLane(rv, cv)) then
			ins = true
			break
		end
	end
	wpg.output_next = wpnext
	if (ins) then return true end
	return false
end

function warptorio.TickWarploaders()
	local wpg = storage.warploaders
	if (not wpg) then return end
	local k, line = warptorio.NextWarploader(wpg.input, wpg.input_next)
	wpg.input_next = k
	if (not isvalid(line)) then return end
	warptorio.DistributeLoaderLine(line)
end

function warptorio.TickLogistics()
	for nm, tpt in pairs(storage.Teleporters) do
		if (tpt.pipes) then
			if (type(tpt.pipes) == "boolean") then error(serpent.block(tpt)) end
			for vi, ve in pairs(tpt.pipes[1]) do
				if (isvalid(ve)) then
					local vo = tpt.pipes[2][vi]
					if (isvalid(vo)) then entity.BalanceFluidPair(ve, vo) end
				end
			end
		end
		if (tpt.chests) then
			for vi, ve in pairs(tpt.chests[1]) do
				if (isvalid(ve)) then
					local vo = tpt.chests[2][vi]
					if (isvalid(vo)) then
						local vdir = tpt.dir[1][vi]
						if (vdir == "input") then entity.ShiftContainer(ve, vo) else entity.ShiftContainer(vo, ve) end
					end
				end
			end
		end
	end
	for nm, tpt in pairs(storage.Harvesters) do
		for vi, ve in pairs(tpt.pipes[1]) do
			if (isvalid(ve)) then
				local vo = tpt.pipes[2][vi]
				if (isvalid(vo)) then entity.BalanceFluidPair(ve, vo) end
			end
		end
		for vi, ve in pairs(tpt.loaders[1]) do
			if (isvalid(ve)) then
				local vo = tpt.loaders[2][vi]
				if (isvalid(vo)) then
					local vdir = tpt.dir[1][vi]
					if (vdir == "input") then entity.ShiftBelt(ve, vo) else entity.ShiftBelt(vo, ve) end
				end
			end
		end
	end
	entity.AutoBalancePower(cache.get("power"))
	entity.AutoBalanceHeat(cache.get("heat"))
	if (storage.warploaders) then
		for i = 1, math.min(table_size(storage.warploaders.input), 10), 1 do
			warptorio
				.TickWarploaders()
		end
	end
end

events.on_tick(1, 0, "TickLogs", warptorio.TickLogistics)
