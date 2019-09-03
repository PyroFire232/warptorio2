
-- hook.add("hook","name",function(...) end) hook.call("hook",varg,varg,...)

-- vector.LayTiles( "out-of-map",game.surfaces[1],vector.area(vector(x,y),vector(x,y)) or vector.square(vector(x,y),vector(w,h)) )
-- if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
-- f.destroy_decoratives(vector.area()) vector.LayTiles(tex,f,vector.area())
-- vector.LayCircle("out-of-map",game.surfaces[1],vector.circle(vector(x,y),radius))

--[[ -- old environment code


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

tpcls=tpcls or {}
function tpcls.nw(upgr,logs) local c=warptorio.corn.nw warptorio.SpawnTurretTeleporter("nw",c.x,c.y,upgr,logs) gwarptorio.Turrets.nw=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.sw(upgr,logs) local c=warptorio.corn.sw warptorio.SpawnTurretTeleporter("sw",c.x,c.y,upgr,logs) gwarptorio.Turrets.sw=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.ne(upgr,logs) local c=warptorio.corn.ne warptorio.SpawnTurretTeleporter("ne",c.x,c.y,upgr,logs) gwarptorio.Turrets.ne=n warptorio.BuildPlatform() warptorio.BuildB1() end
function tpcls.se(upgr,logs) local c=warptorio.corn.se warptorio.SpawnTurretTeleporter("se",c.x,c.y,upgr,logs) gwarptorio.Turrets.sw=n warptorio.BuildPlatform() warptorio.BuildB1() end




function warptorio.TickEnergy(e) local t={}
	for k,v in pairs(gwarptorio.Teleporters)do if(v:ValidA())then table.insert(t,v.a) end if(v:ValidB())then table.insert(t,v.b) end end
	for k,v in pairs(gwarptorio.cache.power)do if(v.valid)then table.insert(t,v) end end
	local pnum=#points local eg=0 local ec=0
	for k,v in pairs(t)do eg=eg+v.energy ec=ec+v.electric_buffer_size end
	for k,v in pairs(t)do local r=(v.electric_buffer_size/ec) v.energy=eg*r end
end

warptorio.railCorn={nw={x=-35,y=-35},ne={x=34,y=-35},sw={x=-35,y=34},se={x=34,y=34}} 
warptorio.railLoader={nw={{2,0},{0,2}},sw={{2,0},{0,-2}},ne={{-2,0},{0,2}},se={{-2,0},{0,-2}}}
warptorio.railOffset={nw={-1,-1},ne={0,-1},sw={-1,0},se={0,0}}

function warptorio.LayFloorVec(tx,f,p,z,b) if(b)then f.destroy_decoratives({area=b}) end
	local t={} for i=0,z[1]-1 do for j=0,z[2]-1 do table.insert(t,{name=tx,position={i+p[1],j+p[2]}}) end end f.set_tiles(t) end



function warptorio.playsound(pth,f,x) players.playsound(pth,f,x) end --for k,v in pairs(game.connected_players)do if(v.surface.name==f)then v.play_sound{path=pth,position=x} end end end

function warptorio.layvoid(f,x,y,z) vector.LayTiles("out-of-map",f,vector.square(vector(x,y),vector(z,z))) end --warptorio.LayFloor("out-of-map",f,x,y,z,z) end

function warptorio.LayFloor(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} for i=0,w-1 do for j=0,h-1 do table.insert(t,{name=tex,position={i+x,j+y}}) end end f.set_tiles(t) end

function warptorio.LayBorder(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} w=w-1 h=h-1
	for i=0,w do table.insert(t,{name=tex,position={x+i,y}}) table.insert(t,{name=tex,position={x+i,y+h}}) end
	for j=0,h do table.insert(t,{name=tex,position={x,y+j}}) table.insert(t,{name=tex,position={x+w,y+j}}) end
	f.set_tiles(t)
end
function warptorio.isinbbox(pos,pos1,pos2) return not ( (pos.x<pos1.x or pos.y<pos1.y) or (pos.x>pos2.x or pos.y>pos2.y) ) end
function warptorio.GetLogisticsChestBelt(dir) local lv=gwarptorio.Research["factory-logistics"] or 0
	if(lv<=1)then return "wooden-chest","loader" elseif(lv==2)then return "iron-chest","fast-loader" elseif(lv==3)then return "steel-chest","express-loader"
	elseif(lv>=4)then return (dir=="output" and gwarptorio.LogisticLoaderChestProvider or gwarptorio.LogisticLoaderChestRequester),warptorio.GetFastestLoader() end
end
function warptorio.SpawnEntity(f,n,x,y,dir,type) return entity.spawn(f,n,vector(x,y),{direction=dir,type=type}) end --local e=f.create_entity{name=n,position={x,y},force=game.forces.player,direction=dir,type=type,raise_built=true} e.last_user=game.players[1] return e end
function warptorio.ProtectEntity(e,min,des) entity.protect(e,min,des) end --if(min~=nil)then e.minable=min end if(des~=nil)then e.destructible=des end end


function warptorio.FlipDirection(v) return (v+4)%8 end

]]

--[[ old tiles code
function warptorio.LaySquare(tex,f,x,y,w,h) local wf,wc=math.floor(w/2),math.ceil(w/2) local hf,hc=math.floor(h/2),math.ceil(h/2) local t={}
	for xv=x-wf,x+wc do for yv=y-hf,y+hf do table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t)
end
function warptorio.LaySquareEx(tex,f,x,y,w,h) local wf,wc=math.ceil(w/2),math.floor(w/2) local hf,hc=math.floor(h/2),math.ceil(h/2) local t={}
	for xv=x-wf,x+wc do for yv=y-hf,y+hc do table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t)
end
function warptorio.LayCircle(tex,f,x,y,z,b) local zf=math.floor(z/2) local t={}
	for xv=x-zf,x+math.floor(z/2) do for yv=y-zf,y+zf do local dist=math.sqrt(((xv-x)^2)+((yv-y)^2)) if(dist<=z/2)then table.insert(t,{name=tex,position={xv,yv}}) end end f.set_tiles(t) end
end
 --if(b)then local bbox={area={{x-z/2,y-z/2},{x+z,y+z}}} f.destroy_decoratives(bbox) end
function warptorio.LayTiles(tex,f,x,y,w,h,b)  local t={} for i=0,w-1 do for j=0,h-1 do table.insert(t,{name=tex,position={i+x,j+y}}) end end f.set_tiles(t) end
function warptorio.LayBorder(tex,f,x,y,w,h,b) if(b)then local bbox={area={{x,y},{x+w,y+h}}} f.destroy_decoratives(bbox) end
	local t={} w=w-1 h=h-1
	for i=0,w do table.insert(t,{name=tex,position={x+i,y}}) table.insert(t,{name=tex,position={x+i,y+h}}) end
	for j=0,h do table.insert(t,{name=tex,position={x,y+j}}) table.insert(t,{name=tex,position={x+w,y+j}}) end
	f.set_tiles(t)
end
function warptorio.LayFloorVec(tx,f,p,z,b) if(b)then f.destroy_decoratives({area=b}) end
	local t={} for i=0,z[1]-1 do for j=0,z[2]-1 do table.insert(t,{name=tx,position={i+p[1],j+p[2]}}) end end f.set_tiles(t) end

]]











--[[ -- Old teleporter logistics code

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

local TELL={} TELL.__index=TELL warptorio.TeleporterMeta=TELL
function TELL.__init(self,n,j) self.name=n self.top=j self.dir={{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"},{"input","output"}}
self.logcont={} gwarptorio.Teleporters[n]=self end
TELL.LogisticsEnts={}
for i=1,8,1 do table.insert(TELL.LogisticsEnts,"loader"..i) table.insert(TELL.LogisticsEnts,"chest"..i) end
for i=1,6,1 do table.insert(TELL.LogisticsEnts,"pipe"..i) end

function TELL:SpawnPointA(n,f,pos,nd) local e=warptorio.SpawnEntity(f,n,pos.x,pos.y) if(not nd)then e.minable=false e.destructible=false end self:SetPointA(e) return e end
function TELL:SpawnPointB(n,f,pos,nd) local e=warptorio.SpawnEntity(f,n,pos.x,pos.y) if(not nd)then e.minable=false e.destructible=false end self:SetPointB(e) return e end
function TELL:SetPointA(e) self.PointA=e if(self.PointAEnergy)then self.PointA.energy=self.PointAEnergy self.PointAEnergy=nil end end
function TELL:SetPointB(e) self.PointB=e if(self.PointBEnergy)then self.PointB.energy=self.PointBEnergy self.PointBEnergy=nil end end

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

function TELL:UpgradeLogistics() if(self.logs)then self:DestroyLogistics() end self:Warpin(false,true) end -- self:SpawnLogistics()
function TELL:UpgradeEnergy() self:Warpin(true) end



function TELL:DoCheckLoader(i)
	self:CheckLoaderDirection(i,self.logs["loader"..i.."-a"],self.logs["loader"..i.."-b"])
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



]]


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

--[[

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



]]


--buildplatform()
--....



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
		warptorio.LaySquare("warp-tile-concrete",f,-1,c.north/2,crz,cpz) -- main bridge
		if(t.nw>=0)then warptorio.LaySquare("warp-tile-concrete",f,(c.west/2),c.north,cpz,cz) end -- leg
		if(t.ne>=0)then warptorio.LaySquare("warp-tile-concrete",f,(c.east/2)-1,c.north,cpz,cz) end -- leg
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




	local lvx=gwarptorio.Research["factory-size"] or 0
	if(lvx>=7)then
		local zvx=96-12 local zvy=128-16 local zxm=32 local zxn=12 local zxc=10

		if(gwarptorio.factory_n)then warptorio.LaySquare("warp-tile-concrete",f,-1,-z-zxm-6,zvy,zvx)
			warptorio.LaySquare("warp-tile-concrete",f,-9-0.5,c.north-zxn,zxc,zxc)
			warptorio.LaySquare("warp-tile-concrete",f,9-0.5,c.north-zxn,zxc,zxc) end

		if(gwarptorio.factory_w)then warptorio.LaySquare("warp-tile-concrete",f,-z-zxm-6,-1,zvx,zvy)
			warptorio.LaySquare("warp-tile-concrete",f,c.west-zxn,-9-1,zxc,zxc)
			warptorio.LaySquare("warp-tile-concrete",f,c.west-zxn,9-1,zxc,zxc) end
		if(gwarptorio.factory_e)then warptorio.LaySquare("warp-tile-concrete",f,z+zxm+4,-1,zvx,zvy)
			warptorio.LaySquare("warp-tile-concrete",f,c.east+zxn,-9-1,zxc,zxc) warptorio.LaySquare("warp-tile-concrete",f,c.east+zxn,9-1,zxc,zxc) end

		if(gwarptorio.factory_s)then warptorio.LaySquare("warp-tile-concrete",f,-1,z+zxm+4,zvy,zvx)
			warptorio.LaySquare("warp-tile-concrete",f,-9-1,c.south+zxn,zxc,zxc) warptorio.LaySquare("warp-tile-concrete",f,9-1,c.south+zxn,zxc,zxc) end

		--for k,v in pairs({nw={-1,-1},sw={-1,-1},ne={-1,-1},se={-1,-1}})do local c=warptorio.railCorn[k] warptorio.LayFloor("hazard-concrete-left",f,c.x+v[1],c.y+v[2],2,2) end
	end
	


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



	if(rFacSize>=7)then -- trains
		for k,rv in pairs(platform.railOffset)do local rc=platform.railCorner[k]
			local rvx=platform.railLoader[k]
			vector.LayTiles("hazard-concrete-left",f,vector.square(vector(rc.x-1,rc.y-1),vector(2,2)))
			warptorio.LayFloor("hazard-concrete-left",f,vector.square(vector(rc.x-1+rvx[1][1],rc.y-1+rvx[1][2]),vector(2,2)))
			warptorio.LayFloor("hazard-concrete-left",f,vector.square(vector(rc.x-1+rvx[2][1],rc.y-1+rvx[2][2]),vector(2,2)))
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
		if(gwarptorio.boiler_n)then warptorio.LaySquare("warp-tile-concrete",f,-1,-z-zxm-6-1,zvy,zvx) warptorio.LaySquare("warp-tile-concrete",f,-9-1,-z-4,7-1,7) warptorio.LaySquare("warp-tile-concrete",f,9,-z-4,7-1,7)
			end
		if(gwarptorio.boiler_s)then warptorio.LaySquare("warp-tile-concrete",f,-1,z+zxm+6-1,zvy,zvx) warptorio.LaySquare("warp-tile-concrete",f,-9-1,z+2,7-1,7) warptorio.LaySquare("warp-tile-concrete",f,9,z+2,7-1,7)
			end
		if(gwarptorio.boiler_w)then warptorio.LaySquareEx("warp-tile-concrete",f,-z-zxm-6-1,-1,zvx,zvy-0.5) warptorio.LaySquare("warp-tile-concrete",f,-z-5,-9-1,7,7) warptorio.LaySquare("warp-tile-concrete",f,-z-5,9,7,7)
			end
		if(gwarptorio.boiler_e)then warptorio.LaySquareEx("warp-tile-concrete",f,z+zxm+6-1,-1,zvx,zvy+0.5) warptorio.LaySquare("warp-tile-concrete",f,z+2,-9-1,7,7) warptorio.LaySquare("warp-tile-concrete",f,z+2,9,7,7)
			end
	end
	
	warptorio.LayFloor("hazard-concrete-left",f,vx,4,vw,3) -- entrance
	warptorio.LayFloor("hazard-concrete-left",f,-2,-2,3,3) -- old center
	warptorio.playsound("warp_in",f.name)
end



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



-- --------
-- Entities / Cache
warptorio.CacheMonitor={["warptorio-heatpipe"]="heat",["warptorio-accumulator"]="power",["warptorio-reactor"]="heat"}

function warptorio.InsertCache(k,v) return table.insertExclusive(gwarptorio.cache[k],v) end
function warptorio.RemoveCache(k,v) table.RemoveByValue(gwarptorio.cache[k],v) end


function warptorio.OnPlayerRotatedEntity(ev)
	local e=ev.entity
	if(warptorio.IsWarpLoader(e))then
		local ot=(e.loader_type=="input" and "loaderOut" or "loaderIn") warptorio.RemoveCache(ot,e) warptorio.InsertCacheLoader(e) warptorio.TickFindLoaders()
	else
		for k,v in pairs(gwarptorio.Rails)do v:CheckLoaders() end
	end
end script.on_event(defines.events.on_player_rotated_entity, warptorio.OnPlayerRotatedEntity)


function warptorio.TickFindLoaders() gwarptorio.cache.loaderOutFilter={} local wlb=gwarptorio.cache.loaderOutFilter
	for k,v in pairs(gwarptorio.cache.loaderOut)do if(v.valid)then for i=1,5,1 do local lf=v.get_filter(i) if(lf)then wlb[lf]=wlb[lf] or {}
		for a,b in pairs(warptorio.GetTransportLines(v))do table.insert(wlb[lf],b) end
	end end end end
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
-------

function warptorio.TrySpawnWarploader(e)
	warptorio.InsertCacheLoader(e)
end

function warptorio.IsWarpLoader(e) return e.name=="warptorio-warploader" end



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

end




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



function warptorio.TryCleanEntity(v) if(v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio")then v.destroy{raise_destroy=true} end end
local lv=research.level("platform-size")




	m.OuterSize=9
	local z=m.OuterSize
	m:SetSize(m.OuterSize)




function warptorio.TickEnergy(e) local t={}
	for k,v in pairs(gwarptorio.Teleporters)do if(v:ValidA())then table.insert(t,v.a) end if(v:ValidB())then table.insert(t,v.b) end end
	for k,v in pairs(gwarptorio.cache.power)do table.insert(t,v) end
	warptorio.AutoBalancePower(t)
end

function warptorio.TickHeat(e) local t=gwarptorio.cache.heat local h=0 for k,v in pairs(t)do h=h+v.temperature end for k,v in pairs(t)do v.temperature=h/#t end end




function warptorio.OnEntSettingsPasted(ev) local p=ev.player_index local e=ev.source local d=ev.destination
	if(warptorio.IsWarpLoader(e))then warptorio.TickFindLoaders() end
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



function warptorio.TickAccelerator(e)
end

function warptorio.TickStabilizer(e)
end




function warptorio.OnEntityDied(ev) local e=ev.entity if(warptorio.IsTeleporterGate(e))then local t=gwarptorio.Teleporters["offworld"] t:DestroyLogisticsB() t.PointB=nil t:Warpin()
	else warptorio.OnPlayerMinedEntity(ev) end
	local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_entity_died",ev) end
end script.on_event(defines.events.on_entity_died,warptorio.OnEntityDied)

function warptorio.CheckWarpReactor()
	local v=gwarptorio.warp_reactor if(isvalid(v))then return end
end



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



	warptorio.TickChargeTimer(e)
	warptorio.TickTeleporters(e)
	warptorio.TickEnergy(e)
	warptorio.TickWarpLoaders()

	if(e%5==0)then
		warptorio.TickLogistics(e)
		if(e%30==0)then
			if(e%120==0)then -- every 2 seconds
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

