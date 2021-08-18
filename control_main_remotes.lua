
--[[ Custom Events ]]--

function warptorio.remote.get_events() return events.vdefs end -- call (), returns {event_name=script_generated_event_name_int}. Used to get a copy of the entire table.
function warptorio.remote.get_event(n) return events.vdefs[n] end -- call (warptorio_event_name_string), returns a specific event.



---------------------------------------------------------------------
--[[ New Surfaces/Platform Interface ]]--
warptorio.remote.GetMainSurface=warptorio.GetMainSurface -- call (), returns LuaSurface,
warptorio.remote.GetMainPlanet=warptorio.GetMainPlanet -- call (), returns planet_table. Same as doing remote.call("planetorio","GetPlanetBySurface",remote.call("warptorio","GetMainSurface"))
warptorio.remote.GetHomeSurface=warptorio.GetHomeSurface -- call (), returns LuaSurface,
warptorio.remote.GetHomePlanet=warptorio.GetHomePlanet -- call (), returns planet_table. Same as doing remote.call("planetorio","GetPlanetBySurface",remote.call("warptorio","GetHomeSurface"))
warptorio.remote.GetSurfaces=warptorio.GetAllSurfaces -- call (), returns {table_of_warptorio_surfaces}. This does not include surfaces that are marked for destroy, such as player being left behind on warp.
warptorio.remote.GetSurface=function(key) return (global.floor[key] and global.floor[key].host or nil) end
warptorio.remote.GetFloor=function(key) return global.floor[key] end
warptorio.remote.GetFloors=function() return global.floor end
warptorio.remote.GetNamedSurfaces=warptorio.GetNamedSurfaces -- call ({table_of_floor_names, e.g. "home","main","factory"}), returns {[name]=surface,...}. Used to get surfaces in bulk.

warptorio.remote.RecallTeleporterGate=function() local t=global.Teleporters.offworld if(t and isvalid(t.b))then t:DestroyLogsB() t:DestroyB() end end -- call(). Used to destroy the teleporter gate.
warptorio.remote.RecallHarvester=function(side,bply) if(global.Harvesters[side])then global.Harvesters[side]:Recall(bply) end end -- call(string_side,bool_recallplayers). side must be "east" or "west". future values may include "nw","ne","sw","se" if i ever add those.

---------------------------------------------------------------------

--[[ Warptorio Remote Interface - Mod Managed Tables ]]--
--[[
For dealing with blacklists and stuff, so if your mod is uninstalled i can remove it from the global table.

old stuff first:
warptorio.remote.insert_warp_blacklist=warptorio.cmdinsertcloneblacklist -- call (mod_name,prototype_name), returns nil. Stops warptorio from cloning a specific prototype name when warping.
warptorio.remote.remove_warp_blacklist=warptorio.cmdremovecloneblacklist -- call (mod_name,prototype_name), returns nil. Stops warptorio from cloning a specific prototype name when warping.
warptorio.remote.is_warp_blacklisted=warptorio.cmdiscloneblacklisted -- call (mod_name,prototype_name), returns nil. Stops warptorio from cloning a specific prototype name when warping.
warptorio.remote.GetWarpBlacklist=warptorio.GetWarpBlacklist -- call (), returns: {warptorio_warp_blacklist}. Returns the full table of all blacklisted entities.


function warptorio.cmdinsertcloneblacklist(mn,e) if(not global.warp_blacklist[mn])then global.warp_blacklist[mn]={} end table.insertExclusive(global.warp_blacklist[mn],e) end
function warptorio.cmdremovecloneblacklist(mn,e) if(not global.warp_blacklist[mn])then global.warp_blacklist[mn]={} end table.RemoveByValue(global.warp_blacklist[mn],e) end
function warptorio.cmdiscloneblacklisted(mn,e) if(not global.warp_blacklist[mn])then return false end return table.HasValue(global.warp_blacklist[mn],e) end
]]


function warptorio.ValidateRemoteTable(x) local mt=global.modtbl if(not mt[x])then mt[x]={} end
	for k,v in pairs(mt[x])do if(not game.active_mods[k])then mt[x][k]=nil end end
end
function warptorio.InsertModTable(x,y,z) if(y=="warptorio2")then return end local mt=global.modtbl if(not mt[x])then return false end mt[x][y]=mt[x][y] or {}
	return table.insertExclusive(mt[x][y],z)
end
function warptorio.RemoveModTable(x,y,z) if(y=="warptorio2")then return end local mt=global.modtbl if(not mt[x])then return false end mt[x][y]=mt[x][y] or {}
	return table.RemoveByValue(mt[x][y],z)
end

warptorio.ModTables={}
function warptorio.GetModTable(x)
	if(warptorio.ModTables[x])then return warptorio.ModTables[x] end
	local mt=global.modtbl if(not mt[x])then return true end
	local t={} for k,v in pairs(mt[x])do for y,z in pairs(v)do table.insertExclusive(t,z) end end
	warptorio.ModTables[x]=t
	return t
end

events.on_config(function()
	global.modtbl=global.modtbl or {}
	warptorio.ValidateRemoteTable("harvester_blacklist") -- prevents certain entities from being affected by harvester deploy/recall cloning.
	warptorio.ValidateRemoteTable("warp_blacklist") -- prevents certain entities from being affected by the big Warpout function / cloning.
end)


warptorio.remote.InsertModTable=warptorio.InsertModTable -- call ("table_name", "mod_name", (ANY) Value). Used to interface with numerous mod related tables. Returns false if bad table, true if the value already exists, and int on success
warptorio.remote.RemoveModTable=warptorio.RemoveModTable -- call ("table_name", "mod_name", (ANY) Value). Returns false/int depending on success

---------------------------------------------------------------------
--[[ Cheats ]]--

warptorio.remote.ResearchNauvis=function() for k,v in pairs(game.forces.player.technologies)do if(not v.name:match("warptorio"))then v.researched=true end end end
warptorio.remote.ResearchCheat=function() for k,v in pairs(game.forces.player.research_queue)do v.researched=true end end
warptorio.remote.cheat=function() for i,p in pairs(game.players)do for k,v in pairs(lootItems)do p.get_main_inventory().insert{name=k,count=v} end end end -- call (), returns: Nil. Gives all players all the items in the lootchest table. Useful for testing.
warptorio.remote.reveal=function(n) n=n or 10 local f=global.floor.main.host game.forces.player.chart(f,{lefttop={x=-64-128*n,y=-64-128*n},rightbottom={x=64+128*n,y=64+128*n}}) end -- call (reveal_scale), returns: nil. Cheat command to reveal the map


---------------------------------------------------------------------
--[[ Warptorio Loot Chest stuff ]]--
warptorio.remote.SpawnLootChest=warptorio.SpawnLootChest -- call (surface,position_table,varg_table={min=1,max=5,dist=dist_from_0_0,stack=stack_size_min_fraction}). returns entity. Creates and fills a loot chest on given surface at given position. varg is used to tweak potential stack sizes and number of items.
warptorio.remote.GetPossibleLoot=warptorio.GetPossibleLoot -- returns a table of potential items from the loot table, filtered by is-craftable.
warptorio.remote.LootTable=warptorio.LootTable -- call (min,max,dist,stack), returns {[item_name]=#count}. Used to get a rolled table of loot items. See varg_table on SpawnLootChest.

---------------------------------------------------------------------
--[[ Needs review, CallDerma is deprecated ]]--
warptorio.remote.ResetGui=warptorio.ResetGui -- call (*optional LuaPlayer), returns nil, used to re-construct a player's, or all player's gui HUD. Used when unlocking research and fixing gui issues.
warptorio.remote.CallDerma=warptorio.CallDerma -- call (derma_name, *event_table), returns nil, specifically added for remotes. Used to refresh a specific internal gui control.

---------------------------------------------------------------------
--[[ Generic/backend stuff exposed for no good reason, if you actually need these let me know ]]--
warptorio.remote.GetChest=warptorio.GetChest -- call ("input" or "output"), returns "chest-prototype-name" depending on level and settings value: loaderchest_provider / loaderchest_requester based on variable.
warptorio.remote.GetBelt=warptorio.GetBelt -- call (), returns loader type based on current logistics level

warptorio.remote.PlanetEntityIsPlatform=warptorio.PlanetEntityIsPlatform -- call (entity), returns true if the entity is a warptorio entity (aka special chest or loader used by stairs or the rails). Used specifically to check for ents on the planet
warptorio.remote.EntityIsPlatform=warptorio.EntityIsPlatform -- call (entity), returns true. Same as PlanetEntityIsPlatform, except checks all teleporters on all surfaces and stuff.
warptorio.remote.BlueprintEntityIsBlacklisted=warptorio.BlueprintEntityIsBlacklisted -- call (entity), returns true/false whether the entity should not be added to blueprints. Currently identical to remote.call("warptorio","EntityIsPlatform",entity), but is not an alias.

warptorio.remote.ResetPlatform=function() warptorio.BuildB1() warptorio.BuildB2() for k,v in pairs(global.Teleporters)do v:Warpin() end end -- Rebuild the platform??


---------------------------------------------------------------------
--[[ Warping related stuff ]]--

warptorio.remote.GetWarpzone=function() return global.warpzone end -- Returns the current warpzone
warptorio.remote.IsAutowarpEnabled=warptorio.IsAutowarpEnabled -- call (), returns: boolean_IsAutowarpEnabled. Does exactly what it says on the tin. If true, the autowarp timer is running.
warptorio.remote.Warpout=warptorio.Warpout -- call (*optional planet_name), returns: nil. The big warp function. Increments the warpzone and other stuff.
warptorio.remote.warp=warptorio.Warpout -- alias

warptorio.remote.StartWarp=warptorio.StartWarp -- call() Forcibly start the warping countdown
warptorio.remote.StopWarp=warptorio.StopWarp -- call() Forcibly stop the warping countdown
warptorio.remote.IsWarping=warptorio.IsWarping -- call(), returns bool_IsWarping.

function warptorio.remote.GetWarpTime() return (global.warp_charging>0 and global.warp_time_left/60 or global.warp_charge_time) end
function warptorio.remote.SetWarpTime(n) global.warp_charge_time=n end

--[[ todo?
function warptorio.remote.GetAutowarpTimeLeft() end
function warptorio.remote.SetAutowarpTimeLeft(n) end
]]

---------------------------------------------------------------------
--[[ Backwards Compatability - DEPRECATED
function warptorio.cmdgetwarpevent() if(not warptorio.warpevent_name)then warptorio.warpevent_name = script.generate_event_name() end return warptorio.warpevent_name end
function warptorio.cmdgetpostwarpevent() if(not warptorio.warpevent_post_name)then warptorio.warpevent_post_name = script.generate_event_name() end return warptorio.warpevent_post_name end
function warptorio.cmdgettickevent() return warptorio.custom_events.ticktime end
function warptorio.cmdevent_harvester_deploy() return warptorio.custom_events.harvester_deploy end
function warptorio.cmdevent_harvester_recall() return warptorio.custom_events.harvester_recall end
function warptorio.cmdevent_warp_started() return warptorio.custom_events.warp_started end
function warptorio.cmdevent_warp_countdown() return warptorio.custom_events.warp_countdown end
function warptorio.cmdevent_autowarp_countdown() return warptorio.custom_events.autowarp_countdown end
function warptorio.cmdevent_ability_used() return warptorio.custom_events.ability_used end
function warptorio.cmdevent_autowarp_countdown() return warptorio.custom_events.autowarp_countdown end
warptorio.remote.event_ticktime=warptorio.cmdgettickevent
warptorio.remote.event_harvester_deploy=warptorio.cmdevent_harvester_deploy
warptorio.remote.event_harvester_recall=warptorio.cmdevent_harvester_recall
warptorio.remote.event_warp=warptorio.cmdgetwarpevent
warptorio.remote.event_post_warp=warptorio.cmdgetpostwarpevent
warptorio.remote.event_warp_started=warptorio.cmdevent_warp_started
warptorio.remote.warpevent=warptorio.cmdgetwarpevent
warptorio.remote.postwarpevent=warptorio.cmdgetpostwarpevent
-_- ]]--
