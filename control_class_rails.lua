
local TRAIL={} TRAIL.__index=TRAIL warptorio.RailMeta=TRAIL
function TRAIL.__init(self,tbl)
	self.key=self.key or tbl.key
	self.chests={{}}
	self.rails={}
	self.loaders={{},{},{},{}}
	self.chestcontents={}
	self.dir="output"
	global.Rails[self.key]=self
end

function TRAIL:Data() return warptorio.platform.rails[self.key] end

function TRAIL:MakeRails()
	local f=warptorio.GetMainSurface()
	local tps=self:Data()
	if(not isvalid(self.rails[1]) or not isvalid(self.rails[2]))then vector.clean(f,vector.square(tps.railpos,vector(1,1))) end
	if(not isvalid(self.rails[1]))then self.rails[1]=entity.protect(entity.spawn(f,"straight-rail",tps.railpos,defines.direction.south),false,false) end
	if(not isvalid(self.rails[2]))then self.rails[2]=entity.protect(entity.spawn(f,"straight-rail",tps.railpos,defines.direction.east),false,false) end
end

function TRAIL:MakeChests()
	local ccls=warptorio.GetChest(self.dir)
	local tps=self:Data()
	local f=global.floor[tps.floor].host
	for i,px in pairs(vector.compasscorn)do
		local v=self.chests[1][i]
		if(isvalid(v) and v.name~=ccls)then self.chestcontents[i]=v.get_inventory(defines.inventory.chest).get_contents() v.destroy{raise_destroy=true} end
		if(not isvalid(v))then
			local vpos=tps.chestpos+px*0.5
			local varea=vector.square(vpos,vector(0.5,0.5))
			vector.clean(f,varea)
			v=entity.protect(entity.create(f,ccls,vpos),false,false)
			self.chests[1][i]=v
			local inv=self.chestcontents[i]
			if(inv)then local cv=v.get_inventory(defines.inventory.chest) for x,y in pairs(inv)do cv.insert{name=x,count=y} end self.chestcontents[i]=nil end
		end
		cache.get_raise_type("types",v.type,v,"Rails",self.key,"chests",1,i)
	end
end

function TRAIL:Rotate() self:MakeChests() for i,tbl in pairs(self.loaders)do for k,v in pairs(tbl)do v.loader_type=self.dir end end end


function TRAIL:MakeLoaders()
	local tps=self:Data()
	local f=global.floor[tps.floor].host
	local bcls=warptorio.GetBelt(self.dir)
	for i,b in pairs(tps.logs)do if(b)then
		local cd=vector.compass[string.compass[i]]*2

		for x=1,2,1 do
		local v=self.loaders[i][x]
		if(isvalid(v) and v.name~=bcls)then entity.destroy(v) end
		if(not isvalid(v))then
			local vang=(((i-1)*2)+4)%8
			local vpos=tps.chestpos+cd+vector.compassall[string.compassall[((vang+2)%8)+1]]*(x==1 and 0.5 or -0.5)
			local varea=vector.square(vpos,vector((i==1 or i==3) and 0.5 or 1,(i==1 or i==3) and 1 or 0.5))
			vector.clean(f,varea)
			v=entity.protect(entity.create(f,bcls,vpos,vang),false,false)
			v.loader_type=self.dir
			self.loaders[i][x]=v
		end
		cache.force_entity(v,"Rails",self.key,"loaders",i,x)
		end
	end end
end


function TRAIL:DoMakes() self:MakeRails() self:MakeChests() self:MakeLoaders() end

-- Warp Rail Logistics


function TRAIL:SplitItem(u,n) local c=n local cx=0 local cinv={} local ui={name=k,count=n}
	for k,v in pairs(self.chests[1])do local iv=v.get_inventory(defines.inventory.chest) if(iv.can_insert(u))then cinv[k]=iv end end local tcn=table_size(cinv)
	for k,v in pairs(cinv)do if(c>0)then local w=v.insert{name=u,count=math.ceil(c/tcn)} cx=cx+w c=c-w tcn=tcn-1 end end
	return cx
end

function TRAIL:UnloadLogistics(e) for _,r in pairs(e)do
	local inv=r.get_inventory(defines.inventory.cargo_wagon) for k,v in pairs(inv.get_contents())do local ct=self:SplitItem(k,v) if(ct>0)then inv.remove({name=k,count=ct}) end end
end end

function TRAIL:LoadLogistics(e)
	local inv={} for k,v in pairs(self.chests[1])do inv[k]=v.get_inventory(defines.inventory.chest) end
	local ct={} for k,v in pairs(inv)do for a,b in pairs(v.get_contents())do ct[a]=(ct[a] or 0)+b end v.clear() end
	for _,r in pairs(e)do local tr=r.get_inventory(defines.inventory.cargo_wagon) for k,v in pairs(ct)do ct[k]=v-(tr.insert{name=k,count=v}) end end
	local ci for a,b in pairs(ct)do local g=b ci=#inv
		for k,v in pairs(inv)do if(ci>0)then local gci=math.ceil(g/ci) if(gci>0)then local w=v.insert{name=a,count=math.ceil(g/ci)} ci=ci-1 g=g-w end end end
	end
end
function TRAIL:BalanceChests() local inv={} for k,v in pairs(self.chests[1])do if(isvalid(v))then inv[k]=v.get_inventory(defines.inventory.chest) end end if(table_size(inv)>0)then
	local ct={} for k,v in pairs(inv)do for a,b in pairs(v.get_contents())do ct[a]=(ct[a] or 0)+b end v.clear() end
	local ci for a,b in pairs(ct)do local g=b ci=table_size(inv) for k,v in pairs(inv)do
		local gci=math.ceil(g/ci) if(gci>0)then local w=v.insert{name=a,count=math.ceil(g/ci)} ci=ci-1 g=g-w end
	end end
end end

function TRAIL:TickLogistics() local f=global.floor.main.host if(not f.valid)then return end local c=self:Data().railpos
	local e=f.find_entities_filtered{name="cargo-wagon",area={{c.x-1,c.y-1},{c.x+1,c.y+1}} }
	if(table_size(e)>0)then if(self.dir=="output")then self:UnloadLogistics(e) self:BalanceChests() else self:LoadLogistics(e) end else self:BalanceChests() end
end


events.on_tick(3,0,"TickRails",function(ev) for k,v in pairs(global.Rails)do v:TickLogistics() end end)
--[[ old stuff


-- Warp Rail Constructor

function warptorio.BuildRailCorner(cn) local r=gwarptorio.Rails[cn] --if(true) then return end
	if(not r)then r=trail(cn)
		local f,fp=warptorio.GetFactorySurface(),warptorio.GetMainSurface() local c,co,cl=platform.railCorner[cn],platform.railOffset[cn],platform.railLoader[cn]
		local vec,cx=vector(2,2),c+co
		local sq=vector.square(cx,vec)
		vector.clear(fp,sq) vector.clear(f,sq) cx=c+vector(-1,-1) vector.clear(f,vector.square(cx,vec)) vector.clear(f,vector.square(cx+cl[1],vec)) vector.clear(f,vector.square(cx+cl[2],vec))
	end
	r:DoMakes()
end

function warptorio.BuildRails() warptorio.BuildRailCorner("nw") warptorio.BuildRailCorner("sw") warptorio.BuildRailCorner("ne") warptorio.BuildRailCorner("se") end --for k,v in pairs(warptorio.railCorn)do warptorio.BuildRailCorner(k) end end



]]


