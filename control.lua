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





Code Index:

-- Environment
Environment setup, variables and useful helper functions

-- Warptorio Environment
Environment setup, variables and useful helper functions specifically used with warptorio

-- Offsets
I hate offsets

-- Warptorio Cache Manager
Manages scripted entities and entity events

-- Warp Rails
-- Warp Rail Logistics
-- Warp Rail Constructor



-- Metatables

Primary metatables used by Warptorio for simplicity


]]---------------------------------------

--[[ Environment ]]--

local util=require("util")
local mod_gui=require("mod-gui")

local custom_events={}
for k,v in pairs{"on_warp","on_post_warp","on_click"}do custom_events[v]=script.generate_event_name() end

function istable(x) return type(x)=="table" end
function isvalid(v) return (v and v.valid) end
function printx(m) for k,v in pairs(game.players)do v.print(m) end end
function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end
function oppositeDir(d) return (d+4)%8 end
function oppositeOutput(d) return (d=="input" and "output" or "input") end
function getEventEnt(ev) local e=ev.created_entity or ev.entity or ev.destination return e end

function table.First(t) for k,v in pairs(t)do return k,v end end
function table.Random(t) local c,i=table_size(t),1 if(c==0)then return end local rng=math.random(1,c) for k,v in pairs(t)do if(i==rng)then return v,k end i=i+1 end end
function table.HasValue(t,a) for k,v in pairs(t)do if(v==a)then return true end end return false end
function table.GetValueIndex(t,a) for k,v in pairs(t)do if(v==a)then return k end end return false end
function table.RemoveByValue(t,a) local i=table.GetValueIndex(t,a) if(i)then table.remove(t,i) end end
function table.insertExclusive(t,a) if(not table.HasValue(t,a))then return table.insert(t,a) end return false end
function table.deepmerge(s,t) for k,v in pairs(t)do if(istable(v) and s[k] and istable(s[k]))then if(table_size(v)==0)then s[k]=s[k] or {} else table.deepmerge(s[k],v) end else s[k]=v end end end
function table.merge(s,t) local x={} for k,v in pairs(s)do x[k]=v end for k,v in pairs(t)do x[k]=v end return x end

function math.round(v) return math.floor(v+0.5) end
function math.radtodeg(x) return x*(180/math.pi) end

vector={} vector.__index=vector setmetatable(vector,vector)
function vector:__call(x,y) return setmetatable({[1]=x,[2]=y,x=x,y=y},vector) end
function vector.__add(x,y) return vector.add(x,y) end
function vector.__sub(x,y) return vector.sub(x,y) end
function vector.__mul(x,y) return vector.mul(x,y) end
function vector.__div(x,y) return vector.div(x,y) end
function vector.add(va,vb) if(type(vb)=="number")then return vector(va.x+vb,va.y+vb) end local x=va.x+vb.x local y=va.y+vb.y return vector(x,y) end
function vector.sub(va,vb) if(type(vb)=="number")then return vector(va.x-vb,va.y-vb) end local x=va.x-vb.x local y=va.y-vb.y return vector(x,y) end
function vector.mul(va,vb) if(type(vb)=="number")then return vector(va.x*vb,va.y*vb) end local x=va.x*vb.x local y=va.y*vb.y return vector(x,y) end
function vector.div(va,vb) if(type(vb)=="number")then return vector(va.x/vb,va.y/vb) end local x=va.x/vb.x local y=va.y/vb.y return vector(x,y) end
function vector.pos(t) if(t.x)then t[1]=t.x elseif(t[1])then t.x=t[1] end if(t.y)then t[2]=t.y elseif(t[2])then t.y=t[2] end return t end
function vector.size(va,vb) return math.sqrt((va^2)+(vb^2)) end
function vector.distance(va,vb) return math.sqrt((va.x-vb.x)^2+(va.y-vb.y)^2) end
function vector.floor(v) return vector(math.floor(v.x),math.floor(v.y)) end
function vector.round(v,k) return vector(math.round(v.x,k),math.round(v.y,k)) end
function vector.ceil(v) return vector(math.ceil(v.x),math.ceil(v.y)) end
function vector.area(va,vb) local t={va,vb,left_top=va,right_bottom=vb} return t end
function vector.square(va,vb) local area={vector.add(va,vector.mul(vb,-0.5)),vector.add(va,vector.mul(vb,0.5))} area.left_top=area[1] area.right_bottom=area[2] return area end
function vector.playsound(pth,f,x) for k,v in pairs(game.connected_players)do if(v.surface.name==f)then v.play_sound{path=pth,position=x} end end end
function vector.isinbbox(p,a,b) local x,y=(p.x or p[1]),(p.y or p[2]) return not ( (x<(a.x or a[1]) or y<(a.y or a[2])) or (x>(b.x or b[1]) or y>(b.y or b[2]) ) ) end
function vector.inarea(v,a) local x,y=(v.x or v[1]),(v.y or v[2]) return not ( (x<(a[1].x or a[1][1]) or y<(a[1].y or a[1][2])) or (x>(a[2].x or a[2][1]) or y>(a[2].y or a[2][2]))) end
function vector.table(area) local t={} for x=area[1].x,area[2].x,1 do for y=area[1].y,area[2].y,1 do table.insert(t,vector(x,y)) end end return t end
function vector.circle(p,z) local t,c,d={},math.round(z/2) for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<=c)then table.insert(t,vector(x,y)) end end end return t end
function vector.circleEx(p,z) local t,c,d={},z/2 for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<c)then table.insert(t,vector(x,y)) end end end return t end
function vector.ovalInverted(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	if((math.abs(x^2)*math.abs(y^2)) < math.abs(xz^2)*math.abs(yz^2)*(curve or 0.5))then table.insert(t,vector(vector.x(p)+x,vector.y(p)+y)) end
end end return t end
function vector.ovalFan(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	local deg=math.radtodeg(180-math.atan2(x,y)*math.pi)
	if(not(math.abs(x)<math.abs(math.sin(deg/180)*xz) and math.abs(y)<math.abs(math.cos(deg/180)*yz) ))then table.insert(t,vector(vector.x(p)+x,vector.y(p)+y)) end
end end return t end
function vector.oval(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	if( (x^2)/(xz^2)+(y^2)/(yz^2) <1 )then table.insert(t,vector(vector.x(p)+x,vector.y(p)+y)) end
end end return t end

function vector.LayTiles(tex,f,area) local t={} for x=area[1].x,area[2].x do for y=area[1].y,area[2].y do table.insert(t,{name=tex,position={x,y}}) end end f.set_tiles(t) return t end
function vector.LayCircle(tex,f,cir) local t={} for k,v in pairs(cir)do table.insert(t,{name=tex,position=v}) end f.set_tiles(t) return t end
function vector.LayBorder(tex,f,a) local t={} for x=a[1].x,a[2].x do table.insert(t,{name=tex,position=vector(x,a[1].y)}) end for y=a[1].y,a[2].y do table.insert(t,{name=tex,position=vector(a[1].x,y)}) end f.set_tiles(t) return t end
function vector.clearplayers(f,area,tpo) for k,v in pairs(players.find(f,area))do entity.safeteleport(v,f,tpo) end end
function vector.clear(f,area,tpo) local e=f.find_entities(area) for k,v in pairs(e)do if(v.type=="character")then if(tpo)then entity.safeteleport(v,f,tpo) end else entity.destroy(v) end end end
function vector.clearFiltered(f,area,tpo) for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=area})do if(v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio")then entity.destroy(v) end end end
function vector.x(vec) return vec.x or vec[1] end
function vector.y(vec) return vec.y or vec[2] end
vector.clean=vector.clear --alias
vector.cleanplayers=vector.clearplayers --alias
vector.cleanFiltered=vector.clearFiltered --alias

vector.dir={[0]=vector(0,-1),[1]=vector(1,-1),[2]=vector(1,0),[3]=vector(1,1),[4]=vector(0,1),[5]=vector(-1,1),[6]=vector(-1,0),[7]=vector(-1,-1)}
setmetatable(vector.dir,{__index=vector.dir,call=function(t,k) return t[k] end})

--[[
local hookMeta={}
local hook=setmetatable({},{__index=hookMeta})
function hookMeta:add(n,k,f) if(not self[n])then self[n]={} end self[n][k]=f end end
function hookMeta:remove(n,k) if(self[n] and self[n][k])then self[n][k]=nil end end
function hookMeta:call(n,...) if(self[n])then for k,v in pairs(self[n])do v(...) end end end
]]

entity={}
function entity.protect(e,min,des) if(min~=nil)then e.minable=min end if(des~=nil)then e.destructible=des end return e end
function entity.spawn(f,n,pos,dir,t) t=t or {} local tx=t or {} tx.name=n tx.position={vector.x(pos),vector.y(pos)} tx.direction=dir tx.player=(t.player or game.players[1])
	tx.force=t.force or game.forces.player
	tx.raise_built=(t.raise_built~=nil and t.raise_built or true) local e=f.create_entity(tx) return e
end
entity.create=entity.spawn -- alias

function entity.destroy(e,r,c) if(e and e.valid)then e.destroy{raise_destroy=(r~=nil and r or true),do_cliff_correction=(c~=nil and c or true)} end end
function entity.ChestRequestMode(e) local cb=e.get_or_create_control_behavior() cb.circuit_mode_of_operation=defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests end
function entity.safeteleport(e,f,pos) e.teleport(f.find_non_colliding_position(e.is_player() and "character" or e.name,pos or e.position,0,0.25,false),f) end
function entity.shouldClean(v) return (v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio") end
function entity.tryclean(v) if(v.valid and entity.shouldClean(v))then entity.destroy(v) end end


entity.copy={} entity.copy.__index=entity.copy setmetatable(entity.copy,entity.copy)
function entity.copy.__call(e) end
function entity.copy.chest(a,b) local c=b.get_inventory(defines.inventory.chest) for k,v in pairs(a.get_inventory(defines.inventory.chest).get_contents())do c.insert{name=k,count=v} end
	local net=a.circuit_connection_definitions
	for c,tbl in pairs(net)do b.connect_neighbour{target_entity=tbl.target_entity,wire=tbl.wire,source_circuit_id=tbl.source_circuit_id,target_circuit_id=tbl.target_circuit_id} end
end
function entity.emitsound(e,path) for k,v in pairs(game.connected_players)do if(v.surface==e.surface)then v.play_sound{path=path,position=e.position} end end end


players={}
function players.find(f,area) local t={} for k,v in pairs(game.players)do if(v.surface==f and vector.inarea(v.position,area))then table.insert(t,v) end end return t end
function players.playsound(path,f,pos) for k,v in pairs(game.connected_players)do if(not f or v.surface==f)then v.play_sound{path=path,position=pos} end end end


research={}
function research.get(n,f) f=f or game.forces.player return f.technologies[n] end
function research.has(n,f) return research.get(n,f).researched end
function research.can(n,f) local r=research.get(n,f) if(r.researched)then return true end local x=table_size(r.prerequisites) for k,v in pairs(r.prerequisites)do if(v.researched)then x=x-1 end end return (x==0) end
function research.level(n,f) f=f or game.forces.player local ft=f.technologies local r=ft[n.."-0"] or ft[n.."-1"] local i=0 while(r)do if(r.researched)then i=r.level r=ft[n.."-".. i+1] else r=nil end end return i end


--[[ Warptorio Environment ]]--

local gwarptorio=setmetatable({},{__index=function(t,k) return global.warptorio[k] end,__newindex=function(t,k,v) global.warptorio[k]=v end})
warptorio=warptorio or {}

warptorio.migrate={}
warptorio.init={}
warptorio.load={}

for k,v in pairs(defines.events)do warptorio[k]={} end

require("control_planets")
require("control_research")

function warptorio.CountEntities() local c=0 for k,v in pairs(gwarptorio.floor)do if(v.surface and v.surface.valid)then
	c=c+table_size(v.surface.find_entities())
end end return c end

--function warptorio.getlabelcontrol(ply,x) local gx=ply.gui.left.warptorio_frame if(gx)then local g for i=1,2,1 do g=gx["warptorio_line"..i][x] if(g)then return g end end end end
--function warptorio.updatelabel(lbl,txt) for k,v in pairs(game.players)do local g=warptorio.getlabelcontrol(v,lbl) if(g and g.valid)then g.caption=txt end end end

function warptorio.spawnbiters(type,n,f) local tbl=game.surfaces[f].find_entities_filtered{type="character"}
	for k,v in ipairs(tbl)do
		for j=1,n do local a,d=math.random(0,2*math.pi),150 local x,y=math.cos(a)*d+v.position.x,math.sin(a)*d+v.position.y
			local p=game.surfaces[f].find_non_colliding_position(t,{x,y},0,2,1)
			local e=game.surfaces[f].create_entity{name=type,position=p}
		end
		game.surfaces[f].set_multi_command{command={type=defines.command.attack,target=v},unit_count=n}
	end
end

function warptorio.IsTeleporterGate(e) return (e.name:sub(1,25)=="warptorio-teleporter-gate") end

function warptorio.settings(n) return settings.global["warptorio_"..n].value end

function warptorio.GetPlanetSurface() return gwarptorio.floor.main.surface end
function warptorio.GetFactorySurface() return gwarptorio.floor.b1.surface end
function warptorio.GetBoilerSurface() return gwarptorio.floor.b2.surface end
function warptorio.GetHarvesterSurface() return gwarptorio.floor.b3.surface end
function warptorio.GetHomeSurface() return gwarptorio.floor.home.surface end

function warptorio.GetPlanetBySurface(f) local idx=(type(f)=="number" and f or f.index) return gwarptorio.planetsurface[idx] end
function warptorio.SetPlanetBySurface(f,p) local idx=(type(f)=="number" and f or f.index) gwarptorio.planetsurface[idx]=p end
function warptorio.on_surface_deleted.planet(ev) gwarptorio.planetsurface[ev.surface_index]=nil end
function warptorio.migrate.planet_surface_tracker() gwarptorio.planetsurface=gwarptorio.planetsurface or {} end

function warptorio.GetCurrentPlanet() return warptorio.GetPlanetBySurface(warptorio.GetPlanetSurface()) end


function warptorio.GetChest(dir) local lv=research.level("warptorio-logistics") if(lv<=1)then return "wooden-chest" elseif(lv<=2)then return "iron-chest" elseif(lv<=3)then return "steel-chest" else
	return (dir=="output" and warptorio.settings("loaderchest_provider") or warptorio.settings("loaderchest_requester")) end
end
function warptorio.GetBelt(dir) local lv=research.level("warptorio-logistics") if(lv<=1)then return "loader" elseif(lv<=2)then return "fast-loader" elseif(lv<=3)then return "express-loader" else
	return "express-loader" end
end

function warptorio.AutoBalancePower(t) local p=#t local g=0 local c=0
	for k,v in pairs(t)do if(v.valid)then g=g+v.energy c=c+v.electric_buffer_size end end
	for k,v in pairs(t)do if(v.valid)then local r=(v.electric_buffer_size/c) v.energy=g*r end end
end
function warptorio.AutoBalanceHeat(t) local h=0 for k,v in pairs(t)do h=h+v.temperature end for k,v in pairs(t)do v.temperature=h/#t end end



function warptorio.GetFastestLoader() -- currently unused
	if(warptorio.FastestLoader)then return warptorio.FastestLoader end if(true)then return "express-loader" end
	local ld={} local topspeed=game.entity_prototypes["express-loader"].belt_speed local top="express-loader"
	for k,v in pairs(game.entity_prototypes)do if(v.type=="loader")then table.insert(ld,v) end end
	for k,v in pairs(ld)do if(not v.name:match("warptorio") and not v.name:match("mini") and v.belt_speed>=topspeed)then topspeed=v.belt_speed top=v.name end end
	warptorio.FastestLoader=top return top
end




--[[ Warptorio Cache Manager ]]--


function warptorio.InsertCache(k,v) return table.insertExclusive(gwarptorio.cache[k],v) end
function warptorio.RemoveCache(k,v) table.RemoveByValue(gwarptorio.cache[k],v) end
function warptorio.CallCache(k,e,ev) if(e and e.valid)then
	local r=warptorio.cache[e.name] if(r)then if(type(k)=="table")then for x,y in ipairs(k)do if(r[y])then return r[y](e,ev) end end elseif(r[k])then return r[k](e,ev) end end
end end

warptorio.cache={}
warptorio.cache["warptorio-heatpipe"]={ create=function(e) warptorio.InsertCache("heat",e) end, destroy=function(e) warptorio.RemoveCache("heat",e) end }
warptorio.cache["warptorio-reactor"]={ create=function(e) warptorio.InsertCache("heat",e) end, destroy=function(e) warptorio.RemoveCache("heat",e) end }
warptorio.cache["warptorio-accumulator"]={ create=function(e) warptorio.InsertCache("power",e) end, destroy=function(e) warptorio.RemoveCache("power",e) end }
warptorio.cache["warptorio-logistic-pipe"]={
	clone=function(e,ev) for k,v in pairs(gwarptorio.Teleporters)do for a,t in pairs(v.pipes)do for i,w in pairs(t)do if(e==w)then t[i]=e return end end end end end,
	destroy=function(e,ev) for k,v in pairs(gwarptorio.Teleporters)do for a,t in pairs(v.pipes)do for i,w in pairs(t)do if(e==w)then t[i]=nil return end end end end end,
}
warptorio.cache["warptorio-teleporter"]={
	create=function(e) warptorio.InsertCache("power",e) end,
	clone=function(e,ev)
		for k,v in pairs(gwarptorio.Teleporters)do if(v.a==ev.source)then v.a=e return elseif(v.b==ev.source)then v.b=e return end end
	end,
	destroy=function(e,ev) warptorio.RemoveCache("power",e) end,
}
warptorio.cache["warptorio-teleporter-gate"]={
	create=function(e)
		warptorio.InsertCache("power",e)
	end,
	built=function(e)
		local ef=e.surface local t=gwarptorio.Teleporters["offworld"]
		if(t:ValidB())then entity.destroy(e) game.print("Max 1 Planet Teleporter Gate allowed at a time") return false end
		t:SetB(e)
		if(ef==warptorio.GetFactorySurface() or ef==warptorio.GetBoilerSurface() or ef==warptorio.GetHarvesterSurface())then game.print("The Teleporter only functions on the Planet") return end
		t:SpawnLogsB()
	end,
	destroy=function(e,ev) warptorio.RemoveCache("power",e)
		local t=gwarptorio.Teleporters.offworld t:DestroyLogsB()
	end,
}
warptorio.cache["warptorio-underground"]={
	create=function(e) warptorio.InsertCache("power",e) end,
	clone=function(e,ev) for k,v in pairs(gwarptorio.Teleporters)do if(v.a==ev.source)then v.a=e v:ConnectCircuit() return elseif(v.b==ev.source)then v.b=e v:ConnectCircuit() return end end end,
	destroy=function(e,ev) warptorio.RemoveCache("power",e) end,
}
for k,v in pairs{"warptorio-teleporter-gate","warptorio-teleporter","warptorio-underground"}do
	for i=0,8,1 do warptorio.cache[v.."-"..i]=warptorio.cache[v] end
end








function warptorio.script_raised_built.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache("create",e,ev) end
function warptorio.on_built_entity.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache("built",e,ev) warptorio.CallCache("create",e,ev) end
function warptorio.script_raised_revive.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache({"revive","create","built"},e,ev) end
function warptorio.on_entity_cloned.cache(ev) local e=ev.entity or ev.created_entity or ev.destination warptorio.CallCache("clone",e,ev) warptorio.CallCache("create",e,ev) end

function warptorio.script_raised_destroy.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache("destroy",e,ev) end
function warptorio.on_entity_died.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache({"died","destroy"},e,ev) end
function warptorio.on_player_mined_entity.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache({"mined","destroy"},e,ev) end
function warptorio.on_robot_mined_entity.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache({"mined","destroy"},e,ev) end

function warptorio.on_player_rotated_entity.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache("rotate",e,ev) end
function warptorio.on_entity_settings_pasted.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache("settings_pasted",e,ev) end
function warptorio.on_pre_entity_settings_pasted.cache(ev) local e=ev.entity or ev.created_entity warptorio.CallCache("pre_settings_pasted",e,ev) end
function warptorio.on_gui_closed.cache(ev) local e=ev.entity warptorio.CallCache("gui_closed",e,ev) end

function warptorio.migrate.cache()
	for k,v in pairs{"heat","power","loaderinput","loaderoutput","ldinputf","ldoutputf"}do gwarptorio.cache[v]=gwarptorio.cache[v] or {} end
	for n,t in pairs(gwarptorio.cache)do for k,v in pairs(t)do if(v.valid==false)then t[k]=nil elseif(not v.name)then for x,y in pairs(v)do if(not isvalid(y))then v[x]=nil end end end end end
end

function warptorio.on_entity_cloned.cache_types(ev) local e=ev.source local d=ev.destination if(not e or not e.valid or not d or not d.valid)then return end
	if(e.type=="offshore-pump" or e.type=="resource")then entity.destroy(e)
	elseif(e.type=="loader")then for k,v in pairs(gwarptorio.Teleporters)do for a,t in pairs(v.loaders)do for i,w in pairs(t)do if(e==w)then
		gwarptorio.Teleporters[k].loaders[a][i]=d end end end end
	elseif(e.type=="container" or e.type=="logistic-container")then for k,v in pairs(gwarptorio.Teleporters)do for a,t in pairs(v.chests)do for i,w in pairs(t)do if(e==w)then
		t[i]=d end end end end
	end
end

function warptorio.on_tick.logistic_heat(ev) warptorio.AutoBalanceHeat(gwarptorio.cache.heat) end
function warptorio.on_tick.logistic_power(ev) warptorio.AutoBalancePower(gwarptorio.cache.power) end



function warptorio.on_player_rotated_entity.platform_loaders(ev)
	local ply,ent,pdir=game.players[ev.player_index],ev.entity,ev.previous_direction
	for k,v in pairs(gwarptorio.Rails)do v:CheckLoaders() end
	for k,v in pairs(gwarptorio.Teleporters)do v:CheckLoaders() end
end







--[[ Platform Offsets ]]--


local platform={} warptorio.platform=platform
platform.railCorner={nw=vector(-35,-35),ne=vector(34,-35),sw=vector(-35,34),se=vector(34,34)}
platform.railOffset={nw=vector(0,0),ne=vector(-1,0),sw=vector(0,-1),se=vector(-1,-1)} --{nw=vector(-1,-1),ne=vector(0,-1),sw=vector(-1,0),se=vector(0,0)}
platform.railLoader={nw=vector.area(vector(2,0),vector(0,2)),sw=vector.area(vector(2,0),vector(0,-2)),ne=vector.area(vector(-2,0),vector(0,2)),se=vector.area(vector(-2,0),vector(0,-2))}
platform.railChest={} for k,v in pairs(platform.railCorner)do platform.railChest[k]=v+platform.railOffset[k] end

platform.letterOpposite={n=defines.direction.south,s=defines.direction.north,e=defines.direction.west,w=defines.direction.east}
platform.railLoaderPos={
	nw={vector(2,0),vector(2,-1),vector(0,2),vector(-1,2)},
	sw={vector(2,0),vector(2,-1),vector(0,-2),vector(-1,-1)},
	ne={vector(-2,0),vector(-2,-1),vector(0,2),vector(-1,2)},
	se={vector(-2,0),vector(-2,-1),vector(0,-2),vector(-1,-2)},
}

platform.corner={nw=vector(-52,-52),ne=vector(50,-52),sw=vector(-52,50),se=vector(50,50)}
platform.side={north=vector(0,-52),south=vector(0,50),east=vector(50,0),west=vector(-52,0)}
--[[
local cirMaxWidth=128+8
local cirHeight=17 --64+4 --17 --
local vz=cirMaxWidth
--local ez=m.harvestSize or 10 -- harvester size max 47
local hvMax=47
local vzx=vz/2 local hvx=hvMax/2 local hvy=hvMax/8

local westPos=warptorio.platform.harvester.west --vector(-(vzx+(hvx-hvy))+0.5,-0.5)
local eastPos=warptorio.platform.harvester.east --vector(vzx+(hvx-hvy),-0.5)
]]
local hvSize=(128+8)/2
local hvMax=47
platform.harvester={}
platform.harvester.east=vector(85.5,-0.5) --hvSize+((hvMax/2)-(hvMax/8)),-0.5) -- 85.625
platform.harvester.west=vector(-85.5,-0.5) -- -(hvSize+((hvMax/2)-(hvMax/8)))+0.5,-0.5) -- -85.125


warptorio.corn={}
warptorio.corn.nw={x=-52,y=-52}
warptorio.corn.ne={x=50,y=-52}
warptorio.corn.sw={x=-52,y=50}
warptorio.corn.se={x=50,y=50}
warptorio.corn.north=-52
warptorio.corn.south=50
warptorio.corn.east=50
warptorio.corn.west=-51.5


function warptorio.GetTeleporterSize(bMain) local lv,dl,tl=research.level("warptorio-logistics"),research.has("warptorio-dualloader-1"),research.has("warptorio-triloader")
	local x=(lv>=1 and 2 or 0)+((bMain and dl) and 1 or 0)+(tl and 1 or 0) return vector((x*2)+2,2)
end
function warptorio.GetTeleporterHazard(bMain,a,b,c)
	local lv,dl,tl=research[a and "has" or "can"]("warptorio-logistics-1"),research[b and "has" or "can"]("warptorio-dualloader-1"),research[c and "has" or "can"]("warptorio-triloader")
	local x=(lv and 2 or 0)+((bMain and dl) and 1 or 0)+(tl and 1 or 0) return vector((x*2)+2,2)
end



--[[ Warp Rails ]]--

local trail={} trail.__index=trail setmetatable(trail,trail) warptorio.TelerailMeta=trail
function trail.__call(t,n) if(warptorio.Rails[n])then return warptorio.Rails[n] else return new(trail,n) end end
function trail.__init(self,n) self.name=n self.chests={} self.rails={} self.loaders={} gwarptorio.Rails[n]=self self.dir="output" self:DoMakes() end

function trail:MakeRails()
	local f=warptorio.GetPlanetSurface()
	local c=platform.railCorner[self.name]+platform.railOffset[self.name]
	if(not isvalid(self.rails[1]))then self.rails[1]=entity.protect(entity.spawn(f,"straight-rail",c,{direction=defines.direction.south}),false,false) end
	if(not isvalid(self.rails[2]))then self.rails[2]=entity.protect(entity.spawn(f,"straight-rail",c,{direction=defines.direction.east}),false,false) end
end
function trail:MakeChestAt(f,chest,i,pos,req)
	local r=self.chests[i] local rx if(isvalid(r) and r.name~=chest)then rx=r r=nil end
	if(not r or not r.valid)then r=entity.protect(entity.spawn(f,chest,pos),false,false) self.chests[i]=r if(req)then entity.ChestRequestMode(r) end end
	if(rx)then entity.copy.chest(rx,r) entity.destroy(rx) end
end
function trail:MakeChests() local chest=warptorio.GetChest(self.dir) local f=warptorio.GetFactorySurface() local req=(self.dir=="input") for k,v in pairs(platform.railChest)do self:MakeChestAt(f,chest,k,v,req) end end
function trail:RotateChests() local c=warptorio.GetChest(self.dir) self:MakeChests(c) end
function trail:RotateLoaders() for k,v in pairs(self.loaders)do v.loader_type=self.dir end end
function trail:CheckLoaders() for k,v in pairs(self.loaders)do if(v.loader_type~=self.dir)then self.dir=v.loader_type return self:RotateLoaders(),self:RotateChests() end end end
function trail:MakeLoaderAt(f,belt,i,pos,dir,type)
	local r=self.loaders[i]
	if(isvalid(r) and r.name~=belt)then entity.destroy(r) r=nil end
	if(not isvalid(r))then r=entity.protect(entity.spawn(f,belt,pos,{direction=dir,type="output"}),false,false) self.loaders[i]=r end
	if(isvalid(r) and r.loader_type~=type)then r.loader_type=type end
	return r
end
function trail:MakeLoaders() local belt=warptorio.GetBelt(self.dir) local f=warptorio.GetFactorySurface() local c=self.name
	for i=1,2 do self:MakeLoaderAt(f,belt,i,platform.railLoaderPos[c][i]+platform.railCorner[c],platform.letterOpposite[c[1]],self.dir) end
	for i=3,4 do self:MakeLoaderAt(f,belt,i,platform.railLoaderPos[c][i]+platform.railCorner[c],platform.letterOpposite[c[2]],self.dir) end
end

function trail:DoMakes() self:MakeRails() self:MakeChests() self:MakeLoaders() end


-- Warp Rail Logistics

function trail:SplitItem(u,n) local c=n local cx=0 local cinv={} local ui={name=k,count=n}
	for k,v in pairs(self.chests)do local iv=v.get_inventory(defines.inventory.chest) if(iv.can_insert(u))then cinv[k]=iv end end local tcn=table_size(cinv)
	for k,v in pairs(cinv)do if(c>0)then local w=v.insert{name=u,count=math.ceil(c/tcn)} cx=cx+w c=c-w tcn=tcn-1 end end
	return cx
end
function trail:LoadLogistics(e)
	local inv={} for k,v in pairs(self.chests)do inv[k]=v.get_inventory(defines.inventory.chest) end
	local ct={} for k,v in pairs(inv)do for a,b in pairs(v.get_contents())do ct[a]=(ct[a] or 0)+b end v.clear() end
	for _,r in pairs(e)do local tr=r.get_inventory(defines.inventory.cargo_wagon) for k,v in pairs(ct)do ct[k]=v-(tr.insert{name=k,count=v}) end end
	local ci for a,b in pairs(ct)do local g=b ci=#inv for k,v in pairs(inv)do local gci=math.ceil(g/ci) if(gci>0)then local w=v.insert{name=a,count=math.ceil(g/ci)} ci=ci-1 g=g-w end end end
end
function trail:UnloadLogistics(e) for _,r in pairs(e)do
		local inv=r.get_inventory(defines.inventory.cargo_wagon) for k,v in pairs(inv.get_contents())do local ct=self:SplitItem(k,v) if(ct>0)then inv.remove({name=k,count=ct}) end end
end end
function trail:BalanceLogistics() local f=gwarptorio.Floors.main:GetSurface() if(not f.valid)then return end local c=warptorio.railCorn[self.name]
	local e=f.find_entities_filtered{name="cargo-wagon",area={{c.x-1,c.y-1},{c.x+1,c.y+1}} }
	if(table_size(e)>0)then if(self.dir=="output")then self:UnloadLogistics(e) self:BalanceChests() else self:LoadLogistics(e) end else self:BalanceChests() end
end
function trail:BalanceChests() local inv={} for k,v in pairs(self.chests)do inv[k]=v.get_inventory(defines.inventory.chest) end
	local ct={} for k,v in pairs(inv)do for a,b in pairs(v.get_contents())do ct[a]=(ct[a] or 0)+b end v.clear() end
	local ci for a,b in pairs(ct)do local g=b ci=#inv for k,v in pairs(inv)do local gci=math.ceil(g/ci) if(gci>0)then local w=v.insert{name=a,count=math.ceil(g/ci)} ci=ci-1 g=g-w end end end
end

-- Warp Rail Constructor

function warptorio.BuildRailCorner(cn) local r=gwarptorio.Rails[cn] if(true) then return end
	if(not r)then r=warptorio.Telerail(cn)
		local f,fp=warptorio.GetFactorySurface(),warptorio.GetPlanetSurface() local c,co,cl=platform.railCorner[cn],platform.railOffset[cn],platform.railLoader[cn]
		local vec,cx=vector(2,2),c+co
		local sq=vector.square(cx,vec)
		vector.clear(fp,sq) vector.clear(f,sq) cx=c+vector(-1,-1) vector.clear(f,vector.square(cx,vec)) vector.clear(f,vector.square(cx+cl[1],vec)) vector.clear(f,vector.square(cx+cl[2],vec))
	end
	r:DoMakes()
end

function warptorio.BuildRails() warptorio.BuildRailCorner("nw") warptorio.BuildRailCorner("sw") warptorio.BuildRailCorner("ne") warptorio.BuildRailCorner("se") end --for k,v in pairs(warptorio.railCorn)do warptorio.BuildRailCorner(k) end end




--[[ Warp Teleporters ]]--




local tell={} tell.__index=tell warptorio.TeleporterMeta=tell --setmetatable(tell,tell)
--function tell.__call(self,n,j,m) if(gwarptorio.Teleporters[n])then return gwarptorio.Teleporters[n] else return new(tell,n,j,m) end end
function tell.__init(self,n,j,m) self.name=n self.top=j self.main=m self.chestcont={a={},b={}}
	self.chests={a={},b={}}
	self.pipes={a={},b={}}
	self.loaders={a={},b={}}
	self.dir={a={},b={}} for i=1,6,1 do self.dir.a[i]="input" self.dir.b[i]="output" end
	gwarptorio.Teleporters[n]=self
end
function tell:TickLogistics()
end

function tell:SetA(e) self.a=e if(self.AEnergy)then self.a.energy=self.AEnergy self.AEnergy=nil end end
function tell:SetB(e) self.b=e if(self.BEnergy)then self.b.energy=self.BEnergy self.BEnergy=nil end end
function tell:MakeA(n,f,pos,prot) local e=entity.protect(entity.create(f,n,pos),prot~=nil and prot or false,prot~=nil and prot or false) self:SetA(e) return e end
function tell:MakeB(n,f,pos,prot) local e=entity.protect(entity.create(f,n,pos),prot~=nil and prot or false,prot~=nil and prot or false) self:SetB(e) return e end
function tell:ValidA() return (isvalid(self.a)) end
function tell:ValidB() return (isvalid(self.b)) end
function tell:DestroyA() if(self:ValidA())then self.AEnergy=self.a.energy self.a.destroy() self.a=nil end end
function tell:DestroyB() if(self:ValidB())then self.BEnergy=self.b.energy self.b.destroy() self.b=nil end end
function tell:Destroy() self:DestroyA() self:DestroyB() end
function tell:ConnectCircuit() self.a.connect_neighbour({target_entity=self.b,wire=defines.wire_type.red}) self.a.connect_neighbour({target_entity=self.b,wire=defines.wire_type.green}) end

function tell:MakeChest(o,k) local e=self.chests[o][k] local ex=warptorio.GetChest(self.dir[o][k])
	if(e and e.name~=ex)then local v=entity.protect(entity.create(e.surface,ex,e.position)) entity.copy.chest(e,v) entity.destroy(e) self.chests[o][k]=v if(self.dir[o][k]=="input")then entity.ChestRequestMode(v) end end
end
function tell:SwapLoaderChests(k) self:MakeChest("a",k) self:MakeChest("b",k) end
function tell:UpgradeChests() for i=1,6,1 do self:SwapLoaderChests(i) end end
function tell:CheckLoaders() for i,t in pairs(self.loaders)do local o=(i=="a" and "b" or "a") for k,v in pairs(t)do
	if(v.loader_type~=self.dir[i][k])then
	self.dir[i][k]=v.loader_type self.dir[o][k]=oppositeOutput(v.loader_type) if(self.loaders[o][k])then self.loaders[o][k].loader_type=self.dir[o][k] end self:SwapLoaderChests(k)
end end end end


function tell:MakeLoaders(o,id) local belt=warptorio.GetBelt(self.dir[o][id])
	local st=warptorio.settings("loader_top")
	local sb=warptorio.settings("loader_bottom")
	local lddir,chesty,belty
	local pos=self[o].position local f=self[o].surface
	if(self.top)then if(st=="up")then lddir=defines.direction.north chesty=-1 belty=0 else lddir=defines.direction.south chesty=1 belty=-1 end
	else if(sb=="down")then lddir=defines.direction.south chesty=1 belty=-1 else lddir=defines.direction.north chesty=-1 belty=0 end end

	local v=self.loaders[o][id] if(isvalid(v) and v.name~=belt)then entity.destroy(v) v=nil end
	if(not isvalid(v))then v=entity.protect(entity.create(f,belt,vector.add(pos,vector(-1-id,belty)),lddir),false,false) self.loaders[o][id]=v end
	local v=self.loaders[o][id+3] if(isvalid(v) and v.name~=belt)then entity.destroy(v) v=nil end
	if(not isvalid(v))then v=entity.protect(entity.create(f,belt,vector.add(pos,vector(1+id,belty)),lddir),false,false) self.loaders[o][id+3]=v end

	local v=self.chests[o][id] local chest=warptorio.GetChest(self.dir[o][id])
	if(isvalid(v) and v.name~=chest)then self.chestcont[o][id]=v.get_inventory(defines.inventory.chest).get_contents() entity.destroy(v) v=nil end
	if(not isvalid(v))then v=entity.protect(entity.create(f,chest,vector.add(vector.pos(pos),vector(-1-id,chesty)) ),false,false) self.chests[o][id]=v
		local inv=self.chestcont[o][id] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert{name=x,count=y} end self.chestcont[o][id]=nil end
	end
	local v=self.chests[o][id+3] local chest=warptorio.GetChest(self.dir[o][id+3])
	if(isvalid(v) and v.name~=chest)then self.chestcont[o][id+3]=v.get_inventory(defines.inventory.chest).get_contents() entity.destroy(v) v=nil end
	if(not isvalid(v))then v=entity.protect(entity.create(f,chest,vector.add(pos,vector(1+id,chesty)) ),false,false) self.chests[o][id+3]=v
		local inv=self.chestcont[o][id+3] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert{name=x,count=y} end self.chestcont[o][id+3]=nil end
	end
end

function tell:MakePipes(o,dist,id)
	local e=self[o]
	local pos=e.position local f=e.surface
	local v=self.pipes[o][id]
	local pipe="warptorio-logistics-pipe"
	if(isvalid(v) and v.surface~=e.surface)then entity.destroy(v) v=nil end
	if(not isvalid(v))then v=entity.protect(entity.create(f,pipe,vector.add(pos,vector(-1-dist,2-id)),defines.direction.west ),false,false) self.pipes[o][id]=v
	else v.teleport(vector.add(pos,vector(-1-dist,2-id))) end

	local v=self.pipes[o][id+3]
	if(isvalid(v) and v.surface~=e.surface)then entity.destroy(v) v=nil end
	if(not isvalid(v))then v=entity.protect(entity.create(f,pipe,vector.add(pos,vector(1+dist,2-id)),defines.direction.east ),false,false) self.pipes[o][id+3]=v
	else v.teleport(vector.add(pos,vector(1+dist,2-id))) end
end

function tell:SpawnLogsPoint(u) local e=self[u] if(not e or not e.valid)then return end
	local lv,dl,tl=research.level("warptorio-logistics"),research.has("warptorio-dualloader-1"),research.has("warptorio-triloader")
	local i=1 if(lv>0)then self:MakeLoaders(u,i) i=i+1 if(tl)then self:MakeLoaders(u,i) i=i+1 end if(dl and self.main)then self:MakeLoaders(u,i) i=i+1 end end
	for x=1,3,1 do if(lv>=x)then self:MakePipes(u,i,x) end end players.playsound("warp_in",e.surface,e.position)
end
function tell:DestroyLogsPoint(o) for k,v in pairs(self.chests[o])do self.chestcont[o][k]=v.get_inventory(defines.inventory.chest).get_contents() entity.destroy(v) self.chests[o][k]=nil end
	for k,v in pairs(self.loaders[o])do entity.destroy(v) self.loaders[o][k]=nil end for k,v in pairs(self.pipes[o])do entity.destroy(v) self.pipes[o][k]=nil end
end
function tell:DestroyLogsA() self:DestroyLogsPoint("a") end
function tell:DestroyLogsB() self:DestroyLogsPoint("b") end
function tell:DestroyLogs() self:DestroyLogsA() self:DestroyLogsB() end
function tell:SpawnLogsA() return self:SpawnLogsPoint("a") end
function tell:SpawnLogsB() return self:SpawnLogsPoint("b") end
function tell:SpawnLogs() self:SpawnLogsA() self:SpawnLogsB() end
function tell:UpgradeLogistics() self:DestroyLogs() self:SpawnLogs() end
function tell:UpgradeEnergy() warptorio.Teleporters[self.name]:Warpin() end
function tell:Warpin() warptorio.Teleporters[self.name]:Warpin() end
function tell:GetLogisticsArea(o) return vector.square(warptorio.Teleporters[self.name].position,warptorio.GetTeleporterSize(self.main)) end

function tell:SpawnLogistics()
	if(self:ValidA())then self:SpawnLogisticsPoint("a") end
	if(self:ValidB())then if(self.name=="offworld")then local f=self.b.surface if(f==warptorio.GetPlanetSurface())then
		if(f.count_entities_filtered{area=self:GetLogisticsArea("b"),collision_mask={"object-layer"}} >1)then game.print("Unable to place teleporter logistics, something is in the way!")
		else self:SpawnLogisticsPoint("b") end
	end else self:SpawnLogisticsPoint("b") end end
end



--[[ Teleporter Registers ]]--

warptorio.Teleporters={} setmetatable(warptorio.Teleporters,{__index=warptorio.Teleporters,
	__call=function(t,n,j,m) if(not gwarptorio.Teleporters[n])then new(tell,n,j,m) end return gwarptorio.Teleporters[n] end,
})

local t={name="offworld"} warptorio.Teleporters[t.name]=t
t.position=vector(-1,5)
function t:Warpin() if(not research.has("warptorio-teleporter-portal"))then return end
	local lvEnergy,lvLogs,lvTri=research.level("warptorio-teleporter-energy"),research.level("warptorio-logistics"),research.has("warptorio-triloader") and 2 or 0
	local tpc,clsA,clsB,f,desA,desB=warptorio.Teleporters(self.name,false,false),"warptorio-teleporter-"..lvEnergy,"warptorio-teleporter-gate-"..lvEnergy,warptorio.GetPlanetSurface()
	local size=warptorio.GetTeleporterSize(tpc.main)
	local aPos=self.position -- vector(-2-lvTri-(lvLogs>0 and 2 or 0),y)
	if(tpc:ValidA())then if(tpc.a.surface~=f)then tpc:DestroyA() tpc:DestroyLogsA() elseif(tpc.a.name~=clsA)then tpc:DestroyA() desA=true end end
	if(not tpc:ValidA())then if(not desA)then vector.clean(f,vector.square(aPos,size)) end tpc:MakeA(clsA,f,aPos) tpc:SpawnLogsA() end
	local bPos=vector(-1,8)
	if(tpc:ValidB())then if(tpc.b.surface~=f)then tpc:DestroyB() tpc:DestroyLogsB() elseif(tpc.b.name~=clsB)then bPos=tpc.b.position tpc:DestroyB() end end
	if(not tpc:ValidB())then tpc:MakeB(clsB,f,f.find_non_colliding_position(clsB,bPos,0,1,1),true) end --tpc:SpawnLogsB() end
	players.playsound("warp_in",f)
end




local t={name="b1",position=vector(-1,-7)} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,true,true),"warptorio-underground-"..lvEnergy,warptorio.GetPlanetSurface(),warptorio.GetFactorySurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=vector(-1,-7)
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end
local t={name="b2",position=vector(-1,5)} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,false,true),"warptorio-underground-"..lvEnergy,warptorio.GetFactorySurface(),warptorio.GetBoilerSurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=vector(-1,5)
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end

local t={name="b3",position=vector(-1,-7)} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,true,true),"warptorio-underground-"..lvEnergy,warptorio.GetBoilerSurface(),warptorio.GetHarvesterSurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=self.position
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end



local t={name="nw",position=platform.corner.nw} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,true,false),"warptorio-underground-"..lvEnergy,warptorio.GetPlanetSurface(),warptorio.GetFactorySurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=self.position
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end

local t={name="ne",position=platform.corner.ne} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,true,false),"warptorio-underground-"..lvEnergy,warptorio.GetPlanetSurface(),warptorio.GetFactorySurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=self.position
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end
local t={name="sw",position=platform.corner.sw} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,false,false),"warptorio-underground-"..lvEnergy,warptorio.GetPlanetSurface(),warptorio.GetFactorySurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=self.position
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end

local t={name="se",position=platform.corner.se} warptorio.Teleporters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy"),research.level("warptorio-logistics"),research.has("warptorio-dualloader-1") and 2 or 0,research.has("warptorio-triloader") and 2 or 0
	local tpc,cls,fa,fb,desA,desB=warptorio.Teleporters(self.name,false,false),"warptorio-underground-"..lvEnergy,warptorio.GetPlanetSurface(),warptorio.GetFactorySurface()
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() tpc:DestroyLogsA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then tpc:DestroyB() desB=true elseif(tpc.b.surface~=fb)then tpc:DestroyB() tpc:DestroyLogsB() end end
	local pos=self.position
	local size=warptorio.GetTeleporterSize(tpc.main)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(pos,size)) end tpc:MakeA(cls,fa,pos) tpc:SpawnLogsA() end
	if(not tpc:ValidB())then if(not desB)then vector.clean(fb,vector.square(pos,size)) end tpc:MakeB(cls,fb,pos) tpc:SpawnLogsB() end
	tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end


--[[ Harvester Pads ]]--

warptorio.cache["warptorio-harvestportal"]={
	create=function(e) warptorio.InsertCache("power",e) end,
	mined=function(e,ev) for k,v in pairs(gwarptorio.Harvesters)do
		if(v.a==e)then
			for x,y in pairs(ev.buffer.get_contents())do ev.buffer.remove({name=x,count=y}) end
			v.a=nil v:Warpin() ev.buffer.insert{name="warptorio-harvestpad-"..k.."-"..research.level("warptorio-harvester-"..k),count=1}
			return
		elseif(v.b==e)then
			for x,y in pairs(ev.buffer.get_contents())do ev.buffer.remove({name=x,count=y}) end
			v.b=nil ev.buffer.insert{name="warptorio-harvestpad-"..k.."-"..research.level("warptorio-harvester-"..k),count=1}
			local hv=gwarptorio.Harvesters[k] if(hv)then hv:Recall() end
			return
		end
	end end,
	clone=function(e,ev) -- should probably remove power from the cloned accumulator
		for k,v in pairs(gwarptorio.Harvesters)do if(v.a==ev.source)then v.b=e v.a=nil v:Warpin() return elseif(v.b==ev.source)then v.b=e return end end
	end,
	destroy=function(e,ev) warptorio.RemoveCache("power",e) end,
}

warptorio.cache["warptorio-harvestpad-west"]={
	built=function(e,ev)
		local f=e.surface if(f~=warptorio.GetPlanetSurface())then return end
		local pos=e.position
		entity.destroy(e)
		local hv=gwarptorio.Harvesters["west"] if(hv)then hv:Deploy(f,pos) end
	end,
}
warptorio.cache["warptorio-harvestpad-east"]={
	built=function(e,ev)
		local f=e.surface if(f~=warptorio.GetPlanetSurface())then return end
		local pos=e.position
		entity.destroy(e)
		local hv=gwarptorio.Harvesters["east"] if(hv)then hv:Deploy(f,pos) end

	end,
}

for k,v in pairs{"warptorio-harvestportal","warptorio-harvestpad-west","warptorio-harvestpad-east"}do
	for i=0,8,1 do warptorio.cache[v.."-"..i]=warptorio.cache[v] end
end




HARV={} HARV.__index=HARV warptorio.HarvesterMeta=HARV setmetatable(HARV,{__index=tell}) 
function HARV.__init(self,n,pos) self.name=n self.position=pos
	self.deployed=false
	self.deploy_position=nil
	
	gwarptorio.Harvesters[n]=self
end
function HARV:UpgradeEnergy() warptorio.Harvesters[self.name]:Warpin() end
function HARV:Warpin() warptorio.Harvesters[self.name]:Warpin() end
function HARV:GetSize() return gwarptorio.floor.b3["harvest_"..self.name] end
function HARV:GetBaseArea(z) z=z or self:GetSize()-1 return vector.square(self.position,vector(z,z)) end
function HARV:GetDeployArea(z) z=z or self:GetSize()-2 return vector.square(self.deploy_position,vector(z,z)) end
function HARV:Recall() -- recall after portal is mined
	if(not self.deployed)then return false end


	local f=warptorio.GetPlanetSurface()
	local ebs={} for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=self:GetDeployArea()})do if(not v.name:match("warptorio"))then table.insert(ebs,v) end end

	local hf=warptorio.GetHarvesterSurface()
	local harvArea=self:GetBaseArea()

	local tbs={}
	local tcs={} for k,v in pairs(hf.find_tiles_filtered{area=harvArea})do
		local vpos=vector.add(vector.sub(v.position,self.position),self.deploy_position)
		table.insert(tcs,{name=v.name,position=vpos})
		table.insert(tbs,{name="warptorio-red-concrete",position=v.position})
	end
	local dcs={} for k,v in pairs(hf.find_decoratives_filtered{area=self:GetBaseArea()})do
		local vpos=vector.add(vector.sub(v.position,self.position),self.deploy_position)
		table.insert(dcs,{name=v.decorative.name,position=vpos,amount=v.amount})
	end

	local ecs={} for k,v in pairs(hf.find_entities_filtered{area=harvArea,type="character",invert=true})do if(not v.name:match("warptorio"))then table.insert(ecs,v) end end

	f.set_tiles(tcs,true)
	f.create_decoratives{decoratives=dcs}
	hf.clone_entities{entities=ecs,destination_surface=f,destination_offset=vector.add(vector.mul(self.position,-1),self.deploy_position),snap_to_grid=false}

	f.clone_entities{entities=ebs,destination_surface=hf,destination_offset=vector.add(vector.mul(self.deploy_position,-1),self.position),snap_to_grid=false}

	for k,v in pairs(ecs)do entity.destroy(v) end
	for k,v in pairs(ebs)do entity.destroy(v) end

	hf.destroy_decoratives{area=harvArea}

	--vector.LayTiles("warp-tile-concrete",hf,self:GetBaseArea(self:GetSize()+2))
	--vector.LayTiles("warptorio-red-concrete",hf,self:GetBaseArea())
	hf.set_tiles(tbs,true)
	self.deployed=false
end
function HARV:Deploy(surf,pos) -- deploy over a harvester pad
	if(self.deployed)then return false end
	local f=surf if(f~=warptorio.GetPlanetSurface())then game.print("Harvesters can only be placed on the planet") return false end
	game.print("deployed at: " .. serpent.line(pos))
	self.deploy_position=vector.pos(pos)
	local hf=gwarptorio.floor.b3.surface

	local ebs=hf.find_entities_filtered{type="character",invert=true,area=self:GetBaseArea()}

	local planetArea=self:GetDeployArea()

	local tcs={} for x=planetArea[1][1],planetArea[2][1] do for y=planetArea[1][2],planetArea[2][2]do local v=f.get_tile(x,y)
		local vpos=vector.add(vector.sub(vector(x,y),self.deploy_position),self.position)
		table.insert(tcs,{name=v.name,position=vpos})
	end end
	local dcs={} for k,v in pairs(f.find_decoratives_filtered{area=self:GetDeployArea(self:GetSize()-3)})do
		local vpos=vector.add(vector.sub(v.position,self.deploy_position),self.position)
		table.insert(dcs,{name=v.decorative.name,position=vpos,amount=v.amount})
	end
	local ecs={} for k,v in pairs(f.find_entities_filtered{area=planetArea,type="character",invert=true})do if(not v.name:find("warptorio"))then table.insert(ecs,v) end end

	hf.set_tiles(tcs,true)
	hf.create_decoratives{decoratives=dcs}
	f.clone_entities{entities=ecs,destination_surface=hf,destination_offset=vector.mul(vector.sub(self.deploy_position,self.position),-1),snap_to_grid=true}

	vector.LayTiles("warptorio-red-concrete",f,self:GetDeployArea())

	hf.clone_entities{entities=ebs,destination_surface=f,destination_offset=vector.add(vector.mul(self.position,-1),self.deploy_position),snap_to_grid=true}

	for k,v in pairs(ecs)do entity.destroy(v) end
	for k,v in pairs(ebs)do entity.destroy(v) end



	self.deployed=true
end

--[[ Harvester Registers ]]--

warptorio.Harvesters={} setmetatable(warptorio.Harvesters,{__index=warptorio.Harvesters,
	__call=function(t,n,j,m) if(not gwarptorio.Harvesters[n])then new(HARV,n,j,m) end return gwarptorio.Harvesters[n] end,
})

local t={name="west",position=warptorio.platform.harvester.west} warptorio.Harvesters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy")
	local tpc,cls,fa,fb,desA,desB=warptorio.Harvesters(self.name,self.position),"warptorio-harvestportal-"..lvEnergy,warptorio.GetHarvesterSurface()
	local apos=self.position local bpos=self.position
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then fb=tpc.b.surface bpos = tpc.b.position tpc:DestroyB() desB=true end end
	local size=vector(2,2)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(apos,size)) end tpc:MakeA(cls,fa,apos,true) end
	if(desB)then tpc:MakeB(cls,fb,bpos,true) end
	--tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end


local t={name="east",position=warptorio.platform.harvester.east} warptorio.Harvesters[t.name]=t
function t:Warpin() local lvEnergy,lvLogs,lvDual,lvTri=research.level("warptorio-energy")
	local tpc,cls,fa,fb,desA,desB=warptorio.Harvesters(self.name,self.position),"warptorio-harvestportal-"..lvEnergy,warptorio.GetHarvesterSurface()
	local apos=self.position local bpos=self.position
	if(tpc:ValidA())then if(tpc.a.name~=cls)then tpc:DestroyA() desA=true elseif(tpc.a.surface~=fa)then tpc:DestroyA() end end
	if(tpc:ValidB())then if(tpc.b.name~=cls)then fb=tpc.b.surface bpos = tpc.b.position tpc:DestroyB() desB=true end end
	local size=vector(2,2)
	if(not tpc:ValidA())then if(not desA)then vector.clean(fa,vector.square(apos,size)) end tpc:MakeA(cls,fa,apos,true) end
	if(desB)then tpc:MakeB(cls,fb,bpos,true) end
	--tpc:ConnectCircuit()
	players.playsound("warp_in",fa) players.playsound("warp_in",fb)
end


--[[ Surface Platforms ]]--



local FLOOR={} FLOOR.__index=FLOOR warptorio.FloorMeta=FLOOR
function FLOOR:__init(n,z) self.name=n gwarptorio.floor[n]=self self.size=z self.position=vector(-1,-1) end
function FLOOR:CheckRadar() if(research.has("warptorio-charting") and not isvalid(self.radar))then self.radar=entity.protect(entity.create(self.surface,"warptorio-invisradar",vector(-1,-1))) end end
function FLOOR:MakeEmptySurface(n) if(self.surface and self.surface.valid)then return self.surface end
	local f=game.create_surface((n or ("warpfloor_" .. self.name)),{default_enable_all_autoplace_controls=false,width=32*12,height=32*12,
		autoplace_settings={entity={treat_missing_as_default=false},tile={treat_missing_as_default=false},decorative={treat_missing_as_default=false}, }, starting_area="none", })

	f.daytime=0 f.always_day=true f.request_to_generate_chunks({0,0},16) f.force_generate_chunk_requests() f.destroy_decoratives({}) for k,v in pairs(f.find_entities())do entity.destroy(v) end
	local area=vector.area(vector(-32*8,-32*8),vector(32*8*2,32*8*2)) vector.LayTiles("out-of-map",f,area) self.surface=f
end

function warptorio.init.floors()
	if(not gwarptorio.floor)then gwarptorio.floor={} end
	local m=gwarptorio.floor.main if(not m)then m=new(FLOOR,"main",8) m.surface=game.surfaces["nauvis"] end
	local m=gwarptorio.floor.b1 if(not m)then m=new(FLOOR,"b1",16) m:MakeEmptySurface() end
	local m=gwarptorio.floor.b2 if(not m)then m=new(FLOOR,"b2",17) m:MakeEmptySurface() end
	local m=gwarptorio.floor.b3 if(not m)then m=new(FLOOR,"b3",17) m.ovalsize={x=19,y=17} m:MakeEmptySurface() end
	warptorio.BuildPlatform()
	warptorio.BuildB1()
	warptorio.BuildB2()
	warptorio.BuildB3()
end
function warptorio.RebuildFloors() warptorio.init.floors() end

function warptorio.BuildPlatform()
	local m=gwarptorio.floor.main local f=m.surface local z=m.size and m.size or 8
	local area=vector.square(vector(-0.5,-0.5),vector(z,z))
	vector.clearFiltered(f,area)
	vector.LayTiles("warp-tile-concrete",f,area)
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-1,-1),vector(4,4)))

	local rSize=research.level("warptorio-platform-size")
	local rLogs=research.level("warptorio-logistics")
	local rFacSize=research.level("warptorio-factory")
	local rTpGate=research.has("warptorio-teleporter-portal")

	if(rSize>0)then local ltm,ltp
		if(rFacSize==0 and rLogs==0)then ltm=vector(2,2) else ltm=warptorio.GetTeleporterHazard(true) end
		if(not rTpGate and rLogs==0)then ltp=vector(2,2) else ltp=warptorio.GetTeleporterHazard(false) end
		vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b1.position,ltm))
		vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.offworld.position,ltp))
	end
	if(rSize>=6)then for k,v in pairs(platform.railCorner)do local o=platform.railOffset[k] vector.LayTiles("hazard-concrete-left",f,vector.square(v+o,vector(1,1))) end end -- trains

	for u,c in pairs(platform.corner)do
		local lvc=research.level("warptorio-turret-"..u.."")
		if(lvc>0)then local rad=math.floor((10+lvc*6))
			for k,v in pairs(f.find_entities_filtered{type="character",force={game.forces.player,game.forces.enemy},invert=true,position=c,radius=math.floor(rad/2)})do entity.tryclean(v) end
			vector.LayCircle("warp-tile-concrete",f,vector.circleEx(c,rad))
			vector.LayTiles("hazard-concrete-left",f,vector.square(c,warptorio.GetTeleporterHazard(false)))
		end
	end
end

function warptorio.BuildB1()
	local m=gwarptorio.floor.b1 local f=m.surface local z=m.size or 16 local area=vector.square(vector(-0.5,-0.5),vector(z,z))
	local rFacSize=research.level("warptorio-factory")
	local rBoiler=research.has("warptorio-boiler-1")
	local rLogs=research.level("warptorio-logistics")
	local rBridge=research.level("warptorio-bridgesize")
	vector.LayTiles("warp-tile-concrete",f,area)
	vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b2.position,((not rBoiler and rLogs==0) and ltp==vector(3,3) or warptorio.GetTeleporterHazard(true)))) -- Boiler
	vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b1.position,warptorio.GetTeleporterHazard(true))) -- factory entrance
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-0.5,-0.5),vector(2,2))) -- beacon
	local rc={} for k in pairs(platform.corner)do local rclv=research.level("warptorio-turret-"..k) if(rclv>0 or research.has("warptorio-turret-"..k.."-0"))then rc[k]=rclv end end
	local zMainWidth=10+rBridge*2
	local zMainHeight=59+rBridge*2-2
	local zLeg=6+rBridge*4
	local whas=(rc.nw or rc.sw) local nhas=(rc.nw or rc.ne) local ehas=(rc.ne or rc.se) local shas=(rc.sw or rc.se)
	if(nhas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,platform.side.north.y/2),vector(zMainWidth,zMainHeight))) end
	if(shas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,platform.side.south.y/2),vector(zMainWidth,zMainHeight))) end
	if(ehas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/2,-1),vector(zMainHeight,zMainWidth))) end
	if(whas)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/2,-1),vector(zMainHeight,zMainWidth))) end
	if(nhas and rc.nw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/2,platform.side.north.y),vector(zMainHeight,zLeg))) end
	if(nhas and rc.ne)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/2,platform.side.north.y),vector(zMainHeight,zLeg))) end
	if(shas and rc.sw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/2,platform.side.south.y),vector(zMainHeight,zLeg))) end
	if(shas and rc.se)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/2,platform.side.south.y),vector(zMainHeight,zLeg))) end
	if(ehas and rc.ne)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x,platform.side.north.y/2),vector(zLeg,zMainHeight))) end
	if(ehas and rc.se)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x,platform.side.south.y/2),vector(zLeg,zMainHeight))) end
	if(whas and rc.nw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x,platform.side.north.y/2),vector(zLeg,zMainHeight))) end
	if(whas and rc.sw)then vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x,platform.side.south.y/2),vector(zLeg,zMainHeight))) end

	for k,c in pairs(platform.corner)do if(rc[k])then local zx=(10+rc[k]*6)
		vector.LayTiles("warp-tile-concrete",f,vector.square(c,vector(zx,zx))) vector.LayTiles("hazard-concrete-left",f,vector.square(c,warptorio.GetTeleporterHazard(false)))
	end end

	local zgWidth=128-16
	local zgHeight=96-12
	local zgLegHeight=17
	local zgLegWidth=10

	if(research.has("warptorio-factory-n"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.north+vector(-1,-zgLegHeight-zgHeight/2-1),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.north+vector(9-1,-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.north+vector(-9-1,-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(research.has("warptorio-factory-s"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.south+vector(-1,zgLegHeight+zgHeight/2),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.south+vector(9-1,zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.south+vector(-9-1,zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(research.has("warptorio-factory-w"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.west+vector(-zgLegHeight-zgHeight/2-1,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.west+vector(-zgLegHeight/2-1,9-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.west+vector(-zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end if(research.has("warptorio-factory-e"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.east+vector(zgLegHeight+zgHeight/2,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.east+vector(zgLegHeight/2-1,9-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(platform.side.east+vector(zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end

	if(rFacSize>=7)then for k,rv in pairs(platform.railOffset)do local rc=platform.railCorner[k] -- trains
		local rvx=platform.railLoader[k]
		vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x,rc.y),vector(1,1)))
		vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x+rvx[1][1],rc.y+rvx[1][2]),vector(1,1)))
		vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x+rvx[2][1],rc.y+rvx[2][2]),vector(1,1)))
	end end

	players.playsound("warp_in",f)
end

function warptorio.BuildB2() local m=gwarptorio.floor.b2 local f=m.surface local z=m.size
	local rBoiler=research.level("warptorio-boiler")
	local rLogs=research.level("warptorio-logistics")
	local rWater=research.level("warptorio-boiler-water")

	vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,-1),vector((z/3)*2,(z*2))))
	vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,-1),vector((z*2),(z/3)*2)))

	if(rWater>0)then
		local zx=2+rWater
		vector.LayTiles("deepwater",f,vector.square(vector(z/3+((zx/2)+1)-0.5,z/3+((zx/2)+1)-0.5),vector(zx,zx)))
		vector.LayTiles("deepwater",f,vector.square(vector(-z/3-((zx/2)+1)-0.5,-z/3-((zx/2)+1)-0.5),vector(zx,zx)))
		vector.LayTiles("deepwater",f,vector.square(vector(-z/3-((zx/2)+1)-0.5,z/3+((zx/2)+1)-0.5),vector(zx,zx)))
		vector.LayTiles("deepwater",f,vector.square(vector(z/3+((zx/2)+1)-0.5,-z/3-((zx/2)+1)-0.5),vector(zx,zx)))
	end
	local rgNorth=research.has("warptorio-boiler-n")
	local rgSouth=research.has("warptorio-boiler-s")
	local rgEast=research.has("warptorio-boiler-e")
	local rgWest=research.has("warptorio-boiler-w")

	local zgWidth=96
	local zgHeight=64
	local zgLegHeight=12
	local zgLegWidth=10

	if(rgNorth)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,-z-zgLegHeight-(zgHeight/2)-1),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(7-1,-z-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-9-1,-z-zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(rgSouth)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1,z+zgLegHeight+(zgHeight/2)),vector(zgWidth,zgHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(7-1,z+zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-9-1,z+zgLegHeight/2-1),vector(zgLegWidth,zgLegHeight)))
	end if(rgEast)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(z+zgLegHeight+(zgHeight/2),-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(z+zgLegHeight/2-1,7-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(z+zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end if(rgWest)then
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-z-zgLegHeight-(zgHeight/2)-1,-1),vector(zgHeight,zgWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-z-zgLegHeight/2-1,7-1),vector(zgLegHeight,zgLegWidth)))
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-z-zgLegHeight/2-1,-9-1),vector(zgLegHeight,zgLegWidth)))
	end

	vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b2.position,((not rBoiler and rLogs==0) and ltp==vector(3,3) or warptorio.GetTeleporterHazard(true)))) -- Boiler
	vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b1.position,warptorio.GetTeleporterHazard(true))) -- factory entrance
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-1,-1),vector(2,2))) -- beacon

	--warptorio.LayFloor("hazard-concrete-left",f,vector(vx,4,vw,3) -- entrance
	--warptorio.LayFloor("hazard-concrete-left",f,-2,-2,3,3) -- old center
	players.playsound("warp_in",f.name)
end

function warptorio.BuildHarvestCorner(cz,k,v)
	if(research.has("warptorio-harvester-"..k.."-gate"))then
		vector.LayTiles("warp-tile-concrete",f,vector.square(v/3*2,vector(cz*1.25,cz*1.25)))
		vector.LayTiles("warptorio-red-concrete",f,vector.square(v/3*2,vector(cz,cz)))
		vector.LayTiles("hazard-concrete-left",f,vector.square((v/3*2),vector(2,2)))
	end 
end


function warptorio.BuildB3()
	local m=gwarptorio.floor.b3 local f=m.surface local z=m.size

	local cirMaxWidth=128+8
	local cirHeight=17 --64+4 --17 --

	local minCir=vector(22,17)
	local maxCir=vector(128+8,64+4)
	local ovSize=vector(vector.x(m.ovalsize),vector.y(m.ovalsize)) -- vector(cirWidth,cirHeight)

	vector.LayCircle("warp-tile-concrete",f,vector.oval(vector(-1,-1),ovSize))


--[[ for 4 corners

	--local zx=(platform.side.east.x+platform.side.west.x)/3*2
	--vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.east.x/3*2,-1),vector(6,platform.side.south.y+3)))
	--vector.LayTiles("warp-tile-concrete",f,vector.square(vector(platform.side.west.x/3*2,-1),vector(6,platform.side.south.y+3)))
	local cz=16
	for k,v in pairs(platform.corner)do warptorio.BuildHarvestCorner(cz,k,v) end
]]

--[[ for 2 sides ]]
	local vz=cirMaxWidth
	--local ez=m.harvestSize or 10 -- harvester size max 47
	local hvMax=47
	local vzx=vz/2 local hvx=hvMax/2 local hvy=hvMax/8

	if(research.has("warptorio-harvester-west-1"))then
		local ez=m.harvest_west or 10
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1-vz/4,-1),vector(vz/2+hvMax/2,4)))
		local westPos=warptorio.platform.harvester.west --vector(-(vzx+(hvx-hvy))+0.5,-0.5)
		local hve=gwarptorio.Harvesters.west
		if(not hve or not hve.deployed)then
			vector.LayTiles("warp-tile-concrete",f,vector.square(westPos,vector(ez+2,ez+2)))
			vector.LayTiles("warptorio-red-concrete",f,vector.square(westPos,vector(ez-2,ez-2)))
		end
	end if(research.has("warptorio-harvester-east-1"))then
		local ez=m.harvest_east or 10
		vector.LayTiles("warp-tile-concrete",f,vector.square(vector(-1+vz/4,-1),vector(vz/2+hvMax/2,4)))
		local eastPos=warptorio.platform.harvester.east --vector(vzx+(hvx-hvy),-0.5)
		local hve=gwarptorio.Harvesters.east
		if(not hve or not hve.deployed)then
			vector.LayTiles("warp-tile-concrete",f,vector.square(eastPos,vector(ez+2,ez+2)))
			vector.LayTiles("warptorio-red-concrete",f,vector.square(eastPos,vector(ez-2,ez-2)))
		end
	end

--[[ ]]

	vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b3.position,warptorio.GetTeleporterHazard(true))) -- entry
	vector.LayTiles("hazard-concrete-left",f,vector.square(warptorio.Teleporters.b2.position,warptorio.GetTeleporterHazard(true))) -- b4 ??
	vector.LayTiles("hazard-concrete-left",f,vector.square(vector(-1,-1),vector(2,2))) -- beacon
end

-- --------
-- Logistics system

function warptorio.GetSteamTemperature(v) local t={name="steam",amount=1,temperature=15} local c=v.remove_fluid(t)
	if(c~=0)then return 15 else t.temperature=165 c=v.remove_fluid(t) if(c~=0)then return 165 else t.temperature=500 c=v.remove_fluid(t) if(c~=0)then return 500 end end end return 15 end

local logz={} warptorio.Logistics=logz
function logz.BalanceEnergy(a,b) local x=(a.energy+b.energy)/2 a.energy,b.energy=x,x end
function logz.BalanceHeat(a,b) local x=(a.temperature+b.temperature)/2 a.temperature,b.temperature=x,x end
function logz.MoveContainer(a,b) local ac,bc=a.get_inventory(defines.inventory.chest),b.get_inventory(defines.inventory.chest)
	for k,v in pairs(ac.get_contents())do local t={name=k,count=v} local c=bc.insert(t) if(c>0)then ac.remove({name=k,count=c}) end end end

function logz.BalanceFluid(a,b) local af,bf=a.get_fluid_contents(),b.get_fluid_contents() local aff,afv=table.First(af) local bff,bfv=table.First(bf) afv=afv or 0 bfv=bfv or 0
	if((not aff and not bff) or (aff and bff and aff~=bff) or (afv==0 and bfv==0) or (afv==bfv))then return end if(not aff)then aff=bff elseif(not bff)then bff=aff end local v=(afv+bfv)/2
	if(aff=="steam")then local temp=15 local at=warptorio.GetSteamTemperature(a) local bt=warptorio.GetSteamTemperature(b) temp=math.max(at,bt)
		a.clear_fluid_inside() b.clear_fluid_inside() a.insert_fluid({name=aff,amount=v,temperature=temp}) b.insert_fluid({name=bff,amount=v,temperature=temp})
	else a.clear_fluid_inside() b.clear_fluid_inside() a.insert_fluid({name=aff,amount=v}) b.insert_fluid({name=bff,amount=v}) end
end
function logz.MoveFluid(a,b) local af,bf=a.get_fluid_contents(),b.get_fluid_contents() local aff,afv=table.First(af) local bff,bfv=table.First(bf)
	if((not aff and not bff) or (aff and bff and aff~=bff) or (afv==0 and bfv==0))then return end
	if(aff=="steam")then
		local temp=15 local at=warptorio.GetSteamTemperature(a) local bt=warptorio.GetSteamTemperature(b) temp=math.max(at,bt)
		local c=b.insert_fluid({name=aff,amount=afv,temperature=temp}) if(c>0)then a.remove_fluid{name=aff,amount=c} end
	else
		local c=b.insert_fluid({name=aff,amount=afv}) if(c>0)then a.remove_fluid{name=aff,amount=c} end
	end
end

function warptorio.BalanceLogistics(a,b,bal) if(not a or not b or not a.valid or not b.valid)then return end -- cost is removed because it's derp
	if(a.type=="accumulator" and b.type==a.type)then -- transfer energy
		warptorio.Logistics.BalanceEnergy(a,b)
	elseif((a.type=="container" or b.type=="logistic-container") and b.type==a.type)then -- transfer items
		warptorio.Logistics.MoveContainer(a,b)
	elseif(a.type=="pipe-to-ground" and b.type==a.type)then -- transfer fluids
		if(bal==true)then warptorio.Logistics.BalanceFluid(a,b)
		else warptorio.Logistics.MoveFluid(a,b)
		end
	elseif(a.temperature and b.temperature)then
		warptorio.Logistics.BalanceHeat(a,b)
	end
end


function warptorio.DoTeleporterTick(k,v)
	for i,e in pairs({v.a,v.b})do
		local o=(i==1 and v.b or v.a) local x=e.position local xxx=math.abs(x.x) local xxy=math.abs(x.y) local p={}
		for idx,ply in pairs(game.players)do
		if(ply.surface==e.surface and vector.inarea(ply.position,vector.area(vector(x.x-1.35,x.y-1.35),vector(x.x+1.35,x.y+1.35)) ) )then table.insert(p,ply) end end
		--function warptorio.isinbbox(pos,pos1,pos2) return not ( (pos.x<pos1.x or pos.y<pos1.y) or (pos.x>pos2.x or pos.y>pos2.y) ) end
		--local p=e.surface.find_entities_filtered{area={{x.x-1.2,x.y-1.2},{x.x+1.2,x.y+1.2}},type="character"}
		-- local dist=math.sqrt((x.x-pp.x)^2 + (x.y-pp.y)^2)
		for a,b in pairs(p)do
			local inv=b.get_main_inventory().get_item_count()
			players.playsound("teleport",e.surface,e.position) players.playsound("teleport",o.surface,o.position)
			local w=b.walking_state
			local ox=o.position
			local mp=2 if(not b.character)then mp=3 end
			if(not w.walking)then local cp=b.position local xd,yd=(x.x-cp.x),(x.y-cp.y) entity.safeteleport(b,o.surface,vector(ox.x+xd*mp,ox.y+yd*mp))
			else local td=warptorio.teleDir[w.direction] entity.safeteleport(b,o.surface,vector(ox.x+td[1]*mp,ox.y+td[2]*mp)) end
		end
	end
end
warptorio.teleDir={[0]={0,-1},[1]={1,-1},[2]={1,0},[3]={1,1},[4]={0,1},[5]={-1,1},[6]={-1,0},[7]={-1,-1}}
function warptorio.on_tick.Teleporters(e)
	for k,v in pairs(gwarptorio.Teleporters)do if(v:ValidA() and v:ValidB())then warptorio.DoTeleporterTick(k,v) end end
	for k,v in pairs(gwarptorio.Harvesters)do if(v:ValidA() and v:ValidB())then warptorio.DoTeleporterTick(k,v) end end
end








-- --------
-- Gui


function warptorio.on_gui_selection_state_changed.gui(ev) local p,dm=game.players[event.player_index],derma.getderma(ev.element.name) if(dm and dm.changed)then dm:changed(p,ev) end end

function warptorio.IncrementAbility(c,m) c=c or 2.5 m=m or 5 local n=(gwarptorio.ability_uses or 0)+1 gwarptorio.ability_uses=n gwarptorio.ability_next=game.tick+60*60*(m+(n)*c)
	warptorio.derma.uses() warptorio.derma.cooldown()
end

function warptorio.PlayerCanStartWarp(p) for k,v in pairs(gwarptorio.floor)do if(v.surface==p.surface)then return true end end return false end
function warptorio.on_gui_click.gui(ev) local derm=derma.getderma(ev.element.name) if(derm and derm.click)then return derm:click(game.players[ev.player_index]) end end

derma={}
derma.frame="warptorio_frame"
derma.rows={"warptorio_row1","warptorio_row2"}
function derma.getframe(ply) local gx=ply.gui.left[derma.frame] if(gx==nil)then gx=ply.gui.left.add{name=derma.frame,type="flow",direction="vertical"} end return gx end
function derma.getrow(ply,i) local f=derma.getframe(ply) local rn=derma.rows[i] local fr=f[rn] if(not fr)then fr=f.add{name=rn,type="flow",direction="horizontal"} end return fr end
function derma.getrows(ply) local f=derma.getframe(ply) local t={} for i=1,table_size(derma.rows),1 do table.insert(t,derma.getrow(ply,i)) end return t end
function derma.getcontrol(ply,n) for k,v in pairs(derma.getrows(ply))do if(k==n)then return v end end end
function derma.setlabel(n,v,...) for k,ply in pairs(game.players)do local c=derma.getcontrol(ply,n) if(c)then return c.set_label(...) end end end
function derma.control(h,n,y,dft) local r=h[n] if(not r)then dft=dft or {} dft.name=n dft.type=y r=h.add(dft) end return r end
function derma.update(wname,...) local c=warptorio.derma[wname] if(c)then c(nil,...) end end
function derma.getderma(cname,...) for k,v in pairs(warptorio.derma)do if(v.name==cname)then return v end end end
function derma.GuiControl(name,type) local t={name=name,type=type}
	return setmetatable(t,{__index=t,__call=function(self,p,...) if(not p)then for k,v in pairs(game.players)do self:update(v,...) end else self:update(p,...) end end})
end


function warptorio.ResetGui(p) if(not p)then for k,v in pairs(game.players)do warptorio.MakeGui(v) end else warptorio.MakeGui(v) end end

function warptorio.MakeGui(p)
	derma.getrow(p,1).clear()
	warptorio.derma.warpbtn(p)
	warptorio.derma.time_passed(p)
	warptorio.derma.charge_time(p)
	warptorio.derma.warpzone(p)
	warptorio.derma.homeworld(p)

	derma.getrow(p,2).clear()
	warptorio.derma.stabilizer(p)
	warptorio.derma.radar(p)
	warptorio.derma.accelerator(p)
	warptorio.derma.cooldown(p)
	warptorio.derma.uses(p)

end


warptorio.derma={} local wderma=warptorio.derma

wderma.warpbtn=derma.GuiControl("warptorio_warpbutton","button")
function wderma.warpbtn:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.warpbtn:update(p) local r=self:get(p)
	if(table_size(game.players)>1)then r.caption={"warptorio.button-votewarp","-"} else r.caption={"warptorio.button-warp","-"} end -- (gwarptorio.votewarp and gwarptorio.votewarp or 
end
function wderma.warpbtn:click(ply,ev)
		if(gwarptorio.warp_charging<1)then local c=table_size(game.players)
			if(c>1 and settings.global["warptorio_votewarp_multi"].value>0)then --votewarp
				local vct={} for k,v in pairs(c)do if(v and v.valid)then table.insert(vct) end end
				local vcn=math.floor(table_size(vct)*settings.global["warptorio_votewarp_multi"].value)
				if(table_size(gwarptorio.votewarp)>=vcn)then
					gwarptorio.warp_charge_start_tick = game.tick
					gwarptorio.warp_charging = 1
					game.print(ply.name .. " started the warpout procedure.")
					for k,v in pairs(game.players)do players.playsound("reactor-stabilized") end
				else
					table.insert(gwarptorio.votewarp,ply)
					warptorio.updatelabel("warptorio_home","Votewarp (" .. gwarptorio.votewarp .. "/" .. vcn .. ")")
					for k,v in pairs(game.players)do warptorio.playsound("teleport",v.surface.name,v.position) end
					game.print(ply.name .. " wants to Warp. " .. (vcn-gwarptorio.votewarp) .. " more votes")
				end
			elseif(warptorio.PlayerCanStartWarp(ply))then
				gwarptorio.warp_charge_start_tick = game.tick
				gwarptorio.warp_charging = 1
				for k,v in pairs(game.players)do players.playsound("reactor-stabilized") end
			else
				ply.print("You must be on the same planet as the platform to warp")
			end
		end
end

wderma.warptgt=derma.GuiControl("warptorio_warptarget","drop-down")
function wderma.warptgt:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.warptgt:update(p) local r=self:get(p) local tgl={"(Random)"}
	if(gwarptorio.homeworld)then table.insert(tgl,"(Homeworld)") end if(research.has("charting"))then for k,v in pairs(warptorio.Planets)do table.insert(tgl,v.key) end end r.items=tgl
end
function wderma.warptgt:changed(p,ev) local r=self:get(p)
	local s=r.items[r.selected_index] if(not s)then return end local sx=s:lower()
	if(sx=="(random)")then gwarptorio.planet_target=nil elseif(sx=="(homeworld)")then gwarptorio.planet_target="home" else gwarptorio.planet_target=sx end
	game.print("Selected Planet: " .. s)
end

wderma.time_passed=derma.GuiControl("warptorio_time_passed","label")
function wderma.time_passed:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.time_passed:update(p) local r=self:get(p) r.caption={"warptorio.time_passed",util.formattime(gwarptorio.time_passed or 0)} end

wderma.charge_time=derma.GuiControl("warptorio_charge_time","label")
function wderma.charge_time:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.charge_time:update(p,val) local r=self:get(p)
	if(gwarptorio.warp_charging>=1)then
		r.caption={"warptorio.warp-in",util.formattime(val or (gwarptorio.warp_time_left or 0))}
	else
		r.caption={"warptorio.charge_time",util.formattime(val or (gwarptorio.warp_charge_time or 0)*60)}
	end
end

wderma.warpzone=derma.GuiControl("warptorio_warpzone","label")
function wderma.warpzone:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.warpzone:update(p) local r=self:get(p) r.caption={"warptorio.warpzone",gwarptorio.warpzone} end

wderma.autowarp=derma.GuiControl("warptorio_autowarp","label")
function wderma.autowarp:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.autowarp:update(p) local r=self:get(p)
	if(warptorio.IsAutowarpEnabled())then r.caption={"warptorio.autowarp-in", util.formattime(gwarptorio.warp_auto_end)} else r.caption="" end
end


local rsHomeworld=0
local rsHomeTimer=0

wderma.homeworld=derma.GuiControl("warptorio_home","button")
function wderma.homeworld:get(p) return derma.control(derma.getrow(p,1),self.name,self.type) end
function wderma.homeworld:update(p) local r=self:get(p) r.caption={"warptorio.button_homeworld"} end
function wderma.homeworld:click(p)
	if(rsHomeTimer>game.tick)then
		warptorio.updatelabel("warptorio_home","Confirm ? .. " .. util.formattime(rsHomeTimer-game.tick))
	elseif(gwarptorio.homeworld)then
		warptorio.updatelabel("warptorio_home","Settle")
	end

		if(gwarptorio.homeworld)then
			if(rsHomeTimer<game.tick)then
				rsHomeTimer=game.tick+(60*5)
			else
				gwarptorio.homeworld=gwarptorio.warpzone gwarptorio.floor.home.surface=gwarptorio.floor.main.surface
				rsHomeTimer=0 warptorio.derma.homeworld() --warptorio.updatelabel("warptorio_home","Settle")
				players.playsound("warp_in",f.name)
				game.print("Homeworld Set.")
			end
		end

end

wderma.stabilizer=derma.GuiControl("warptorio_stabilizer","button")
function wderma.stabilizer:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.stabilizer:update(p) local r=self:get(p) r.caption={"warptorio.button_stabilizer"} end
function wderma.stabilizer:click(p)
	if(game.tick<(gwarptorio.ability_next or 0) or not research.has("warp_reactor"))then return end
	warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value,settings.global["warptorio_ability_cooldown"].value)
	game.forces["enemy"].evolution_factor=0	
	gwarptorio.pollution_amount = 1.25
	gwarptorio.pollution_expansion = 1.5
	local f=warptorio.GetPlanetSurface()
	f.clear_pollution()
	if(gwarptorio.warp_reactor)then f.set_multi_command{command={type=defines.command.flee, from=gwarptorio.warp_reactor}, unit_count=1000, unit_search_distance=500} end
	warptorio.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Stabilized")
end

wderma.accelerator=derma.GuiControl("warptorio_accelerator","button")
function wderma.accelerator:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.accelerator:update(p) local r=self:get(p) r.caption={"warptorio.button_accelerator"} end
function wderma.accelerator:click(p)
	if(game.tick<(gwarptorio.ability_next or 0) or gwarptorio.warp_charge_time<=10)then return end
	warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value,settings.global["warptorio_ability_cooldown"].value)
	gwarptorio.warp_charge_time=math.max(math.ceil(gwarptorio.warp_charge_time^0.8),10)
	if(gwarptorio.warp_charging~=1)then warptorio.derma.charge_time() end --,gwarptorio.warp_charge_time*60) end

	local f=warptorio.GetPlanetSurface()
	warptorio.playsound("reactor-stabilized", f)
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
	local f=warptorio.GetPlanetSurface()
	game.forces.player.chart(f,{lefttop={x=-64-128*n,y=-64-128*n},rightbottom={x=64+128*n,y=64+128*n}})
	players.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Scanner Sweep")
end

wderma.cooldown=derma.GuiControl("warptorio_ability_cooldown","label")
function wderma.cooldown:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.cooldown:update(p) local r=self:get(p)
	local tl=math.max((gwarptorio.ability_next or 0)-game.tick,0) if(tl<=0)then r.caption={"warptorio.ability_ready"} else r.caption={"warptorio.ability_cooldown",util.formattime(tl)} end
end

wderma.uses=derma.GuiControl("warptorio_ability_uses","label")
function wderma.uses:get(p) return derma.control(derma.getrow(p,2),self.name,self.type) end
function wderma.uses:update(p) local r=self:get(p) r.caption={"warptorio.ability_uses",gwarptorio.ability_uses or 0} end

function warptorio.on_tick.timers(tick) if(tick%60==0)then
	if(gwarptorio.warp_charging==1)then
		gwarptorio.warp_time_left=(60*gwarptorio.warp_charge_time) - (tick-gwarptorio.warp_charge_start_tick)
		if(gwarptorio.warp_time_left<=0)then warptorio.Warpout() gwarptorio.warp_last=tick end
	end
	gwarptorio.time_passed=tick-gwarptorio.time_spent_start_tick
	warptorio.derma.time_passed()
	warptorio.derma.charge_time()

	if(warptorio.IsAutowarpEnabled())then
		gwarptorio.warp_auto_end=(60*gwarptorio.warp_auto_time+gwarptorio.warp_last)-(tick-gwarptorio.warp_last)
		if(gwarptorio.warp_auto_end<=0)then warptorio.Warpout() gwarptorio.warp_last=tick end
	end
	warptorio.derma.autowarp()

	if(research.has("warptorio-charting") or research.has("warptorio-accelerator") or research.has("warptorio-stabilizer"))then warptorio.derma.cooldown() end

end end
function warptorio.on_tick.charge_countdown(tick) if(gwarptorio.warp_charging<1 and gwarptorio.warp_charge_time>30)then
	local r=60-(research.level("warptorio-reactor")*3) if(tick%(r*5)==0)then gwarptorio.warp_charge_time=math.max(gwarptorio.warp_charge_time-1,30) warptorio.derma.charge_time() end
end end


function warptorio.on_tick.pollution(tick) if(tick%(warptorio.settings("pollution_tickrate")*60)==0)then
	local f=warptorio.GetPlanetSurface()
	if(not f or not f.valid)then return end
	if(settings.global["warptorio_pollution_disable"].value~=true)then
		f.pollute({-1,-1},gwarptorio.pollution_amount)
		gwarptorio.pollution_amount = math.min( gwarptorio.pollution_amount+(gwarptorio.pollution_amount ^ settings.global['warptorio_pollution_exponent'].value)*settings.global["warptorio_pollution_multiplier"].value, 1000000)
	end

	local m=gwarptorio.floor
	local pb1=m.b1.surface.get_total_pollution()
	local pb2=m.b2.surface.get_total_pollution()
	f.pollute({-1,-1},pb1+pb2)
	m.b1.surface.clear_pollution()
	m.b2.surface.clear_pollution()
	
	if(settings.global["warptorio_biter_disable"].value~=true)then
		gwarptorio.pollution_expansion = math.min( gwarptorio.pollution_expansion * settings.global["warptorio_biter_expansion"].value, 60*60*settings.global["warptorio_biter_redux"].value )
		game.map_settings.enemy_expansion.min_expansion_cooldown = math.max((60*60*settings.global["warptorio_biter_min"].value)-gwarptorio.pollution_expansion,60*60*1)
		game.map_settings.enemy_expansion.max_expansion_cooldown = math.max( ((60*60*settings.global["warptorio_biter_max"].value)-gwarptorio.pollution_expansion)+1,60*60*1)
		--game.print("pol: " .. game.map_settings.enemy_expansion.min_expansion_cooldown)
		local pt=(gwarptorio.time_passed/60)/60
		if(pt>settings.global["warptorio_biter_wavestart"].value)then pt=pt-settings.global["warptorio_biter_wavestart"].value
			local el=math.ceil(pt*settings.global["warptorio_biter_wavesize"].value)
			local erng=math.ceil(pt*settings.global["warptorio_biter_waverng"].value)
			local bmax=settings.global["warptorio_biter_wavesizemax"].value if(bmax>0)then el=math.min(el,bmax) end
			if(math.random(1,math.max(math.min(settings.global["warptorio_biter_wavemax"].value-erng,settings.global["warptorio_biter_wavemin"].value),1))<=1)then
				f.set_multi_command{command={type=defines.command.attack_area, destination={0,0},radius=128}, unit_count=el}
			end
		end
	end
end end


function warptorio.on_tick.warpalarm(tick) if(tick%120==0)then
	if( (gwarptorio.warp_charging == 1 and gwarptorio.warp_time_left <= 3600) or (warptorio.IsAutowarpEnabled() and gwarptorio.warp_auto_end <=3600) )then 
		players.playsound("warp_alarm")
	end
end end



-- Initialize Players
function warptorio.InitPlayer(e)
	local i=e.player_index
	local p=game.players[i]
	warptorio.MakeGui(p)
	--if(i==1)then warptorio.PostPlayerInit() end
	entity.safeteleport(p,warptorio.GetPlanetSurface(),vector(0,-5))
end script.on_event(defines.events.on_player_created,warptorio.InitPlayer)

--[[
function warptorio.OnPlayerRemoved(ev) local i=ev.player_index
end script.on_event(defines.events.on_player_removed,warptorio.OnPlayerRemoved)
function warptorio.OnPlayerPreRemoved(ev) local i=ev.player_index
end script.on_event(defines.events.on_pre_player_removed,warptorio.OnPlayerPreRemoved)
function warptorio.OnPlayerLeft(ev) local i=ev.player_index
end script.on_event(defines.events.on_player_left_game,warptorio.OnPlayerLeft)
function warptorio.OnPlayerPreLeft(ev) local i=ev.player_index
end script.on_event(defines.events.on_pre_player_left_game,warptorio.OnPlayerPreLeft)
]]

function warptorio.OnPlayerJoined(ev)
	local i=ev.player_index local p=game.players[i]
	warptorio.MakeGui(p)
	if(p and p.valid)then entity.safeteleport(p,warptorio.GetPlanetSurface(),{0,-5}) end
end script.on_event(defines.events.on_player_joined_game,warptorio.OnPlayerJoined)



function warptorio.OnCapsuleUse(ev)
	if(ev.item.name=="warptorio-townportal")then
		local p=game.players[ev.player_index]
		if(p and p.valid)then
			entity.safeteleport(p,gwarptorio.floor.main.surface,vector(0,-5))
			players.playsound("teleport",p.surface,p.position)
			players.playsound("teleport",gwarptorio.floor.main.surface,vector(0,-5))
		end
	end
end script.on_event(defines.events.on_player_used_capsule,warptorio.OnCapsuleUse)

function warptorio.OnPlayerRespawned(event) -- teleport to warp platform on respawn
	--local i=ev.player_index local player_port=ev.player_port
	local cf=gwarptorio.floor.main.surface local gp=game.players[event.player_index]
	if(gp.surface~=cf)then local pos=cf.find_non_colliding_position("character",{0,-5},0,1,1) gp.teleport(pos,cf) end
end script.on_event(defines.events.on_player_respawned,warptorio.OnPlayerRespawned)

for k,v in pairs{"on_built_entity","on_robot_built_entity","script_raised_built","script_raised_revive","on_player_mined_entity","on_entity_died","on_entity_cloned","on_chunk_deleted","on_chunk_generated"}do
	warptorio[v].planet=function(ev) local e=getEventEnt(ev) if(e and e.valid)then local p=warptorio.GetPlanetBySurface(e.surface.index) if(p)then warptorio.CallPlanetEvent(p,v,ev) end end end
end
--[[
function warptorio.on_built_entity.planet(ev) local e=getEventEnt(ev) if(e.valid)then local p=warptorio.GetPlanetBySurface(e.surface.index) if(p)then warptorio.CallPlanetEvent(p,"on_built_entity",ev) end end end
function warptorio.on_robot_built_entity.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index) if(p)then warptorio.CallPlanetEvent(p,"on_robot_built_entity",ev) end end

function warptorio.script_raised_built.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index)  if(p)then warptorio.CallPlanetEvent(p,"script_raised_built",ev) end end
function warptorio.script_raised_destroy.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index)  if(p)then warptorio.CallPlanetEvent(p,"script_raised_destroy",ev) end end
function warptorio.script_raised_revive.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index)  if(p)then warptorio.CallPlanetEvent(p,"script_raised_revive",ev) end end
function warptorio.on_player_mined_entity.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index)  if(p)then warptorio.CallPlanetEvent(p,"on_player_mined_entity",ev) end end
function warptorio.on_entity_died.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index)  if(p)then warptorio.CallPlanetEvent(p,"on_entity_died",ev) end end
function warptorio.on_entity_cloned.planet(ev) local p=warptorio.GetPlanetBySurface(getEventEnt(ev).surface.index)  if(p)then warptorio.CallPlanetEvent(p,"on_entity_cloned",ev) end end

function warptorio.on_chunk_deleted.planet(ev) local p=warptorio.GetPlanetBySurface(ev.surface.index) if(p)then warptorio.CallPlanetEvent(p,"on_chunk_deleted",ev) end end
function warptorio.on_chunk_generated.planet(ev) local p=warptorio.GetPlanetBySurface(ev.surface.index) if(p)then warptorio.CallPlanetEvent(p,"on_chunk_generated",ev) end end
]]

function warptorio.on_tick.planet(tick) for k,v in pairs(game.surfaces)do
	local p=warptorio.GetPlanetBySurface(v.index) if(p)then warptorio.CallPlanetEvent(p,"on_tick",{tick=tick,surface=v}) end
end end

-- --------
-- Warpout

function warptorio.PlanetCanSpawn(p,w,r,b) -- (planet, b_nowater, b_norest, b_nobiters)
	if(p.required_controls)then for k,v in pairs(p.required_controls)do if(not game.autoplace_control_prototypes[v])then return false end end end
	if(w and p.nowater)then return false elseif(r and p.rest)then return false elseif(b and p.biter)then return false end
	return true
end

function warptorio.RandomPlanet(z) z=z or gwarptorio.warpzone local zp={} local zx=0
	local lpt=warptorio.GetCurrentPlanet() local nowater,norest,nobiter=false,false,false
	if(lpt)then if(lpt.rest)then norest=true end if(lpt.nowater)then nowater=true end if(lpt.biter)then nobiter=true end end
	for k,v in pairs(warptorio.Planets)do if(v.zone<=z and v.rng>0 and warptorio.PlanetCanSpawn(v,nowater,norest,nobiter))then zx=zx+v.rng table.insert(zp,k) end end --for i=1,(v.rng or 1) do table.insert(zp,k) end end end
	if(zx<=0)then return warptorio.Planets["normal"] end
	local rng=math.random(1,zx) local zy=0
	for _,k in pairs(zp)do local v=warptorio.Planets[k] if(v.zone<=z and v.rng>0)then zy=zy+v.rng if(rng<=zy)then return v end end end
	return warptorio.Planets["normal"]
end

function warptorio.DoNextPlanet() local w=warptorio.RandomPlanet(gwarptorio.warpzone+1) return w end



function warptorio.BuildNewPlanet(vplanet) local w 
	if(vplanet)then w=warptorio.Planets[vplanet] end
	local lvl=gwarptorio.Research["reactor"] or 0

	local sizelv=(gwarptorio.Research["platform-size"] or 0)
	--warptorio.TweakResourcePlacements(9999) --1+(sizelv*0.33))

	if(lvl>=8 and gwarptorio.planet_target and not w)then local wx=gwarptorio.planet_target
		if(wx=="home")then local hf=warptorio.GetHomeSurface()
			if(warptorio.GetPlanetSurface()~=warptorio.GetHomeSurface() and math.random(1,10)<=3)then local hp=warptorio.GetPlanetBySurface(hf)
				game.print("-Successful Warp-") game.print(hp.name .. ". Home sweet home.") 
				return hf,hp
			end
		elseif(math.random(1,100)<=settings.global["warptorio_warpchance"].value)then
			w=warptorio.Planets[wx] if(w and not warptorio.PlanetCanSpawn(w))then w=nil elseif(w)then game.print("-Successful Warp-") end
		end
	end
	if(not w)then w=warptorio.RandomPlanet() end

	if(research.has("warptorio-charting") or not w.desc)then game.print(w.name) end
	if(w.desc)then game.print(w.desc) end

	local g=warptorio.GeneratePlanetSettings(w,gwarptorio.charting)
	local f=warptorio.GeneratePlanetSurface(w,g,gwarptorio.charting)

	return f,w,g
end


function warptorio.IsAutowarpEnabled() return gwarptorio.autowarp_disable~=true and (not gwarptorio.warp_reactor or not gwarptorio.warp_reactor.valid or gwarptorio.autowarp_always) end

function warptorio.CheckReactor()
	local m=gwarptorio.floor.main
	local rlv=gwarptorio.Research["reactor"] or 0
	if(rlv>=6 and (not gwarptorio.warp_reactor or not gwarptorio.warp_reactor.valid))then
		local f=m.surface
		vector.clean(f,vector.square(vector(-1,-1),vector(4,4)))
		local e=f.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player,player=game.players[1]}
		vector.cleanplayers(f,vector.square(vector(-1,-1),vector(4,4)))
		gwarptorio.warp_reactor=e
		e.minable=false
	end
end

function warptorio.IsElectricPole(e) return (e.name:match("electric-pole") or e.name:match("substation")) end


function warptorio.ValidateWarpBlacklist() if(not gwarptorio.warp_blacklist)then gwarptorio.warp_blacklist={} end
	for k,v in pairs(gwarptorio.warp_blacklist)do if(not game.active_mods[k])then gwarptorio.warp_blacklist[k]=nil end end
end
local staticBlacklist={"highlight-box","big_brother-blueprint-radar"}
function warptorio.GetWarpBlacklist() if(warptorio.WarpBlacklist)then return warptorio.WarpBlacklist else
	local t={} for k,v in pairs(gwarptorio.warp_blacklist)do for i,e in pairs(v)do table.insertExclusive(t,e) end end
	for k,v in pairs(staticBlacklist)do table.insertExclusive(t,v) end
	warptorio.WarpBlacklist=t return t
end end

function warptorio.Warpout(vplanet)
	warptorio.IsWarping=true
	gwarptorio.warp_charge=0 gwarptorio.warp_charging=0 gwarptorio.warpzone = gwarptorio.warpzone+1
	warptorio.derma.warpzone()
	warptorio.derma.warpbtn()
	local m=gwarptorio.floor.main local c=m.surface
	local marea=vector.square(vector.pos(m.position),vector(m.size,m.size))
	gwarptorio.votewarp=0

	-- charge time
	local cot=warptorio.CountEntities()
	local sgZone=settings.global["warptorio_warpcharge_zone"].value
	local sgZoneGain=settings.global["warptorio_warpcharge_zonegain"].value
	local sgMax=settings.global["warptorio_warpcharge_max"].value

	local sgFactor=settings.global["warptorio_warp_charge_factor"].value

	local sgAbilCooldown=settings.global["warptorio_ability_warp"].value
	local sgMul=settings.global["warptorio_warpcharge_multi"].value

	gwarptorio.warp_charge_time=math.min( 10+cot/sgFactor+gwarptorio.warpzone*sgMul+(sgZoneGain*60*( math.min(gwarptorio.warpzone,sgZone) /sgZone)) ,60*sgMax)
	gwarptorio.warp_time_left = 60*gwarptorio.warp_charge_time
	gwarptorio.warp_last=game.tick

	if(warptorio.IsAutowarpEnabled())then local rta=(gwarptorio.Research.reactor or 0)
		gwarptorio.warp_auto_end=game.tick+60*(60*settings.global["warptorio_autowarp_time"].value+60*10*rta) gwarptorio.warp_auto_time=60*settings.global["warptorio_autowarp_time"].value+60*10*rta
		warptorio.derma.autowarp() --warptorio.updatelabel("warptorio_autowarp","    Auto-Warp In : " .. util.formattime(gwarptorio.warp_auto_time*60))
	end

	-- abilities
	if(gwarptorio.accelerator or gwarptorio.radar or gwarptorio.stabilizer)then gwarptorio.ability_uses=0 gwarptorio.radar_uses=0
		gwarptorio.ability_next=game.tick+60*60*sgAbilCooldown
		--warptorio.updatelabel("warptorio_radar","Radar (0)")
		warptorio.derma.uses() --warptorio.updatelabel("warptorio_ability_uses","    Uses : " .. gwarptorio.ability_uses)
		warptorio.derma.cooldown() --warptorio.updatelabel("warptorio_ability_next","    Cooldown : " .. util.formattime(gwarptorio.ability_next-game.tick))
	end

	local cp=warptorio.GetCurrentPlanet()

	-- Designate next planet and make new surface
	local f,w=warptorio.BuildNewPlanet(vplanet)

	-- Add planet warp multiplier
	if(w.warp_multiply)then gwarptorio.warp_charge_time=gwarptorio.warp_charge_time*w.warp_multiply gwarptorio.warp_time_left=gwarptorio.warp_time_left*w.warp_multiply end
	warptorio.derma.charge_time() --warptorio.updatelabel("warptorio_time_left","    Charge Time : " .. util.formattime(gwarptorio.warp_charge_time*60))

	-- packup old teleporter gate
	local tp=gwarptorio.Teleporters.offworld if(tp and tp:ValidB())then tp:DestroyB() tp:DestroyLogsB() end

	-- Clean and prepare new surface
	for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=marea})do v.destroy() end
	gwarptorio.floor.main.surface=f
	warptorio.BuildPlatform()

	-- Clean and prepare old surface


	-- unused factorissimo stuff cleanup old surface
	--local vfFactorissimo=c.find_entities_filtered{name={"factory-1","factory-2","factory-3"}}
	--for k,v in pairs(vfFactorissimo)do script.raise_event(defines.events.on_marked_for_deconstruction,{entity=v}) end

	-- warp event calls
	if(warptorio.warpevent_name)then script.raise_event(warptorio.warpevent_name,{newplanet=f,newworld=w,oldplanet=c,oldworld=cp}) end
	if(cp)then if(cp.on_warp)then cp.on_warp(f,w,c,cp) end if(cp.on_warp_call)then remote.call(cp.on_warp_call[1],cp.on_warp_call[2],f,w,c,cp) end end


	-- find entities and players to copy/transfer to new surface
	local tpply={} local cx=warptorio.corn
	local etbl={}
	for k,v in pairs(c.find_entities_filtered{type="character",invert=true,area=marea})do
	if(v.type=="item-entity" or v.type=="character-corpse" or v.last_user or v.force.name=="player" or v.force.name=="enemy")then
		table.insert(etbl,v)
	end end

	-- find players to teleport to new platform
	for k,v in pairs(game.players)do if(v.character==nil or (v.surface==c and vector.inarea(v.position,marea)))then
		table.insert(tpply,{v,vector.pos(v.position)})
	end end

	-- find entities/players on the corners
	for k,v in pairs({"nw","ne","sw","se"})do local ug=gwarptorio.Research["turret-"..v] or -1 if(ug>=0)then
		local etc=f.find_entities_filtered{position={cx[v].x+0.5,cx[v].y+0.5},radius=(11+(ug*6))/2} for a,e in pairs(etc)do e.destroy() end -- clean new platform corner

		local etp=c.find_entities_filtered{type="character",position={cx[v].x+0.5,cx[v].y+0.5},radius=(11+(ug*6))/2} -- find corner players
		for a,e in pairs(etp)do if(e.player and e.player.character~=nil)then table.insert(tpply,{e.player,{e.position.x,e.position.y}}) end end

		local et=c.find_entities_filtered{type="character",invert=true,position={cx[v].x+0.5,cx[v].y+0.5},radius=(11+(ug*6))/2} -- find corner ents
		for k,v in pairs(et)do if(v.last_user or v.force.name=="player" or v.force.name=="enemy")then
			table.insertExclusive(etbl,v)
		end end

	end end

	local blacktbl={}
	for k,v in pairs(etbl)do if(table.HasValue(warptorio.GetWarpBlacklist(),v.name))then table.insert(blacktbl,v) etbl[k]=nil end end --script.raise_event(defines.events.on_robot_pre_mined,{entity=v}) end
	--for k,v in pairs(etbl)do if(not v or not v.valid)then etbl[k]=nil end end

	-- do the cloning
	c.clone_entities{entities=etbl,destination_offset={0,0},destination_surface=f} --,destination_force=game.forces.player}
	--local clones={} for k,v in pairs(etbl)do if(v.valid)then table.insert(clones,v.clone{position=v.position,surface=f,force=v.force}) end end

	-- do the player teleport
	for k,v in pairs(tpply)do v[1].teleport(f.find_non_colliding_position("character",{v[2][1],v[2][2]},0,1,1),f) end


	-- Recreate teleporter gate
	if(gwarptorio.Teleporters.offworld)then warptorio.Teleporters.offworld:Warpin() end
	for k,v in pairs(game.players)do if(v and v.valid)then local iv=v.get_main_inventory() for i,x in pairs(iv.get_contents())do
		if(i:sub(1,25)=="warptorio-teleporter-gate")then iv.remove{name=i,count=x} end
	end end end

	--// cleanup past entities
	
	for k,v in pairs(etbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end
	for k,v in pairs(blacktbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end
	--for k,v in pairs(vfFactorissimo)do if(v.valid)then v.cancel_deconstruction(game.forces.player) end end

	--// radar -- game.forces.player.chart(f,{lefttop={x=-256,y=-256},rightbottom={x=256,y=256}})

	--// build void
	for k,v in pairs({"nw","ne","sw","se"})do local ug=gwarptorio.Research["turret-"..v] or -1 if(ug>=0)then vector.LayCircle("out-of-map",c,vector.circle(vector(cx[v].x,cx[v].y),11+ug*6)) end end
	vector.LayTiles("out-of-map",c,marea)
	


	-- reset pollution & biters
	game.forces["enemy"].evolution_factor=0
	gwarptorio.pollution_amount=1.1
	gwarptorio.pollution_expansion=1.1

	-- warp sound
	players.playsound("warp_in")
	players.playsound("warp_in")

	for k,v in pairs(tpply)do v[1].teleport(f.find_non_colliding_position("character",{v[2][1],v[2][2]},0,1,1),f) end -- re-teleport players to prevent getting stuck

	--// delete abandoned surfaces
	for k,v in pairs(game.surfaces)do if(#(v.find_entities_filtered{type="character"})<1 and v.name~=f.name)then
		local n=v.name if(n:sub(1,9)=="warpsurf_" and n~="warpsurf_"..tostring(gwarptorio.homeworld))then game.delete_surface(v) end
	end end

	warptorio.CheckReactor()

	if(gwarptorio.warpevent_post_name)then script.raise_event(gwarptorio.warpevent_post_name,{newplanet=f,newworld=w}) end
	if(w.postwarpout)then pnt.postwarpout(f,w) end
	if(w.postwarpout_call)then remote.call(pnt.postwarpout_call[1],pnt.postwarpout_call[2],f,w) end

	warptorio.IsWarping=false
end
--[[c.clone_area{source_area=bbox,destination_area=bbox,destination_surface=f,destination_force=game.forces.player,expand_map=false,clone_tiles=true,
clone_entities=true,clone_decoratives=false,clear_destination=true}]]

function warptorio.OnPreSurfaceCleared(ev) local f=game.surfaces[ev.surface_index] local rds={}
--[[
	for k,e in pairs(gwarptorio.cache.heat)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(gwarptorio.cache.power)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(gwarptorio.cache.loaderIn)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(gwarptorio.cache.loaderOut)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(rds)do e.destroy{raise_destroy=true} end
]]
end
script.on_event({defines.events.on_pre_surface_cleared,defines.events.on_pre_surface_deleted},warptorio.OnPreSurfaceCleared)


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

local carebearItems={
["transport-belt"]=10,
["underground-belt"]=2,
["splitter"]=1,
["assembling-machine-1"]=2,
["small-electric-pole"]=5,
["steam-engine"]=1,
["boiler"]=1,
["gun-turret"]=4,
["wooden-chest"]=4,
["electronic-circuit"]=10,
["iron-gear-wheel"]=10,
["iron-plate"]=20,
["copper-plate"]=20,

["uranium-rounds-magazine"]=50,
["piercing-rounds-magazine"]=200,
["firearm-magazine"]=400,
["coal"]=20,
["burner-mining-drill"]=2,
["stone"]=20,

}

function warptorio.MakeCarebearChest()
	gwarptorio.carebear=true
	local e=gwarptorio.Floors.main:GetSurface().create_entity{name="warptorio-carebear-chest",position={-1,-1},force=game.forces.player}
	local inv=e.get_inventory(defines.inventory.chest)
	for k,v in pairs(carebearItems)do
		inv.insert{name=k,count=v}
	end

end
warptorio.Loaded=false
function warptorio.Initialize()
	if(not global.warptorio)then global.warptorio={} gwarptorio=global.warptorio else gwarptorio=global.warptorio return end
	warptorio.Migrate()
	if(settings.global["warptorio_carebear"].value)then warptorio.MakeCarebearChest() end
	if(settings.global["warptorio_water"].value)then game.forces.player.technologies["warptorio-boiler-water-1"].researched=true gwarptorio.waterboiler=1 end
	warptorio.ValidateWarpBlacklist()
	--warptorio.OverrideNauvis(true)
end script.on_init(warptorio.Initialize)


function warptorio.OnLoad()
	--if(not global.warptorio or gwarptorio)then return end
	gwarptorio=global.warptorio
	for k,v in pairs(gwarptorio.floor)do setmetatable(v,warptorio.FloorMeta) end
	for k,v in pairs(gwarptorio.Teleporters)do setmetatable(v,warptorio.TeleporterMeta) end
	for k,v in pairs(gwarptorio.Rails)do setmetatable(v,warptorio.TelerailMeta) end
	for k,v in pairs(gwarptorio.Harvesters)do setmetatable(v,warptorio.HarvesterMeta) end
end script.on_load(warptorio.OnLoad)

function warptorio.OnModSettingChanged(ev) local p=ev.player_index local s=ev.setting local st=ev.setting_type
	if(s=="warptorio_loaderchest_provider")then gwarptorio.LogisticLoaderChestProvider=settings.global[s].value
	elseif(s=="warptorio_loaderchest_requester")then gwarptorio.LogisticLoaderChestRequester=settings.global[s].value
	elseif(s=="warptorio_autowarp_disable")then gwarptorio.autowarp_disable=settings.global[s].value for k,v in pairs(game.players)do warptorio.BuildGui(v) end
	elseif(s=="warptorio_autowarp_always")then gwarptorio.autowarp_always=settings.global[s].value for k,v in pairs(game.players)do warptorio.BuildGui(v) end
	elseif(s=="warptorio_water")then if(settings.global[s].value)then game.forces.player.technologies["warptorio-boiler-water-1"].researched=true end
	elseif(s=="warptorio_carebear")then if(settings.global[s].value)then if(not isvalid(gwarptorio.warp_reactor) and not gwarptorio.carebear)then warptorio.MakeCarebearChest() end end
	elseif(s=="warptorio_loader_top")then for k,v in pairs(gwarptorio.Teleporters)do if(v.top)then v:UpgradeLogistics() end end
	elseif(s=="warptorio_loader_bottom")then for k,v in pairs(gwarptorio.Teleporters)do if(not v.top)then v:UpgradeLogistics() end end
	end
end script.on_event(defines.events.on_runtime_mod_setting_changed,warptorio.OnModSettingChanged)

function warptorio.OnConfigChanged(ev)
	warptorio.OnLoad()
	warptorio.Migrate()

	local fb=warptorio.GetFastestLoader()
	if(gwarptorio.fastest_loader ~= fb)then
		for k,v in pairs(gwarptorio.Teleporters)do v:UpgradeLogistics() end for k,v in pairs(gwarptorio.Rails)do v:DoMakes(true) end
		gwarptorio.fastest_loader=fb
	end
	warptorio.ValidateWarpBlacklist()
	--warptorio.OverrideNauvis()

end script.on_configuration_changed(warptorio.OnConfigChanged)

function warptorio.Migrate() if(warptorio.Loaded)then return end
	gwarptorio.warpzone=gwarptorio.warpzone or 0
	gwarptorio.time_spent_start_tick = gwarptorio.time_spent_start_tick or game.tick
	gwarptorio.time_passed = gwarptorio.time_passed or 0

	warptorio.ApplyMapSettings()

	gwarptorio.warp_charge_time=gwarptorio.warp_charge_time or 10 --in seconds
	gwarptorio.warp_charge_start_tick = gwarptorio.warp_charge_start_tick or 0
	gwarptorio.warp_charging = gwarptorio.warp_charging or 0
	gwarptorio.warp_timeleft = gwarptorio.warp_timeleft or 60*10
	gwarptorio.warp_reactor = gwarptorio.warp_reactor or nil
	gwarptorio.warp_auto_time = gwarptorio.warp_auto_time or 60*settings.global["warptorio_autowarp_time"].value
	gwarptorio.warp_auto_end = gwarptorio.warp_auto_end or 60*60*settings.global["warptorio_autowarp_time"].value
	gwarptorio.warp_last=gwarptorio.warp_last or game.tick
	gwarptorio.autowarp_disable=settings.global["warptorio_autowarp_disable"].value
	gwarptorio.autowarp_always=settings.global["warptorio_autowarp_always"].value

	gwarptorio.pollution_amount = gwarptorio.pollution_amount or 1.1--+settings.global['warptorio_warp_polution_factor'].value
	gwarptorio.pollution_expansion = gwarptorio.pollution_expansion or 1.1
	gwarptorio.ability_uses=gwarptorio.ability_uses or 0
	gwarptorio.ability_next=gwarptorio.ability_next or 0
	gwarptorio.radar_uses=gwarptorio.radar_uses or 0

	gwarptorio.cache=gwarptorio.cache or {}
	gwarptorio.cache.heat=gwarptorio.cache.heat or {}
	gwarptorio.cache.power=gwarptorio.cache.power or {}
	gwarptorio.cache.loaderIn=gwarptorio.cache.loaderIn or {}
	gwarptorio.cache.ldoutputut=gwarptorio.cache.ldoutput or {}
	gwarptorio.cache.loaderOutFilter=gwarptorio.cache.loaderOutFilter or {}
	gwarptorio.cache.loaderOutNext=gwarptorio.cache.loaderOutNext or {}

	gwarptorio.votewarp=gwarptorio.votewarp or {} if(type(gwarptorio.votewarp)~="table")then gwarptorio.votewarp={} end


	gwarptorio.Teleporters=gwarptorio.Teleporters or {}
	gwarptorio.Research=gwarptorio.Research or {}
	gwarptorio.Turrets=gwarptorio.Turrets or {}
	gwarptorio.Rails=gwarptorio.Rails or {}
	gwarptorio.Harvesters=gwarptorio.Harvesters or {}

	if(not gwarptorio.floor)then warptorio.init.floors() end--warptorio.InitFloors() end

	--BuildCache()
	--warptorio.ValidateCache()

	gwarptorio.LogisticLoaderChestProvider=settings.global['warptorio_loaderchest_provider'].value
	gwarptorio.LogisticLoaderChestRequester=settings.global['warptorio_loaderchest_requester'].value
	gwarptorio.warp_blacklist=gwarptorio.warp_blacklist or {}

	for k,v in pairs(warptorio.migrate)do v() end

	warptorio.Loaded=true


end


local lootItems={
["roboport"]=4,
["construction-robot"]=10,
["logistic-chest-passive-provider"]=10,
["logistic-chest-requester"]=10,
["logistic-chest-buffer"]=10,
["wooden-chest"]=20,
["iron-chest"]=20,
["steel-chest"]=20,
["storage-tank"]=10,

["red-wire"]=100,
["green-wire"]=100,
["pipe"]=200,
["pipe-to-ground"]=50,

["iron-plate"]=400,
["iron-gear-wheel"]=300,

["copper-plate"]=300,
["steel-plate"]=200,

["wood"]=100,
["stone"]=100,

["electronic-circuit"]=200,
["advanced-circuit"]=200,
["processing-unit"]=100,
["big-electric-pole"]=25,
["medium-electric-pole"]=25,
["small-electric-pole"]=25,
["substation"]=15,

["transport-belt"]=400,
["fast-transport-belt"]=300,
["express-transport-belt"]=200,
["landfill"]=100,

["express-underground-belt"]=15,
["fast-underground-belt"]=20,
["underground-belt"]=25,

["steam-engine"]=10,
["heat-exchanger"]=10,
["nuclear-reactor"]=10,
["accumulator"]=10,
["heat-pipe"]=25,
["steam-turbine"]=10,
["nuclear-reactor"]=1,
["chemical-plant"]=10,
["assembling-machine-1"]=15,
["assembling-machine-2"]=15,
["assembling-machine-3"]=15,
["inserter"]=50,
["fast-inserter"]=25,
["stack-inserter"]=25,
["warptorio-atomic-bomb"]=1,
["atomic-bomb"]=2,
["warptorio-warponium-fuel-cell"]=2,
["warptorio-warponium-fuel"]=1,

["uranium-rounds-magazine"]=100,
["firearm-magazine"]=400,
["piercing-rounds-magazine"]=200,
["gun-turret"]=10,
}

function warptorio.cheat() for i,p in pairs(game.players)do for k,v in pairs(lootItems)do p.get_main_inventory().insert{name=k,count=v} end end end
function warptorio.cmdwarp(v) warptorio.Warpout(v) end
function warptorio.cmdresetplatform() warptorio.BuildPlatform() warptorio.BuildB1() warptorio.BuildB2() for k,v in pairs(gwarptorio.Teleporters)do v:Warpin() end end
function warptorio.cmdinsertcloneblacklist(mn,e) if(not gwarptorio.warp_blacklist[mn])then gwarptorio.warp_blacklist[mn]={} end table.insertExclusive(gwarptorio.warp_blacklist[mn],e) end
function warptorio.cmdremovecloneblacklist(mn,e) if(not gwarptorio.warp_blacklist[mn])then gwarptorio.warp_blacklist[mn]={} end table.RemoveByValue(gwarptorio.warp_blacklist[mn],e) end
function warptorio.cmdiscloneblacklisted(mn,e) if(not gwarptorio.warp_blacklist[mn])then return false end return table.HasValue(gwarptorio.warp_blacklist[mn],e) end

function warptorio.cmdgetresources() return warptorio.GetAllResources() end
function warptorio.cmdgetglobal(k) return global.warptorio[k] end
function warptorio.cmdgetplanets() return warptorio.Planets end
function warptorio.cmdreveal(n) n=n or 10 local f=gwarptorio.Floors.main:GetSurface() game.forces.player.chart(f,{lefttop={x=-64-128*n,y=-64-128*n},rightbottom={x=64+128*n,y=64+128*n}}) end
function warptorio.cmdgetplanet(n) return warptorio.Planets[n] end
function warptorio.cmdgenerateplanet(n) return warptorio.GeneratePlanetSettings(warptorio.Planets[n],false) end

function warptorio.cmdRegisterPlanet(t) warptorio.RegisterPlanet(t) end
function warptorio.cmdcurrentsurface() return gwarptorio.Floors.main:GetSurface() end
function warptorio.cmdhomesurface() return gwarptorio.Floors.home:GetSurface() end
function warptorio.cmdfactorysurface() return gwarptorio.Floors.b1:GetSurface() end
function warptorio.cmdboilersurface() return gwarptorio.Floors.b2:GetSurface() end

function warptorio.cmdgetwarpevent() if(not gwarptorio.warpevent_name)then gwarptorio.warpevent_name = script.generate_event_name() end return gwarptorio.warpevent_name end
function warptorio.cmdgetpostwarpevent() if(not gwarptorio.warpevent_post_name)then gwarptorio.warpevent_post_name = script.generate_event_name() end return gwarptorio.warpevent_post_name end

function warptorio.cmdtiledefault(n,b) warptorio.TileDefault(n,b) end

local interfaceTable={

	warp=warptorio.cmdwarp, -- force warp to a specific planet

	tiledefault=warptorio.cmdtiledefault, -- add a tileset to not spawn by default in nauvis map_gen_settings using probability expressions, ex. see official planets pack

	getplanets=warptorio.cmdgetplanets, -- get a copy of the current warptorio planets table
	getplanet=warptorio.cmdgetplanet, -- get a copy of a specific planet

	getresources=warptorio.cmdgetresources, -- get a copy of the warptorio auto-detected resources "all resources", useful with mods
	getglobal=warptorio.cmdgetglobal, -- get a variable from the global table
	registerplanet=warptorio.cmdRegisterPlanet, -- register a new planet

	currentplanet=warptorio.cmdcurrentsurface, -- get the current planet surface
	homeplanet=warptorio.cmdhomesurface, -- get the homeworld surface
	factorysurface=warptorio.cmdfactorysurface, -- get the factory surface
	boilersurface=warptorio.cmdboilersurface, -- get the boiler surface
	warpevent=warptorio.cmdgetwarpevent, -- get the named event for on warpout
	postwarpevent=warptorio.cmdgetpostwarpevent, -- get the named event for post warpout


	get_resources=warptorio.cmdgetresources, -- alias

	cheat=warptorio.cheat, -- give free items cheat command for debugging purposes
	reveal=warptorio.cmdreveal, -- map reveal cheat command for debugging purposes
	generateplanet=warptorio.cmdgenerateplanet, -- generate a planet table for debugging purposes
	resetplatform=warptorio.cmdresetplatform, -- Reconstruct the platforms for debugging purposes

	insert_warp_blacklist=warptorio.cmdinsertcloneblacklist,
	remove_warp_blacklist=warptorio.cmdremovecloneblacklist,
	is_warp_blacklisted=warptorio.cmdiscloneblacklisted,

	event_warp=warptorio.cmdgetwarpevent, -- alias
	event_post_warp=warptorio.cmdgetpostwarpevent, -- alias
}

remote.add_interface("warptorio",interfaceTable)
remote.add_interface("warptorio2",interfaceTable)



function warptorio.on_chunk_generated.lootchest(ev) local a=ev.area local f=ev.surface

	if(f.name=="nauvis" or f~=warptorio.GetPlanetSurface())then return end
	-- spawn chest with goodies
	if(math.random(1,175)>1)then return end
	local x=math.random(a.left_top.x,a.right_bottom.x)
	local y=math.random(a.left_top.y,a.right_bottom.y)
	local dist=math.sqrt(math.abs(x^2)+math.abs(y^2))
	if(dist < 256)then return end

	local lt={} for k,v in pairs(lootItems)do local r=game.forces.player.recipes[k] if(not r or (r and r.enabled==true))then lt[k]=v end end
	if(table_size(lt)<1)then return end
	local e=f.create_entity{name="warptorio-lootchest",position={x,y},force=game.forces.player}
	if(not e or not e.valid)then game.print("Invalid Chest") return end
	--game.print("Made Chest x: " .. x .. " y: " .. y)
	local inv=e.get_inventory(defines.inventory.chest)
	for i=1,math.random(1,5),1 do
		local u,k=table.Random(lt)
		local dv=math.min(dist/1700,1)
		local fc=math.random(20,100)/100
		local cx=math.max(math.ceil(u*dv*fc),1)
		--game.print("Insert Random Item: " .. tostring(k) .. " c: " .. cx .. " u: " .. tostring(u) .. " dv: " .. dv .. " fc: " .. fc)
		inv.insert{name=k,count=cx}
	end
end


-- Hook events
for k,v in pairs(defines.events)do if(k~="on_tick" and table_size(warptorio[k])>0)then script.on_event(v,function(ev,...) for x,y in pairs(warptorio[k])do y(ev,...) end end) end end

script.on_event(defines.events.on_tick,function(ev) for k,v in pairs(warptorio.on_tick)do v(ev.tick) end end)


