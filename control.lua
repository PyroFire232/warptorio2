
-- --------
-- Setup

local gwarptorio={}
local util = require("util")
local mod_gui = require("mod-gui")
local function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end
function table.Count(t) local c=0 for k,v in pairs(t)do c=c+1 end return c end
function table.First(t) for k,v in pairs(t)do return k,v end end
function table.Random(t) local c,i=table.Count(t),1 if(c==0)then return end local rng=math.random(1,c) for k,v in pairs(t)do if(i==rng)then return v end i=i+1 end end
local function istable(x) return type(x)=="table" end
local function printx(m) for k,v in pairs(game.players)do v.print(m) end end
local function isvalid(v) return (v and v.valid) end
function table.HasValue(t,a) for k,v in pairs(t)do if(v==a)then return true end end return false end

local Vector2={} Vector2.__index=Vector2 setmetatable(Vector2,Vector2)
function Vector2.__call(x,y) x=x or 0 y=y or 0 local t={} setmetatable(t,Vector2) t.x=x t.y=y t[1]=t.x t[2]=t.y return t end
function Vector2.__add(a,b) local t={} setmetatable(t,Vector2) t.x=a.x+b.x t.y=a.y+b.y t[1]=t.x t[2]=t.y return t end
function Vector2.__mul(a,b) local t={} setmetatable(t,Vector2) t.x=a.x*b.x t.y=a.y*b.y t[1]=t.x t[2]=t.y return t end
function Vector2:AddAngle(r,d) local t={} setmetatable(t,Vector2) t.x=self.x+math.sin(r)*d t.y=self.y+math.cos(r)*d t[1]=t.x t[2]=t.y return t end
function Vector2:Length() return math.sqrt(self.x^2+self.y^2) end


warptorio=warptorio or {}

function warptorio.CopyChestEntity(a,b)
	local c=b.get_inventory(defines.inventory.chest)
	for k,v in pairs(a.get_inventory(defines.inventory.chest).get_contents())do c.insert{name=k,count=v} end
	for c,tbl in pairs(a.circuit_connected_entities)do for k,v in pairs(tbl)do v.connect_neighbour{target_entity=b,wire=defines.wire_type[c]} end end
end


function warptorio.FlipDirection(v) return (v+4)%8 end

require("control_planets")
-- --------
-- Logistics & Teleporters

local TELL={} TELL.__index=TELL warptorio.TeleporterMeta=TELL
function TELL.__init(self,n) self.name=n self.dir={{"input","output"},{"input","output"}} self.logcont={} gwarptorio.Teleporters[n]=self end
TELL.LogisticsEnts={"loader1","loader2","chest1","chest2","pipe1","pipe2","pipe3","pipe4","pipe5","pipe6"}


function TELL:SwapLoaderChests(i,a,b)
	local lv=gwarptorio.Research["factory-logistics"] or 0
	if(lv>=4)then -- buffer chests
		local ea=self.logs["chest"..i.."-a"] local eax=(a.loader_type=="input" and "logistic-chest-requester" or "logistic-chest-active-provider")
		local eb=self.logs["chest"..i.."-b"] local ebx=(a.loader_type=="output" and "logistic-chest-requester" or "logistic-chest-active-provider")
		local va=warptorio.SpawnEntity(ea.surface,eax,ea.position.x,ea.position.y)
		local vb=warptorio.SpawnEntity(eb.surface,ebx,eb.position.x,eb.position.y)
		warptorio.CopyChestEntity(ea,va) warptorio.CopyChestEntity(eb,vb)
		ea.destroy() eb.destroy()
		self.logs["chest"..i.."-a"]=va self.logs["chest"..i.."-b"]=vb
	end
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

function TELL:SpawnPointA(n,f,pos) local e=warptorio.SpawnEntity(f,n,pos.x,pos.y) self:SetPointA(e) return e end
function TELL:SpawnPointB(n,f,pos) local e=warptorio.SpawnEntity(f,n,pos.x,pos.y) self:SetPointB(e) return e end
function TELL:SetPointA(e) self.PointA=e if(self.PointAEnergy)then self.PointA.energy=self.PointAEnergy self.PointAEnergy=nil end end
function TELL:SetPointB(e) self.PointB=e if(self.PointBEnergy)then self.PointB.energy=self.PointBEnergy self.PointBEnergy=nil end end
function TELL:BalanceLogistics()
	if(self.logs)then
		self:CheckLoaderDirection(1,self.logs["loader1-a"],self.logs["loader1-b"]) --,self.logs["chest1-a"],self.logs["chest1-b"])
		self:CheckLoaderDirection(2,self.logs["loader2-a"],self.logs["loader2-b"]) --,self.logs["chest2-a"],self.logs["chest2-b"])
		if(self.dir[1][1]=="input")then warptorio.BalanceLogistics(self.logs["chest1-a"],self.logs["chest1-b"])
		else warptorio.BalanceLogistics(self.logs["chest1-b"],self.logs["chest1-a"])
		end
		if(self.dir[2][1]=="input")then warptorio.BalanceLogistics(self.logs["chest2-a"],self.logs["chest2-b"])
		else warptorio.BalanceLogistics(self.logs["chest2-b"],self.logs["chest2-a"])
		end

		for i=1,6,1 do warptorio.BalanceLogistics(self.logs["pipe"..i.."-a"],self.logs["pipe"..i.."-b"],true) end
	end
	--warptorio.BalanceLogistics(self.PointA,self.PointB) -- energy
end

function TELL:Warpout() local f=gwarptorio.Floors.main:GetSurface().name
	if(self:ValidPointA() and self.PointA.surface.name==f)then self:DestroyPointA() self:DestroyLogisticsA() end
	if(self:ValidPointB() and self.PointB.surface.name==f)then self:DestroyPointB() self:DestroyLogisticsB() end
end
function TELL:Warpin() warptorio.TeleCls[self.name]() end
function TELL:ValidPointA() return (self.PointA and self.PointA.valid) end
function TELL:ValidPointB() return (self.PointB and self.PointB.valid) end
function TELL:ValidPoints() return (self:ValidPointA() and self:ValidPointB()) end
function TELL:DestroyPoints() self:DestroyPointA() self:DestroyPointB() end
function TELL:DestroyPointA() if(self.PointA and self.PointA.valid)then self.PointAEnergy=self.PointA.energy self.PointA.destroy() self.PointA=nil end end
function TELL:DestroyPointB() if(self.PointB and self.PointB.valid)then self.PointBEnergy=self.PointB.energy self.PointB.destroy() self.PointB=nil end end
function TELL:DestroyLogisticsA() if(self.logs)then for k,v in pairs(self.LogisticsEnts)do local e=self.logs[v.."-a"] if(e)then if(e.valid)then
	if(e.type=="container")then local inv=e.get_inventory(defines.inventory.chest) self.logcont[v.."-a"]=inv.get_contents()
		for x,y in pairs(self.logcont[v.."-a"])do game.print(x .. " " .. y) end end
	e.destroy()
end self.logs[v.."-a"]=nil end end end end
function TELL:DestroyLogisticsB() if(self.logs)then for k,v in pairs(self.LogisticsEnts)do local e=self.logs[v.."-b"] if(e)then if(e.valid)then
	if(e.type=="container")then local inv=e.get_inventory(defines.inventory.chest) self.logcont[v.."-b"]=inv.get_contents() end
	e.destroy()
end self.logs[v.."-b"]=nil end end end end
function TELL:DestroyLogistics() self:DestroyLogisticsA() self:DestroyLogisticsB() end
function TELL:UpgradeLogistics() if(self.logs)then self:DestroyLogistics() end self:SpawnLogistics() end
function TELL:UpgradeEnergy() self:Warpout() self:Warpin() end

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


function TELL:ConnectCircuit()
	local vv=self.PointA.connect_neighbour({target_entity=self.PointB,wire=defines.wire_type.red})
	local vv=self.PointA.connect_neighbour({target_entity=self.PointB,wire=defines.wire_type.green})
end

function TELL:SpawnLogistics() if(not self.logs)then self.logs={} end
	local lv=gwarptorio.Research["factory-logistics"] or 0 if(lv==0)then return end
	local chest,belt local pipe="warptorio-logistics-pipe"
	if(lv==1)then chest,belt="wooden-chest","loader"
	elseif(lv==2)then chest,belt="iron-chest","fast-loader"
	elseif(lv==3)then chest,belt="steel-chest","express-loader"
	elseif(lv>=4)then chest,belt="logistic-chest-buffer","express-loader" end

	local a=self.PointA
	local b=self.PointB
	if(a and a.valid)then
		local f,p=a.surface,a.position
		local v=self.logs["loader1-a"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,belt,p.x-2,p.y-1,defines.direction.south) self.logs["loader1-a"]=v v.loader_type=self.dir[1][1] end
		local v=self.logs["loader2-a"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,belt,p.x+2,p.y-1,defines.direction.south) self.logs["loader2-a"]=v v.loader_type=self.dir[2][1] end
		local v=self.logs["chest1-a"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,chest,p.x-2,p.y+1) self.logs["chest1-a"]=v
			local inv=self.logcont["chest1-a"] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do game.print("inserted " .. x .. " " .. y) cv.insert({name=x,count=y}) end end
			self.logcont["chest1-a"]=nil
		end
		local v=self.logs["chest2-a"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,chest,p.x+2,p.y+1) self.logs["chest2-a"]=v
			local inv=self.logcont["chest2-a"] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert({name=x,count=y}) end end
			self.logcont["chest2-a"]=nil
		end
		local v=self.logs["pipe1-a"] if(not v or not v.valid)then self.logs["pipe1-a"]=warptorio.SpawnEntity(f,pipe,p.x-3,p.y+1,defines.direction.west) end
		local v=self.logs["pipe2-a"] if(not v or not v.valid)then self.logs["pipe2-a"]=warptorio.SpawnEntity(f,pipe,p.x+3,p.y+1,defines.direction.east) end
		if(lv>=2)then
			local v=self.logs["pipe3-a"] if(not v or not v.valid)then self.logs["pipe3-a"]=warptorio.SpawnEntity(f,pipe,p.x-3,p.y,defines.direction.west) end
			local v=self.logs["pipe4-a"] if(not v or not v.valid)then self.logs["pipe4-a"]=warptorio.SpawnEntity(f,pipe,p.x+3,p.y,defines.direction.east) end
		end if(lv>=4)then
			local v=self.logs["pipe5-a"] if(not v or not v.valid)then self.logs["pipe5-a"]=warptorio.SpawnEntity(f,pipe,p.x-3,p.y-1,defines.direction.west) end
			local v=self.logs["pipe6-a"] if(not v or not v.valid)then self.logs["pipe6-a"]=warptorio.SpawnEntity(f,pipe,p.x+3,p.y-1,defines.direction.east) end
		end
		warptorio.playsound("warp_in",f)
	end

	if(b and b.valid)then
		local f,p=b.surface,b.position
		local v=self.logs["loader1-b"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,belt,p.x-2,p.y-1,defines.direction.south) self.logs["loader1-b"]=v v.loader_type=self.dir[1][2] end
		local v=self.logs["loader2-b"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,belt,p.x+2,p.y-1,defines.direction.south) self.logs["loader2-b"]=v v.loader_type=self.dir[2][2] end
		local v=self.logs["chest1-b"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,chest,p.x-2,p.y+1) self.logs["chest1-b"]=v
			local inv=self.logcont["chest1-b"] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert({name=x,count=y}) end end
			self.logcont["chest1-b"]=nil
		end
		local v=self.logs["chest2-b"] if(not v or not v.valid)then v=warptorio.SpawnEntity(f,chest,p.x+2,p.y+1) self.logs["chest2-b"]=v
			local inv=self.logcont["chest2-b"] if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert({name=x,count=y}) end end
			self.logcont["chest2-b"]=nil
		end
		local v=self.logs["pipe1-b"] if(not v or not v.valid)then self.logs["pipe1-b"]=warptorio.SpawnEntity(f,pipe,p.x-3,p.y+1,defines.direction.west) end
		local v=self.logs["pipe2-b"] if(not v or not v.valid)then self.logs["pipe2-b"]=warptorio.SpawnEntity(f,pipe,p.x+3,p.y+1,defines.direction.east) end
		if(lv>=2)then
			local v=self.logs["pipe3-b"] if(not v or not v.valid)then self.logs["pipe3-b"]=warptorio.SpawnEntity(f,pipe,p.x-3,p.y,defines.direction.west) end
			local v=self.logs["pipe4-b"] if(not v or not v.valid)then self.logs["pipe4-b"]=warptorio.SpawnEntity(f,pipe,p.x+3,p.y,defines.direction.east) end
		end if(lv>=4)then
			local v=self.logs["pipe5-b"] if(not v or not v.valid)then self.logs["pipe5-b"]=warptorio.SpawnEntity(f,pipe,p.x-3,p.y-1,defines.direction.west) end
			local v=self.logs["pipe6-b"] if(not v or not v.valid)then self.logs["pipe6-b"]=warptorio.SpawnEntity(f,pipe,p.x+3,p.y-1,defines.direction.east) end
		end
		warptorio.playsound("warp_in",f)
	end

	for k,v in pairs(self.logs)do if(v and v.valid)then v.minable=false v.destructible=false end end
end

local tpcls={} warptorio.TeleCls=tpcls
function tpcls.offworld()
	local lv=gwarptorio.Research["teleporter-energy"] or 0
	local lgv=gwarptorio.Research["factory-logistics"] or 0
	local x=gwarptorio.Teleporters["offworld"] if(not x)then x=new(TELL,"offworld") end
	x.cost=true
	local m=gwarptorio.Floors.main
	local f=m:GetSurface()
	local bpos={-1,8}
	local makeA="warptorio-teleporter-"..lv
	if(x:ValidPointA() and x.PointA.name~=makeA)then x:DestroyPointA() end
	if(not x.PointA or not x.PointA.valid)then warptorio.cleanbbox(f,-3,5,7,3) local e=x:SpawnPointA("warptorio-teleporter-"..lv,f,{x=-1,y=5}) e.minable=false e.destructible=false end

	local makeB="warptorio-teleporter-gate-"..lv
	if(x:ValidPointB() and x.PointB.name~=makeB)then bpos=x.PointB.position x:DestroyPointB() end
	if(not x.PointB)then bpos=f.find_non_colliding_position("warptorio-teleporter-gate-"..lv,bpos,0,1,1) local e=x:SpawnPointB("warptorio-teleporter-gate-"..lv,f,{x=bpos.x,y=bpos.y}) end


	if(lgv>=0)then x:SpawnLogistics() end
	warptorio.playsound("warp_in",f.name)
	return x
end
function tpcls.b1(lv)
	local lv=gwarptorio.Research["factory-energy"] or 0 local lgv=gwarptorio.Research["factory-logistics"] or 0
	local x=gwarptorio.Teleporters["b1"] if(not x)then x=new(TELL,"b1") end
	local m=gwarptorio.Floors.main local f=m:GetSurface()
	local mb=gwarptorio.Floors.b1 local fb=mb:GetSurface()
	local makeA,makeB="warptorio-underground-"..lv,"warptorio-underground-"..lv
	if(x:ValidPointA())then if(x.PointA.surface~=f)then x:DestroyPointA() self:DestroyLogisticsA() elseif(x.PointA~=makeA)then x:DestroyPointA() end end
	if(x:ValidPointB())then if(x.PointB.surface~=fb)then x:DestroyPointB() self:DestroyLogisticsB() elseif(x.PointB~=makeB)then x:DestroyPointB() end end
	if(not x.PointA or not x.PointA.valid)then warptorio.cleanbbox(f,-3,-7,7,3) local e=x:SpawnPointA(makeA,f,{x=-1,y=-7}) e.minable=false end
	if(not x.PointB or not x.PointB.valid)then warptorio.cleanbbox(fb,-3,-7,7,3) local e=x:SpawnPointB(makeB,fb,{x=-1,y=-7}) e.minable=false e.destructible=false end

	x:ConnectCircuit()

	if(lgv>0)then x:SpawnLogistics() end
	warptorio.playsound("warp_in",f.name)
	return x
end
function tpcls.b2(lv) lv=lv or 0
	local lv=gwarptorio.Research["factory-energy"] or 0
	local lgv=gwarptorio.Research["factory-logistics"] or 0
	local x=gwarptorio.Teleporters["b2"] if(not x)then x=new(TELL,"b2") end
	local m=gwarptorio.Floors.b1 local f=m:GetSurface()
	local mb=gwarptorio.Floors.b2 local fb=mb:GetSurface()
	local makeA,makeB="warptorio-underground-"..lv,"warptorio-underground-"..lv
	if(x:ValidPointA())then if(x.PointA.surface~=f)then x:DestroyPointA() self:DestroyLogisticsA() elseif(x.PointA~=makeA)then x:DestroyPointA() end end
	if(x:ValidPointB())then if(x.PointB.surface~=fb)then x:DestroyPointB() self:DestroyLogisticsB() elseif(x.PointB~=makeB)then x:DestroyPointB() end end
	if(not x:ValidPointA())then warptorio.cleanbbox(f,-3,5,7,3) local e=x:SpawnPointA(makeA,f,{x=-1,y=5}) e.minable=false end
	if(not x:ValidPointB())then warptorio.cleanbbox(fb,-3,5,7,3) local e=x:SpawnPointB(makeB,fb,{x=-1,y=5}) e.minable=false e.destructible=false end
	if(lgv>0)then x:SpawnLogistics() end

	x:ConnectCircuit()
	warptorio.playsound("warp_in",f.name)
	return x
end



function warptorio.SpawnTurretTeleporter(c,xp,yp)
	local lv=gwarptorio.Research["turret-"..c] or 0
	local lgv=gwarptorio.Research["factory-logistics"] or 0
	local x=gwarptorio.Teleporters[c] if(not x)then x=new(TELL,c) end
	local m=gwarptorio.Floors.main local f=m:GetSurface()
	local mb=gwarptorio.Floors.b1 local fb=mb:GetSurface()
	local makeA,makeB="warptorio-underground-"..lv,"warptorio-underground-"..lv
	if(x:ValidPointA())then if(x.PointA.surface~=f)then x:DestroyPointA() self:DestroyLogisticsA() elseif(x.PointA~=makeA)then x:DestroyPointA() end end
	if(x:ValidPointB())then if(x.PointB.surface~=fb)then x:DestroyPointB() self:DestroyLogisticsB() elseif(x.PointB~=makeB)then x:DestroyPointB() end end
	if(not x:ValidPointA())then warptorio.cleanbbox(f,xp-2,yp,7,3) local e=x:SpawnPointA(makeA,f,{x=xp,y=yp}) e.minable=false end
	if(not x:ValidPointB())then warptorio.cleanbbox(fb,xp-2,yp,7,3) local e=x:SpawnPointB(makeB,fb,{x=xp,y=yp}) e.minable=false e.destructible=false end

	if(lgv>0)then x:SpawnLogistics() end

	x:ConnectCircuit()
	warptorio.playsound("warp_in",f.name)
	return x
end


function warptorio.LaySquare(tex,f,x,y,w,h) local wf,wc=math.floor(w/2),math.ceil(w/2) local hf,hc=math.floor(h/2),math.ceil(h/2) local t={}
	for xv=x-wf,x+wc do for yv=y-hf,y+hf do table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t)
end

function warptorio.LayCircle(tex,f,x,y,z,b) local zf=math.floor(z/2) local t={} if(b)then local bbox={area={{x-z/2,y-z/2},{x+z,y+z}}} f.destroy_decoratives(bbox) end
	for xv=x-zf,x+math.floor(z/2) do for yv=y-zf,y+zf do local dist=math.sqrt(((xv-x)^2)+((yv-y)^2)) if(dist<=z/2)then table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t) end
end

warptorio.corn={}
warptorio.corn.nw={x=-52,y=-52}
warptorio.corn.ne={x=50,y=-52}
warptorio.corn.sw={x=-52,y=50}
warptorio.corn.se={x=50,y=50}
warptorio.corn.north=-51.5
warptorio.corn.south=50
warptorio.corn.east=50
warptorio.corn.west=-52

function tpcls.nw() local c=warptorio.corn.nw warptorio.SpawnTurretTeleporter("nw",c.x,c.y) gwarptorio.Turrets.nw=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.sw() local c=warptorio.corn.sw warptorio.SpawnTurretTeleporter("sw",c.x,c.y) gwarptorio.Turrets.sw=n warptorio.BuildPlatform() warptorio.BuildB1()end
function tpcls.ne() local c=warptorio.corn.ne warptorio.SpawnTurretTeleporter("ne",c.x,c.y) gwarptorio.Turrets.ne=n warptorio.BuildPlatform() warptorio.BuildB1()end
function tpcls.se() local c=warptorio.corn.se warptorio.SpawnTurretTeleporter("se",c.x,c.y) gwarptorio.Turrets.sw=n warptorio.BuildPlatform() warptorio.BuildB1()end


function warptorio.BuildPlatform() local m=gwarptorio.Floors.main local f=m:GetSurface() local z=m.z local lv=(gwarptorio.Research["platform-size"] or 0)
	for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area={{-z/2,-z/2},{z,z}}})do
		if(not v.last_user and v.name:sub(1,9)~="warptorio")then v.destroy() end
	end
	warptorio.LayFloor("warp-tile",f,math.floor(-z/2),math.floor(-z/2),z,z,true) -- main platform

	warptorio.LayFloor("hazard-concrete-left",f,-3,-3,5,5)

	if(lv>0)then
		warptorio.LayFloor("hazard-concrete-left",f,-4,4,7,3) --teleporter
		--warptorio.LayFloor("hazard-concrete-left",f,-3,-5,5,5) -- radar
		--warptorio.LayFloor("hazard-concrete-left",f,4,-2,3,3) -- solar stabilizer
		warptorio.LayFloor("hazard-concrete-left",f,-4,-8,7,3) -- underground
	end

	local t={} for k,v in pairs({"nw","ne","sw","se"}) do
		t.nw=(gwarptorio.Research["turret-nw"]) or -1
		t.ne=(gwarptorio.Research["turret-ne"]) or -1
		t.sw=(gwarptorio.Research["turret-sw"]) or -1
		t.se=(gwarptorio.Research["turret-se"]) or -1
	end
	local c=warptorio.corn
	if(t.nw>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.nw.x,c.nw.y},radius=(11+t.nw*6)/2})do
			if(not v.last_user and v.name:sub(1,9)~="warptorio")then v.destroy() end
		end
		warptorio.LayCircle("warp-tile",f,c.nw.x,c.nw.y,11+t.nw*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.nw.x-3,c.nw.y-1,7,3)
	end
	if(t.ne>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.ne.x,c.ne.y},radius=(11+t.ne*6)/2})do
			if(not v.last_user and v.name:sub(1,9)~="warptorio")then v.destroy() end
		end
		warptorio.LayCircle("warp-tile",f,c.ne.x,c.ne.y,11+t.ne*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.ne.x-3,c.ne.y-1,7,3)
	end
	if(t.sw>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.sw.x,c.sw.y},radius=(11+t.sw*6)/2})do
			if(not v.last_user and v.name:sub(1,9)~="warptorio")then v.destroy() end
		end
		warptorio.LayCircle("warp-tile",f,c.sw.x,c.sw.y,11+t.sw*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.sw.x-3,c.sw.y-1,7,3)
	end
	if(t.se>=0)then
		for k,v in pairs(f.find_entities_filtered{type="character",invert=true,position={c.se.x,c.se.y},radius=(11+t.se*6)/2})do
			if(not v.last_user and v.name:sub(1,9)~="warptorio")then v.destroy() end
		end
		warptorio.LayCircle("warp-tile",f,c.se.x,c.se.y,11+t.se*6,true) warptorio.LayFloor("hazard-concrete-left",f,c.se.x-3,c.se.y-1,7,3)
	end


	--local z=31 --m.InnerSize or 24
	--warptorio.LayBorder("hazard-concrete-left",f,math.floor(-z/2),math.floor(-z/2),z,z)
end

function warptorio.BuildB1() local m=gwarptorio.Floors.b1 local f=m:GetSurface() local z=m.z

	local t={} for k,v in pairs({"nw","ne","sw","se"}) do
		t.nw=(gwarptorio.Research["turret-nw"]) or -1
		t.ne=(gwarptorio.Research["turret-ne"]) or -1
		t.sw=(gwarptorio.Research["turret-sw"]) or -1
		t.se=(gwarptorio.Research["turret-se"]) or -1
	end
	local ltop=(t.nw>=0 or t.ne>=0)
	local lbot=(t.sw>=0 or t.se>=0)
	local lleft=(t.nw>=0 or t.sw>=0)
	local lright=(t.ne>=0 or t.se>=0)

	local c=warptorio.corn

	local cz=10
	local cpz=59

	if(ltop)then
		warptorio.LaySquare("warp-tile",f,-1,c.north/2,10,cpz)
		if(t.nw>=0)then warptorio.LaySquare("warp-tile",f,c.west/2,c.north,cpz,10) end
		if(t.ne>=0)then warptorio.LaySquare("warp-tile",f,c.east/2,c.north,cpz,10) end
	end
	if(lbot)then
		warptorio.LaySquare("warp-tile",f,-1,c.south/2,10,cpz)
		if(t.sw>=0)then warptorio.LaySquare("warp-tile",f,c.west/2,c.south,cpz,10) end
		if(t.se>=0)then warptorio.LaySquare("warp-tile",f,c.east/2,c.south,cpz,10) end
	end
	if(lleft)then
		warptorio.LaySquare("warp-tile",f,c.west/2,-1,cpz+1,10)
		if(t.nw>=0)then warptorio.LaySquare("warp-tile",f,c.west,c.north/2,10,cpz) end
		if(t.sw>=0)then warptorio.LaySquare("warp-tile",f,c.west,c.south/2,10,cpz) end
	end
	if(lright)then
		warptorio.LaySquare("warp-tile",f,c.east/2,-1,cpz,10)
		if(t.ne>=0)then warptorio.LaySquare("warp-tile",f,c.east,c.north/2,10,cpz) end
		if(t.se>=0)then warptorio.LaySquare("warp-tile",f,c.east,c.south/2,10,cpz) end
	end

	if(t.nw>=0)then local z=10+t.nw*6 t.nwz=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile",f,c.nw.x,c.nw.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.nw.x-3,c.nw.y-1,7,3) end
	if(t.ne>=0)then local z=10+t.ne*6 t.nez=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile",f,c.ne.x,c.ne.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.ne.x-3,c.ne.y-1,7,3) end
	if(t.sw>=0)then local z=10+t.sw*6 t.swz=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile",f,c.sw.x,c.sw.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.sw.x-3,c.sw.y-1,7,3) end
	if(t.se>=0)then local z=10+t.se*6 t.sez=z local zx=math.floor(z/2) warptorio.LaySquare("warp-tile",f,c.se.x,c.se.y,z,z) warptorio.LayFloor("hazard-concrete-left",f,c.se.x-3,c.se.y-1,7,3) end


	warptorio.LayFloor("warp-tile",f,math.floor(-z/2),math.floor(-z/2),z,z)
	warptorio.LayFloor("hazard-concrete-left",f,-4,-8,7,3)
	warptorio.LayFloor("hazard-concrete-left",f,-4,4,7,3)
	warptorio.LayFloor("hazard-concrete-left",f,-2,-2,3,3)


	warptorio.playsound("warp_in",f.name)
end

function warptorio.BuildB2() local m=gwarptorio.Floors.b2 local f,z=m:GetSurface(),m.z

	local lv=gwarptorio.waterboiler

	warptorio.LayFloor("warp-tile",f,math.floor(-z/3),math.floor(-z),(z/3)*2,z*2)
	warptorio.LayFloor("warp-tile",f,math.floor(-z),math.floor(-z/3),z*2,(z/3)*2)

	if(lv)then
		warptorio.LayFloor("deepwater",f,math.floor(-z/3)-4,math.floor(-z/3)-4,4,4)
		warptorio.LayFloor("deepwater",f,math.floor(z/3),math.floor(-z/3)-4,4,4)
		warptorio.LayFloor("deepwater",f,math.floor(z/3),math.floor(z/3),4,4)
		warptorio.LayFloor("deepwater",f,math.floor(-z/3)-4,math.floor(z/3),4,4)
	end

	warptorio.LayFloor("hazard-concrete-left",f,-4,4,7,3)
	warptorio.LayFloor("hazard-concrete-left",f,-3,-3,5,5)
	warptorio.playsound("warp_in",f.name)
end


function warptorio.InitTeleporters(event) end --for k,v in pairs(warptorio.TeleCls)do if(not gwarptorio.Teleporters[k])then gwarptorio.Teleporters[k]=v() end end end


function warptorio.TickTeleporters(e) for k,v in pairs(gwarptorio.Teleporters)do if(v.PointA and v.PointB and v.PointA.valid and v.PointB.valid)then
	for i,e in pairs({v.PointA,v.PointB})do
		local o=(i==1 and v.PointB or v.PointA) local x=e.position local p=e.surface.find_entities_filtered{area={{x.x-1.09,x.y-1.09},{x.x+1.09,x.y+1.09}},type="character"}
		for a,b in pairs(p)do
			local inv=b.get_main_inventory().get_item_count()
			if(e.energy and v.cost and false)then
				local bp=o.position local dist=math.sqrt((x.x+bp.x)^2+(x.y+bp.y)^2) local jc=(inv*2000)*(1+dist/200)
				if(e.energy<jc)then warptorio.PrintToCharacter(b,"Not enough energy to teleport! You may have too much in your inventory") break end
				e.energy=math.max(e.energy-jc,0)
				warptorio.playsound("stairs",e.surface.name,e.position) warptorio.playsound("stairs",o.surface.name,o.position)
			else
				warptorio.playsound("teleport",e.surface.name,e.position) warptorio.playsound("teleport",o.surface.name,o.position)
			end
			warptorio.safeteleport(b,o.position,o.surface)
		end
	end
end end end

-- Teleporter mined/destroyed/rebuilt
function warptorio.OnBuiltEntity(event) local e=event.created_entity if(warptorio.IsTeleporterGate(e))then local t=gwarptorio.Teleporters["offworld"] t:SetPointB(e) t:Warpin() end
end script.on_event(defines.events.on_built_entity, warptorio.OnBuiltEntity)

function warptorio.OnPlayerMinedEntity(event) local e=event.entity if(warptorio.IsTeleporterGate(e))then local t=gwarptorio.Teleporters["offworld"] t:DestroyLogisticsB() end
end script.on_event(defines.events.on_player_mined_entity,warptorio.OnPlayerMinedEntity)

function warptorio.OnEntityDied(event) local e=event.entity if(warptorio.IsTeleporterGate(e))then local t=gwarptorio.Teleporters["offworld"] t:DestroyLogisticsB() t.PointB=nil t:Warpin() end
end script.on_event(defines.events.on_entity_died,warptorio.OnEntityDied)

function warptorio.IsTeleporterGate(e) return (e.name:sub(1,25)=="warptorio-teleporter-gate") end

-- --------
-- Logistics system

function warptorio.GetLogisticsEnergyCost(c) return 200 end
function warptorio.SpendLogisticsEnergy(c) end

function warptorio.GetSteamTemperature(v) local t={name="steam",amount=1,temperature=15} local c=v.remove_fluid(t)
	if(c~=0)then return 15 else t.temperature=165 c=v.remove_fluid(t) if(c~=0)then return 165 else t.temperature=500 c=v.remove_fluid(t) if(c~=0)then return 500 end end end return 15
end

local logz={} warptorio.Logistics=logz
function logz.BalanceEnergy(a,b) local x=(a.energy+b.energy)/2 a.energy,b.energy=x,x end
function logz.BalanceHeat(a,b) local x=(a.temperature+b.temperature)/2 a.temperature,b.temperature=x,x end

function logz.MoveContainer(a,b) local ac,bc=a.get_inventory(defines.inventory.chest),b.get_inventory(defines.inventory.chest)
	for k,v in pairs(ac.get_contents())do local t={name=k,count=v} local c=bc.insert(t) if(c>0)then ac.remove({name=k,count=c}) end end
end
function logz.BalanceFluid(a,b) local af,bf=a.get_fluid_contents(),b.get_fluid_contents() local aff,afv=table.First(af) local bff,bfv=table.First(bf) afv=afv or 0 bfv=bfv or 0
	if((not aff and not bff) or (aff and bff and aff~=bff) or (afv==0 and bfv==0) or (afv==bfv))then return end
	if(not aff)then aff=bff elseif(not bff)then bff=aff end
	local v=(afv+bfv)/2
	
	if(aff=="steam")then
		local temp=15 local at=warptorio.GetSteamTemperature(a) local bt=warptorio.GetSteamTemperature(b) temp=math.max(at,bt)
		a.clear_fluid_inside() b.clear_fluid_inside() a.insert_fluid({name=aff,amount=v,temperature=temp}) b.insert_fluid({name=bff,amount=v,temperature=temp})
	else
		a.clear_fluid_inside() b.clear_fluid_inside() a.insert_fluid({name=aff,amount=v}) b.insert_fluid({name=bff,amount=v})
	end
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
	elseif(a.type=="container" and b.type==a.type)then -- transfer items
		warptorio.Logistics.MoveContainer(a,b)
	elseif(a.type=="pipe-to-ground" and b.type==a.type)then -- transfer fluids
		if(bal==true)then warptorio.Logistics.BalanceFluid(a,b)
		else warptorio.Logistics.MoveFluid(a,b)
		end
	elseif(a.temperature and b.temperature)then
		warptorio.Logistics.BalanceHeat(a,b)
	end
end

function warptorio.TickLogistics(e)
	local points={}
	for k,v in pairs(gwarptorio.Teleporters)do v:BalanceLogistics() table.insert(points,v.PointA) table.insert(points,v.PointB) end
	--local pnum=#points
	--local eg=0
	--for k,v in pairs(points)do eg=eg+v.energy end

end


-- --------
-- Warptorio Entities

function warptorio.SpawnEntity(f,n,x,y,dir,type) local e=f.create_entity{name=n,position={x,y},force=game.forces.player,direction=dir,type=type} e.last_user=game.players[1] return e end

function warptorio.InitEntities()
	local main=gwarptorio.Floors.main
	local b1=gwarptorio.Floors.b1
	local b2=gwarptorio.Floors.b2

	local e=main.f.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player}
	main.ents.warp_reactor=e
	e.minable=false
end

warptorio.BadCloneTypes={"offshore-pump","resource","warptorio-underground-1"}

local clone={} warptorio.OnEntCloned=clone
clone["warp-reactor"] = function(event)
	if gwarptorio.warpenergy then event.destination.insert{name="warptorio-reactor-fuel-cell",count=1} end
	gwarptorio.warp_reactor = event.destination
end

function warptorio.OnEntityCloned(ev) local d=ev.destination local type,name=d.type,d.name if(type=="character" or warptorio.BadCloneTypes[name])then d.destroy() return
	elseif(clone[name])then clone[name](ev) return end
	local e=ev.source
	for k,v in pairs(gwarptorio.Teleporters)do
		if(e==v.PointA)then v.PointA=d v:ConnectCircuit() return
		elseif(e==v.PointB)then v.PointB=d v:ConnectCircuit() return
		elseif(v.logs)then for a,x in pairs(v.logs)do
			if(ev.source==x)then v.logs[a]=d return end
		end end
	end
end script.on_event(defines.events.on_entity_cloned, warptorio.OnEntityCloned)




-- ----
-- further setup

function warptorio.OnLoad()
	--if(not global.warptorio)then global.warptorio={} end gwarptorio=(gwarptorio or global.warptorio)
	gwarptorio=global.warptorio
	for k,v in pairs(gwarptorio.Floors)do setmetatable(v,warptorio.FloorMeta) end
	for k,v in pairs(gwarptorio.Teleporters)do setmetatable(v,warptorio.TeleporterMeta) end
end script.on_load(warptorio.OnLoad)




function warptorio.TickWarpEnergy(e)
	--*** warp energy upgrade update - warp reactor heat
end


function warptorio.TickPollution()
	local f=gwarptorio.Floors.main:GetSurface()
	if(not f or not f.valid)then return end
	f.pollute({-1,-1},gwarptorio.pollution_amount)

	local m=gwarptorio.Floors
	local pb1=m.b1:GetSurface().get_total_pollution()
	local pb2=m.b2:GetSurface().get_total_pollution()
	gwarptorio.Floors.main:GetSurface().pollute({-1,-1},pb1+pb2)
	m.b1:GetSurface().clear_pollution()
	m.b2:GetSurface().clear_pollution()
	
	gwarptorio.pollution_amount = gwarptorio.pollution_amount * settings.global['warptorio_warp_polution_factor'].value
	local expandcd=math.floor(gwarptorio.biter_expand_cooldown / game.forces["enemy"].evolution_factor / 100)
	local et=game.map_settings.enemy_expansion
	local ex=expandcd
	if(expandcd > 3600*60)then ex=3600*60-1 end
	et.max_expansion_cooldown=math.min(expandcd+1,3600*60)


	game.map_settings.enemy_expansion.max_expansion_cooldown = game.map_settings.enemy_expansion.min_expansion_cooldown + 1
	
end
function warptorio.TickWarpAlarm()
	if gwarptorio.warp_charging == 1 then 
		if gwarptorio.warp_time_left <= 3600 then 
			warptorio.playsound("warp_alarm", gwarptorio.Floors.main:GetSurface().name)
		end
	end 
end
function warptorio.TickAccelerator(e)
	
	--*** warp accelerator logic
	if gwarptorio.warp_accelerator ~= nil and gwarptorio.warp_charging == 0 then
		if gwarptorio.warp_accelerator.energy > 5*math.pow(10, 6)-1 then
			gwarptorio.warp_accelerator.energy = 0
			gwarptorio.warp_charge_time = gwarptorio.warp_charge_time *0.99
			local caption = "   Charge Time : " .. util.formattime(math.ceil(60*global.warp_charge_time))
			warptorio.updatelabel("time_left",caption)
		end
	end
end

function warptorio.TickStabilizer(e)
	--*** bitter anger clean capacity
	if global.warp_stabilizer_accumulator ~= nil then
		local stabilize = 0
		if global.warp_stabilizer_accumulator_discharge_count == 0 and global.warp_stabilizer_accumulator.energy > 1*math.pow(10, 8)-1 then
			global.warp_stabilizer_accumulator_discharge_count = 1
			stabilize = 1
			if global.warp_stabilizer_accumulator_research_level > 1 then
				create_warp_stab_accu(2)
			end	
		elseif global.warp_stabilizer_accumulator_discharge_count == 1 and global.warp_stabilizer_accumulator.energy > 1*math.pow(10, 10)-1 and global.warp_stabilizer_accumulator_research_level > 1 then
			stabilize = 1
			if global.warp_stabilizer_accumulator_research_level > 2 then
				create_warp_stab_accu(3)
			end					
		elseif global.warp_stabilizer_accumulator_discharge_count == 2 and global.warp_stabilizer_accumulator.energy > 1*math.pow(10, 11)-1 and global.warp_stabilizer_accumulator_research_level > 2 then
			stabilize = 1
			global.warp_stabilizer_accumulator_discharge_count = 3
		end
		if stabilize == 1 then
			game.forces["enemy"].evolution_factor=0	
			global.polution_amount = 1
			game.surfaces[global.current_surface].clear_pollution()
			game.surfaces[global.current_surface].set_multi_command{command={type=defines.command.flee, from=global.warp_reactor}, unit_count=1000, unit_search_distance=500}
			surface_play_sound("reactor-stabilized", global.current_surface)	

		end
	end
end

function warptorio.TickTimers(e)
	if(gwarptorio.warp_charging==1)then
		gwarptorio.warp_time_left=60*gwarptorio.warp_charge_time - (e-gwarptorio.warp_charge_start_tick)
		warptorio.updatelabel("time_left","   Time to warp : " .. util.formattime(gwarptorio.warp_time_left))
		if(gwarptorio.warp_time_left<=0)then
			warptorio.Warpout()
			gwarptorio.time_spent_start_tick=e
		end
	end
	gwarptorio.time_passed=e - gwarptorio.time_spent_start_tick
	warptorio.updatelabel("time_passed_label","   Time passed on this planet : " .. util.formattime(gwarptorio.time_passed))
end

function warptorio.Tick(ev) local e=ev.tick
	if(e%5==0)then
		warptorio.TickLogistics(e)
		if(e%30==0)then
			warptorio.TickTeleporters(e)
			if(e%60==0)then
				warptorio.TickTimers(e)
				if(e%120==0)then
					-- attack left behind engineers (removed because not needed and factorissimo support)
					warptorio.TickPollution(e)
					warptorio.TickWarpAlarm(e)
					warptorio.TickWarpEnergy(e)
					warptorio.TickWarpAlarm(e)
					warptorio.TickAccelerator(e)
					warptorio.TickStabilizer(e)
				end
			end
		end
	end
end script.on_event(defines.events.on_tick,warptorio.Tick)





function warptorio.OnPlayerRespawned(event) -- teleport to warp platform on respawn
	local cf=warptorio.Floors.main:GetSurface() local gp=game.players[event.player_index]
	if(gp.character.surface~=cf)then local pos=cf.find_non_colliding_position("character",{0,-5},0,1,1) gp.teleport(pos,cf) end
end script.on_event(defines.events.on_player_respawned,warptorio.OnPlayerRespawned)



-- -------
-- Upgrades

local upcs={} warptorio.UpgradeClass=upcs

function warptorio.DoUpgrade(ev) local up=ev.name local u=warptorio.Research[up] if(u)then
	if(type(u)=="table")then local lv=ev.level gwarptorio.Research[u[1]]=lv local c=warptorio.UpgradeClass[u[1]] if(c)then c(lv,u[2]) end -- (gwarptorio.Research[u[1]] or 0)+1
	elseif(type(u)=="function")then u() end
end end script.on_event(defines.events.on_research_finished,function(event) warptorio.DoUpgrade(event.research) end)

function warptorio.GetUpgrade(up) local u=warptorio.Research[u] if(u)then
	if(type(u)=="table")then local lv=gwarptorio.Research[u[1]] or 0 return lv,u[2] end
end end

upcs["platform-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.Floors.main m.OuterSize=n m:SetSize(m.OuterSize) warptorio.BuildPlatform() end
upcs["factory-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.Floors.b1 m:SetSize(n) warptorio.BuildB1() end
upcs["boiler-size"]=function(lv,f) local n=f(lv) local m=gwarptorio.Floors.b2 m:SetSize(n) warptorio.BuildB2() end

upcs["teleporter-energy"]=function(lv) gwarptorio.Teleporters.offworld:UpgradeEnergy() end
upcs["factory-logistics"]=function(lv) for k,v in pairs(gwarptorio.Teleporters)do v:UpgradeLogistics() end end
upcs["factory-energy"]=function(lv) local m=gwarptorio.Teleporters
	if(m.b1)then m.b1:UpgradeEnergy() end if(m.b2)then m.b2:UpgradeEnergy() end
	for k,v in pairs({"nw","ne","sw","se"}) do if(m[v])then m[v]:UpgradeEnergy() end end
end

upcs["factory-beacon"]=function(lv,f) local m=gwarptorio.Floors.b1 local inv={}
	if(m.beacon and m.beacon.valid)then inv=m.beacon.get_module_inventory().get_contents() end
	warptorio.cleanbbox(m:GetSurface(),-2,-2,1,1) m.beacon=warptorio.SpawnEntity(m:GetSurface(),"warptorio-beacon-"..lv,-1,-1) m.beacon.minable=false m.beacon.destructible=false
	for k,v in pairs(inv)do m.beacon.get_module_inventory().insert({name=k,count=v}) end
	warptorio.playsound("warp_in",m:GetSurface().name)
end
upcs["reactor"]=function(lv) local m=gwarptorio.Floors.b2
	if(not m.heat1 or not m.heat1.valid)then local e=warptorio.SpawnEntity(m:GetSurface(),"heat-pipe",-1,0) e.minable=false e.destructible=false m.heat1=e end
	if(lv>=1 and (not m.heat2 or not m.heat2.valid))then local e=warptorio.SpawnEntity(m:GetSurface(),"heat-pipe",-1,-1) e.minable=false e.destructible=false m.heat2=e end
	if(lv>=2 and (not m.heat3 or not m.heat3.valid))then local e=warptorio.SpawnEntity(m:GetSurface(),"heat-pipe",-1,-2) e.minable=false e.destructible=false m.heat3=e end
	if(lv>=3 and (not m.heat4 or not m.heat4.valid))then local e=warptorio.SpawnEntity(m:GetSurface(),"heat-pipe",-1,-3) e.minable=false e.destructible=false m.heat4=e end
	warptorio.playsound("warp_in",m:GetSurface().name)
end
upcs["stabilizer"]=function(lv) local m=gwarptorio.Floors.main
	warptorio.cleanbbox(m:GetSurface(),-6,-2,-4,0) local e=warptorio.SpawnEntity(m:GetSurface(),"warptorio-stabilizer-"..lv,-5,-1) m.stabilizer=e e.minable=false
	warptorio.playsound("warp_in",m:GetSurface().name)
end
upcs["accelerator"]=function(lv) local m=gwarptorio.Floors.main
	warptorio.cleanbbox(m:GetSurface(),-3,-3,2,2) local e=warptorio.SpawnEntity(m:GetSurface(),"warptorio-accelerator-"..lv,4,-1) e.minable=false
end

local ups={} warptorio.Research=warptorio.Research or ups
ups["warptorio-platform-size-1"] = {"platform-size",function() return 10+7 end}
ups["warptorio-platform-size-2"] = {"platform-size",function() return 18+7 end}
ups["warptorio-platform-size-3"] = {"platform-size",function() return 24+7 end}
ups["warptorio-platform-size-4"] = {"platform-size",function() return 32+7 end}
ups["warptorio-platform-size-5"] = {"platform-size",function() return 48+7 end}
ups["warptorio-platform-size-6"] = {"platform-size",function() return 64+7 end}
ups["warptorio-platform-size-7"] = {"platform-size",function() return 96+7 end}

ups["warptorio-factory-0"] = function() warptorio.TeleCls.b1() end -- 17
ups["warptorio-factory-1"] = {"factory-size",function() return 23 end}
ups["warptorio-factory-2"] = {"factory-size",function() return 31 end}
ups["warptorio-factory-3"] = {"factory-size",function() return 39 end}
ups["warptorio-factory-4"] = {"factory-size",function() return 47 end}
ups["warptorio-factory-5"] = {"factory-size",function() return 55 end}
ups["warptorio-factory-6"] = {"factory-size",function() return 63 end}
ups["warptorio-factory-7"] = {"factory-size",function() return 71+2 end}

ups["warptorio-boiler-0"] = function() warptorio.TeleCls.b2() end
ups["warptorio-boiler-1"] = {"boiler-size",function() return 24 end}
ups["warptorio-boiler-2"] = {"boiler-size",function() return 32 end}
ups["warptorio-boiler-3"] = {"boiler-size",function() return 40 end}
ups["warptorio-boiler-4"] = {"boiler-size",function() return 48 end}
ups["warptorio-boiler-5"] = {"boiler-size",function() return 56 end}
ups["warptorio-boiler-6"] = {"boiler-size",function() return 64 end}
ups["warptorio-boiler-7"] = {"boiler-size",function() return 72 end}

ups["warptorio-reactor-1"] = {"reactor"}
ups["warptorio-reactor-2"] = {"reactor"}
ups["warptorio-reactor-3"] = {"reactor"}
ups["warptorio-reactor-4"] = {"reactor"}

ups["warptorio-teleporter-0"] = function() warptorio.TeleCls.offworld() end
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

ups["warptorio-radar-1"] = {"radar"}
ups["warptorio-radar-2"] = {"radar"}
ups["warptorio-radar-3"] = {"radar"}

ups["warptorio-stabilizer-1"] = {"stabilizer"}
ups["warptorio-stabilizer-2"] = {"stabilizer"}
ups["warptorio-stabilizer-3"] = {"stabilizer"}
ups["warptorio-stabilizer-4"] = {"stabilizer"}


ups["warptorio-accelerator-1"] = {"accelerator"}

ups["warptorio-duallogistic-1"] = function() gwarptorio.duallogistic=true end
ups["warptorio-warpenergy-0"] = function() gwarptorio.warpenergy=true end

-- ups["warptorio-train-1"] = function() warptorio.TeleCls.train() end
-- ups["warptorio-train-2"] = function() warptorio.TeleCls.train2() end

upcs["turret-nw"] = function(lv) warptorio.TeleCls.nw() end
upcs["turret-sw"] = function(lv) warptorio.TeleCls.sw() end
upcs["turret-ne"] = function(lv) warptorio.TeleCls.ne() end
upcs["turret-se"] = function(lv) warptorio.TeleCls.se() end

for k,v in pairs{"nw","ne","se","sw"} do
ups["warptorio-turret-"..v.."-0"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-1"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-2"] = {"turret-"..v}
ups["warptorio-turret-"..v.."-3"] = {"turret-"..v}
end

ups["warptorio-boiler-water-1"] = function() gwarptorio.waterboiler=1 warptorio.BuildB2() end
ups["warptorio-boiler-water-2"] = function() gwarptorio.waterboiler=2 warptorio.BuildB2() end



-- --------
-- Gui



function warptorio.BuildGui(player)

	button_warp = mod_gui.get_frame_flow(player).add{type = "button", name = "warp", caption = {"warp"}}
	mod_gui.get_frame_flow(player).add{type = "label", name = "time_passed_label", caption = {"time-passed-label", "-"}}	
	mod_gui.get_frame_flow(player).add{type = "label", name = "time_left", caption = {"time-left", "-"}}
	mod_gui.get_frame_flow(player).add{type = "label", name = "number_of_warps_label", caption = {"number-of-warps-label", "-"}}
	
	local label = mod_gui.get_frame_flow(player).number_of_warps_label
	label.caption = "   Warp number : " .. (gwarptorio.warpzone or 0)
	
	local label = mod_gui.get_frame_flow(player).time_left
	label.caption = "   Charge Time : " .. util.formattime(0) --global.warp_time_left)

	
end

script.on_event(defines.events.on_gui_click, function(event)
	local gui = event.element
	if gui.name == "warp" and gwarptorio.warp_charging<1 then
		gwarptorio.warp_charge_start_tick = event.tick
		gwarptorio.warp_charging = 1
	end
end)


-- Initialize Players
function warptorio.InitPlayer(e)
	local i=e.player_index
	local p=game.players[i]
	warptorio.BuildGui(p)
	--if(i==1)then warptorio.Initialize() end
	warptorio.safeteleport(p.character,{0,-5},gwarptorio.Floors.main:GetSurface())
end script.on_event(defines.events.on_player_created,warptorio.InitPlayer)

-- --------
-- Platforms

local FLOOR={} FLOOR.__index=FLOOR warptorio.FloorMeta=FLOOR
function FLOOR.__init(self,n,z) global.warptorio.Floors[n]=self self.f,self.n=f,n self.ents={} self:SetSize(z) end
function FLOOR:SetSize(z) self.z,self.x,self.y,self.w,self.h=z,-z/2,-z/2,z,z self:CalcSizebox() end
function FLOOR:CalcSizebox() self.pos={self.x,self.y} self.size={self.w,self.h}
	self.bbox={self.x+self.w,self.y+self.h} self.area={self.pos,self.bbox} self.sizebox={self.pos,self.size} end
function FLOOR:GetPos() return self.pos end
function FLOOR:GetSize() return self.size end
function FLOOR:GetBBox() return self.bbox end
function FLOOR:GetSizebox() return {self.pos,self.size} end
function FLOOR:SetSurface(f) self.f=f end
function FLOOR:GetSurface() return self.f end
function FLOOR:BuildSurface(id) if(self:GetSurface())then return end
	local f=game.create_surface(id,{width=2,height=2})
	f.always_day = true
	f.daytime=0
	f.request_to_generate_chunks({0,0},24)
	f.force_generate_chunk_requests()
	local e=f.find_entities() for k,v in pairs(e)do e[k].destroy() end
	--f.name=id
	f.destroy_decoratives({area={self.pos,self.bbox}})
	self:SetSurface(f)
	return f
end

function warptorio.GetFloor(n) return global.warptorio.Floors[n] end
function warptorio.CurrentFloor() return global.warptorio.Floors["main"] end

function warptorio.InitFloors() -- init_floors(f)
	local f=game.surfaces["nauvis"]
	local m=new(FLOOR,"main",6)
	m:SetSurface(f)
	m.OuterSize=9
	local z=m.OuterSize
	m:SetSize(m.OuterSize)

	warptorio.BuildPlatform(z)
	warptorio.cleanbbox(f,math.floor(-z/2),math.floor(-z/2),z,z)

	local m=new(FLOOR,"b1",17)
	local f=m:BuildSurface("warpfloor-b1")
	warptorio.BuildB1()

	local m=new(FLOOR,"b2",17)
	local f=m:BuildSurface("warpfloor-b2")
	warptorio.BuildB2()

end


-- ----
-- Floor helpers

function warptorio.CountEntities() local c=0 for k,v in pairs(gwarptorio.Floors)do local e=v.f.find_entities(v.area) for a,b in pairs(e)do c=c+1 end end return c end


-- --------
-- Warpout




function warptorio.RandomPlanet(z) z=z or gwarptorio.warpzone local zp={} for k,v in pairs(warptorio.Planets)do if((v.zone or 0)<z)then for i=1,(v.rng or 1) do table.insert(zp,k) end end end
	return warptorio.Planets[table.Random(zp)] end

function warptorio.DoNextPlanet()
	local w=warptorio.RandomPlanet(gwarptorio.warpzone+1)
	return w
end

function warptorio.BuildNewPlanet()
	local rng=math.random(1,table.Count(warptorio.Planets))
	local w if(gwarptorio.nextplanet)then w=warptorio.Planets[gwarptorio.nextplanet] gwarptorio.nextplanet=warptorio.DoNextPlanet() else w=warptorio.RandomPlanet() end
	local lvl=gwarptorio.Research["radar"] or 0

	if(lvl==1)then game.print(w.name) end
	game.print(w.desc)

	local seed=(game.surfaces["nauvis"].map_gen_settings.seed + math.random(0,4294967295)) % 4294967296
	local t=(w.gen and table.deepcopy(w.gen) or {}) t.seed=seed if(w.fgen)then w.fgen(t,lvl>=3) end local f = game.create_surface("warpsurf_"..gwarptorio.warpzone,t)
	f.request_to_generate_chunks({0,0},3) f.force_generate_chunk_requests()
	if(w.spawn)then w.spawn(f,lvl==1) end

	game.forces.player.chart_all(f)

	return f
end






function warptorio.Warpout()
	gwarptorio.warp_charge = 0
	gwarptorio.warp_charging=0
	gwarptorio.warpzone = gwarptorio.warpzone+1
	warptorio.updatelabel("number_of_warps_label","    Warp number : " .. gwarptorio.warpzone)

	-- charge time
	local c=warptorio.CountEntities()
	gwarptorio.warp_charge_time=1 --10+c/settings.global['warptorio_warp_charge_factor'].value + gwarptorio.warpzone*0.5
	gwarptorio.warp_time_left = 1 --60*gwarptorio.warp_charge_time
	warptorio.updatelabel("time_left","   Charge Time : " .. util.formattime(gwarptorio.warp_time_left))

	-- create next surface
	local f=warptorio.BuildNewPlanet()

	-- Do the thing
	--for k,v in pairs(gwarptorio.Teleporters)do v:Warpout() end

	local m=gwarptorio.Floors.main
	local c=m:GetSurface()
	local bbox=m.area

	local tpply={}
	c.clone_area{source_area=bbox, destination_area=bbox, destination_surface=f, destination_force=game.forces.player, expand_map=false, clone_tiles=true, clone_entities=true,
		clone_decoratives=false, clear_destination=true}

	-- teleport players to new surface
	for k,v in pairs(game.players)do
		local p,b=m:GetPos(),m:GetBBox()
		if(v.character~=nil and v.surface.name==c.name and warptorio.isinbbox(v.character.position,{x=p[1],y=p[2]},{x=b[1],y=b[2]}))then
			table.insert(tpply,{v,{v.position.x,v.position.y}})
		elseif(v.character~=nil and v.surface.name==gwarptorio.Floors.b1:GetSurface().name or v.surface.name==gwarptorio.Floors.b2:GetSurface().name)then
			table.insert(tpply,{v,{0,0}})
		end
	end

	local cx=warptorio.corn
	for k,v in pairs({"nw","ne","sw","se"})do local ug=gwarptorio.Research["turret-"..v] or -1 if(ug>=0)then
		local etc=f.find_entities_filtered{position={cx[v].x,cx[v].y},radius=(11+(ug*6))/2} for a,e in pairs(etc)do e.destroy() end

		local etp=c.find_entities_filtered{type="character",position={cx[v].x,cx[v].y},radius=(11+(ug*6))/2}
		for a,e in pairs(etp)do if(e.player and e.player.character~=nil)then table.insert(tpply,{e.player,{e.position.x,e.position.y}}) end end
			--e.player.teleport(f.find_non_colliding_position("character",{e.position.x,e.position.y},0,1,1),f) end end

		local et=c.find_entities_filtered{type="character",invert=true,position={cx[v].x,cx[v].y},radius=(11+(ug*6))/2}
		c.clone_entities{entities=et,destination_offset={0,0},destination_surface=f,destination_force=game.forces.player}
	end end


	for k,v in pairs(tpply)do
		v[1].teleport(f.find_non_colliding_position("character",{v[2][1],v[2][2]},0,1,1),f)
	end

	gwarptorio.Floors.main:SetSurface(f)
	--for k,v in pairs(gwarptorio.Teleporters)do v:Warpin() end


	-- radar stuff -- game.forces.player.chart(game.player.surface, {lefttop = {x = -1024, y = -1024}, rightbottom = {x = 1024, y = 1024}})
	--game.forces.player.chart(f,{lefttop={x=-256,y=-256},rightbottom={x=256,y=256}})

	-- build void

	for k,v in pairs({"nw","ne","sw","se"})do local ug=gwarptorio.Research["turret-"..v] or -1 if(ug>=0)then
			warptorio.LayCircle("out-of-map",c,cx[v].x,cx[v].y,11+ug*6)
	end end
	warptorio.LayFloorVec("out-of-map",c,m:GetPos(),m:GetSize())

	-- delete abandoned surfaces
	for k,v in pairs(game.surfaces)do if(#(v.find_entities_filtered{type="character"})<1)then local n=v.name if(n:sub(1,9)=="warpsurf_")then game.delete_surface(v) end end end

	-- stuff to reset
	gwarptorio.surf_to_leave_angry_biters_counter = 0
	game.forces["enemy"].evolution_factor=0
	gwarptorio.pollution_amount=1
	gwarptorio.warp_stabilizer_accumulator_discharge_count = 0

	-- warp sound
	warptorio.playsound("warp_in", c.name)
	warptorio.playsound("warp_in", f.name)

	-- What an odd bug.
	warptorio.BuildPlatform()
end


-- --------
-- Helper functions

function warptorio.layvoid(f,x,y,z) warptorio.FillSquare("out-of-map",f,x,y,z,z) end

function warptorio.LayFloor(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} for i=0,w-1 do for j=0,h-1 do table.insert(t,{name=tex,position={i+x,j+y}}) end end f.set_tiles(t) end

function warptorio.LayBorder(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} w=w-1 h=h-1
	for i=0,w do table.insert(t,{name=tex,position={x+i,y}}) table.insert(t,{name=tex,position={x+i,y+h}}) end
	for j=0,h do table.insert(t,{name=tex,position={x,y+j}}) table.insert(t,{name=tex,position={x+w,y+j}}) end
	f.set_tiles(t)
end



function warptorio.LayFloorVec(tx,f,p,z,b) if(b)then f.destroy_decoratives({area=b}) end
	local t={} for i=0,z[1]-1 do for j=0,z[2]-1 do table.insert(t,{name=tx,position={i+p[1],j+p[2]}}) end end f.set_tiles(t) end
function warptorio.cleanbbox(f,x,y,w,h) local e=f.find_entities({{x,y},{x+w,y+h}})
	for k,v in ipairs(e)do if(v.type~="character")then v.destroy() else warptorio.safeteleport(v,{0,0},f) end end end
function warptorio.safeteleport(e,x,f) local xf=f.find_non_colliding_position(e.name,x,0,1,1)
	if(e.type=="character")then for k,v in pairs(game.players)do if(v.character==e)then v.teleport(xf,f) end end end end

function warptorio.PrintToCharacter(c,msg,x) for k,v in pairs(game.players)do if(v.character==c)then v.print(msg) end end end
function warptorio.updatelabel(lbl,txt) for k,v in pairs(game.players)do local lb=mod_gui.get_frame_flow(v) local lb2=lb[lbl] lb2.caption=txt end end
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





function warptorio.Initialize() if(not global.warptorio)then global.warptorio={} gwarptorio=global.warptorio else gwarptorio=global.warptorio return end
	gwarptorio.warpzone=0

	gwarptorio.surf_to_leave_angry_biters_counter = 0
	gwarptorio.pollution_amount = 1

	gwarptorio.warp_charge_time= 1--10 --in seconds
	gwarptorio.warp_charge_start_tick = 0
	gwarptorio.warp_charging = 0
	gwarptorio.warp_timeleft = 60*10
	gwarptorio.warp_reactor = nil

	gwarptorio.time_spent_start_tick = 0
	gwarptorio.time_passed = 0

	gwarptorio.pollution_amount = settings.global['warptorio_warp_polution_factor'].value
	gwarptorio.biter_expand_cooldown = 1000 * 60
	gwarptorio.charge_factor = settings.global['warptorio_warp_charge_factor'].value


	gwarptorio.Teleporters={}
	gwarptorio.Research={}
	gwarptorio.Floors={}
	gwarptorio.Turrets={}

	warptorio.InitFloors()
	warptorio.InitEntities()
	warptorio.InitTeleporters()

	game.map_settings.pollution.diffusion_ratio = 0.1
	game.map_settings.pollution.pollution_factor = 0.0000001
		
	game.map_settings.pollution.min_to_diffuse=15
	game.map_settings.unit_group.min_group_gathering_time = 600
	game.map_settings.unit_group.max_group_gathering_time = 2 * 600
	game.map_settings.unit_group.max_unit_group_size = 200
	game.map_settings.unit_group.max_wait_time_for_late_members = 2 * 360
	game.map_settings.unit_group.settler_group_min_size = 1
	game.map_settings.unit_group.settler_group_max_size = 1

--[[


--local warp_charge_time_lengthening = settings.global['warptorio_warp_charge_time_lengthening'].value --in seconds
--local warp_charge_time_at_start = settings.global['warptorio_warp_charge_time_at_start'].value --in seconds


	global.warp_reactor = nil
	global.warp_stabilizer_accumulator = nil
	global.warp_stabilizer_accumulator_discharge_count = 0
	global.warp_stabilizer_accumulator_research_level = 0

]]
end script.on_init(warptorio.Initialize)


