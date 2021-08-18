--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_control_cache.lua
Purpose: cache stuff with events

-----

Copyright (c) 2019 Pyro-Fire

I put a lot of work into these library files. Please retain the above text and this copyright disclaimer message in derivatives/forks.

Permission to use, copy, modify, and/or distribute this software for any
purpose without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

------

Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.

]]---------------------------------------


--[[ Simple Cache & Events Manager ]]--
--[[ Usage
cache.ent("assembling-machine-1",{built=function(ent) dostuff() end})
cache.type("assembling-machine",{built=function(ent_with_type) dostuff() end})

Also has global table manager for arbitrary data on stuff.
Create/destroy manually though, still easier than writing a new handler every time.

cache.vgui("hud_frame",{ click=function(elm,ev)
	local menu=cache.get_menu("hud",ev.player_index)
	cache.call_menu("clickyframe",menu,ev,...)
	..etc
end })

cache.menu("menu_name",{ create=function(menu,...) menu.frame=etc() end, destroy=function(menu,ev,...) forceclose() end, closed=function(menu,ev,...) onclosed() end })
local menu=cache.raise_menu("hud",ply)
menu.frame=ply.gui.add("hud_frame",...)
...
local menu=cache.get_menu("menu_name",ply)
cache.call_menu("func_name",menu,data,...)
...
...
cache.destroy_menu(menu) -- force close menu


local vtbl=cache.raise_entity(entity)
...
cache.destroy_entity(vtbl)
-- etc etc


]]--

local cache={}


-- cache classes
cache.surfaces={}
cache.spatterns={}
cache.ents={}
cache.types={}
cache.patterns={}
cache.vguis={}
cache.gtypes={}
cache.gpatterns={}
cache.players={}
cache.forces={}
cache.fpatterns={}
cache.units={}
cache.utypes={}
cache.menus={}

-- translate named function tables
cache.primaries={
	ent="ents",type="types",pattern="patterns",
	vgui="vguis",gpattern="gpatterns",gtype="gtype",
	menu="menus",
	player="players",force="forces",
	surface="surfaces",spattern="spatterns",
	unit="units",utype="utypes",
}
-- grouped class types for event filters
cache.classes={
	ents={name="ents",type="types",ptrn="patterns"},
	vgui={name="vguis",type="gtypes",ptrn="gpatterns"},
	menus={name="menus"},
	players={single="players"},
	forces={name="forces",ptrn="fpatterns"},
	surfaces={name="surfaces",spattern="spatterns"},
}

for k,v in pairs(cache.primaries)do if(k~="player")then cache[k]=function(name,tbl) cache[v][name]=tbl end end end
function cache.player(tbl) cache.players=tbl end


cache.events={} -- Functions to distribute individual events among the caches in correct orders

function cache.init()
	global._lib=global._lib or {}
	cache.migrate()
end

function cache.migrate(ev)
	if(global._libcache)then global._lib={cache=global._libcache} global._libcache=nil else global._lib=global._lib or {cache={}} end -- global._lib.cache
	global._lib.cache=global._lib.cache or {}
	for key,category in pairs(cache.primaries)do -- global._lib[raised_type]
		global._lib[category]=global._lib[category] or {}
		global._lib[category.."_idx"]=global._lib[category.."_idx"] or {}
	end
end


function cache.load()
end

 -- helper functions for simple caching
function cache.insert(n,ent) global._lib.cache[n]=global._lib.cache[n] or {} table.insertExclusive(global._lib.cache[n],ent) end
function cache.validate(n) global._lib.cache[n]=global._lib.cache[n] or {} for k,v in pairs(global._lib.cache[n])do if(not isvalid(v))then global._lib.cache[n][k]=nil end end end
function cache.remove(n,ent) global._lib.cache[n]=global._lib.cache[n] or {} table.RemoveByValue(global._lib.cache[n],ent) end
function cache.get(n) if(isstring(n))then return global._lib.cache[n] or {} end  end
--function cache.call(n,evn,ev,...) for k,v in pairs(cache.get(n))do ev.entity=v cache.call_ents(evn,ev,...) end end -- Call a simple event on all entities in a cache table.
function cache.entcall(n,evn,ev,...) for k,v in pairs(cache.get(n))do ev.entity=v cache.call_ents(evn,ev,...) end end -- Call a simple event on all entities in a cache table.
function cache.surfacecall(n,evn,ev,...) for k,v in pairs(cache.get(n))do ev.entity=v cache.call_surfaces(evn,ev,...) end end -- Call a simple event on all entities in a cache table.




function cache.call_ents(vn,ev,...) local ent=events.entity(ev) if(not isvalid(ent))then return end
	local tx=cache.types[ent.type=="ghost" and ent.ghost_type or ent.type] if(tx and tx[vn])then tx[vn](ent,ev,...) end if(not isvalid(ent))then return end
	local tx=cache.ents[ent.type=="ghost" and ent.ghost_name or ent.name] if(tx and tx[vn])then tx[vn](ent,ev,...) end if(not isvalid(ent))then return end
	local tx for k,v in pairs(cache.patterns)do if((ent.type=="ghost" and ent.ghost_name or ent.name):find(k,1,true))then tx=v break end end if(tx and tx[vn])then tx[vn](ent,ev,...) end
end
function cache.call_vgui(vn,ev,...) local elm=ev.element if(not isvalid(elm))then return end
	local tx=cache.vguis[elm.name] if(tx and tx[vn])then tx[vn](ev.element,ev,...) end
	local tx=cache.gtypes[elm.type] if(tx and tx[vn])then tx[vn](ev.element,ev,...) end
	local tx for k,v in pairs(cache.gpatterns)do if(elm.name:find(k,1,true))then tx=v break end end if(tx and tx[vn])then tx[vn](ev.element,ev,...) end
end
function cache.call_player(vn,ev,...) local tx=cache.players[vn] if(not tx)then return end
	if(tx)then tx(game.players[ev.player_index],ev,...) end
end
function cache.call_force(vn,ev,...) local f=ev.force if(not f)then f=game.forces[ev.force_index] end if(not f)then f=game.forces[ev.force_name] end if(not isvalid(f))then return end
	local tx=cache.forces[f.name] if(tx and tx[vn])then tx[vn](f,ev,...) end
	local tx for k,v in pairs(cache.fpatterns)do if(f.name:find(k,1,true))then tx=v break end end if(tx and tx[vn])then tx[vn](f,ev,...) end
end

function cache.call_surface(vn,ev,...) local f=ev.surface if(not f)then f=game.surfaces[ev.surface_index] end if(not isvalid(f))then return end
	local tx=cache.surfaces[f.name] if(tx and tx[vn])then tx[vn](f,ev,...) end
	local tx for k,v in pairs(cache.spatterns)do if(f.name:find(k,1,true))then tx=v break end end if(tx and tx[vn])then tx[vn](f,ev,...) end
end
function cache.call_menu(vn,menu,ev,...)
	local tx=cache.menus[menu.name] if(tx and tx[vn])then tx[vn](menu,ev,...) end
end

function cache.get_index(host,key) return host[key] end

-- Raise/destroy stuff to cache into global table. It gives us an internally managed cache table to shove data into e.g. creation/destruction of the base object.
function cache.raise_type(vtype,name,host,...)
	local uid if(isnumber(host))then uid=host else local cx cx,uid=pcall(cache.get_index,host,"index") if(not cx)then cx,uid=pcall(cache.get_index,host,"unit_number") if(not cx)then uid=nil end end end
	local hdx=uid
	if(hdx)then local gc=global._lib[vtype.."_idx"][hdx] if(gc and name)then gc=gc[name] end if(gc)then return gc end end -- get existing hosted/index vtype
	local c=cache[vtype] -- cache["ents"][name]. You can call these manually if you need to for ptrn, surfaces etc.
	if(not c)then return end if(name)then c=c[name] if(not c)then return end end -- only menus and vguis typically use names.
	local idx=#global._lib[vtype]+1
	local t={index=idx,name=name,type=vtype,host=host,hostindex=hdx} global._lib[vtype][idx]=t
	if(hdx)then
		if(name)then local gc=global._lib[vtype.."_idx"][hdx] or {} global._lib[vtype.."_idx"][hdx]=gc gc[t.name]=t
		else global._lib[vtype.."_idx"][hdx]=t
		end
	end
	if(c.raise)then c.raise(t,...) end
	if(vtype=="ents")then if(c[host.name] and c[host.name].raise)then c[host.name].raise(t,...) end end
	if(vtype=="types")then local htype=(host.is_player() and "player" or host.type) if(c[htype] and c[htype].raise)then c[htype].raise(t,...) end end

	return t
end
function cache.destroy_type(obj,...) local vtype=obj.type
	local c=cache[vtype] if(not c)then return end if(obj.name)then c=c[obj.name] if(not c)then return end end
	if(c.unraise)then c.unraise(obj,...) end
	global._lib[vtype][obj.index]=nil
	if(obj.hostindex)then global._lib[vtype.."_idx"][obj.hostindex]=nil end
end
function cache.get_type(vtype,name,host) local t=global._lib[vtype.."_idx"]
	if(t)then
		local uid if(isnumber(host))then uid=host else local cx cx,uid=pcall(cache.get_index,host,"index") if(not cx)then cx,uid=pcall(cache.get_index,host,"unit_number") if(not cx)then uid=nil end end end
		if(uid)then t=t[uid] else t=nil end
	end
	if(t and name)then t=t[name] end
	return t
end
function cache.get_raise_type(vtype,name,host,...) return cache.get_type(vtype,name,host) or cache.raise_type(vtype,name,host,...) end
function cache.get_types(vtype) local t=global._lib[vtype] return t end

function cache.destroy(obj,...) return cache.destroy_type(obj,...) end -- This just destroys the cache object, not the actual in-game object.


function cache.raise_menu(name,ply,...) return cache.raise_type("menus",name,ply,...) end
function cache.force_menu(name,ply,...) return cache.get_raise_type("menus",name,ply,...) end
function cache.get_menu(name,ply) return cache.get_type("menus",name,ply) end
cache.destroy_menu=cache.destroy

function cache.raise_vgui(name,menu,...) return cache.raise_type("vguis",name,menu,...) end
function cache.force_vgui(name,menu,...) return cache.get_raise_type("vguis",name,menu,...) end
function cache.get_vgui(name,menu) return cache.get_type("vguis",name,menu) end
cache.destroy_vgui=cache.destroy

function cache.raise_player(ply,...) return cache.raise_type("players",nil,ply,...) end
function cache.force_player(ply,...) return cache.get_raise_type("players",nil,ply,...) end
function cache.get_player(ply) return cache.get_type("players",nil,ply) end
cache.destroy_player=cache.destroy

function cache.raise_force(force,...) return cache.raise_type("forces",nil,force,...) end
function cache.force_force(force,...) return cache.get_raise_type("forces",nil,force,...) end
function cache.get_force(force) return cache.get_type("forces",nil,force) end
cache.destroy_force=cache.destroy

function cache.raise_surface(surface,...) return cache.raise_type("surfaces",nil,surface,...) end
function cache.force_surface(surface,...) return cache.get_raise_type("surfaces",nil,surface,...) end
function cache.get_surface(surface) return cache.get_type("surfaces",nil,surface) end
cache.destroy_surface=cache.destroy

function cache.raise_unit(unit,...) return cache.raise_type("units",nil,unit,...) end
function cache.force_unit(unit,...) return cache.get_raise_type("units",nil,unit,...) end
function cache.get_unit(unit) return cache.get_type("units",nil,unit) end
cache.destroy_unit=cache.destroy

function cache.raise_entity(ent,...) return cache.raise_type("ents",nil,ent,...) end
function cache.force_entity(ent,...) return cache.get_raise_type("ents",nil,ent,...) end
function cache.get_entity(ent) return cache.get_type("ents",nil,ent) end
cache.destroy_entity=cache.destroy



function cache.update(ent,vn,...) vn=vn or "update"
	local tx=cache.types[ent.type] if(tx and tx[vn])then tx[vn](ent,...) end
	local tx=cache.ents[ent.name] if(tx and tx[vn])then tx[vn](ent,...) end
	local tx for k,v in pairs(cache.patterns)do if(ent.name:find(k,1,true))then tx=v break end end if(tx and tx[vn])then tx[vn](ent,...) end
end
function cache.updategui(elm,...) local vn="update" if(not isstring(elm))then elm=elm.name end
	local tx=cache.vguis[elm.name] if(tx and tx[vn])then tx[vn](elm,...) end
	local tx=cache.gtypes[elm.name] if(tx and tx[vn])then tx[vn](elm,...) end
	local tx for k,v in pairs(cache.gpatterns)do if(elm.name:find(k,1,true))then tx=v break end end if(tx and tx[vn])then tx[vn](elm,...) end
end
function cache.updatemenu(mn,vn,ev,...) for i,ply in pairs(game.players)do
	local menu=cache.get_menu(mn,ply) if(menu)then
		cache.call_menu(vn,menu,ev,...)
	end
end end



function cache.inject_type(nm,evdata)
	local funcs=cache.events[nm]
	local defs=cache.events[nm.."_defs"]
	local ccls=cache.classes[nm]


	local ptrn=false
	for evtype,vdefs in pairs(defs)do
		if(ccls.name)then for tpnm,cls in pairs(cache[ccls.name])do if(cls[evtype])then
			for _,def in pairs(vdefs)do evdata[def]=evdata[def] or {} table.insert(evdata[def],{nm=nm,tpnm=tpnm,evtype=evtype,ghost=cls.ghost,clsname=ccls.name,func=funcs[def]}) end
		end end end
		if(ccls.type)then for tpnm,cls in pairs(cache[ccls.type])do if(cls[evtype])then
			for _,def in pairs(vdefs)do evdata[def]=evdata[def] or {} table.insert(evdata[def],{nm=nm,tpnm=tpnm,evtype=evtype,ghost=cls.ghost,clstype=ccls.type,func=funcs[def]}) end
		end end end
		if(ccls.ptrn)then for tpnm,cls in pairs(cache[ccls.ptrn])do if(cls[evtype])then ptrn=true
			for _,def in pairs(vdefs)do evdata[def]=evdata[def] or {} table.insert(evdata[def],{nm=nm,tpnm=tpnm,evtype=evtype,ghost=cls.ghost,clsptrn=ccls.ptrn,func=funcs[def]}) end
		end end end
		if(ccls.single)then local cls=cache[ccls.single] if(cls[evtype])then
			for _,def in pairs(vdefs)do evdata[def]=evdata[def] or {} table.insert(evdata[def],{nm=nm,tpnm=tpnm,evtype=evtype,ghost=cls.ghost,clssingle=ccls.single,func=funcs[def]}) end
		end end
	end
	--if(nm=="players")then error(serpent.block(evdata)) end
end


function cache.inject() -- interface with events
	local evdata={} for nm in pairs(cache.classes)do cache.inject_type(nm,evdata) end
	--error(serpent.block(evdata))
	for def,tbl in pairs(evdata)do
		local filters={}
		local nmf,tpf,ptf,sgf
		--if(events.events_with_filters[def])then
			for i,vtbl in pairs(tbl)do
				if(vtbl.clsptrn)then ptf=vtbl.func filters=nil
				elseif(vtbl.clstype)then tpf=vtbl.func
					if(filters)then table.insert(filters,{filter="type",type=vtbl.tpnm})
						if(vtbl.ghost)then table.insert(filters,{filter="ghost_type",type=vtbl.tpnm}) end
					end
				elseif(vtbl.clsname)then nmf=vtbl.func
					if(filters)then table.insert(filters,{filter="name",name=vtbl.tpnm})
						if(vtbl.ghost)then table.insert(filters,{filter="ghost_name",name=vtbl.tpnm}) end
					end
				elseif(vtbl.clssingle)then sgf=vtbl.func filters=nil
				end
			end
		--end
		if(not events.events_with_filters[def])then filters=nil end

		if(nmf)then events.hook(defines.events[def],nmf,filters) end
		if(tpf)then events.hook(defines.events[def],tpf,filters) end
		if(ptf)then events.hook(defines.events[def],ptf,filters) end
		if(sgf)then events.hook(defines.events[def],sgf,filters) end
	end
end

--[[ Unknowns
on_put_item
on_ai_command_completed

on_difficulty_settings_changed
on_cutscene_waypout_reached

on_console_command
on_console_chat

on_chart_tag_added
on_chart_tag_modified
on_chart_tag_removed -- force events

on_game_created_from_scenario

on_robot_built_entity
on_robot_built_tile
on_robot_exploded_cliff
on_robot_mined
on_robot_mined_entity
on_robot_mined_tile
on_robot_pre_mined
on_rocket_launch_ordered
on_rocket_launched
on_runtime_mod_setting_changed
on_script_path_request_finished -- pathfinding
on_sector_scanned -- radar
on_string_translated

on_train_changed_state
on_train_created
on_train_schedule_changed

on_trigger_fired_artillery

on_unit_added_to_group
on_unit_group_created
on_unit_removed_from_group
on_biter_base_built


on_market_item_purchased


]]


cache.events.forces={}
function cache.events.forces.on_research_finished(ev) cache.call_force("research_finished",ev) end
function cache.events.forces.on_research_started(ev) cache.call_force("research_started",ev) end
function cache.events.forces.on_technology_effects_reset(ev) cache.call_force("research_reset",ev) end
function cache.events.forces.on_chart_tag_added(ev) cache.call_force("tag_added",ev) end
function cache.events.forces.on_chart_tag_modified(ev) cache.call_force("tag_modified",ev) end
function cache.events.forces.on_chart_tag_removed(ev) cache.call_force("tag_removed",ev) end

cache.events.forces_defs={ -- Things that specifically are called with a force. Player stuff can be hooked from players.
	research_finished={"on_research_finished"},
	research_started={"on_research_started"},
	research_reset={"on_technology_effects_reset"},
}

cache.events.ents={}
function cache.events.ents.on_built_entity(ev) cache.call_ents("built",ev) cache.call_ents("create",ev) end
function cache.events.ents.script_raised_built(ev) cache.call_ents("create",ev) end
function cache.events.ents.on_entity_cloned(ev) cache.call_ents("clone",ev) cache.call_ents("create",ev) end
function cache.events.ents.on_robot_built_entity(ev) cache.call_ents("built",ev) cache.call_ents("create",ev) end
function cache.events.ents.script_raised_destroy(ev) cache.call_ents("destroy",ev) end
function cache.events.ents.on_entity_died(ev) cache.call_ents("died",ev) cache.call_ents("destroy",ev) end
function cache.events.ents.on_post_entity_died(ev) cache.call_ents("post_died",ev) end
function cache.events.ents.on_player_mined_entity(ev) cache.call_ents("mined",ev) cache.call_ents("destroy",ev) end
function cache.events.ents.on_robot_mined_entity(ev) cache.call_ents("mined",ev) cache.call_ents("destroy",ev) end
function cache.events.ents.on_player_rotated_entity(ev) cache.call_ents("rotate",ev) end
function cache.events.ents.on_entity_settings_pasted(ev) cache.call_ents("settings_pasted",ev) end
function cache.events.ents.on_pre_entity_settings_pasted(ev) cache.call_ents("pre_settings_pasted",ev) end
function cache.events.ents.on_cancelled_deconstruction(ev) cache.call_ents("cancel_deconstruct",ev) end
function cache.events.ents.on_cancelled_upgrade(ev) cache.call_ents("cancel_upgrade",ev) end
function cache.events.ents.on_marked_for_deconstruction(ev) cache.call_ents("deconstruct",ev) end
function cache.events.ents.on_marked_for_upgrade(ev) cache.call_ents("upgrade",ev) end
function cache.events.ents.on_pre_ghost_deconstructed(ev) cache.call_ents("deconstruct_ghost",ev) end
function cache.events.ents.on_post_entity_died(ev) cache.call_ents("post_died",ev) end
function cache.events.ents.on_mod_item_opened(ev) cache.call_ents("item_menu",ev) end
function cache.events.ents.on_entity_damaged(ev) cache.call_ents("damage",ev) end
function cache.events.ents.on_trigger_created_entity(ev) cache.call_ents("trigger",ev) end
function cache.events.ents.on_entity_spawned(ev) cache.call_ents("spawned",ev) end
function cache.events.ents.on_land_mine_armed(ev) cache.call_ents("mine_armed",ev) end
function cache.events.ents.on_gui_opened(ev) cache.call_ents("gui_opened",ev) end
function cache.events.ents.on_gui_closed(ev) cache.call_ents("gui_closed",ev) end
function cache.events.ents.on_pre_robot_exploded_cliff(ev) cache.call_ents("pre_robot_exploded_cliff",ev) end
function cache.events.ents.on_post_entity_died(ev) cache.call_ents("post_died",ev) end
function cache.events.ents.on_combat_robot_expired(ev) cache.call_ents("robot_expired",ev) end
function cache.events.ents.script_raised_revive(ev) cache.call_ents("create",ev) end
function cache.events.ents.on_entity_renamed(ev) cache.call_ents("rename",ev) end

cache.events.ents_defs={
	built={"on_built_entity","on_robot_built_entity"},
	create={"on_built_entity","script_raised_built","on_entity_cloned","on_robot_built_entity","script_raised_revive"},
	mined={"on_player_mined_entity","on_robot_mined_entity"},
	rotate={"on_player_rotated_entity"},
	rename={"on_entity_renamed"},
	destroy={"on_player_mined_entity","on_robot_mined_entity","script_raised_destroy","on_entity_died"},

	died={"on_entity_died"},
	post_died={"on_post_entity_died"},

	settings_pasted={"on_entity_settings_pasted"},
	pre_settings_pasted={"on_pre_entity_settings_pasted"},
	cancel_deconstruct={"on_cancelled_deconstruction"},
	cancel_upgrade={"on_cancelled_upgrade"},
	deconstruct={"on_marked_for_deconstruction"},
	deconstruct_ghost={"on_pre_ghost_deconstructed"},

	upgrade={"on_marked_for_upgrade"},

	gui_opened={"on_gui_opened"},
	gui_closed={"on_gui_closed"},

	item_menu={"on_mod_item_opened"}, --Called when the player uses the 'Open item GUI' control on an item defined with 'can_be_mod_opened' as true
	damage={"on_entity_damaged"},
	trigger={"on_trigger_created_entity"},
	robot_expired={"on_combat_robot_expired"},

	spawned={"on_entity_spawned"},
	mine_armed={"on_land_mine_armed"},

	pre_robot_exploded_cliff={"on_pre_robot_exploded_cliff"},
	post_died={"on_post_entity_died"},
}


cache.events.vgui={}
function cache.events.vgui.on_gui_opened(ev) cache.call_vgui("open_menu",ev) end
function cache.events.vgui.on_gui_closed(ev) cache.call_vgui("gui_closed",ev) cache.call_vgui("gui_closed",ev) end
function cache.events.vgui.on_gui_click(ev) cache.call_vgui("click",ev) end
function cache.events.vgui.on_gui_confirmed(ev) cache.call_vgui("confirm",ev) end
function cache.events.vgui.on_gui_text_changed(ev) cache.call_vgui("text_changed",ev) end
function cache.events.vgui.on_gui_selection_state_changed(ev) cache.call_vgui("selection_changed",ev) end
function cache.events.vgui.on_player_display_resolution_changed(ev) cache.call_vgui("on_resolution",ev) end
function cache.events.vgui.on_player_display_scale_changed(ev) cache.call_vgui("on_scale",ev) end
function cache.events.vgui.on_gui_checked_state_changed(ev) cache.call_vgui("on_checked",ev) end
function cache.events.vgui.on_gui_elem_changed(ev) cache.call_vgui("elem_changed",ev) end
function cache.events.vgui.on_gui_location_changed(ev) cache.call_vgui("location_changed",ev) end
function cache.events.vgui.on_gui_selected_tab_changed(ev) cache.call_vgui("tab_changed",ev) end
function cache.events.vgui.on_gui_switch_state_changed(ev) cache.call_vgui("on_switched",ev) end
function cache.events.vgui.on_gui_value_changed(ev) cache.call_vgui("value_changed",ev) end

cache.events.vgui_defs={
	click={"on_gui_click"},
	open_menu={"on_gui_opened"},
	gui_closed={"on_gui_closed"},
	confirm={"on_gui_confirmed"},
	text_changed={"on_gui_text_changed"},
	selection_changed={"on_gui_selection_state_changed"},
	on_resolution={"on_player_display_resolution_changed"},
	on_scale={"on_player_display_scale_changed"},
	on_checked={"on_gui_checked_state_changed"},
	elem_changed={"on_gui_elem_changed"},
	location_changed={"on_gui_location_changed"},
	tab_changed={"on_gui_selected_tab_changed"},
	on_switched={"on_gui_switch_state_changed"},
	value_changed={"on_gui_value_changed"},
}



cache.events.surfaces={}
function cache.events.surfaces.on_surface_created(ev) cache.call_surface("create",ev) end
function cache.events.surfaces.on_pre_surface_deleted(ev) cache.call_surface("pre_deleted",ev) end
function cache.events.surfaces.on_pre_surface_cleared(ev) cache.call_surface("pre_cleared",ev) end
function cache.events.surfaces.on_surface_deleted(ev) cache.call_surface("on_deleted",ev) end
function cache.events.surfaces.on_surface_imported(ev) cache.call_surface("import",ev) end
function cache.events.surfaces.on_surface_renamed(ev) cache.call_surface("rename",ev) end
function cache.events.surfaces.on_chunk_generated(ev) cache.call_surface("chunk",ev) end
function cache.events.surfaces.on_chunk_deleted(ev) cache.call_surface("chunk_deleted",ev) end
function cache.events.surfaces.on_pre_chunk_deleted(ev) cache.call_surface("pre_chunk_deleted",ev) end
function cache.events.surfaces.on_chunk_charted(ev) cache.call_surface("chart",ev) end

cache.events.surfaces_defs={
	create={"on_surface_created"},
	pre_deleted={"on_pre_surface_deleted"},
	pre_cleared={"on_pre_surface_cleared"},
	on_cleared={"on_surface_cleared"},
	on_deleted={"on_surface_deleted"},

	import={"on_surface_imported"},
	rename={"on_surface_renamed"},
	chunk={"on_chunk_generated"},
	chunk_deleted={"on_chunk_deleted"},
	pre_chunk_deleted={"on_pre_chunk_deleted"},

	chart={"on_chunk_charted"},
}

cache.events.players={}
function cache.events.players.on_player_toggled_alt_mode(ev) cache.call_player("on_alt",ev) end
function cache.events.players.on_player_toggled_map_editor(ev) cache.call_player("on_editor",ev) end
function cache.events.players.on_player_cheat_mode_enabled(ev) cache.call_player("on_cheat",ev) end
function cache.events.players.on_player_cheat_mode_disabled(ev) cache.call_player("on_uncheat",ev) end
function cache.events.players.on_player_driving_changed_state(ev) cache.call_player("on_driving",ev) end
function cache.events.players.on_pickup_item(ev) cache.call_player("on_pickup_item",ev) end
function cache.events.players.on_player_dropped_item(ev) cache.call_player("on_drop_item",ev) end
function cache.events.players.on_player_fast_transferred(ev) cache.call_player("on_fast_transfer",ev) end
function cache.events.players.on_player_gun_inventory_changed(ev) cache.call_player("on_gun_inv",ev) end
function cache.events.players.on_player_ammo_inventory_changed(ev) cache.call_player("on_ammo_changed",ev) end
function cache.events.players.on_player_armor_inventory_changed(ev) cache.call_player("on_armor_changed",ev) end
function cache.events.players.on_player_placed_equipment(ev) cache.call_player("on_equip",ev) end
function cache.events.players.on_player_removed_equipment(ev) cache.call_player("on_dequip",ev) end

function cache.events.players.on_built_tile(ev) cache.call_player("on_built_tile",ev) end
function cache.events.players.on_built_entity(ev) cache.call_player("on_built",ev) end
function cache.events.players.on_player_changed_position(ev) cache.call_player("on_position",ev) end
function cache.events.players.on_player_changed_surface(ev) cache.call_player("on_surface",ev) end
function cache.events.players.on_character_corpse_expired(ev) cache.call_player("on_corpse_expired",ev) end
function cache.events.players.on_lua_shortcut(ev) cache.call_player("on_shortcut",ev) end
function cache.events.players.on_player_alt_selected_area(ev) cache.call_player("on_alt_select_area",ev) end
function cache.events.players.on_player_deconstructed_area(ev) cache.call_player("on_deconstruct_area",ev) end
function cache.events.players.on_player_selected_area(ev) cache.call_player("on_select_area",ev) end
function cache.events.players.on_player_configured_blueprint(ev) cache.call_player("on_blueprint",ev) end
function cache.events.players.on_player_setup_blueprint(ev) cache.call_player("on_setup_blueprint",ev) end
function cache.events.players.on_selected_entity_changed(ev) cache.call_player("on_selected_entity_changed",ev) end
function cache.events.players.on_player_respawned(ev) cache.call_player("on_respawn",ev) end
function cache.events.players.on_player_created(ev) cache.call_player("on_create",ev) end
function cache.events.players.on_player_joined_game(ev) cache.call_player("on_join",ev) end
function cache.events.players.on_player_banned(ev) cache.call_player("on_banned",ev) end
function cache.events.players.on_player_left_game(ev) cache.call_player("on_left",ev) end
function cache.events.players.on_player_removed(ev) cache.call_player("on_removed",ev) end
function cache.events.players.on_pre_player_left_game(ev) cache.call_player("on_pre_left",ev) end
function cache.events.players.on_pre_player_removed(ev) cache.call_player("on_pre_removed",ev) end
function cache.events.players.on_player_unbanned(ev) cache.call_player("on_unban",ev) end
function cache.events.players.on_player_unmuted(ev) cache.call_player("on_unmute",ev) end
function cache.events.players.on_player_demoted(ev) cache.call_player("on_demoted",ev) end
function cache.events.players.on_player_died(ev) cache.call_player("on_died",ev) end
function cache.events.players.on_pre_player_died(ev) cache.call_player("on_pre_died",ev) end
function cache.events.players.on_player_muted(ev) cache.call_player("on_muted",ev) end
function cache.events.players.on_player_promoted(ev) cache.call_player("on_promoted",ev) end
function cache.events.players.on_player_main_inventory_changed(ev) cache.call_player("on_inventory",ev) end
function cache.events.players.on_player_mined_entity(ev) cache.call_player("on_mined",ev) end
function cache.events.players.on_pre_player_mined_item(ev) cache.call_player("on_pre_mined_item",ev) end
function cache.events.players.on_player_mined_item(ev) cache.call_player("on_mined_item",ev) end
function cache.events.players.on_player_mined_tile(ev) cache.call_player("on_mined_tile",ev) end
function cache.events.players.on_player_cursor_stack_changed(ev) cache.call_player("on_cursor",ev) end
function cache.events.players.on_player_pipette(ev) cache.call_player("on_pipette",ev) end
function cache.events.players.on_player_cancelled_crafting(ev) cache.call_player("on_cancel_craft",ev) end
function cache.events.players.on_pre_player_crafted_item(ev) cache.call_player("on_pre_craft",ev) end
function cache.events.players.on_player_crafted_item(ev) cache.call_player("on_craft",ev) end
function cache.events.players.on_player_repaired_entity(ev) cache.call_player("on_repair",ev) end
function cache.events.players.on_player_rotated_entity(ev) cache.call_player("on_rotate",ev) end
function cache.events.players.on_player_trash_inventory_changed(ev) cache.call_player("on_trash_changed",ev) end
function cache.events.players.on_player_used_capsule(ev) cache.call_player("on_capsule",ev) end


cache.events.players_defs={

	on_alt={"on_player_toggled_alt_mode"},
	on_editor={"on_player_toggled_map_editor"},

	on_cheat={"on_player_cheat_mode_enabled"},
	on_uncheat={"on_player_cheat_mode_disabled"},

	on_driving={"on_player_driving_changed_state"},

	on_pickup_item={"on_picked_up_item"},
	on_drop_item={"on_player_dropped_item"},

	on_fast_transfer={"on_player_fast_transferred"},
	on_gun_inv={"on_player_gun_inventory_changed"},
	on_ammo_changed={"on_player_ammo_inventory_changed"},
	on_armor_changed={"on_player_armor_inventory_changed"},
	on_equip={"on_player_placed_equipment"},
	on_dequip={"on_player_removed_equipment"},

	on_built_tile={"on_player_built_tile"},
	on_built={"on_entity_built"},

	on_position={"on_player_changed_position"},
	on_surface={"on_player_changed_surface"},

	on_corpse_expired={"on_character_corpse_expired"},

	on_shortcut={"on_lua_shortcut"},
	on_alt_select_area={"on_player_alt_selected_area"},
	on_deconstruct_area={"on_player_deconstructed_area"},
	on_select_area={"on_player_selected_area"},


	on_blueprint={"on_player_configured_blueprint"},
	on_setup_blueprint={"on_player_setup_blueprint"},

	on_select={"on_selected_entity_changed"},

	on_respawn={"on_player_respawned"},
	on_create={"on_player_created"},
	on_join={"on_player_joined_game"},

	on_banned={"on_player_banned"},
	on_left={"on_player_left_game"},
	on_removed={"on_player_removed"},
	on_pre_left={"on_pre_player_left_game"},
	on_pre_removed={"on_pre_player_removed"},

	on_unban={"on_player_unbanned"},
	on_unmute={"on_player_unmuted"},
	on_demote={"on_player_demoted"},

	on_died={"on_player_died"},
	on_pre_died={"on_pre_player_died"},

	on_muted={"on_player_muted"},
	on_promoted={"on_player_promoted"},

	on_inventory={"on_player_main_inventory_changed"},
	on_mined={"on_player_mined_entity"},
	on_pre_mined_item={"on_pre_player_mined_item"},
	on_mined_item={"on_player_mined_item"},
	on_mined_tile={"on_player_mined_tile"},

	on_cursor={"on_player_cursor_stack_changed"},
	on_pipette={"on_player_pipette"},

	on_cancel_craft={"on_player_cancelled_crafting"},
	on_pre_craft={"on_pre_player_crafted_item"},
	on_craft={"on_player_crafted_item"},

	on_repair={"on_player_repaired_entity"},
	on_rotate={"on_player_rotated_entity"},

	on_trash_changed={"on_player_trash_inventory_changed"},

	on_capsule={"on_player_used_capsule"},
	
}
cache.events.menus={}
cache.events.menus_defs={
}

return cache