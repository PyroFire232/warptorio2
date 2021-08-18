--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_control.lua
Purpose: control stuff

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

--[[ Settings Lib ? ]]--

function lib.setting(n) return lib.modname.."_"..settings.global[n].value end
function lib.call(r,...) if(istable(r))then return remote.call(r[1],r[2],...) end return r(...) end



--[[ Entity Library ]]--

function is_entity(x) return (x.valid~=nil) end


entity={}
function entity.protect(e,min,des) if(min~=nil)then e.minable=min end if(des~=nil)then e.destructible=des end return e end
function entity.spawn(f,n,pos,dir,t) t=t or {} local tx=t or {} tx.name=n tx.position={vector.getx(pos),vector.gety(pos)} tx.direction=dir tx.player=(t.player or game.players[1])
	tx.force=t.force or game.forces.player
	tx.raise_built=true --(t.raise_built~=nil and t.raise_built or true)
	local e=f.create_entity(tx) return e
end
entity.create=entity.spawn -- alias

function entity.destroy(e,r,c) if(e and e.valid)then e.destroy{raise_destroy=(r~=nil and r or true),do_cliff_correction=(c~=nil and c or true)} end end
function entity.ChestRequestMode(e) local cb=e.get_or_create_control_behavior() if(cb.type==defines.control_behavior.type.logistic_container)then
	cb.circuit_mode_of_operation=defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests end end
function entity.safeteleport(e,f,pos,bsnap) f=f or e.surface e.teleport(f.find_non_colliding_position(e.is_player() and "character" or e.name,pos or e.position,0,1,bsnap),f) end
function entity.shouldClean(v) return (v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio") end
function entity.tryclean(v) if(v.valid and entity.shouldClean(v))then entity.destroy(v) end end
function entity.emitsound(e,path) for k,v in pairs(game.connected_players)do if(v.surface==e.surface)then v.play_sound{path=path,position=e.position} end end end


--[[ Entity Cloning helpers ]]--

entity.copy={} entity.copy.__index=entity.copy setmetatable(entity.copy,entity.copy)
function entity.copy.__call(e) end
function entity.copy.chest(a,b) local c=b.get_inventory(defines.inventory.chest) for k,v in pairs(a.get_inventory(defines.inventory.chest).get_contents())do c.insert{name=k,count=v} end
	local net=a.circuit_connection_definitions
	for c,tbl in pairs(net)do b.connect_neighbour{target_entity=tbl.target_entity,wire=tbl.wire,source_circuit_id=tbl.source_circuit_id,target_circuit_id=tbl.target_circuit_id} end
end


-- --------
-- Logistics system


function entity.AutoBalancePower(t) -- Auto-balance electricity between all entities in a table
	local p=#t local g=0 local c=0
	for k,v in pairs(t)do if(v.valid)then g=g+v.energy c=c+v.electric_buffer_size end end
	for k,v in pairs(t)do if(v.valid)then local r=(v.electric_buffer_size/c) v.energy=g*r end end
end
function entity.BalancePowerPair(a,b) local x=(a.energy+b.energy)/2 a.energy,b.energy=x,x end


function entity.AutoBalanceHeat(t) -- Auto-balance heat between all entities in a table
	local h=0 for k,v in pairs(t)do h=h+v.temperature end for k,v in pairs(t)do v.temperature=h/#t end
end
function entity.BalanceHeatPair(a,b) local x=(a.temperature+b.temperature)/2 a.temperature,b.temperature=x,x end
function entity.ShiftHeat(a,b) end -- move temperature from a to b

function entity.ShiftContainer(a,b) -- Shift contents from a to b
	local ac,bc=a.get_inventory(defines.inventory.chest),b.get_inventory(defines.inventory.chest)
	for k,v in pairs(ac.get_contents())do local t={name=k,count=v} local c=bc.insert(t) if(c>0)then ac.remove({name=k,count=c}) end end
end

function entity.GetFluidTemperature(v) local fb=v.fluidbox if(fb and fb[1])then return fb[1].temperature end return 15 end

function entity.BalanceFluidPair(a,b)
	local af,bf=a.get_fluid_contents(),b.get_fluid_contents() local aff,afv=table.First(af) local bff,bfv=table.First(bf) afv=afv or 0 bfv=bfv or 0
	if((not aff and not bff) or (aff and bff and aff~=bff) or (afv<1 and bfv<1) or (afv==bfv))then return end if(not aff)then aff=bff elseif(not bff)then bff=aff end local v=(afv+bfv)/2
	if(aff=="steam")then local temp=15 local at=entity.GetFluidTemperature(a) local bt=entity.GetFluidTemperature(b) temp=math.max(at,bt)
		a.clear_fluid_inside() b.clear_fluid_inside() a.insert_fluid({name=aff,amount=v,temperature=temp}) b.insert_fluid({name=bff,amount=v,temperature=temp})
	else a.clear_fluid_inside() b.clear_fluid_inside() a.insert_fluid({name=aff,amount=v}) b.insert_fluid({name=bff,amount=v}) end
end


function entity.ShiftFluid(a,b)
	local af,bf=a.get_fluid_contents(),b.get_fluid_contents() local aff,afv=table.First(af) local bff,bfv=table.First(bf) -- this is apparently broken
	if((not aff and not bff) or (aff and bff and aff~=bff) or (afv<1 and bfv<1))then return end
	if(aff=="steam")then
		local temp=15 local at=entity.GetFluidTemperature(a) local bt=entity.GetFluidTemperature(b) temp=math.max(at,bt)
		local c=b.insert_fluid({name=aff,amount=afv,temperature=temp}) if(c>0)then a.remove_fluid{name=aff,amount=c} end
	elseif(aff)then
		local c=b.insert_fluid({name=aff,amount=afv}) if(c>0)then a.remove_fluid{name=aff,amount=c} end
	end
end

function entity.ShiftBelt(a,b) -- splitters could have up to 4 lines
	for i=1,2,1 do local bl=b.get_transport_line(i) if(bl.can_insert_at_back())then local al=a.get_transport_line(i)
		local k,v=next(al.get_contents()) if(k and v)then bl.insert_at_back{name=k,count=1} al.remove_item{name=k,count=1} end
	end end

end


--[[ unused
function entity.BalanceLogistics(a,b) if(not a or not b or not a.valid or not b.valid)then return end -- cost is removed because it's derp
	if(a.type=="accumulator" and b.type==a.type)then -- transfer energy
		warptorio.Logistics.BalanceEnergy(a,b)
	elseif((a.type=="container" or b.type=="logistic-container") and b.type==a.type)then -- transfer items
		warptorio.Logistics.MoveContainer(a,b)
	elseif(a.type=="pipe-to-ground" and b.type==a.type)then -- transfer fluids
		if(true)then warptorio.Logistics.BalanceFluid(a,b)
		else warptorio.Logistics.MoveFluid(a,b)
		end
	elseif(a.temperature and b.temperature)then
		warptorio.Logistics.BalanceHeat(a,b)
	elseif(a.type=="loader" and b.type==a.type)then
		warptorio.Logistics.MoveBelt(a,b)
	end
end
]]






--[[ Player Library ]]--

players={}
function players.find(f,area) local t={} for k,v in pairs(game.players)do if(v.surface==f and vector.inarea(v.position,area))then table.insert(t,v) end end return t end
function players.playsound(path,f,pos)
	if(f)then f.play_sound{path=path,position=pos} else game.forces.player.play_sound{path=path,position=pos} end
end
function players.safeclean(e,tpo) local f=e.surface local pos=tpo or e.position
	if(tpo or f.count_entities_filtered{area=vector.square(vector.pos(pos),vector(0.5,0.5))}>1)then entity.safeteleport(e,f,pos) end
end

--[[ todo



warptorio.teleDir={[0]={0,-1},[1]={1,-1},[2]={1,0},[3]={1,1},[4]={0,1},[5]={-1,1},[6]={-1,0},[7]={-1,-1}}
function warptorio.TeleportTick(nm,tpg,idx,ply)
	for i,e in pairs({tpg.a,tpg.b})do if(ply.surface==e.surface)then
		local o=(i==1 and tpg.b or tpg.a) local x=e.position local xxx=math.abs(x.x) local xxy=math.abs(x.y)
		if(vector.inarea(ply.position,vector.area(vector(x.x-1.5,x.y-1.5),vector(x.x+1.5,x.y+1.5)) ) )then
			local w=ply.walking_state
			local ox=o.position
			local mp=2 if(not ply.character)then mp=3 end
			if(not w.walking)then local cp=ply.position local xd,yd=(x.x-cp.x),(x.y-cp.y) entity.safeteleport(ply,o.surface,vector(ox.x+xd*mp,ox.y+yd*mp))
			else local td=warptorio.teleDir[w.direction] entity.safeteleport(ply,o.surface,vector(ox.x+td[1]*mp,ox.y+td[2]*mp)) end
			players.playsound("teleport",e.surface,e.position) players.playsound("teleport",o.surface,o.position)
		end
	end end
end
function warptorio.on_player_changed_position.Teleporters(ev)
	local ply=game.players[ev.player_index]
	if(not ply.driving)then
		for k,v in pairs(gwarptorio.Teleporters)do if(v:ValidA() and v:ValidB())then warptorio.TeleportTick(k,v,ev.player_index,ply) end end
		for k,v in pairs(gwarptorio.Harvesters)do if(v:ValidA() and v:ValidB())then warptorio.TeleportTick(k,v,ev.player_index,ply) end end
	end
end

]]




--[[ Technology Library ]]--


research={}
function research.get(n,f) f=f or game.forces.player return f.technologies[n] end
function research.has(n,f) return research.get(n,f).researched end
function research.can(n,f) local r=research.get(n,f) if(r.researched)then return true end local x=table_size(r.prerequisites) for k,v in pairs(r.prerequisites)do if(v.researched)then x=x-1 end end return (x==0) end
--function research.level(n,f) f=f or game.forces.player local ft=f.technologies local r=ft[n.."-0"] or ft[n.."-1"] local i=0 while(r)do if(r.researched)then i=r.level r=ft[n.."-".. i+1] else r=nil end end return i end
function research.level(n,f) f=f or game.forces.player local ft=f.technologies local i,r=0,ft[n.."-0"] or ft[n.."-1"]
	while(r)do if not r.researched then i=r.level-1 r=nil else i=r.level r=ft[n.."-".. i+1] end end
	return i
end -- Thanks Bilka!!

--[[ Surfaces Library ]]--
surfaces={}

function surfaces.BlankSurface(n)

end
function surfaces.spawnbiters(type,n,f) local tbl=game.surfaces[f].find_entities_filtered{type="character"}
	for k,v in ipairs(tbl)do
		for j=1,n do local a,d=math.random(0,2*math.pi),150 local x,y=math.cos(a)*d+v.position.x,math.sin(a)*d+v.position.y
			local p=game.surfaces[f].find_non_colliding_position(t,{x,y},0,2,1)
			local e=game.surfaces[f].create_entity{name=type,position=p}
		end
		game.surfaces[f].set_multi_command{command={type=defines.command.attack,target=v},unit_count=n}
	end
end
function surfaces.EmitText(f,pos,text) f.create_entity{name="tutorial-flying-text", text=text, position=pos} end


--[[ Events Library ]]--

events={}
events.defs={}
events.vdefs={}
events.filters={}
events.loadfuncs={}
events.initfuncs={}
events.migratefuncs={}
events.tickers={}
local events_with_filters={"on_built_entity","on_cancelled_deconstruction","on_cancelled_upgrade","on_entity_damaged","on_entity_died","on_marked_for_deconstruction",
	"on_marked_for_upgrade","on_player_mined_item","on_player_repaired_entity","on_post_entity_died","on_pre_ghost_deconstructed","on_pre_player_mined_item","on_robot_built_entity",
	"on_robot_mined","on_robot_pre_mined","on_player_mined_entity",}
events.events_with_filters={}
for k,v in pairs(events_with_filters)do events.events_with_filters[v]=v end


for k,v in pairs(defines.events)do events.defs[v]={} end
function events.hook(nm,func,fts) if(istable(nm))then for k,v in pairs(nm)do events.hook(v,func,fts) end return end
	local nm=(isnumber(nm) and nm or defines.events[nm]) events.defs[nm]=events.defs[nm] or {} table.insert(events.defs[nm],func)
	if(fts)then events.filters[nm]=events.filters[nm] or {} for k,v in pairs(fts)do table.insert(events.filters[nm],table.deepcopy(v)) end end
end
events.on_event=events.hook -- alias
function events.raise(name,ev) ev=ev or {} ev.name=ev.name or table.KeyFromName(defines.events,name) script.raise_event(name,ev) end

function events.register(name) events.vdefs[name]=script.generate_event_name() end
-- unused function events.vhook(name,func) if(istable(name))then for k,v in pairs(nm)do events.vhook(name,func) end end events.vhooks[name]=func end
function events.vraise(name,ev) ev=ev or {} ev.name=name script.raise_event(events.vdefs[name],ev) end

function events.entity(ev) return ev.entity or ev.created_entity or ev.destination or ev.mine end
function events.source(ev) return ev.source end
function events.destination(ev) return ev.created_entity or ev.destination end

function events.on_load(f) table.insert(events.loadfuncs,f) end
function events.on_init(f) table.insert(events.initfuncs,f) end
function events.on_migrate(f) table.insert(events.migratefuncs,f) end
events.on_config=events.on_migrate events.on_configration_changed=events.on_migrate -- aliases
function events.raise_load() cache.load() for k,v in ipairs(events.loadfuncs)do v() end if(lib.PLANETORIO)then lib.planets.lua() end end
function events.raise_init() cache.init() for k,v in ipairs(events.initfuncs)do v() end if(lib.PLANETORIO)then lib.planets.lua() end end
function events.raise_migrate(ev) cache.migrate(ev) for k,v in ipairs(events.migratefuncs)do v(ev or {}) end if(lib.PLANETORIO)then lib.planets.lua() end end

function events.on_tick(rate,offset,fnm,func)
	local r=events.tickers[rate] or {} events.tickers[rate]=r local o=r[offset] or {} r[offset]=o o[fnm]=func
	script.on_event(defines.events.on_tick,events.raise_tick)
end
function events.un_tick(rate,offset,fnm) local r=events.tickers[rate] or {} events.tickers[rate]=r local o=r[offset] or {} r[offset]=o o[fnm]=nil
	if(table_size(o)==0)then r[offset]=nil end
	if(table_size(r)==0)then events.tickers[rate]=nil end
	if(table_size(events.tickers)==0)then script.on_event(defines.events.on_tick,nil) end
end
function events.raise_tick(ev) for rt,ff in pairs(events.tickers)do for x,y in pairs(ff)do if(ev.tick%rt==x)then for a,b in pairs(y)do b(ev.tick) end end end end end

function events.inject()
	--error(serpent.block(events.filters[defines.events.on_built_entity]))
	for k,v in pairs(events.defs)do if(v and table_size(v)>0)then
		if(events.events_with_filters[table.KeyFromValue(defines.events,k)] and events.filters[k] and table_size(events.filters[k])>0)then
			--if(k==defines.events.on_built_entity and #events.filters[k]>0)then error(k..":\n"..serpent.block(events.filters[k])) end
			script.on_event(k,function(ev) for x,y in pairs(v)do y(ev) end end,events.filters[k])
		else script.on_event(k,function(ev) for x,y in pairs(v)do y(ev) end end)
		end
	end end
	if(table_size(events.tickers)>0)then script.on_event(defines.events.on_tick,events.raise_tick) end



	script.on_init(events.raise_init)
	script.on_load(events.raise_load)
	script.on_configuration_changed(events.raise_migrate)
end
function events.surface(ev) return ev.surface or game.surfaces[ev.surface_index] end



-- --------
-- Gui

vgui=vgui or {}
function vgui.create(parent,tbl)
	local elm=parent[tbl.name] if(not isvalid(elm))then elm=parent.add(tbl) end
	for k,v in pairs(tbl)do if(vgui.mods[k])then vgui.mods[k](elm,v) end end
	return elm
end



vgui.mods={} vmods=vgui.mods
function vmods.horizontal_align(e,v) e.style.horizontal_align=v end
function vmods.vertical_align(e,v) e.style.vertical_align=v end
function vmods.align(e,v) e.style.horizontal_align=(istable(v) and v[1] or v) e.style.vertical_align=istable(v and v[2] or v) end


-- --------
-- Remotes

