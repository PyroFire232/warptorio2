
-- --------
-- Setup

local gwarptorio --=setmetatable({},{__index=function(t,k) return global.warptorio[k] end,__newindex=function(t,k,v) global.warptorio[k]=v end})
local util = require("util")
local mod_gui = require("mod-gui")
local function istable(x) return type(x)=="table" end
local function printx(m) for k,v in pairs(game.players)do v.print(m) end end
local function isvalid(v) return (v and v.valid) end
local function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end

function table.Count(t) return table_size(t) end --local c=0 for k,v in pairs(t)do c=c+1 end return c end
function table.First(t) for k,v in pairs(t)do return k,v end end
function table.Random(t) local c,i=table_size(t),1 if(c==0)then return end local rng=math.random(1,c) for k,v in pairs(t)do if(i==rng)then return v,k end i=i+1 end end
function table.HasValue(t,a) for k,v in pairs(t)do if(v==a)then return true end end return false end
function table.GetValueIndex(t,a) for k,v in pairs(t)do if(v==a)then return k end end return false end
function table.RemoveByValue(t,a) local i=table.GetValueIndex(t,a) if(i)then table.remove(t,i) end end
function table.insertExclusive(t,a) if(not table.HasValue(t,a))then return table.insert(t,a) end return false end
function table.deepmerge(s,t) for k,v in pairs(t)do if(istable(v) and s[k] and istable(s[k]))then if(table_size(v)==0)then s[k]=s[k] or {} else table.deepmerge(s[k],v) end else s[k]=v end end end
function table.merge(s,t) local x={} for k,v in pairs(s)do x[k]=v end for k,v in pairs(t)do x[k]=v end return x end

function table.GetMatchTable(t,n) local x={}
	if(istable(n))then for k,v in pairs(t)do if(table.HasMatchValue(n,v))then table.insert(x,v) end end
	else for i,v in pairs(t)do if(v:match(n))then table.insert(x,v) end end
	end return x
end
function table.HasValueMatch(t,u) for k,v in pairs(t)do if(v:match(u))then return v end end end
function table.HasMatchValue(t,u) for k,v in pairs(t)do if(u:match(v))then return v end end end

warptorio=warptorio or {}
--warptorio.LogisticLoaderChestProvider="logistic-chest-active-provider"
--warptorio.LogisticLoaderChestRequester="logistic-chest-requester"

require("control_planets")
require("control_research")
--require("control_nauvis") --function warptorio.OverrideNauvis() end--


warptorio.railCorn={nw={x=-35,y=-35},ne={x=34,y=-35},sw={x=-35,y=34},se={x=34,y=34}} 
warptorio.railLoader={nw={{2,0},{0,2}},sw={{2,0},{0,-2}},ne={{-2,0},{0,2}},se={{-2,0},{0,-2}}}
warptorio.railOffset={nw={-1,-1},ne={0,-1},sw={-1,0},se={0,0}}


function warptorio.TryCleanEntity(v) if(v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio")then v.destroy{raise_destroy=true} end end

function warptorio.SetLogisticsCircuitMode(r) local cb=r.get_or_create_control_behavior() cb.circuit_mode_of_operation=defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests end
function warptorio.CopyChestEntity(a,b) local c=b.get_inventory(defines.inventory.chest) for k,v in pairs(a.get_inventory(defines.inventory.chest).get_contents())do c.insert{name=k,count=v} end
	local net=a.circuit_connection_definitions
	for c,tbl in pairs(net)do b.connect_neighbour{target_entity=tbl.target_entity,wire=tbl.wire,source_circuit_id=tbl.source_circuit_id,target_circuit_id=tbl.target_circuit_id} end
end
function warptorio.FlipDirection(v) return (v+4)%8 end


-- ----
-- Rail Logistics

local TRAIL={} TRAIL.__index=TRAIL warptorio.TelerailMeta=TRAIL
function TRAIL.__init(self,n) self.name=n self.chests={} self.rails={} self.loaders={} gwarptorio.Rails[n]=self self.dir="output" end
function TRAIL:MakeRails() local f=gwarptorio.Floors.main:GetSurface() local c=warptorio.railCorn[self.name]
	local r=self.rails[1] if(not isvalid(r))then r=warptorio.SpawnEntity(f,"straight-rail",c.x,c.y,defines.direction.south) self.rails[1]=r r.minable=false r.destructible=false end
	local r=self.rails[2] if(not isvalid(r))then r=warptorio.SpawnEntity(f,"straight-rail",c.x,c.y,defines.direction.east) self.rails[2]=r r.minable=false r.destructible=false end
end
function TRAIL:MakeChestAt(f,chest,i,x,y,rd) local r=self.chests[i] local rx if(isvalid(r) and r.name~=chest)then rx=r r=nil end
	if(not isvalid(r))then r=warptorio.SpawnEntity(f,chest,x,y) self.chests[i]=r r.minable=false r.destructible=false if(rd)then warptorio.SetLogisticsCircuitMode(r) end end
	if(rx)then warptorio.CopyChestEntity(rx,r) rx.destroy() end
end
function TRAIL:MakeChests(chest) local f=gwarptorio.Floors.b1:GetSurface() local c=warptorio.railCorn[self.name] local rd=(self.dir=="input")
	self:MakeChestAt(f,chest,1,c.x,c.y,rd) self:MakeChestAt(f,chest,2,c.x-1,c.y,rd) self:MakeChestAt(f,chest,3,c.x,c.y-1,rd) self:MakeChestAt(f,chest,4,c.x-1,c.y-1,rd)
end
function TRAIL:DoCheckLoader(i) local r=self.loaders[i] if(r and r.loader_type~=self.dir)then self.dir=r.loader_type self:DoMakes(true) return end end
function TRAIL:CheckLoaders() for i=1,4,1 do self:DoCheckLoader(i) end end
function TRAIL:SpawnLoaderAt(f,belt,i,x,y,ori,dir)
	local r=self.loaders[i] if(isvalid(r) and (r.name~=belt or r.loader_type~=dir))then r.destroy() r=nil end
	if(not isvalid(r))then r=warptorio.SpawnEntity(f,belt,x,y,ori,"output") r.loader_type=dir self.loaders[i]=r r.minable=false r.destructible=false end
	return r
end
TRAIL.SpawnLoader={}
TRAIL.SpawnLoader.nw=function(self,belt,f,c)
	self:SpawnLoaderAt(f,belt,1,c.x+2,c.y,defines.direction.east,self.dir) self:SpawnLoaderAt(f,belt,2,c.x+2,c.y-1,defines.direction.east,self.dir)
	self:SpawnLoaderAt(f,belt,3,c.x,c.y+2,defines.direction.south,self.dir) self:SpawnLoaderAt(f,belt,4,c.x-1,c.y+2,defines.direction.south,self.dir) end
TRAIL.SpawnLoader.sw=function(self,belt,f,c)
	self:SpawnLoaderAt(f,belt,1,c.x+2,c.y,defines.direction.east,self.dir) self:SpawnLoaderAt(f,belt,2,c.x+2,c.y-1,defines.direction.east,self.dir)
	self:SpawnLoaderAt(f,belt,3,c.x,c.y-2,defines.direction.north,self.dir) self:SpawnLoaderAt(f,belt,4,c.x-1,c.y-2,defines.direction.north,self.dir) end
TRAIL.SpawnLoader.ne=function(self,belt,f,c)
	self:SpawnLoaderAt(f,belt,1,c.x-2,c.y,defines.direction.west,self.dir) self:SpawnLoaderAt(f,belt,2,c.x-2,c.y-1,defines.direction.west,self.dir)
	self:SpawnLoaderAt(f,belt,3,c.x,c.y+2,defines.direction.south,self.dir) self:SpawnLoaderAt(f,belt,4,c.x-1,c.y+2,defines.direction.south,self.dir) end
TRAIL.SpawnLoader.se=function(self,belt,f,c)
	self:SpawnLoaderAt(f,belt,1,c.x-2,c.y,defines.direction.west,self.dir) self:SpawnLoaderAt(f,belt,2,c.x-2,c.y-1,defines.direction.west,self.dir)
	self:SpawnLoaderAt(f,belt,3,c.x,c.y-2,defines.direction.north,self.dir) self:SpawnLoaderAt(f,belt,4,c.x-1,c.y-2,defines.direction.north,self.dir) end
function TRAIL:MakeLoaders(belt) self.SpawnLoader[self.name](self,belt,gwarptorio.Floors.b1:GetSurface(),warptorio.railCorn[self.name]) end

function TRAIL:SplitItem(u,n) local c=n local cx=0 local cinv={} local ui={name=k,count=n}
	for k,v in pairs(self.chests)do local iv=v.get_inventory(defines.inventory.chest) if(iv.can_insert(u))then cinv[k]=iv end end local tcn=table.Count(cinv)
	for k,v in pairs(cinv)do if(c>0)then local w=v.insert{name=u,count=math.ceil(c/tcn)} cx=cx+w c=c-w tcn=tcn-1 end end
	return cx
end
function TRAIL:LoadLogistics(e)
	local inv={} for k,v in pairs(self.chests)do inv[k]=v.get_inventory(defines.inventory.chest) end
	local ct={} for k,v in pairs(inv)do for a,b in pairs(v.get_contents())do ct[a]=(ct[a] or 0)+b end v.clear() end
	for _,r in pairs(e)do local tr=r.get_inventory(defines.inventory.cargo_wagon) for k,v in pairs(ct)do ct[k]=v-(tr.insert{name=k,count=v}) end end
	local ci for a,b in pairs(ct)do local g=b ci=#inv for k,v in pairs(inv)do local gci=math.ceil(g/ci) if(gci>0)then local w=v.insert{name=a,count=math.ceil(g/ci)} ci=ci-1 g=g-w end end end
end
function TRAIL:UnloadLogistics(e) for _,r in pairs(e)do
		local inv=r.get_inventory(defines.inventory.cargo_wagon) for k,v in pairs(inv.get_contents())do local ct=self:SplitItem(k,v) if(ct>0)then inv.remove({name=k,count=ct}) end end
end end
function TRAIL:BalanceLogistics() local f=gwarptorio.Floors.main:GetSurface() if(not f.valid)then return end local c=warptorio.railCorn[self.name]
	local e=f.find_entities_filtered{name="cargo-wagon",area={{c.x-1,c.y-1},{c.x+1,c.y+1}} }
	if(table.Count(e)>0)then if(self.dir=="output")then self:UnloadLogistics(e) self:BalanceChests() else self:LoadLogistics(e) end else self:BalanceChests() end
end
function TRAIL:BalanceChests() local inv={} for k,v in pairs(self.chests)do inv[k]=v.get_inventory(defines.inventory.chest) end
	local ct={} for k,v in pairs(inv)do for a,b in pairs(v.get_contents())do ct[a]=(ct[a] or 0)+b end v.clear() end
	local ci for a,b in pairs(ct)do local g=b ci=#inv for k,v in pairs(inv)do local gci=math.ceil(g/ci) if(gci>0)then local w=v.insert{name=a,count=math.ceil(g/ci)} ci=ci-1 g=g-w end end end
end

function warptorio.GetFastestLoader() if(warptorio.FastestLoader)then return warptorio.FastestLoader end if(true)then return "express-loader" end
	local ld={}
	local topspeed=game.entity_prototypes["express-loader"].belt_speed local top="express-loader"
	for k,v in pairs(game.entity_prototypes)do if(v.type=="loader")then table.insert(ld,v) end end
	for k,v in pairs(ld)do if(not v.name:match("warptorio") and not v.name:match("mini") and v.belt_speed>=topspeed)then topspeed=v.belt_speed top=v.name end end
	warptorio.FastestLoader=top return top
end

function warptorio.GetLogisticsChestBelt(dir) local lv=gwarptorio.Research["factory-logistics"] or 0
	if(lv<=1)then return "wooden-chest","loader" elseif(lv==2)then return "iron-chest","fast-loader" elseif(lv==3)then return "steel-chest","express-loader"
	elseif(lv>=4)then return (dir=="output" and gwarptorio.LogisticLoaderChestProvider or gwarptorio.LogisticLoaderChestRequester),warptorio.GetFastestLoader() end
end
function TRAIL:DoMakes(udir) local chest,belt=warptorio.GetLogisticsChestBelt(self.dir) if(not udir)then self:MakeRails() end self:MakeChests(chest) self:MakeLoaders(belt) end

function warptorio.BuildRailCorner(cn) local c=warptorio.railCorn[cn] local v=warptorio.railOffset[cn] local vx=warptorio.railLoader[cn]
	local r=gwarptorio.Rails[cn]
	if(not r)then r=new(TRAIL,cn) local f=gwarptorio.Floors.b1:GetSurface()
		warptorio.cleanbbox(gwarptorio.Floors.main:GetSurface(),c.x+v[1],c.y+v[2],2,2)
		warptorio.cleanbbox(f,c.x-1,c.y-1,2,2) warptorio.cleanbbox(f,c.x-1+vx[1][1],c.y-1+vx[1][2],2,2) warptorio.cleanbbox(f,c.x-1+vx[2][1],c.y-1+vx[2][2],2,2)
	end
	r:DoMakes()
end

function warptorio.BuildRails() warptorio.BuildRailCorner("nw") warptorio.BuildRailCorner("sw") warptorio.BuildRailCorner("ne") warptorio.BuildRailCorner("se") end --for k,v in pairs(warptorio.railCorn)do warptorio.BuildRailCorner(k) end end


-- --------
-- Logistics & Teleporters



local TELL={} TELL.__index=TELL warptorio.TeleporterMeta=TELL
function TELL.__init(self,n,j) self.name=n self.top=j self.dir={{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"}} self.logcont={} gwarptorio.Teleporters[n]=self end
TELL.LogisticsEnts={}
for i=1,8,1 do table.insert(TELL.LogisticsEnts,"loader"..i) table.insert(TELL.LogisticsEnts,"chest"..i) end
for i=1,6,1 do table.insert(TELL.LogisticsEnts,"pipe"..i) end

function TELL:SpawnPointA(n,f,pos,nd) local e=warptorio.SpawnEntity(f,n,pos.x,pos.y) if(not nd)then e.minable=false e.destructible=false end self:SetPointA(e) return e end
function TELL:SpawnPointB(n,f,pos,nd) local e=warptorio.SpawnEntity(f,n,pos.x,pos.y) if(not nd)then e.minable=false e.destructible=false end self:SetPointB(e) return e end
function TELL:SetPointA(e) self.PointA=e if(self.PointAEnergy)then self.PointA.energy=self.PointAEnergy self.PointAEnergy=nil end end
function TELL:SetPointB(e) self.PointB=e if(self.PointBEnergy)then self.PointB.energy=self.PointBEnergy self.PointBEnergy=nil end end
function TELL:DoCheckLoader(i)
	self:CheckLoaderDirection(i,self.logs["loader"..i.."-a"],self.logs["loader"..i.."-b"]) --,self.logs["chest"..i.."-a"],self.logs["chest"..i.."-b"])
	if(self.dir[i][1]=="input")then warptorio.BalanceLogistics(self.logs["chest"..i.."-a"],self.logs["chest"..i.."-b"])
	else warptorio.BalanceLogistics(self.logs["chest"..i.."-b"],self.logs["chest"..i.."-a"])
	end
end

function TELL:BalanceLogistics()
	if(self.logs)then
		for i=1,8,1 do self:DoCheckLoader(i) end
		for i=1,6,1 do warptorio.BalanceLogistics(self.logs["pipe"..i.."-a"],self.logs["pipe"..i.."-b"],true) end
	end
	--warptorio.BalanceLogistics(self.PointA,self.PointB) -- energy
end

function TELL:Warpout() local f=gwarptorio.Floors.main:GetSurface().name
	if(self:ValidPointA() and self.PointA.surface.name==f)then self:DestroyPointA() self:DestroyLogisticsA() end
	if(self:ValidPointB() and self.PointB.surface.name==f)then self:DestroyPointB() self:DestroyLogisticsB() end
end
function TELL:Warpin(upgr,logs) warptorio.TeleCls[self.name](upgr,logs) end
function TELL:ValidPointA() return (self.PointA and self.PointA.valid) end
function TELL:ValidPointB() return (self.PointB and self.PointB.valid) end
function TELL:ValidPoints() return (self:ValidPointA() and self:ValidPointB()) end
function TELL:DestroyPoints() self:DestroyPointA() self:DestroyPointB() end
function TELL:DestroyPointA() if(self.PointA and self.PointA.valid)then self.PointAEnergy=self.PointA.energy self.PointA.destroy() self.PointA=nil end end
function TELL:DestroyPointB() if(self.PointB and self.PointB.valid)then self.PointBEnergy=self.PointB.energy self.PointB.destroy() self.PointB=nil end end
function TELL:DestroyLogisticsA() if(self.logs)then for k,v in pairs(self.LogisticsEnts)do local e=self.logs[v.."-a"] if(e)then if(e.valid)then
	if(e.type=="container")then local inv=e.get_inventory(defines.inventory.chest) self.logcont[v.."-a"]=inv.get_contents() end
		--for x,y in pairs(self.logcont[v.."-a"])do game.print(x .. " " .. y) end
	e.destroy()
end self.logs[v.."-a"]=nil end end end end
function TELL:DestroyLogisticsB() if(self.logs)then for k,v in pairs(self.LogisticsEnts)do local e=self.logs[v.."-b"] if(e)then if(e.valid)then
	if(e.type=="container")then local inv=e.get_inventory(defines.inventory.chest) self.logcont[v.."-b"]=inv.get_contents() end
	e.destroy()
end self.logs[v.."-b"]=nil end end end end
function TELL:DestroyLogistics() self:DestroyLogisticsA() self:DestroyLogisticsB() end
function TELL:UpgradeLogistics() if(self.logs)then self:DestroyLogistics() end self:Warpin(false,true) end -- self:SpawnLogistics()
function TELL:UpgradeEnergy() self:Warpin(true) end

--[[
a.temperature
]]

--[[function logz.MoveFluid(a,b) local af,bf=a.get_fluid_contents(),b.get_fluid_contents() local aff,afv=table.First(af) local bff,bfv=table.First(bf)
	if((not aff and not bff) or (aff and bff and aff~=bff) or (afv==0 and bfv==0))then return end
	if(aff=="steam")then
		local temp=15 local at=warptorio.GetSteamTemperature(a) local bt=warptorio.GetSteamTemperature(b) temp=math.max(at,bt)
		local c=b.insert_fluid({name=aff,amount=afv,temperature=temp}) if(c>0)then a.remove_fluid{name=aff,amount=c} end
	else
		local c=b.insert_fluid({name=aff,amount=afv}) if(c>0)then a.remove_fluid{name=aff,amount=c} end
	end
end
]]


function TELL:SwapLoaderChests(i,a,b)
	local lv=gwarptorio.Research["factory-logistics"] or 0
	if(lv>=4)then -- buffer chests
		local ea=self.logs["chest"..i.."-a"] local eax=(a.loader_type=="input" and gwarptorio.LogisticLoaderChestRequester or gwarptorio.LogisticLoaderChestProvider)
		local eb=self.logs["chest"..i.."-b"] local ebx=(a.loader_type=="output" and gwarptorio.LogisticLoaderChestRequester or gwarptorio.LogisticLoaderChestProvider)
		local va=warptorio.SpawnEntity(ea.surface,eax,ea.position.x,ea.position.y) va.minable=false va.destructible=false
		local vb=warptorio.SpawnEntity(eb.surface,ebx,eb.position.x,eb.position.y) vb.minable=false vb.destructible=false
		warptorio.CopyChestEntity(ea,va) warptorio.CopyChestEntity(eb,vb)
		local cb if(a.loader_type=="input")then cb=va.get_or_create_control_behavior() else cb=vb.get_or_create_control_behavior() end
		cb.circuit_mode_of_operation=defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests
		ea.destroy() eb.destroy()
		self.logs["chest"..i.."-a"]=va self.logs["chest"..i.."-b"]=vb
	end
end

function TELL:ConnectCircuit()
	local vv=self.PointA.connect_neighbour({target_entity=self.PointB,wire=defines.wire_type.red})
	local vv=self.PointA.connect_neighbour({target_entity=self.PointB,wire=defines.wire_type.green})
end

function TELL:CheckLoaderDirection(i,a,b) if(not a or not a.valid or not b or not b.valid)then return end
	local lv=gwarptorio.Research["factory-logistics"] or 0
	if(a.loader_type ~= self.dir[i][1])then -- A has rotated
		self.dir[i][1]=a.loader_type
		self.dir[i][2]=(a.loader_type=="input" and "output" or "input")
		b.loader_type=self.dir[i][2]
		self:SwapLoaderChests(i,a,b)
	elseif(b.loader_type ~= self.dir[i][2])then -- B has rotated
		self.dir[i][2]=b.loader_type
		self.dir[i][1]=(b.loader_type=="input" and "output" or "input")
		a.loader_type=self.dir[i][1]
		self:SwapLoaderChests(i,a,b)
	end
end

function TELL:MakeLoaderPair(f,chest,belt,p,i,u) local ix=(i*2)-1

	local st=settings.global["warptorio_loader_top"].value
	local sb=settings.global["warptorio_loader_bottom"].value
	local lddir,chesty,belty
	if(self.top)then
		if(st=="up")then lddir=defines.direction.north chesty=-1 belty=0
		else lddir=defines.direction.south chesty=1 belty=-1
		end
	else
		if(sb=="down")then lddir=defines.direction.south chesty=1 belty=-1
		else lddir=defines.direction.north chesty=-1 belty=0
		end
	end

	local v=self.logs["loader"..ix.."-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,belt,p.x-1-i,p.y+belty,lddir) v.minable=false v.destructible=false
		self.logs["loader"..ix.."-"..u]=v v.loader_type=self.dir[ix][(u=="a" and 1 or 2)] end

	local v=self.logs["loader"..ix+1 .."-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,belt,p.x+1+i,p.y+belty,lddir) v.minable=false v.destructible=false
		self.logs["loader"..ix+1 .."-"..u]=v v.loader_type=self.dir[ix+1][(u=="a" and 1 or 2)] end

	local v=self.logs["chest"..ix.."-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,chest,p.x-1-i,p.y+chesty) self.logs["chest"..ix.."-"..u]=v v.minable=false v.destructible=false 
		local inv=self.logcont["chest"..ix .."-"..u] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert({name=x,count=y}) end end
		self.logcont["chest"..ix .."-"..u]=nil
	end
	local v=self.logs["chest"..ix+1 .."-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,chest,p.x+1+i,p.y+chesty) self.logs["chest"..ix+1 .."-"..u]=v v.minable=false v.destructible=false 
		local inv=self.logcont["chest"..ix+1 .."-"..u] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert({name=x,count=y}) end end
		self.logcont["chest"..ix+1 .."-"..u]=nil
	end
end

function TELL:SpawnLogisticsPoint(u,a,chest,belt,pipe,dl,lv)
	if(a and a.valid)then
		local f,p=a.surface,a.position
		self:MakeLoaderPair(f,chest,belt,p,1,u)
		if(dl>=1)then self:MakeLoaderPair(f,chest,belt,p,2,u) end
		if(dl>=2)then self:MakeLoaderPair(f,chest,belt,p,3,u) end
		if(dl>=3)then self:MakeLoaderPair(f,chest,belt,p,4,u) end

		local px=dl
		local v=self.logs["pipe1-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,pipe,p.x-3-px,p.y+1,defines.direction.west) self.logs["pipe1-"..u]=v v.minable=false v.destructible=false end
		local v=self.logs["pipe2-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,pipe,p.x+3+px,p.y+1,defines.direction.east) self.logs["pipe2-"..u]=v v.minable=false v.destructible=false end
		if(lv>=2)then
			local v=self.logs["pipe3-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,pipe,p.x-3-px,p.y,defines.direction.west) self.logs["pipe3-"..u]=v v.minable=false v.destructible=false end
			local v=self.logs["pipe4-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,pipe,p.x+3+px,p.y,defines.direction.east) self.logs["pipe4-"..u]=v v.minable=false v.destructible=false end
		end if(lv>=4)then
			local v=self.logs["pipe5-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,pipe,p.x-3-px,p.y-1,defines.direction.west) self.logs["pipe5-"..u]=v v.minable=false v.destructible=false end
			local v=self.logs["pipe6-"..u] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,pipe,p.x+3+px,p.y-1,defines.direction.east) self.logs["pipe6-"..u]=v v.minable=false v.destructible=false end
		end
		warptorio.playsound("warp_in",f)
	end


end

function TELL:SpawnLogistics() if(not self.logs)then self.logs={} end
	local lv=gwarptorio.Research["factory-logistics"] or 0 if(lv==0)then return end
	local chest,belt local pipe="warptorio-logistics-pipe"
	if(lv==1)then chest,belt="wooden-chest","loader"
	elseif(lv==2)then chest,belt="iron-chest","fast-loader"
	elseif(lv==3)then chest,belt="steel-chest","express-loader"
	elseif(lv>=4)then chest,belt="logistic-chest-buffer",warptorio.GetFastestLoader() end

	local dl=0 if(self.name=="b1" or self.name=="b2")then dl=gwarptorio.Research["dualloader"] or 0 else dl=gwarptorio.Research["triloader"] or 0 end

	local a=self.PointA
	if(a and a.valid)then self:SpawnLogisticsPoint("a",self.PointA,chest,belt,pipe,dl,lv) end

	local f=gwarptorio.Floors.main:GetSurface()
	local b=self.PointB
	if(b and b.valid)then if(self.name=="offworld")then -- check for collisions
		if(b.surface.name == f.name)then
			local bp=b.position local bb={bp.x-5,bp.y-1} local bbox={bb,{bb[1]+9,bb[2]+2}}
			if(f.count_entities_filtered{area=bbox,collision_mask={"object-layer"}} > 1)then if(not warptorio.IsWarping)then game.print("Unable to place teleporter logistics, something is in the way!") end
			else self:SpawnLogisticsPoint("b",self.PointB,chest,belt,pipe,dl,lv)
			end
		else
			game.print("Teleporter Logistics can only spawn on the planet")
		end
	else
		self:SpawnLogisticsPoint("b",self.PointB,chest,belt,pipe,dl,lv)
	end end
	local lv=gwarptorio.Research["factory-logistics"] or 0
	if(lv>=4)then -- buffer chests
		for i=1,8,1 do local a,b=self.logs["loader"..i.."-a"],self.logs["loader"..i.."-b"] if(a and b and a.valid and b.valid)then self:SwapLoaderChests(i,a,b) end end
	end
	for k,v in pairs(self.logs)do if(v and v.valid)then v.minable=false v.destructible=false end end
end

local tpcls={} warptorio.TeleCls=tpcls
function tpcls.offworld(upgr,logs)
	local lv=gwarptorio.Research["teleporter-energy"] or 0
	local lgv=(gwarptorio.Research["factory-logistics"] or 0)>0
	local lgx=gwarptorio.Research["triloader"] or 0
	local x=gwarptorio.Teleporters["offworld"] if(not x)then x=new(TELL,"offworld",false) end
	x.cost=true
	local m=gwarptorio.Floors.main
	local f=m:GetSurface()
	local bpos={-1,8}
	local makeA="warptorio-teleporter-"..lv
	local ades=false
	if(x:ValidPointA())then if(logs or x.PointA.surface~=f)then x:DestroyPointA() x:DestroyLogisticsA() elseif(x.PointA.name~=makeA)then x:DestroyPointA() ades=true end end
	if(not x.PointA or not x.PointA.valid)then if(not ades)then warptorio.cleanbbox(f,-2-lgx-(lgv and 2 or 0),4,3+(lgv and 4 or 0)+lgx*2,3) end local e=x:SpawnPointA("warptorio-teleporter-"..lv,f,{x=-1,y=5}) e.minable=false e.destructible=false end

	local makeB="warptorio-teleporter-gate-"..lv
	if(x:ValidPointB())then if(x.PointB.name~=makeB)then bpos=x.PointB.position x:DestroyPointB() elseif(x.PointB.surface.name~=f.name)then x:DestroyPointB() x:DestroyLogisticsB() end end
	if(not x:ValidPointB())then bpos=f.find_non_colliding_position("warptorio-teleporter-gate-"..lv,bpos,0,1,1) local e=x:SpawnPointB("warptorio-teleporter-gate-"..lv,f,{x=bpos.x,y=bpos.y},true) end

	if(lgv and not upgr)then x:SpawnLogistics() end
	warptorio.playsound("warp_in",f.name)
	return x
end
function tpcls.b1(upgr,logs)
	local lv=gwarptorio.Research["factory-energy"] or 0
	local x=gwarptorio.Teleporters["b1"] if(not x)then x=new(TELL,"b1",true) end
	local m=gwarptorio.Floors.main local f=m:GetSurface()
	local mb=gwarptorio.Floors.b1 local fb=mb:GetSurface()
	local lgv=(gwarptorio.Research["factory-logistics"] or 0)>0
	local lgx=gwarptorio.Research["dualloader"] or 0
	local vx = -2-(lgv and 2 or 0)-lgx
	local vw = 3+(lgv and 4 or 0)+lgx*2
	local makeA,makeB="warptorio-underground-"..lv,"warptorio-underground-"..lv
	local ades=false local bdes=false
	if(x:ValidPointA())then if((logs or x.PointA.surface~=f))then x:DestroyPointA() x:DestroyLogisticsA() elseif(x.PointA~=makeA)then x:DestroyPointA() ades=true end end
	if(x:ValidPointB())then if((logs or x.PointB.surface~=fb))then x:DestroyPointB() x:DestroyLogisticsB() elseif(x.PointB~=makeB)then x:DestroyPointB() bdes=true end end
	if(not x.PointA or not x.PointA.valid)then
		if(not ades)then warptorio.cleanbbox(f,vx,-8,vw,3) end
		local e=x:SpawnPointA(makeA,f,{x=-1,y=-7}) e.minable=false e.destructible=false
	end --- 7,-8  13,3
	if(not x.PointB or not x.PointB.valid)then
		if(not bdes)then warptorio.cleanbbox(fb,vx,-8,vw,3) end
		local e=x:SpawnPointB(makeB,fb,{x=-1,y=-7}) e.minable=false e.destructible=false
	end

	x:ConnectCircuit()

	if(lgv and not upgr)then x:SpawnLogistics() end
	warptorio.playsound("warp_in",f.name)
	return x
end


function tpcls.b2(upgr,logs)
	local lv=gwarptorio.Research["factory-energy"] or 0
	local x=gwarptorio.Teleporters["b2"] if(not x)then x=new(TELL,"b2",false) end
	local m=gwarptorio.Floors.b1 local f=m:GetSurface()
	local mb=gwarptorio.Floors.b2 local fb=mb:GetSurface()
	local lgv=(gwarptorio.Research["factory-logistics"] or 0)>0
	local lgx=gwarptorio.Research["dualloader"] or 0
	local makeA,makeB="warptorio-underground-"..lv,"warptorio-underground-"..lv
	local ades=false local bdes=false
	if(x:ValidPointA())then if(logs or x.PointA.surface~=f)then x:DestroyPointA() x:DestroyLogisticsA() elseif(x.PointA.name~=makeA)then x:DestroyPointA() ades=true end end
	if(x:ValidPointB())then if((logs or x.PointB.surface~=fb))then x:DestroyPointB() x:DestroyLogisticsB() elseif(x.PointB.name~=makeB)then x:DestroyPointB() bdes=true end end
	local vx = -2-(lgv and 2 or 0)-lgx
	local vw = 3+(lgv and 4 or 0)+lgx*2
	if(not x:ValidPointA())then if(not ades)then warptorio.cleanbbox(f,vx,4,vw,3) end local e=x:SpawnPointA(makeA,f,{x=-1,y=5}) e.minable=false e.destructible=false end
	if(not x:ValidPointB())then if(not bdes)then warptorio.cleanbbox(fb,vx,4,vw,3) end local e=x:SpawnPointB(makeB,fb,{x=-1,y=5}) e.minable=false e.destructible=false end
	if(lgv and not upgr)then x:SpawnLogistics() end

	x:ConnectCircuit()
	warptorio.playsound("warp_in",f.name)
	return x
end


function warptorio.SpawnTurretTeleporter(c,xp,yp,upgr,logs)
	local lv=gwarptorio.Research["turret-"..c] or 0
	local x=gwarptorio.Teleporters[c] if(not x)then x=new(TELL,c,(c=="nw" or c=="ne")) end
	local m=gwarptorio.Floors.main local f=m:GetSurface()
	local mb=gwarptorio.Floors.b1 local fb=mb:GetSurface()
	local lvge=gwarptorio.Research["factory-energy"] or 0
	local makeA,makeB="warptorio-underground-"..lvge,"warptorio-underground-"..lvge

	local ades=false local bdes=false
	if(x:ValidPointA())then if((logs or x.PointA.surface~=f))then x:DestroyPointA() x:DestroyLogisticsA() elseif(x.PointA.name~=makeA)then x:DestroyPointA() ades=true end end
	if(x:ValidPointB())then if((logs or x.PointB.surface~=fb))then x:DestroyPointB() x:DestroyLogisticsB() elseif(x.PointB.name~=makeB)then x:DestroyPointB() bdes=true end end
	local lgv=(gwarptorio.Research["factory-logistics"] or 0)>0
	local lgx=gwarptorio.Research["triloader"] or 0
	local vx = -1-(lgv and 2 or 0)-lgx
	local vw = 3+(lgv and 4 or 0)+lgx*2
	if(not x:ValidPointA())then if(not (upgr) and not ades)then warptorio.cleanbbox(f,xp+vx,yp-1,vw,3) end local e=x:SpawnPointA(makeA,f,{x=xp,y=yp}) e.minable=false e.destructible=false end
	if(not x:ValidPointB())then if(not (upgr) and not bdes)then warptorio.cleanbbox(fb,xp+vx,yp-1,vw,3) end local e=x:SpawnPointB(makeB,fb,{x=xp,y=yp}) e.minable=false e.destructible=false end

	if(lgv and not upgr)then x:SpawnLogistics() end

	x:ConnectCircuit()
	warptorio.playsound("warp_in",f.name)
	return x
end


function warptorio.LaySquare(tex,f,x,y,w,h) local wf,wc=math.floor(w/2),math.ceil(w/2) local hf,hc=math.floor(h/2),math.ceil(h/2) local t={}
	for xv=x-wf,x+wc do for yv=y-hf,y+hf do table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t)
end
function warptorio.LaySquareEx(tex,f,x,y,w,h) local wf,wc=math.ceil(w/2),math.floor(w/2) local hf,hc=math.floor(h/2),math.ceil(h/2) local t={}
	for xv=x-wf,x+wc do for yv=y-hf,y+hc do table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t)
end

function warptorio.LayCircle(tex,f,x,y,z,b) local zf=math.floor(z/2) local t={} --if(b)then local bbox={area={{x-z/2,y-z/2},{x+z,y+z}}} f.destroy_decoratives(bbox) end
	for xv=x-zf,x+math.floor(z/2) do for yv=y-zf,y+zf do local dist=math.sqrt(((xv-x)^2)+((yv-y)^2)) if(dist<=z/2)then table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t) end
end

warptorio.corn={}
warptorio.corn.nw={x=-52,y=-52}
warptorio.corn.ne={x=50,y=-52}
warptorio.corn.sw={x=-52,y=50}
warptorio.corn.se={x=50,y=50}
warptorio.corn.north=-52
warptorio.corn.south=50
warptorio.corn.east=50
warptorio.corn.west=-51.5

function tpcls.nw(upgr,logs) local c=warptorio.corn.nw warptorio.SpawnTurretTeleporter("nw",c.x,c.y,upgr,logs) gwarptorio.Turrets.nw=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.sw(upgr,logs) local c=warptorio.corn.sw warptorio.SpawnTurretTeleporter("sw",c.x,c.y,upgr,logs) gwarptorio.Turrets.sw=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.ne(upgr,logs) local c=warptorio.corn.ne warptorio.SpawnTurretTeleporter("ne",c.x,c.y,upgr,logs) gwarptorio.Turrets.ne=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.se(upgr,logs) local c=warptorio.corn.se warptorio.SpawnTurretTeleporter("se",c.x,c.y,upgr,logs) gwarptorio.Turrets.sw=n warptorio.BuildPlatform() warptorio.BuildB1() end


function warptorio.BuildPlatform() local m=gwarptorio.Floors.main local f=m:GetSurface() local z=m.z
	local lv=(gwarptorio.Research["platform-size"] or 0)
	for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area={{math.floor(-z/2),math.floor(-z/2)},{(z/2)-1,(z/2)-1}}})do warptorio.TryCleanEntity(v) end

	warptorio.LayFloor("warp-tile-concrete",f,math.floor(-z/2),math.floor(-z/2),z,z,true) -- main platform



	local lvc={} for k,v in pairs({"nw","ne","sw","se"})do lvc[v]=gwarptorio.Research["turret-"..v] or -1 end
	local lvf=gwarptorio.Research["factory-energy"] or 0
	local lvfs=gwarptorio.Research["factory-size"]
	local lvt=gwarptorio.Research["teleporter-energy"]
	local lvs=gwarptorio.Research["factory-logistics"] or 0
	local lgv=(lvs)>0
	local lgx=math.min((gwarptorio.Research["triloader"] or 0)+(lgv and 1 or 0),1)
	local lgy=math.min((gwarptorio.Research["dualloader"] or 0)+(lgv and 1 or 0),1) --3
	local vx = -2-(lgv and 2 or 0)-lgx
	local vw = 3+(lgv and 4 or 0)+lgx*2

	warptorio.LayFloor("hazard-concrete-left",f,-3,-3,5,5) -- warp reactor

	if(lv>0)then
		lgv=((lvt or 0)>0 or lvs>0 or lvfs)
		local vx = -2-(lgv and 2 or 0)-(lvt and lgx or 0)
		local vw = 3+(lgv and 4 or 0)+(lvt and lgx*2 or 0)
		warptorio.LayFloor("hazard-concrete-left",f,vx,4,vw,3) --teleporter
		lgv=(lvfs or lvs>0)
		local vx = -2-(lgv and 2 or 0)-(lvfs and lgy or 0)
		local vw = 3+(lgv and 4 or 0)+(lvfs and lgy*2 or 0)
		warptorio.LayFloor("hazard-concrete-left",f,vx,-8,vw,3) -- underground

		--warptorio.LayFloor("hazard-concrete-left",f,-3,-5,5,5) -- radar
		--warptorio.LayFloor("hazard-concrete-left",f,4,-2,3,3) -- solar stabilizer
	end

	if(lv>=6)then -- trains
		for k,v in pairs({nw={-1,-1},ne={0,-1},sw={-1,0},se={0,0}})do local c=warptorio.railCorn[k]
			warptorio.LayFloor("hazard-concrete-left",f,c.x+v[1],c.y+v[2],2,2)
		end
	end

	lgv=(true)
	local vx = -1-(lgv and 2 or 0)-lgx
	local vw = 3+(lgv and 4 or 0)+lgx*2
	local c=warptorio.corn
	if(lvc.nw>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.nw.x+0.5,c.nw.y+0.5},radius=(11+lvc.nw*6)/2})do warptorio.TryCleanEntity(v) end
		warptorio.LayCircle("warp-tile-concrete",f,c.nw.x,c.nw.y,11+lvc.nw*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.nw.x+vx,c.nw.y-1,vw,3)
	end
	if(lvc.ne>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.ne.x+0.5,c.ne.y+0.5},radius=(11+lvc.ne*6)/2})do warptorio.TryCleanEntity(v) end
		warptorio.LayCircle("warp-tile-concrete",f,c.ne.x,c.ne.y,11+lvc.ne*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.ne.x+vx,c.ne.y-1,vw,3)
	end
	if(lvc.sw>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.sw.x+0.5,c.sw.y+0.5},radius=(11+lvc.sw*6)/2})do warptorio.TryCleanEntity(v) end
		warptorio.LayCircle("warp-tile-concrete",f,c.sw.x,c.sw.y,11+lvc.sw*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.sw.x+vx,c.sw.y-1,vw,3)
	end
	if(lvc.se>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.se.x+0.5,c.se.y+0.5},radius=(11+lvc.se*6)/2})do warptorio.TryCleanEntity(v) end
		warptorio.LayCircle("warp-tile-concrete",f,c.se.x,c.se.y,11+lvc.se*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.se.x+vx,c.se.y-1,vw,3)
	end


	--local z=31 --m.InnerSize or 24
	--warptorio.LayBorder("hazard-concrete-left",f,math.floor(-z/2),math.floor(-z/2),z,z)
end

function warptorio.BuildB1() local m=gwarptorio.Floors.b1 local f=m:GetSurface() local z=m.z

	local t={} for k,v in pairs({"nw","ne","sw","se"}) do t[v]=(gwarptorio.Research["turret-"..v]) or -1 end
	local c=warptorio.corn
	local rsz=gwarptorio.Research.bridgesize or 0
	local cz=6+(rsz)*4
	local cpz=59+(rsz)*2
	local crz=10+rsz*2

	-- Paths
	if((t.nw>=0 or t.ne>=0))then
		warptorio.LaySquare("warp-tile-concrete",f,-1,c.north/2,crz,cpz)
		if(t.nw>=0)then warptorio.LaySquare("warp-tile-concrete",f,(c.west/2),c.north,cpz,cz) end
		if(t.ne>=0)then warptorio.LaySquare("warp-tile-concrete",f,(c.east/2)-1,c.north,cpz,cz) end
	end
	if((t.sw>=0 or t.se>=0))then
		warptorio.LaySquare("warp-tile-concrete",f,-1,math.floor(c.south/2)-1,crz,cpz)
		if(t.sw>=0)then warptorio.LaySquare("warp-tile-concrete",f,(c.west/2),c.south,cpz,cz) end
		if(t.se>=0)then warptorio.LaySquare("warp-tile-concrete",f,(c.east/2)-1,c.south,cpz,cz) end
	end
	if((t.nw>=0 or t.sw>=0))then
		warptorio.LaySquare("warp-tile-concrete",f,math.floor(c.west/2)+1,-1,cpz+1,crz)
		if(t.nw>=0)then warptorio.LaySquare("warp-tile-concrete",f,c.west,(c.north/2),cz,cpz) end
		if(t.sw>=0)then warptorio.LaySquare("warp-tile-concrete",f,c.west,(c.south/2),cz,cpz) end
	end
	if((t.ne>=0 or t.se>=0))then
		warptorio.LaySquare("warp-tile-concrete",f,math.floor(c.east/2)-2,-1,cpz,crz)
		if(t.ne>=0)then warptorio.LaySquare("warp-tile-concrete",f,c.east,(c.north/2),cz,cpz) end
		if(t.se>=0)then warptorio.LaySquare("warp-tile-concrete",f,c.east,(c.south/2),cz,cpz) end
	end


	local lvc={} for k,v in pairs({"nw","ne","sw","se"})do lvc[k]=gwarptorio.Research["turret-"..v] or -1 end
	local lvf=gwarptorio.Research["factory-energy"] or 0
	local lvfs=gwarptorio.Research["factory-size"]
	local lvbs=gwarptorio.Research["boiler-size"]
	local lvs=gwarptorio.Research["factory-logistics"] or 0
	local lgv=(lvs)>0
	local lgx=math.min((gwarptorio.Research["triloader"] or 0)+(lgv and 1 or 0),1)
	local lgy=math.min((gwarptorio.Research["dualloader"] or 0)+(lgv and 1 or 0),1) --3
	lgv=(lvfs) or lvs>0
	local vx = -1-(lgv and 2 or 0)-lgx
	local vw = 3+(lgv and 4 or 0)+lgx*2

	-- Turrets
	if(t.nw>=0)then local z=10+t.nw*6 t.nwz=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile-concrete",f,c.nw.x,c.nw.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.nw.x+vx,c.nw.y-1,vw,3) end
	if(t.ne>=0)then local z=10+t.ne*6 t.nez=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile-concrete",f,c.ne.x,c.ne.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.ne.x+vx,c.ne.y-1,vw,3) end
	if(t.sw>=0)then local z=10+t.sw*6 t.swz=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile-concrete",f,c.sw.x,c.sw.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.sw.x+vx,c.sw.y-1,vw,3) end
	if(t.se>=0)then local z=10+t.se*6 t.sez=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile-concrete",f,c.se.x,c.se.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.se.x+vx,c.se.y-1,vw,3) end

	lgv=(lvfs) or lvs>0
	local vx = -2-(lgv and 2 or 0)-(lvfs and lgy or 0)
	local vw = 3+(lgv and 4 or 0)+(lvfs and lgy*2 or 0)
	warptorio.LayFloor("warp-tile-concrete",f,math.floor(-z/2),math.floor(-z/2),z,z)
	warptorio.LayFloor("hazard-concrete-left",f,vx,-8,vw,3) -- entrance

	lgv=(lvbs) or lvs>0
	local vx = -2-(lgv and 2 or 0)-(lvbs and lgy or 0)
	local vw = 3+(lgv and 4 or 0)+(lvbs and lgy*2 or 0)
	warptorio.LayFloor("hazard-concrete-left",f,vx,4,vw,3) -- boiler
	warptorio.LayFloor("hazard-concrete-left",f,-2,-2,3,3) -- beacon

	local lvx=gwarptorio.Research["factory-size"] or 0
	if(lvx>=7)then
		local zvx=96-12 local zvy=128-16 local zxm=32 local zxn=12 local zxc=10
		if(gwarptorio.factory_w)then warptorio.LaySquare("warp-tile-concrete",f,-z-zxm-6,-1,zvx,zvy)
			warptorio.LaySquare("warp-tile-concrete",f,c.west-zxn,-9-1,zxc,zxc) warptorio.LaySquare("warp-tile-concrete",f,c.west-zxn,9-1,zxc,zxc) end
		if(gwarptorio.factory_e)then warptorio.LaySquare("warp-tile-concrete",f,z+zxm+4,-1,zvx,zvy)
			warptorio.LaySquare("warp-tile-concrete",f,c.east+zxn,-9-1,zxc,zxc) warptorio.LaySquare("warp-tile-concrete",f,c.east+zxn,9-1,zxc,zxc) end
		if(gwarptorio.factory_n)then warptorio.LaySquare("warp-tile-concrete",f,-1,-z-zxm-6,zvy,zvx)
			warptorio.LaySquare("warp-tile-concrete",f,-9-0.5,c.north-zxn,zxc,zxc) warptorio.LaySquare("warp-tile-concrete",f,9-0.5,c.north-zxn,zxc,zxc) end
		if(gwarptorio.factory_s)then warptorio.LaySquare("warp-tile-concrete",f,-1,z+zxm+4,zvy,zvx)
			warptorio.LaySquare("warp-tile-concrete",f,-9-1,c.south+zxn,zxc,zxc) warptorio.LaySquare("warp-tile-concrete",f,9-1,c.south+zxn,zxc,zxc) end

		--for k,v in pairs({nw={-1,-1},sw={-1,-1},ne={-1,-1},se={-1,-1}})do local c=warptorio.railCorn[k] warptorio.LayFloor("hazard-concrete-left",f,c.x+v[1],c.y+v[2],2,2) end
	end
	

	if((lvfs or 0)>=7)then -- trains
		for k,rv in pairs(warptorio.railOffset)do local rc=warptorio.railCorn[k] local rvx=warptorio.railLoader[k]
			warptorio.LayFloor("hazard-concrete-left",f,rc.x-1,rc.y-1,2,2)
			warptorio.LayFloor("hazard-concrete-left",f,rc.x-1+rvx[1][1],rc.y-1+rvx[1][2],2,2)
			warptorio.LayFloor("hazard-concrete-left",f,rc.x-1+rvx[2][1],rc.y-1+rvx[2][2],2,2)
		end
	end



	warptorio.playsound("warp_in",f.name)
end



function warptorio.BuildB2() local m=gwarptorio.Floors.b2 local f,z=m:GetSurface(),m.z

	local lvc={} for k,v in pairs({"nw","ne","sw","se"})do lvc[k]=gwarptorio.Research["turret-"..v] or -1 end
	local lvf=gwarptorio.Research["factory-energy"] or 0
	local lvfs=gwarptorio.Research["factory-size"]
	local lvbs=gwarptorio.Research["boiler-size"]
	local lvs=gwarptorio.Research["factory-logistics"] or 0
	local lgv=(lvs)>0
	local lgx=math.min((gwarptorio.Research["triloader"] or 0)+(lgv and 1 or 0),1)
	local lgy=math.min((gwarptorio.Research["dualloader"] or 0)+(lgv and 1 or 0),1) --3
	lgv=(lvbs) or lvs>0
	local vx = -2-(lgv and 2 or 0)-lgy
	local vw = 3+(lgv and 4 or 0)+lgy*2

	warptorio.LayFloor("warp-tile-concrete",f,math.floor(-z/3),math.floor(-z),(z/3)*2,(z*2)-1)
	warptorio.LayFloor("warp-tile-concrete",f,math.floor(-z),math.floor(-z/3),(z*2)-1,(z/3)*2)

	local lv=gwarptorio.waterboiler or 0
	if(lv>0)then
		local zx=2+lv
		warptorio.LayFloor("deepwater",f,math.floor(-z/3)-zx,math.floor(-z/3)-zx,zx,zx)
		warptorio.LayFloor("deepwater",f,math.floor(z/3),math.floor(-z/3)-zx,zx,zx)
		warptorio.LayFloor("deepwater",f,math.floor(z/3),math.floor(z/3),zx,zx)
		warptorio.LayFloor("deepwater",f,math.floor(-z/3)-zx,math.floor(z/3),zx,zx)
	end
	local lvx=gwarptorio.Research["boiler-size"] or 0
	if(lvx>=7)then
		local zvx=64 local zvy=96+1 local zxm=32
		if(gwarptorio.boiler_w)then warptorio.LaySquareEx("warp-tile-concrete",f,-z-zxm-6-1,-1,zvx,zvy-0.5) warptorio.LaySquare("warp-tile-concrete",f,-z-5,-9-1,7,7) warptorio.LaySquare("warp-tile-concrete",f,-z-5,9,7,7)
			end
		if(gwarptorio.boiler_e)then warptorio.LaySquareEx("warp-tile-concrete",f,z+zxm+6-1,-1,zvx,zvy+0.5) warptorio.LaySquare("warp-tile-concrete",f,z+2,-9-1,7,7) warptorio.LaySquare("warp-tile-concrete",f,z+2,9,7,7)
			end
		if(gwarptorio.boiler_n)then warptorio.LaySquare("warp-tile-concrete",f,-1,-z-zxm-6-1,zvy,zvx) warptorio.LaySquare("warp-tile-concrete",f,-9-1,-z-4,7-1,7) warptorio.LaySquare("warp-tile-concrete",f,9,-z-4,7-1,7)
			end
		if(gwarptorio.boiler_s)then warptorio.LaySquare("warp-tile-concrete",f,-1,z+zxm+6-1,zvy,zvx) warptorio.LaySquare("warp-tile-concrete",f,-9-1,z+2,7-1,7) warptorio.LaySquare("warp-tile-concrete",f,9,z+2,7-1,7)
			end
	end
	
	warptorio.LayFloor("hazard-concrete-left",f,vx,4,vw,3) -- entrance
	warptorio.LayFloor("hazard-concrete-left",f,-2,-2,3,3) -- old center
	warptorio.playsound("warp_in",f.name)
end


warptorio.teleDir={[0]={0,-1},[1]={1,-1},[2]={1,0},[3]={1,1},[4]={0,1},[5]={-1,1},[6]={-1,0},[7]={-1,-1}}
function warptorio.TickTeleporters(e) for k,v in pairs(gwarptorio.Teleporters)do if(v.PointA and v.PointB and v.PointA.valid and v.PointB.valid)then
	for i,e in pairs({v.PointA,v.PointB})do
		local o=(i==1 and v.PointB or v.PointA) local x=e.position local p=e.surface.find_entities_filtered{area={{x.x-1.2,x.y-1.2},{x.x+1.2,x.y+1.2}},type="character"}
		for a,b in pairs(p)do
			local inv=b.get_main_inventory().get_item_count()
			if(e.energy and v.cost and false)then
				local bp=o.position local dist=math.sqrt((x.x+bp.x)^2+(x.y+bp.y)^2) local jc=(inv*2000)*(1+dist/200)
				if(e.energy<jc)then warptorio.PrintToCharacter(b,"Not enough energy to teleport! You may have too much in your inventory") break end
				e.energy=math.max(e.energy-jc,0)
				warptorio.playsound("teleport",e.surface.name,e.position) warptorio.playsound("teleport",o.surface.name,o.position)
			else
				warptorio.playsound("teleport",e.surface.name,e.position) warptorio.playsound("teleport",o.surface.name,o.position)
			end
			local w=b.walking_state
			local ox=o.position
			if(not w.walking)then local cp=b.position local xd,yd=(x.x-cp.x),(x.y-cp.y) warptorio.safeteleport(b,{x=ox.x+xd*1.25,y=ox.y+yd*1.25},o.surface)
			else local td=warptorio.teleDir[w.direction] warptorio.safeteleport(b,{x=ox.x+td[1]*2,y=ox.y+td[2]*2},o.surface) end
		end
	end
end end end

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



-- --------
-- Warptorio Entities


warptorio.CacheMonitor={["warptorio-heatpipe"]="heat",["warptorio-accumulator"]="power",["warptorio-reactor"]="heat"}


function warptorio.GetCache(k) return gwarptorio.cache[k] end -- can add validation here
function warptorio.InsertCache(k,v) return table.insertExclusive(gwarptorio.cache[k],v) end
function warptorio.RemoveCache(k,v) table.RemoveByValue(gwarptorio.cache[k],v) end
function warptorio.InsertCacheLoader(v) local cv=(v.loader_type=="input" and "loaderIn" or "loaderOut") warptorio.InsertCache(cv,v)
end
function warptorio.RemoveCacheLoader(v) local cv=(v.loader_type=="input" and "loaderIn" or "loaderOut") warptorio.RemoveCache(cv,v)
end

function warptorio.ValidateCache()
	local t={} for k,v in pairs(gwarptorio.cache["heat"])do if(not isvalid(v))then table.insert(t,v) end end for k,v in pairs(t)do warptorio.RemoveCache("heat",v) end
	local t={} for k,v in pairs(gwarptorio.cache["power"])do if(not isvalid(v))then table.insert(t,v) end end for k,v in pairs(t)do warptorio.RemoveCache("power",v) end
	--local t={} for k,v in pairs(gwarptorio.cache["loaderIn"])do if(not isvalid(v))then table.insert(t,v) end end for k,v in pairs(t)do warptorio.RemoveCacheLoader(v) end
	--local t={} for k,v in pairs(gwarptorio.cache["loaderOut"])do if(not isvalid(v))then table.insert(t,v) end end for k,v in pairs(t)do warptorio.RemoveCacheLoader(v) end
end

function warptorio.BuildCache()
	for a,f in pairs(game.surfaces)do
		for k,v in pairs(f.find_entities_filtered{name={"warptorio-warploader"}})do warptorio.InsertCacheLoader(v) end
		for k,v in pairs(f.find_entities_filtered{name={"warptorio-heatpipe"}})do warptorio.InsertCache("heat",v) end
		for k,v in pairs(f.find_entities_filtered{name={"warptorio-accumulator"}})do warptorio.InsertCache("power",v) end
	end
	if(gwarptorio.warp_reactor and gwarptorio.warp_reactor.valid)then warptorio.InsertCache("heat",gwarptorio.warp_reactor) end
end

function warptorio.SpawnEntity(f,n,x,y,dir,type) local e=f.create_entity{name=n,position={x,y},force=game.forces.player,direction=dir,type=type,raise_built=true} e.last_user=game.players[1] return e end
function warptorio.ProtectEntity(e,min,des) if(min~=nil)then e.minable=min end if(des~=nil)then e.destructible=des end end


warptorio.BadCloneTypes={["offshore-pump"]=true,["resource"]=true}

local clone={} warptorio.OnEntCloned=clone
clone["warptorio-reactor"] = function(ev)
	--if gwarptorio.warpenergy then event.destination.insert{name="warptorio-reactor-fuel-cell",count=1} end
	warptorio.RemoveCache("heat",ev.source) warptorio.InsertCache("heat",ev.destination)
	gwarptorio.warp_reactor = ev.destination
end
clone["warptorio-accumulator"] = function(ev) warptorio.RemoveCache("power",ev.source) warptorio.InsertCache("power",ev.destination) end
clone["warptorio-heatpipe"] = function(ev) warptorio.RemoveCache("heat",ev.source) warptorio.InsertCache("heat",ev.destination) end
clone["warptorio-warploader"] = function(ev) warptorio.RemoveCacheLoader(ev.source) warptorio.InsertCacheLoader(ev.destination) end

function warptorio.OnEntityCloned(ev) local d,e=ev.destination,ev.source local type,name=d.type,d.name
	--if(name:sub(1,8)=="factory-")then script.raise_event(defines.events.on_cancelled_deconstruction,{entity=d}) return end
	if(type=="character" or warptorio.BadCloneTypes[name])then d.destroy{raise_destroy=true,do_cliff_correction=true} return elseif(clone[name])then clone[name](ev) return end
	for k,v in pairs(gwarptorio.Teleporters)do
		if(k~="offworld")then if(e==v.PointA)then v.PointA=d v:ConnectCircuit() return elseif(e==v.PointB)then v.PointB=d v:ConnectCircuit() return
			elseif(v.logs)then for a,x in pairs(v.logs)do if(e==x)then v.logs[a]=d return end end end
		elseif(v.logs)then for a,x in pairs(v.logs)do if(ev.source==x)then v.logs[a]=d return end end
		end
	end
	if(type=="entity-ghost")then if(e.direction)then d.direction=e.direction elseif(d.ghost_type=="splitter")then local df,dp=d.surface,d.position d.destroy()
		d=df.create_entity{name="entity-ghost",force=e.force,player=e.last_user,inner_name=e.ghost_name,expires=e.time_to_live,position=dp,direction=e.direction} d.copy_settings(e)
	end end

end script.on_event(defines.events.on_entity_cloned, warptorio.OnEntityCloned)


function warptorio.TrySpawnTeleporterGate(e) local en=e.surface.name local t=gwarptorio.Teleporters["offworld"]
	if(t:ValidPointB())then e.destroy{raise_destroy=true,do_cliff_correction=true} game.print("Max 1 Planet Teleporter Gate allowed at a time") return false end t:SetPointB(e)
	if(en==gwarptorio.Floors.b1:GetSurface().name or en==gwarptorio.Floors.b2:GetSurface().name)then game.print("The Teleporter only functions on the Planet") return false end t:Warpin()
end
function warptorio.TrySpawnWarploader(e)
	warptorio.InsertCacheLoader(e)
end

function warptorio.DoOnBuiltEntity(ev) local e=ev.created_entity if(not e)then e=ev.entity end
	if(warptorio.IsTeleporterGate(e))then warptorio.TrySpawnTeleporterGate(e)
	elseif(warptorio.IsWarpLoader(e))then warptorio.TrySpawnWarploader(e)
	elseif(warptorio.CacheMonitor[e.name])then warptorio.InsertCache(warptorio.CacheMonitor[e.name],e) end
end
function warptorio.OnBuiltEntity(ev) warptorio.DoOnBuiltEntity(ev) local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_built_entity",ev) end end
function warptorio.OnRobotBuiltEntity(ev) warptorio.DoOnBuiltEntity(ev) local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_robot_built_entity",ev) end end
function warptorio.OnScriptRaisedBuilt(ev) warptorio.DoOnBuiltEntity(ev) local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"script_raised_built",ev) end end
function warptorio.OnScriptRevived(ev) warptorio.DoOnBuiltEntity(ev) local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"script_raised_revive",ev) end end
script.on_event(defines.events.on_built_entity, warptorio.OnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, warptorio.OnRobotBuiltEntity)
script.on_event(defines.events.script_raised_built, warptorio.OnScriptRaisedBuilt)
script.on_event(defines.events.script_raised_revive, warptorio.OnScriptRevived)

function warptorio.OnPlayerMinedEntity(ev) local e=ev.entity
	if(warptorio.IsTeleporterGate(e))then local t=gwarptorio.Teleporters["offworld"] t:DestroyLogisticsB()
	elseif(warptorio.IsWarpLoader(e))then warptorio.RemoveCacheLoader(e)
	elseif(warptorio.CacheMonitor[e.name])then warptorio.RemoveCache(warptorio.CacheMonitor[e.name],e)
	end
end script.on_event({defines.events.on_player_mined_entity,defines.events.on_robot_mined_entity,defines.events.script_raised_destroy},warptorio.OnPlayerMinedEntity)

function warptorio.OnEntityDied(ev) local e=ev.entity if(warptorio.IsTeleporterGate(e))then local t=gwarptorio.Teleporters["offworld"] t:DestroyLogisticsB() t.PointB=nil t:Warpin()
	else warptorio.OnPlayerMinedEntity(ev) end
	local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_entity_died",ev) end
end script.on_event(defines.events.on_entity_died,warptorio.OnEntityDied)

function warptorio.IsTeleporterGate(e) return (e.name:sub(1,25)=="warptorio-teleporter-gate") end
function warptorio.IsWarpLoader(e) return e.name=="warptorio-warploader" end

function warptorio.CheckWarpReactor()
	local v=gwarptorio.warp_reactor if(isvalid(v))then return end
end

function warptorio.GetTransportLines(v) return {v.get_transport_line(1),v.get_transport_line(2)} end

function warptorio.TickWarpLoaders()
	local inv={} local con={} local wlb=gwarptorio.cache.loaderOutFilter local con=gwarptorio.cache.loaderOutNext local cin=gwarptorio.cache.loaderInNext
	for k,v in pairs(gwarptorio.cache.loaderIn)do if(v.valid)then for u,l in pairs(warptorio.GetTransportLines(v))do
		for a,b in pairs(l.get_contents())do if(wlb[a])then inv[a]=(inv[a] or {}) inv[a][l]=b con[a]=con[a] or 1 end end
	end end end
	for k,v in pairs(inv)do for l,c in pairs(v)do if(v[l]>0)then local vx=wlb[k] if(vx)then local cvx=#vx for i=1,cvx,1 do if(v[l]>0)then local ui=((con[k])%(cvx))+1 con[k]=ui local fl=vx[ui]
			if(isvalid(fl) and fl.can_insert_at_back())then fl.insert_at_back({name=k,count=1}) l.remove_item{name=k,count=1} v[l]=v[l]-1 end
	end end end end end end
end

function warptorio.TickFindLoaders() gwarptorio.cache.loaderOutFilter={} local wlb=gwarptorio.cache.loaderOutFilter
	for k,v in pairs(gwarptorio.cache.loaderOut)do if(v.valid)then for i=1,5,1 do local lf=v.get_filter(i) if(lf)then wlb[lf]=wlb[lf] or {}
		for a,b in pairs(warptorio.GetTransportLines(v))do table.insert(wlb[lf],b) end
	end end end end
end

function warptorio.TickLogistics(e)
	for k,v in pairs(gwarptorio.Teleporters)do v:BalanceLogistics() end
	for k,v in pairs(gwarptorio.Rails)do v:BalanceLogistics() end

end

function warptorio.TickEnergy(e)
	local points={}
	for k,v in pairs(gwarptorio.Teleporters)do if(v:ValidPointA())then table.insert(points,v.PointA) end if(v:ValidPointB())then table.insert(points,v.PointB) end end
	for k,v in pairs(gwarptorio.cache.power)do if(v.valid)then table.insert(points,v) end end
	local pnum=#points local eg=0 local ec=0
	for k,v in pairs(points)do eg=eg+v.energy ec=ec+v.electric_buffer_size end
	for k,v in pairs(points)do local r=(v.electric_buffer_size/ec) v.energy=eg*r end
end

function warptorio.TickHeat(e) local t=gwarptorio.cache.heat local h=0 for k,v in pairs(t)do h=h+v.temperature end for k,v in pairs(t)do v.temperature=h/#t end end

function warptorio.OnPlayerRotatedEntity(ev)
	local e=ev.entity
	if(warptorio.IsWarpLoader(e))then
		local ot=(e.loader_type=="input" and "loaderOut" or "loaderIn") warptorio.RemoveCache(ot,e) warptorio.InsertCacheLoader(e) warptorio.TickFindLoaders()
	else
		for k,v in pairs(gwarptorio.Rails)do v:CheckLoaders() end
	end
end script.on_event(defines.events.on_player_rotated_entity, warptorio.OnPlayerRotatedEntity)


function warptorio.OnEntSettingsPasted(ev) local p=ev.player_index local e=ev.source local d=ev.destination
	if(warptorio.IsWarpLoader(e))then warptorio.TickFindLoaders() end
end script.on_event(defines.events.on_entity_settings_pasted,warptorio.OnEntSettingsPasted)




function warptorio.TickPollution()
	local f=gwarptorio.Floors.main:GetSurface()
	if(not f or not f.valid)then return end
	if(settings.global["warptorio_pollution_disable"].value~=true)then
		f.pollute({-1,-1},gwarptorio.pollution_amount)
		gwarptorio.pollution_amount = math.min( gwarptorio.pollution_amount+(gwarptorio.pollution_amount ^ settings.global['warptorio_pollution_exponent'].value), 1000000)
	end

	local m=gwarptorio.Floors
	local pb1=m.b1:GetSurface().get_total_pollution()
	local pb2=m.b2:GetSurface().get_total_pollution()
	gwarptorio.Floors.main:GetSurface().pollute({-1,-1},pb1+pb2)
	m.b1:GetSurface().clear_pollution()
	m.b2:GetSurface().clear_pollution()
	

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
end
function warptorio.TickWarpAlarm()
	if( (gwarptorio.warp_charging == 1 and gwarptorio.warp_time_left <= 3600) or (not gwarptorio.warp_reactor and gwarptorio.warp_auto_end <=3600) )then 
		warptorio.playsound("warp_alarm", gwarptorio.Floors.main:GetSurface().name)
	end 
end

local rsHomeworld=0
local rsHomeTimer=0

function warptorio.PlayerCanStartWarp(p) for k,v in pairs(gwarptorio.Floors)do if(v:GetSurface()==p.surface)then return true end end return false end
script.on_event(defines.events.on_gui_click, function(event)
	local gui = event.element
	local ply=game.players[event.player_index]
	if gui.name == "warptorio_dowarp" then
		if(gwarptorio.warp_charging<1)then local c=table_size(game.players)
			if(c>1 and settings.global["warptorio_votewarp_multi"].value>0)then --votewarp
				local vct={} for k,v in pairs(c)do if(v and v.valid and v.character)then table.insert(vct) end end
				local vcn=math.floor(table_size(vct)*settings.global["warptorio_votewarp_multi"].value)
				if(table_size(gwarptorio.votewarp)>=vcn)then
					gwarptorio.warp_charge_start_tick = event.tick
					gwarptorio.warp_charging = 1
				else
					table.insert(gwarptorio.votewarp,ply)
					warptorio.updatelabel("warptorio_home","Votewarp (" .. gwarptorio.votewarp .. "/" .. vcn .. ")")
				end
			elseif(warptorio.PlayerCanStartWarp(ply))then
				gwarptorio.warp_charge_start_tick = event.tick
				gwarptorio.warp_charging = 1
			else
				ply.print("You must be on the same planet as the platform to warp")
			end
		end

	elseif(gui.name == "warptorio_dostabilize")then -- Stabilizer
		warptorio.TryStabilizer()

	elseif(gui.name == "warptorio_radar")then -- Radar
		warptorio.TryRadar()
	elseif(gui.name=="warptorio_accel")then -- Accelerator
		warptorio.TryAccelerator()
	elseif(gui.name=="warptorio_home")then -- Do homeworld stuff
		if(gwarptorio.homeworld)then
			if(rsHomeTimer<game.tick)then
				rsHomeTimer=game.tick+(60*5)
			else
				gwarptorio.homeworld=gwarptorio.warpzone gwarptorio.Floors.home:SetSurface(gwarptorio.Floors.main:GetSurface()) gwarptorio.Floors.home.world=gwarptorio.planet
				rsHomeTimer=0 warptorio.updatelabel("warptorio_home","Settle")
				for k,v in pairs(gwarptorio.Floors)do local f=v:GetSurface() warptorio.playsound("warp_in",f.name) end
			end
		end
	end
end)



function warptorio.TickTimers(e)
	if(gwarptorio.warp_charging==1)then
		gwarptorio.warp_time_left=60*gwarptorio.warp_charge_time - (e-gwarptorio.warp_charge_start_tick)
		warptorio.updatelabel("warptorio_time_left","    Warp-out In : " .. util.formattime(gwarptorio.warp_time_left))
		if(gwarptorio.warp_time_left<=0)then
			warptorio.Warpout()
			gwarptorio.time_spent_start_tick=e
		end
	end
	gwarptorio.time_passed=e - gwarptorio.time_spent_start_tick
	warptorio.updatelabel("warptorio_time_passed","    Planet Time Passed : " .. util.formattime(gwarptorio.time_passed))

	if(rsHomeTimer>game.tick)then
		warptorio.updatelabel("warptorio_home","Confirm ? .. " .. util.formattime(rsHomeTimer-game.tick))
	elseif(gwarptorio.homeworld)then
		warptorio.updatelabel("warptorio_home","Settle")
	end

	local rta=(gwarptorio.Research.reactor or 0)
	if(warptorio.IsAutowarpEnabled())then
		gwarptorio.warp_auto_end=60*gwarptorio.warp_auto_time - (e-gwarptorio.warp_last)
		warptorio.updatelabel("warptorio_autowarp","    Auto-Warp In : " .. util.formattime(gwarptorio.warp_auto_end))
		if(gwarptorio.warp_auto_end<=0)then
			warptorio.Warpout()
			gwarptorio.time_spent_start_tick=e
		end
	else warptorio.updatelabel("warptorio_autowarp","") end

	if(gwarptorio.charting or gwarptorio.accelerator or gwarptorio.stabilizer)then
		local n=math.max((gwarptorio.ability_next or 0)-game.tick,0)
		if(n<=0)then warptorio.updatelabel("warptorio_ability_next","    Ability Ready!") else warptorio.updatelabel("warptorio_ability_next","    Cooldown : " .. util.formattime(n)) end
	end
end

function warptorio.TickChargeTimer(e)
	if(gwarptorio.warp_charging<1 and gwarptorio.warp_charge_time>30)then -- passive cooldown
		local r=60-(gwarptorio.Research["reactor"] or 0)*3
		if(e%(r*5)==0)then
			gwarptorio.warp_charge_time=math.max(gwarptorio.warp_charge_time-1,30)
			warptorio.updatelabel("warptorio_time_left","    Charge Time : " .. util.formattime(gwarptorio.warp_charge_time*60))
		end
	end
end

function warptorio.Tick(ev) local e=ev.tick
	local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_tick",ev) end

	warptorio.TickChargeTimer(e)
	warptorio.TickTeleporters(e)
	warptorio.TickEnergy(e)
	warptorio.TickWarpLoaders()
	if(e%5==0)then
		warptorio.TickLogistics(e)
		if(e%30==0)then
			if(e%60==0)then
				warptorio.TickTimers(e)
				if(e%120==0)then -- every 2 seconds
					-- attack left behind engineers (removed because not needed and factorissimo support)
					warptorio.TickPollution(e)
					warptorio.TickWarpAlarm(e)
					warptorio.TickHeat(e)
					warptorio.TickAccelerator(e)
					warptorio.TickStabilizer(e)
					if(e%(60*10)==0)then -- every 10 seconds
						warptorio.TickFindLoaders(e)
					end
				end
			end
		end
	end
end script.on_event(defines.events.on_tick,warptorio.Tick)



-- --------
-- Gui


function warptorio.ResetGui(p) if(not p)then for k,v in pairs(game.players)do if(v.valid and v.gui and v.gui.valid and v.gui.left.warptorio_frame)then warptorio.ResetGui(v) end end return end
	p.gui.left.warptorio_frame.clear() warptorio.BuildGui(p)
end

function warptorio.BuildGui(player)
	local gui=player.gui
	if(not gui.valid)then player.print("invalid gui error!") return end

	local f=gui.left.warptorio_frame if(f==nil)then f=gui.left.add{name="warptorio_frame",type="flow",direction="vertical"} end
	local fa=f.warptorio_line1 if(fa==nil)then fa=f.add{name="warptorio_line1",type="flow",direction="horizontal"} end
	local fb=f.warptorio_line2 if(fb==nil)then fb=f.add{name="warptorio_line2",type="flow",direction="horizontal"} end

	local g=fa.warptorio_dowarp if(g==nil)then g=fa.add{type="button",name="warptorio_dowarp",caption={"warptorio-warp"}} end
	local tgl={"(Random)"} if(gwarptorio.homeworld)then table.insert(tgl,"(Homeworld)") end if(gwarptorio.charting)then for k,v in pairs(warptorio.Planets)do table.insert(tgl,v.key) end end 
	local g=fa.warptorio_target if(g==nil)then g=fa.add{type="drop-down",name="warptorio_target",items={"(Random)"}} end g.items=tgl
	if(gwarptorio.homeworld)then local g=fa.warptorio_home if(g==nil)then g=fa.add{type="button",name="warptorio_home",caption={"warptorio-btnhome","-"}} end end

	local g=fa.warptorio_time_passed if(g==nil)then g=fa.add{type="label",name="warptorio_time_passed",caption={"warptorio-time-passed","-"}} end
	local g=fa.warptorio_time_left if(g==nil)then g=fa.add{type="label",name="warptorio_time_left",caption={"warptorio-time-left","-"}} end
	local g=fa.warptorio_warpzone if(g==nil)then g=fa.add{type="label",name="warptorio_warpzone",caption={"warptorio-warpzone","-"}} end
	local g=fa.warptorio_autowarp if(g==nil)then g=fa.add{type="label",name="warptorio_autowarp",caption={"warptorio-autowarp","-"}} end

	fa.warptorio_warpzone.caption="    Warp number : " .. (gwarptorio.warpzone or 0)
	fa.warptorio_time_left.caption="    Charge Time : " .. util.formattime((gwarptorio.warp_time_left or 0))
	if(gwarptorio.homeworld)then fa.warptorio_home.caption="Settle" end

	local rta=(gwarptorio.Research.reactor or 0)
	if(warptorio.IsAutowarpEnabled())then
		fa.warptorio_autowarp.caption="    Auto-Warp In : " .. util.formattime(gwarptorio.warp_auto_time*60)
	else warptorio.updatelabel("warptorio_autowarp","") end


	fb.clear()
	if(gwarptorio.stabilizer)then local g=fb.warptorio_dostabilize if(g==nil)then g=fb.add{type="button",name="warptorio_dostabilize",caption={"warptorio-stabilize"}} end end
	if(gwarptorio.charting)then local g=fb.warptorio_radar if(g==nil)then g=fb.add{type="button",name="warptorio_radar",caption={"warptorio-radar"}} end end
	if(gwarptorio.accelerator)then local g=fb.warptorio_accel if(g==nil)then g=fb.add{type="button",name="warptorio_accel",caption={"warptorio-accel"}} end end
	if(gwarptorio.stabilizer or gwarptorio.charting or gwarptorio.accelerator)then
		local g=fb.warptorio_ability_next if(g==nil)then g=fb.add{type="label",name="warptorio_ability_next",caption={"warptorio-ability-next","-"}} end
		local abc=math.max((gwarptorio.ability_next or 0)-game.tick,0)
		if(abc<=0)then g.caption="    Ability Ready!" else g.caption="    Cooldown : " .. util.formattime(abc) end

		local g=fb.warptorio_ability_uses if(g==nil)then g=fb.add{type="label",name="warptorio_ability_uses",caption={"warptorio-ability-uses","-"}} end
		g.caption="    Uses on this planet : " .. gwarptorio.ability_uses
	end


end

warptorio.SwitchingTarget=false
script.on_event(defines.events.on_gui_selection_state_changed,function(event) local gui=event.element local pidx=event.player_index
	if(gui.name=="warptorio_target" and not warptorio.SwitchingTarget)then warptorio.SwitchingTarget=true
		local s=gui.items[gui.selected_index] if(not s)then return end local sx=s:lower()
		if(sx=="(random)")then gwarptorio.planet_target=nil elseif(sx=="(homeworld)")then gwarptorio.planet_target="home" else gwarptorio.planet_target=sx end
		--for k,v in pairs(game.players)do if(v.index~=pidx)then warptorio.getlabelcontrol(v,"warptorio_target").selected_index=gui.selected_index end end
		game.print("Selected Planet: " .. s) warptorio.SwitchingTarget=false
	end
end)


function warptorio.TickAccelerator(e)
end

function warptorio.TickStabilizer(e)
end

function warptorio.IncrementAbility(c,m) c=c or 2.5 m=m or 5
	local n=gwarptorio.ability_uses+1
	gwarptorio.ability_uses=n
	gwarptorio.ability_next= game.tick+60*60*(m+(n)*c)
	warptorio.updatelabel("warptorio_ability_uses","    Uses : " .. n)
	warptorio.updatelabel("warptorio_ability_next","    Cooldown : " .. util.formattime(math.max(gwarptorio.ability_next-game.tick,0)) )
end

function warptorio.TryStabilizer() if(game.tick<(gwarptorio.ability_next or 0) or not gwarptorio.warp_reactor or not gwarptorio.warp_reactor.valid)then return end warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value,settings.global["warptorio_ability_cooldown"].value)
	game.forces["enemy"].evolution_factor=0	
	gwarptorio.pollution_amount = 1.25
	gwarptorio.pollution_expansion = 1.5
	local f=gwarptorio.Floors.main:GetSurface()
	f.clear_pollution()
	f.set_multi_command{command={type=defines.command.flee, from=gwarptorio.warp_reactor}, unit_count=1000, unit_search_distance=500}
	warptorio.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Stabilized")
end

function warptorio.TryRadar() if(game.tick<(gwarptorio.ability_next or 0))then return end warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value/1.25,settings.global["warptorio_ability_cooldown"].value*0.6)
	local n=gwarptorio.radar_uses+1 gwarptorio.radar_uses=n
	warptorio.updatelabel("warptorio_radar","Radar ("..n..")")
	local f=gwarptorio.Floors.main:GetSurface()
	game.forces.player.chart(f,{lefttop={x=-64-128*n,y=-64-128*n},rightbottom={x=64+128*n,y=64+128*n}})
	warptorio.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Scanner Sweep")
end

function warptorio.TryAccelerator() if(game.tick<(gwarptorio.ability_next or 0) or gwarptorio.warp_charge_time<=10)then return end warptorio.IncrementAbility(settings.global["warptorio_ability_timegain"].value,settings.global["warptorio_ability_cooldown"].value)
	gwarptorio.warp_charge_time=math.max(math.ceil(gwarptorio.warp_charge_time^0.9),10)
	if(gwarptorio.warp_charging~=1)then warptorio.updatelabel("warptorio_time_left","    Charge Time : " .. util.formattime(math.ceil(gwarptorio.warp_charge_time*60)) ) end
	local f=gwarptorio.Floors.main:GetSurface()
	warptorio.playsound("reactor-stabilized", f)
	game.print("Warp Reactor Accelerated")
end


-- Initialize Players
function warptorio.InitPlayer(e)
	local i=e.player_index
	local p=game.players[i]
	warptorio.BuildGui(p)
	--if(i==1)then warptorio.PostPlayerInit() end
	warptorio.safeteleport(p.character,{0,-5},gwarptorio.Floors.main:GetSurface())
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
	warptorio.BuildGui(p)
	if(p.character and p.character.valid)then warptorio.safeteleport(p.character,{0,-5},gwarptorio.Floors.main:GetSurface()) end
end script.on_event(defines.events.on_player_joined_game,warptorio.OnPlayerJoined)



function warptorio.OnCapsuleUse(ev)
	if(ev.item.name=="warptorio-townportal")then
		local p=game.players[ev.player_index]
		if(p.character and p.character.valid)then
			warptorio.safeteleport(p.character,{0,-5},gwarptorio.Floors.main:GetSurface())
			warptorio.playsound("teleport",p.character.surface.name,p.character.position)
			warptorio.playsound("teleport",gwarptorio.Floors.main:GetSurface().name,{0,-5})
		end
	end
end script.on_event(defines.events.on_player_used_capsule,warptorio.OnCapsuleUse)

function warptorio.OnPlayerRespawned(event) -- teleport to warp platform on respawn
	--local i=ev.player_index local player_port=ev.player_port
	local cf=gwarptorio.Floors.main:GetSurface() local gp=game.players[event.player_index]
	if(gp.character.surface~=cf)then local pos=cf.find_non_colliding_position("character",{0,-5},0,1,1) gp.teleport(pos,cf) end
end script.on_event(defines.events.on_player_respawned,warptorio.OnPlayerRespawned)




-- --------
-- Platforms

local FLOOR={} FLOOR.__index=FLOOR warptorio.FloorMeta=FLOOR
function FLOOR.__init(self,n,z) global.warptorio.Floors[n]=self self.f,self.n=f,n self.ents={} self:SetSize(z) end
function FLOOR:SetSize(z) self.z,self.x,self.y,self.w,self.h=z,-z/2,-z/2,z,z self:CalcSizebox() end
function FLOOR:CalcSizebox() self.pos={self.x,self.y} self.size={self.w,self.h}
	self.bbox={self.x+self.w-1,self.y+self.h-1} self.area={self.pos,self.bbox} self.sizebox={self.pos,self.size} end
function FLOOR:GetPos() return self.pos end
function FLOOR:GetSize() return self.size end
function FLOOR:GetBBox() return self.bbox end
function FLOOR:GetSizebox() return {self.pos,self.size} end
function FLOOR:SetSurface(f) self.f=f end
function FLOOR:GetSurface() return self.f end
function FLOOR:BuildSurface(id) if(self:GetSurface())then return end
	local f=game.create_surface(id,{default_enable_all_autoplace_controls=false,width=32*12,height=32*12,
		autoplace_settings={entity={treat_missing_as_default=false},tile={treat_missing_as_default=false},decorative={treat_missing_as_default=false}, }, starting_area="none",
	})
	f.always_day = true
	f.daytime=0
	f.request_to_generate_chunks({0,0},24)
	f.force_generate_chunk_requests()
	local e=f.find_entities() for k,v in pairs(e)do e[k].destroy{raise_destroy=true,do_cliff_correction=true} end
	--f.name=id
	f.destroy_decoratives({area={self.pos,self.bbox}})

	warptorio.LayFloor("out-of-map",f,-32*16,-32*16,32*16*2,32*16*2)
	self:SetSurface(f)
	return f
end
function FLOOR:CheckRadar()
	local rs=gwarptorio.charting
	if(rs and (not self.radar or not self.radar.valid))then local e=warptorio.SpawnEntity(self:GetSurface(),"warptorio-invisradar",-1,-1) self.radar=e e.minable=false e.destructible=false end
end

function warptorio.GetFloor(n) return global.warptorio.Floors[n] end
function warptorio.CurrentFloor() return global.warptorio.Floors["main"] end

function warptorio.RebuildFloors() warptorio.BuildPlatform() warptorio.BuildB1() warptorio.BuildB2() end
function warptorio.InitFloors() -- init_floors(f)
	local f=game.surfaces["nauvis"]
	local m=new(FLOOR,"main",6)
	m:SetSurface(f)
	m.OuterSize=9
	local z=m.OuterSize
	m:SetSize(m.OuterSize)

	warptorio.BuildPlatform()
	--warptorio.cleanbbox(f,math.floor(-z/2),math.floor(-z/2),z-1,z-1)

	local m=new(FLOOR,"b1",17)
	local f=m:BuildSurface("warpfloor-b1")
	warptorio.BuildB1()

	local m=new(FLOOR,"b2",17)
	local f=m:BuildSurface("warpfloor-b2")
	warptorio.BuildB2()
end




-- --------
-- Warpout

--[[
warptorio.Expressions={entity_prototypes={},tile_prototypes={}}
warptorio.ExpressionToggle={entity_prototypes={},tile_prototypes={}}

function warptorio.GetExpression(u,k) if(not warptorio.Expressions[u])then error("Invalid Expression Class: " .. tostring(u))
	elseif(not warptorio.Expressions[u][k])then local r=game[u][k].autoplace_specification if(r)then warptorio.Expressions[u][k]=table.deepcopy(r) end end
	return warptorio.Expressions[u][k]
end

function warptorio.StartExpression(u,k)
	local e=warptorio.GetExpression(u,k)
	gwarptorio.ExpressionToggle[u][k]=true
	game[u][k]=table.deepcopy(e)
	return e
end
function warptorio.StopExpression(u,k)
	local e=warptorio.GetExpression(u,k)
	e.ExpressionToggle[u][k]=false
	return e
end
function warptorio.ModifyExpression(u,k)
end
function warptorio.ResetExpression(u,k)
end

function warptorio.WalkResourcePlacement(t,o,z) if(t["1"]~=nil and t["2"]~=nil)then
		if(t["1"].variable_name=="distance" and t["2"].type=="literal_number")then
			t["2"].literal_value=o["2"].literal_value*z
		elseif(t["2"].variable_name=="distance" and t["1"].type=="literal_number")then
			t["1"].literal_value=o["1"].literal_value*z
		else
			for k,v in pairs(t)do if(type(v)=="table")then warptorio.WalkResourcePlacement(v,o[k]) end end
		end
	else
		for k,v in pairs(t)do if(type(v)=="table")then warptorio.WalkResourcePlacement(v,o[k]) end end
	end
end

warptorio.ResourceAutoplaceSpecs={}
function warptorio.TweakResourcePlacements(z)
	for k,v in pairs(game.entity_prototypes)do
		if(v.type=="resource" and v.autoplace_specification)then
			if(not warptorio.ResourceAutoplaceSpecs[v.name])then warptorio.ResourceAutoplaceSpecs[v.name]=table.deepcopy(v.autoplace_specification) end
			warptorio.WalkResourcePlacement(v.autoplace_specification,warptorio.ResourceAutoplaceSpecs[v.name],z)
		end
	end
end
]]

function warptorio.RandomPlanet(z) z=z or gwarptorio.warpzone local zp={}
	local zx=0
	local lpt=gwarptorio.planet local nowater,norest,nobiter=false,false,false
	if(lpt)then if(lpt.rest)then norest=true end if(lpt.nowater)then nowater=true end if(lpt.biter)then nobiter=true end end
	for k,v in pairs(warptorio.Planets)do if(v.zone<=z and v.rng>0 and warptorio.PlanetCanSpawn(v,nowater,norest,nobiter))then zx=zx+v.rng table.insert(zp,k) end end --for i=1,(v.rng or 1) do table.insert(zp,k) end end end
	if(zx<=0)then return warptorio.Planets["normal"] end
	local rng=math.random(1,zx) local zy=0
	for _,k in pairs(zp)do local v=warptorio.Planets[k] if(v.zone<=z and v.rng>0)then zy=zy+v.rng if(rng<=zy)then return v end end end
	return warptorio.Planets["normal"]
end

function warptorio.DoNextPlanet()
	local w=warptorio.RandomPlanet(gwarptorio.warpzone+1)
	return w
end
function warptorio.PlanetCanSpawn(p,w,r,b)
	if(p.required_controls)then for k,v in pairs(p.required_controls)do if(not game.autoplace_control_prototypes[v])then return false end end end
	if(w and p.nowater)then return false elseif(r and p.rest)then return false elseif(b and p.biter)then return false end
	return true
end


function warptorio.BuildNewPlanet(vplanet) local w 
	if(vplanet)then w=warptorio.Planets[vplanet] end
	local lvl=gwarptorio.Research["reactor"] or 0

	local sizelv=(gwarptorio.Research["platform-size"] or 0)
	--warptorio.TweakResourcePlacements(9999) --1+(sizelv*0.33))

	if(lvl>=8 and gwarptorio.planet_target and not w)then local wx=gwarptorio.planet_target
		if(wx=="home")then
			if(gwarptorio.Floors.main:GetSurface().name~=gwarptorio.Floors.home:GetSurface().name and math.random(1,10)<=3)then
				game.print("-Successful Warp-") game.print(gwarptorio.Floors.home.world.name .. ". Home sweet home.") 
				return gwarptorio.Floors.home:GetSurface(),gwarptorio.Floors.home.world
			end
		elseif(math.random(1,100)<=settings.global["warptorio_warpchance"].value)then
			w=warptorio.Planets[wx] if(not warptorio.PlanetCanSpawn(w))then w=nil elseif(w)then game.print("-Successful Warp-") end
		end
	end
	if(not w)then w=warptorio.RandomPlanet() end

	if(gwarptorio.charting or not w.desc)then game.print(w.name) end
	if(w.desc)then game.print(w.desc) end

	gwarptorio.planet=w

	local g=warptorio.GeneratePlanetSettings(w,gwarptorio.charting)
	local f=warptorio.GeneratePlanetSurface(w,g,gwarptorio.charting)

	return f,w,g
end

--[[ old buildplanet code
	--game.print("Generating Planet: " .. w.name)

	local orig=(game.surfaces["nauvis"].map_gen_settings)
	local seed=(orig.seed + math.random(0,4294967295)) % 4294967296
	local t if(w.nauvis_override)then t={} else t=table.deepcopy(orig) end t.seed=seed
	local key=w.key

	if(w.fgen_event)then script.raise_event(w.fgen_event,{zone=gwarptorio.warpzone,charting=gwarptorio.charting,key=w.key,oldsurface=gwarptorio.Floors.main:GetSurface().name}) w=warptorio.Planets[key] end
	local wmap=(w.gen and table.deepcopy(w.gen) or {})
	if(w.fgen)then w.fgen(wmap,gwarptorio.charting,orig) end

	--game.print("wmap") for k,v in pairs(wmap)do game.print(tostring(k) .. " " .. tostring(v)) if(istable(v))then for a,b in pairs(v)do game.print("-->" .. tostring(a) .. " " .. tostring(b)) end end end
	if(w.orig_mul)then
		if(wmap.autoplace_controls)then for k,v in pairs(wmap.autoplace_controls)do
			if(not getmetatable(v))then setmetatable(v,warptorio.PlanetControlMeta) end
			wmap.autoplace_controls[k]=v*(orig.autoplace_controls[k] or 1)
		end end
	end
	table.deepmerge(t,wmap) 

	warptorio.CheckPlanetControls(t)
	local f = game.create_surface("warpsurf_"..gwarptorio.warpzone,t)

	f.request_to_generate_chunks({0,0},3) f.force_generate_chunk_requests()
	if(w.spawn_event)then script.raise_event(w.spawn_event,{surface=f.name,oldsurface=gwarptorio.Floors.main:GetSurface().name,map_gen=t,charting=gwarptorio.charting,zone=gwarptorio.warpzone,key=w.key}) end
	if(w.spawn)then w.spawn(f,gwarptorio.charting) end

	game.forces.player.chart_all(f)

	return f,w
end
]]


function warptorio.IsAutowarpEnabled() return gwarptorio.autowarp_disable~=true and (not gwarptorio.warp_reactor or not gwarptorio.warp_reactor.valid or gwarptorio.autowarp_always) end

function warptorio.CheckReactor()
	local m=gwarptorio.Floors.main
	local rlv=gwarptorio.Research["reactor"] or 0
	if(rlv>=6 and (not gwarptorio.warp_reactor or not gwarptorio.warp_reactor.valid))then
		local f=m:GetSurface()
		warptorio.cleanbbox(f,-3,-3,5,5)
		local e=gwarptorio.Floors.main.f.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player,player=game.players[1]}
		warptorio.cleanplayers(f,-3,-3,5,5)
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
	warptorio.updatelabel("warptorio_warpzone","    Warp number : " .. gwarptorio.warpzone)
	warptorio.updatelabel("warptorio_dowarp","Warp !")
	local m=gwarptorio.Floors.main local c=m:GetSurface()
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
		warptorio.updatelabel("warptorio_autowarp","    Auto-Warp In : " .. util.formattime(gwarptorio.warp_auto_time*60))
	end

	-- abilities
	if(gwarptorio.accelerator or gwarptorio.radar or gwarptorio.stabilizer)then gwarptorio.ability_uses=0 gwarptorio.radar_uses=0
		gwarptorio.ability_next=game.tick+60*60*sgAbilCooldown
		warptorio.updatelabel("warptorio_radar","Radar (0)")
		warptorio.updatelabel("warptorio_ability_uses","    Uses : " .. gwarptorio.ability_uses)
		warptorio.updatelabel("warptorio_ability_next","    Cooldown : " .. util.formattime(gwarptorio.ability_next-game.tick))
	end

	local cp=gwarptorio.planet

	-- Designate next planet and make new surface
	local f,w=warptorio.BuildNewPlanet(vplanet)

	-- Add planet warp multiplier
	if(w.warp_multiply)then gwarptorio.warp_charge_time=gwarptorio.warp_charge_time*w.warp_multiply gwarptorio.warp_time_left=gwarptorio.warp_time_left*w.warp_multiply end
	warptorio.updatelabel("warptorio_time_left","    Charge Time : " .. util.formattime(gwarptorio.warp_charge_time*60))


	-- Clean and prepare new surface
	for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=m.area})do v.destroy() end
	gwarptorio.Floors.main:SetSurface(f)
	warptorio.BuildPlatform()

	-- Clean and prepare old surface
	local tp=gwarptorio.Teleporters.offworld if(tp and tp:ValidPointB())then tp:DestroyPointB() tp:DestroyLogisticsB() end -- packup old teleporter gate

	--local vfFactorissimo=c.find_entities_filtered{name={"factory-1","factory-2","factory-3"}}
	--for k,v in pairs(vfFactorissimo)do script.raise_event(defines.events.on_marked_for_deconstruction,{entity=v}) end

	if(gwarptorio.warpevent_name)then script.raise_event(gwarptorio.warpevent_name,{newplanet=f,newworld=w,oldplanet=c,oldworld=cp}) end

	if(cp)then
		if(cp.warpout)then pnt.onwarpout(f,w,c,cp) end
		if(cp.warpout_call)then remote.call(pnt.warpout_call[1],pnt.warpout_call[2],f,w,c,cp) end
	end


	-- find entities and players to copy/transfer to new surface
	local tpply={} local cx=warptorio.corn
	local etbl={}
	for k,v in pairs(c.find_entities_filtered{type="character",invert=true,area=m.area})do if(v.type=="item-entity" or v.type=="character-corpse" or v.last_user or v.force.name=="player" or v.force.name=="enemy")then
		table.insert(etbl,v)
	end end

	-- find players to teleport to new platform
	for k,v in pairs(game.players)do local p,b=m:GetPos(),m:GetBBox() if(v.character~=nil and v.surface==c and warptorio.isinbbox(v.character.position,{x=p[1],y=p[2]},{x=b[1]+1,y=b[2]+1}))then
		table.insert(tpply,{v,{v.position.x,v.position.y}})
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
	if(gwarptorio.Teleporters.offworld)then warptorio.TeleCls.offworld() end
	for k,v in pairs(game.players)do if(v.character~=nil and v.valid)then local iv=v.get_main_inventory() for i,x in pairs(iv.get_contents())do
		if(i:sub(1,25)=="warptorio-teleporter-gate")then iv.remove{name=i,count=x} end
	end end end

	--// cleanup past entities
	
	for k,v in pairs(etbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end
	for k,v in pairs(blacktbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end
	--for k,v in pairs(vfFactorissimo)do if(v.valid)then v.cancel_deconstruction(game.forces.player) end end

	--// radar -- game.forces.player.chart(f,{lefttop={x=-256,y=-256},rightbottom={x=256,y=256}})

	--// build void
	for k,v in pairs({"nw","ne","sw","se"})do local ug=gwarptorio.Research["turret-"..v] or -1 if(ug>=0)then warptorio.LayCircle("out-of-map",c,cx[v].x,cx[v].y,11+ug*6) end end
	warptorio.LayFloorVec("out-of-map",c,m:GetPos(),m:GetSize())
	


	-- reset pollution & biters
	game.forces["enemy"].evolution_factor=0
	gwarptorio.pollution_amount=1.1
	gwarptorio.pollution_expansion=1.1

	-- warp sound
	warptorio.playsound("warp_in", c.name)
	warptorio.playsound("warp_in", f.name)

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
	for k,e in pairs(gwarptorio.cache.heat)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(gwarptorio.cache.power)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(gwarptorio.cache.loaderIn)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(gwarptorio.cache.loaderOut)do if(e.valid and e.surface==f)then table.insert(rds,e) end end
	for k,e in pairs(rds)do e.destroy{raise_destroy=true} end
end script.on_event({defines.events.on_pre_surface_cleared,defines.events.on_pre_surface_deleted},warptorio.OnPreSurfaceCleared)


-- --------
-- Helper functions

function warptorio.layvoid(f,x,y,z) warptorio.LayFloor("out-of-map",f,x,y,z,z) end

function warptorio.LayFloor(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} for i=0,w-1 do for j=0,h-1 do table.insert(t,{name=tex,position={i+x,j+y}}) end end f.set_tiles(t) end

function warptorio.LayBorder(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} w=w-1 h=h-1
	for i=0,w do table.insert(t,{name=tex,position={x+i,y}}) table.insert(t,{name=tex,position={x+i,y+h}}) end
	for j=0,h do table.insert(t,{name=tex,position={x,y+j}}) table.insert(t,{name=tex,position={x+w,y+j}}) end
	f.set_tiles(t)
end
function warptorio.CountEntities() local c=0 for k,v in pairs(gwarptorio.Floors)do if(v.f and v.f.valid)then local e=v.f.find_entities(v.area) for a,b in pairs(e)do c=c+1 end end end return c end



function warptorio.LayFloorVec(tx,f,p,z,b) if(b)then f.destroy_decoratives({area=b}) end
	local t={} for i=0,z[1]-1 do for j=0,z[2]-1 do table.insert(t,{name=tx,position={i+p[1],j+p[2]}}) end end f.set_tiles(t) end

function warptorio.cleanplayers(f,x,y,w,h) local e=f.find_entities({{x,y},{x+w,y+h}})
	for k,v in ipairs(e)do if(v.type=="character")then warptorio.safeteleport(v,{0,0},f) end end end

function warptorio.cleanbbox(f,x,y,w,h) local e=f.find_entities({{x,y},{x+w,y+h}})
	for k,v in ipairs(e)do if(v.valid)then if(v.type~="character")then v.destroy{raise_destroy=true,do_cliff_correction=true} else warptorio.safeteleport(v,{0,0},f) end end end end
function warptorio.safeteleport(e,x,f) 
	if(e.type=="character")then for k,v in pairs(game.players)do if(v.character==e)then v.teleport(f.find_non_colliding_position("character",x,12,1,true),f) end end end end

function warptorio.PrintToCharacter(c,msg,x) for k,v in pairs(game.players)do if(v.character==c)then v.print(msg) end end end
function warptorio.getlabelcontrol(ply,x) local gx=ply.gui.left.warptorio_frame if(gx)then local g for i=1,2,1 do g=gx["warptorio_line"..i][x] if(g)then return g end end end end
function warptorio.updatelabel(lbl,txt) for k,v in pairs(game.players)do local g=warptorio.getlabelcontrol(v,lbl) if(g and g.valid)then g.caption=txt end end end
function warptorio.isinbbox(pos,pos1,pos2) return not ( (pos.x<pos1.x or pos.y<pos1.y) or (pos.x>pos2.x or pos.y>pos2.y) ) end
function warptorio.playsound(pth,f,x) for k,v in pairs(game.connected_players)do if(v.surface.name==f)then v.play_sound{path=pth,position=x} end end end


function warptorio.spawnbiters(type,n,f) local tbl=game.surfaces[f].find_entities_filtered{type="character"}
	for k,v in ipairs(tbl)do
		for j=1,n do local a,d=math.random(0,2*math.pi),150 local x,y=math.cos(a)*d+v.position.x,math.sin(a)*d+v.position.y
			local p=game.surfaces[f].find_non_colliding_position(t,{x,y},0,2,1)
			local e=game.surfaces[f].create_entity{name=type,position=p}
		end
		game.surfaces[f].set_multi_command{command={type=defines.command.attack,target=v},unit_count=n}
	end
end



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
	if(not global.warptorio or gwarptorio)then return end
	gwarptorio=global.warptorio
	for k,v in pairs(gwarptorio.Floors)do setmetatable(v,warptorio.FloorMeta) end
	for k,v in pairs(gwarptorio.Teleporters)do setmetatable(v,warptorio.TeleporterMeta) end
	for k,v in pairs(gwarptorio.Rails)do setmetatable(v,warptorio.TelerailMeta) end
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
	gwarptorio.cache.loaderOut=gwarptorio.cache.loaderOut or {}
	gwarptorio.cache.loaderOutFilter=gwarptorio.cache.loaderOutFilter or {}
	gwarptorio.cache.loaderOutNext=gwarptorio.cache.loaderOutNext or {}

	gwarptorio.votewarp=gwarptorio.votewarp or {} if(type(gwarptorio.votewarp)~="table")then gwarptorio.votewarp={} end


	gwarptorio.Teleporters=gwarptorio.Teleporters or {}
	gwarptorio.Research=gwarptorio.Research or {}
	gwarptorio.Turrets=gwarptorio.Turrets or {}
	gwarptorio.Rails=gwarptorio.Rails or {}

	if(not gwarptorio.Floors)then gwarptorio.Floors={} warptorio.InitFloors() end
	warptorio.BuildCache()
	warptorio.ValidateCache()

	gwarptorio.LogisticLoaderChestProvider=settings.global['warptorio_loaderchest_provider'].value
	gwarptorio.LogisticLoaderChestRequester=settings.global['warptorio_loaderchest_requester'].value
	gwarptorio.warp_blacklist=gwarptorio.warp_blacklist or {}

	warptorio.Loaded=true

end


local lootItems={
["roboport"]=10,
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

function warptorio.OnChunkGenerated(ev) local a=ev.area local f=ev.surface
	local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_chunk_generated",ev) end

	if(f.name=="nauvis" or f.name~=(gwarptorio.Floors.main:GetSurface().name))then return end
	-- spawn chest with goodies
	if(math.random(1,175)>1)then return end
	local x=math.random(a.left_top.x,a.right_bottom.x)
	local y=math.random(a.left_top.y,a.right_bottom.y)
	local dist=math.sqrt(math.abs(x^2)+math.abs(y^2))
	if(dist < 256)then return end

	local lt={} for k,v in pairs(lootItems)do local r=game.forces.player.recipes[k] if(not r or (r and r.enabled==true))then lt[k]=v end end
	if(table.Count(lt)<1)then return end
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
end script.on_event(defines.events.on_chunk_generated,warptorio.OnChunkGenerated)


function warptorio.OnChunkDeleted(ev)
	local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_chunk_deleted",ev) end
end script.on_event(defines.events.on_chunk_deleted,warptorio.OnChunkDeleted)
