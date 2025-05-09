

--[[
harvestpad item on upgrade

	local lv=research.level("warptorio-harvester-"..self.name)
	local cls="warptorio-harvestpad-"..lv
	for k,v in pairs(game.players)do if(v and v.valid)then local iv=v.get_main_inventory() if(iv)then for i,x in pairs(iv.get_contents())do
		if(i:sub(1,20)=="warptorio-harvestpad" and i:sub(22,22+self.name:len())==self.name)then local lvx=tonumber(i:sub(-1,-1))
			if(lvx<lv)then iv.remove{name=i,count=x} iv.insert{name=cls,count=1} elseif(x>1)then iv.remove{name=i,count=(x-1)} end
		end
	end end end end

]]


--[[ Harvesters ]]--

warptorio.HarvesterSizes={12,20,26,32,38,46}
function warptorio.GetHarvesterLevelSize(lv) local z=warptorio.HarvesterSizes[lv] return vector(z,z) end
function warptorio.GetHarvesterLevelSizeNum(lv) local z=warptorio.HarvesterSizes[lv] return z end

local HARV={} HARV.__index=HARV warptorio.HarvesterMeta=HARV setmetatable(HARV,warptorio.TeleporterMeta)
function HARV.__init(self,tbl)
	self.key=tbl.key
	self.rank=1
	local t={}
	table.merge(t,table.deepcopy(warptorio.platform.harvesters[self.key]))
	table.merge(t,table.deepcopy(warptorio.platform.HarvesterPointData))
	self.gdata=t
	warptorio.TeleporterMeta.__init(self,self)
	self.position=tbl.position

	self.pipes=self.pipes or {{},{}}
	self.loaders=self.loaders or {{},{}}
	self.loaderFilter=self.loaderFilter or {{},{}}
	self.combos=self.combos or {nil,nil}
	if(not self.dir)then self.dir={{},{}} for i=1,6,1 do self.dir[1][i]="input" self.dir[2][i]="output" end end

	self.deployed=self.deployed or false
	self.deploy_position=self.deploy_position or nil
	self.gdata.pair[2].position=self.gdata.pair[2].position or self.deploy_position or self.position
	self.gdata.pair[1].position=self.gdata.pair[1].position or self.position
	self.chests=nil

	global.Harvesters[tbl.key]=self
end
function HARV:Data() return self.gdata end

function HARV:GetSize(brank)
	local tps=self:Data()
	if(tps.fixed_level)then return warptorio.GetHarvesterLevelSizeNum(tps.fixed_level) end
	local tcn=tps.tech
	local lv=(brank and self.rank or warptorio.GetPlatformTechLevel(tcn))
	return warptorio.GetHarvesterLevelSize(lv)
end
function HARV:GetBaseArea(z,rank) z=z or self:GetSize(rank)-1 return vector.square(self.position,vector(z,z)) end
function HARV:GetDeployArea(z,rank) z=z or self:GetSize(rank)-2 return vector.square(vector.pos(self.deploy_position),vector(z,z)) end


function HARV:CheckTeleporterPairs(bSound) -- Call updates and stuff. Automatically deals with logistics, upgrades and cleaning as-needed with good accuracy
	local tps=self:Data()
	local wps=warptorio.platform.HarvesterPointData
	self:MakePointTeleporter(wps,1,wps.pair[1],self.position)
	if(self.deployed)then
		self:MakePointTeleporter(wps,2,wps.pair[2],self.deploy_position)
	end
	self:CheckPointLogistics(1)
	self:CheckPointLogistics(2)
end

function HARV:UpgradePlayerInventories()
	for k,v in pairs(game.players)do if(v and v.valid)then local iv=v.get_main_inventory() if(iv)then for i,x in pairs(iv.get_contents())do
		if(i:sub(1,20)=="warptorio-harvestpad" and i:sub(22,22+self.key:len())==self.key)then local lvx=tonumber(i:sub(-1,-1))
			if(lvx<lv)then iv.remove{name=i,count=x} iv.insert{name=cls,count=1} elseif(x>1)then iv.remove{name=i,count=(x-1)} end
		end
	end end end end
end


function HARV:MakePointTeleporter(tps,i,t,pos)
	local p=self.points[i]
	local f=global.floor[t.floor].host

	local epos
	if(t.prototype)then
		local vproto=t.prototype
		if(tps.energy)then vproto=vproto.."-"..(warptorio.GetPlatformTechLevel(tps.energy)) end
		local e=p.ent
		if(isvalid(e))then
			if(e.surface~=f)then self:DestroyPointTeleporter(i) self:DestroyPointLogistics(i)
			elseif(e.name~=vproto)then epos=e.position self:DestroyPointTeleporter(i)
			end
		end
		if(not isvalid(e))then
			local vepos=epos or (pos or t.position)
			if(not vepos)then return end
			local vpos=((t.gate and not epos) and f.find_non_colliding_position(vproto,vepos,0,1,1) or vepos)
			local varea
			if(not t.gate)then varea=vector.square(vpos,vector(2,2)) vector.clean(f,varea) end
			e=entity.protect(entity.create(f,vproto,vpos),t.minable~=nil and t.minable or false,t.destructible~=nil and t.destructible or false)
			if(not t.gate)then vector.cleanplayers(f,varea) end
			p.ent=e
		end
		if(p.energy)then e.energy=e.energy+p.energy p.energy=nil end
		if(t.sprites)then self:MakePointSprites(tps,i,t.sprites) end
		if(t.sprite_arrow)then self:MakePointArrow(tps,i,t.sprite_arrow) end
	end
	if(epos or not t.gate)then self:CheckPointLogistics(i) end

	cache.force_entity(p.ent,"Harvesters",self.key,"points",i)

end

function HARV:RunUpgrade()
	local tps=self:Data()
	local vz=self:GetSize()
	local lv=warptorio.GetPlatformTechLevel(tps.tech)

	local f=global.floor[tps.pair[1].floor].host

	local pos=tps.position
	if(not self.deployed)then
		local bh=warptorio.platform.floors.harvester.BuildHarvester -- bridges first
		if(bh[self.key])then bh[self.key](f) end

		local lvm=math.max(lv*2,2) -- Makes buffer area around the harvesters
		vector.LayTiles("warp-tile-concrete",f,vector.square(tps.position,vector(vz+lvm,vz+lvm)))
		vector.LayTiles("warptorio-red-concrete",f,vector.square(tps.position,vector(vz-2,vz-2)))

		self:CheckTeleporterPairs(true)
	end
	if(research.has("warptorio-logistics-1"))then
		self:DestroyPointLogistics(1)
		self:CheckPointLogistics(1)
		if(not self.deployed)then self:DestroyPointLogistics(2) self:CheckPointLogistics(2) end
	end
	self:DestroyCombos()
	self:CheckCombo()

	self:UpgradePlayerInventories() -- upgrade their harvestpads for this harvester (if needed)

	self.rank=lv
end


function HARV:Upgrade() self.ReadyUpgrade=true if(not self.deployed)then self:DoUpgrade() end end
function HARV:DoUpgrade() if(self.ReadyUpgrade)then self.ReadyUpgrade=false self:RunUpgrade() end end


--[[ Harvester Combinator ]]--


function HARV:ConnectCombo() if(not self.deployed and self:ValidCombos())then
	self.combos[1].connect_neighbour({target_entity=self.combos[2],wire=defines.wire_type.red}) self.combos[1].connect_neighbour({target_entity=self.combos[2],wire=defines.wire_type.green})
end end
function HARV:ValidCombos() return isvalid(self.combos[1]) and isvalid(self.combos[2]) end
function HARV:CheckCombo() if(research.has("warptorio-alt-combinator"))then self:MakeComboA() self:MakeComboB() self:ConnectCombo() end end
function HARV:DestroyComboA() if(isvalid(self.combos[1]))then entity.destroy(self.combos[1]) end self.combos[1]=nil end
function HARV:DestroyComboB() if(isvalid(self.combos[2]))then entity.destroy(self.combos[2]) end self.combos[2]=nil end
function HARV:DestroyCombos() self:DestroyComboA() self:DestroyComboB() end

function HARV:MakeComboA() local vx=self.points[1].ent
	local cfg=settings.global.warptorio_combinator_offset.value local ofv if(cfg)then ofv=(self.key=="east" and 1 or 1.5) else ofv=0 end
	local vpos=vector.pos(vx.position)+vector(self:GetSize().x/2*(self.key=="east" and 1 or -1)+ofv,0)
	vector.clean(vx.surface,vector.square(vpos,vector(0.5,0.5)))
	local e=entity.protect(entity.create(vx.surface,"warptorio-alt-combinator",vpos),false,false)
	self.combos[1]=e

	cache.force_entity(e,"Harvesters",self.key,"combos",1)
end
function HARV:MakeComboB() local vx=(isvalid(self.points[2].ent) and self.points[2].ent or self.points[1].ent)
	local cfg=settings.global.warptorio_combinator_offset.value local ofv if(cfg)then ofv=(self.key=="east" and -2 or -1) else ofv=(self.key=="east" and -1 or 1) end
	local vpos=vector.pos(vx.position)+vector(self:GetSize().x/2*(self.key=="east" and 1 or -1)+ofv,0)
	vector.clean(vx.surface,vector.square(vpos,vector(0.5,0.5)))
	local e=entity.protect(entity.create(vx.surface,"warptorio-alt-combinator",vpos),false,false)
	self.combos[2]=e

	cache.force_entity(e,"Harvesters",self.key,"combos",2)
end

--[[ Harvester Logistics ]]--

function HARV:MakePointPipes(tps,i,id,pos,f,lddir,belty,vexdir)
	local pipe="warptorio-logistics-pipe"
	local v=self.pipes[i][id]
	local vpos=vector(pos)+vector(vexdir)+vector(belty)
	if(isvalid(v) and (v.surface~=f or v.position.x~=vpos.x or v.position.y~=vpos.y))then entity.destroy(v) end
	if(not isvalid(v))then
		local varea=vector.square(vpos,vector(0.5,0.5))
		vector.clean(f,varea)
		v=entity.protect(entity.create(f,pipe,vpos,lddir),false,false)
		self.pipes[i][id]=v
	end

	cache.force_entity(v,"Harvesters",self.key,"pipes",i,id)
end

function HARV:MakePointLoader(tps,i,id,pos,f,belt,lddir,belty,beltsquare,vexdir)
	local v=self.loaders[i][id]
	if(isvalid(v) and v.name~=belt)then v.destroy{raise_destroy=true} end
	if(not isvalid(v))then
		local vpos=vector(pos)+vector(vexdir)+vector(belty)
		local varea=vector.square(vpos,beltsquare)
		vector.clean(f,varea)
		v=entity.protect(entity.create(f,belt,vpos,lddir),false,false)
		v.loader_type=self.dir[i][id]
		self.loaders[i][id]=v
		local inv=self.loaderFilter[i][id] if(inv)then for invx,invy in pairs(inv)do v.set_filter(invx,invy) end end
	end
	cache.force_entity(v,"Harvesters",self.key,"loaders",i,id)

end

function HARV:CheckPointLogistics(i)
	local tps=self:Data()
	local t=tps.pair[i]
	if(self.maxloader==0 or not tps.logs_pattern)then return end
	local belt=warptorio.GetBelt()
	local pos=tps.position
	local f=global.floor.harvester.host
	if(i==2 and self.deployed)then f=global.floor.main.host pos=self.deploy_position end

	local ldl=0
	local lvLogs=research.level("warptorio-logistics")
	if(tps.logs and lvLogs>0)then ldl=ldl+1 end
	if(tps.dualloader and research.has("warptorio-dualloader-1"))then ldl=ldl+1 end
	if(tps.triloader and research.has("warptorio-triloader"))then ldl=ldl+1 end
	if(ldl<=0)then return end

	local lddir=(i==2 and string.compassdef[tps.logs_pattern] or string.compassdef[string.compassopp[tps.logs_pattern]])
	local ldodir=(i==1 and string.compassdef[tps.logs_pattern] or string.compassdef[string.compassopp[tps.logs_pattern]])
	local vcomp=vector.compass[tps.logs_pattern]
	--game.print(tps.logs_pattern .. " , lddir: " .. lddir)
	local vdir=vcomp*(self:GetSize()/2) + vcomp*(i==2 and -1 or 1)

	local beltsquare=vector(1,0.5)
	local pipe=vector(0,(id==1 and 2 or -2) )
	if(tps.logs_pattern=="north" or tps.logs_pattern=="south")then beltsquare=vector(0.5,1) end
	for id=1,ldl do
		local belty=vector( 0,(id%2==0 and 1 or 0)+(id%3==0 and -1 or 0) )
		self:MakePointLoader(tps,i,id,pos,f,belt,lddir,belty,beltsquare,vdir-vcomp*0.5)
	end

	if(tps.dopipes and lvLogs>0)then
		for id=1,math.min(lvLogs,2),1 do
			local belty=vector( 0,(id==1 and 2 or -2) ) + (i==1 and vcomp*-1 or 0)
			self:MakePointPipes(tps,i,id,pos,f,ldodir,belty,vdir)
		end
	end
end



--[[ DEPLOY/RECALL ]]--
--cleanlanding()


function HARV:Recall(bply) -- recall after portal is mined
	if(self.recalling)then return end self.recalling=true
	local tps=self:Data()
	if(not self.deployed)then self:DestroyPointTeleporter(1,false) self:CheckTeleporterPairs()
		self:DoUpgrade()
		self:CheckCombo()
		self:ConnectCombo()
		self.recalling=false
		return true
	end
	local t=tps.pair[i]
	--self:CleanLanding() -- clean for loaders and combinators -- done automatically now
	--if(isvalid(self.points[2].ent))then self.points[2].ent.destroy() end
	--self.points[2].ent=nil



	local f=global.floor.main.host
	local ebs={}
	for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=self:GetDeployArea(nil,true)})do
		if(v.type~="resource" and v~=self.points[1].ent)then table.insert(ebs,v) end
		--v~=self.b and v~=self.a and (v.name=="warptorio-combinator" or v.name:sub(1,9)~="warptorio") )then table.insert(ebs,v) end
	end

	local hf=global.floor.harvester.host
	local harvArea=self:GetBaseArea(nil,true)


	local tbs={}
	local tcs={} for k,v in pairs(hf.find_tiles_filtered{area=harvArea})do
		local vpos=vector.add(vector.sub(v.position,self.position),self.deploy_position)
		table.insert(tcs,{name=v.name,position=vpos})
		table.insert(tbs,{name="warptorio-red-concrete",position=v.position})
	end
	local dcs={} for k,v in pairs(hf.find_decoratives_filtered{area=self:GetBaseArea(nil,true)})do
		local vpos=vector.add(vector.sub(v.position,self.position),self.deploy_position)
		table.insert(dcs,{name=v.decorative.name,position=vpos,amount=v.amount})
	end


	local ecs={} for k,v in pairs(hf.find_entities_filtered{area=harvArea,type="character",invert=true})do
		if(v and v.valid and v~=self.points[1].ent and v~=self.points[2].ent and not entity.shouldClean(v) and not cache.get_entity(v) and v.type~="resource")then table.insert(ecs,v) end
	end



	local blacktbl={}
	for k,v in pairs(ebs)do if(table.HasValue(warptorio.GetWarpBlacklist(),v.name))then table.insert(blacktbl,v) ebs[k]=nil end end
	for k,v in pairs(ebs)do if(table.HasValue(warptorio.GetModTable("harvester_blacklist"),v.name))then table.insert(blacktbl,v) ebs[k]=nil end end

	for k,v in pairs(ecs)do if(table.HasValue(warptorio.GetWarpBlacklist(),v.name))then table.insert(blacktbl,v) ecs[k]=nil end end
	for k,v in pairs(ecs)do if(table.HasValue(warptorio.GetModTable("harvester_blacklist"),v.name))then table.insert(blacktbl,v) ecs[k]=nil end end


	warptorio.Cloned_Entities={} warptorio.IsCloning=true
	hf.clone_entities{entities=ecs,destination_surface=f,destination_offset=vector.add(vector.mul(self.position,-1),self.deploy_position),snap_to_grid=false}
	local hfe=warptorio.Cloned_Entities warptorio.IsCloning=false warptorio.Cloned_Entities=nil


	if(#ebs>0)then for i=#ebs,1,-1 do if(not ebs[i] or not ebs[i].valid)then table.remove(ebs,i) end end end -- bad ents in table ?

	warptorio.Cloned_Entities={} warptorio.IsCloning=true
	f.clone_entities{entities=ebs,destination_surface=hf,destination_offset=vector.add(vector.mul(self.deploy_position,-1),self.position),snap_to_grid=false}
	local fe=warptorio.Cloned_Entities warptorio.IsCloning=false warptorio.Cloned_Entities=nil

	local hfm={} for k,v in pairs(hfe)do if(isvalid(v.source) and isvalid(v.destination) and table.HasValue(ecs,v.source))then table.insert(hfm,v.source) end end
	local fm={} for k,v in pairs(fe)do if(isvalid(v.source) and isvalid(v.destination) and table.HasValue(ebs,v.source))then table.insert(fm,v.source) end end

	for k,v in pairs(fm)do entity.destroy(v) end
	for k,v in pairs(hfm)do entity.destroy(v) end

	f.set_tiles(tcs,true)
	f.create_decoratives{decoratives=dcs}

	hf.destroy_decoratives{area=harvArea}

	if(bply)then -- players now
		local tpply={}
		for k,v in pairs(game.players)do if(v.character==nil or (v.surface==f and vector.inarea(v.position,self:GetDeployArea(nil,true))) )then
			table.insert(tpply,{v,vector.add(vector.add(vector.mul(self.deploy_position,-1),vector.pos(v.position)),self.position)})
		end end
		for k,v in pairs(tpply)do v[1].teleport(f.find_non_colliding_position("character",{v[2][1],v[2][2]},0,1),hf) end
	end

	--vector.LayTiles("warp-tile-concrete",hf,self:GetBaseArea(self:GetSize()+2))
	--vector.LayTiles("warptorio-red-concrete",hf,self:GetBaseArea())
	hf.set_tiles(tbs,true)
	self.deployed=false
	self:DestroyComboB()
	self:DestroyPointTeleporter(1,false) self:DestroyPointTeleporter(2,false)
	self:CheckTeleporterPairs()

	self:DoUpgrade()
	self:CheckCombo()
	self:ConnectCombo()
	self.recalling=false

end



function HARV:Deploy(surf,pos) -- deploy over a harvester platform
	if(self.deployed)then return false end
	local f=surf if(f~=warptorio.GetMainSurface())then game.print("Harvesters can only be placed on the planet") return false end
	--game.print("deployed at: " .. serpent.line(pos))
	self.deploy_position=vector.pos(pos)
	local hf=global.floor.harvester.host

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
	local ecs={} for k,v in pairs(f.find_entities_filtered{area=planetArea,type={"construction-robot","logistic-robot","character"},invert=true})do if(v.type~="resource" and v.name:sub(1,9)~=("warptorio"))then table.insert(ecs,v) end end

	hf.set_tiles(tcs,true)
	hf.create_decoratives{decoratives=dcs}

	local ebsc=#ebs
	local ecsc=#ecs


	local blacktbl={}
	--for k,v in pairs(ebs)do if(isvalid(v))then if(table.HasValue(warptorio.GetWarpBlacklist(),v.name))then table.insert(blacktbl,v) ebs[k]=nil end end end
	--for k,v in pairs(ebs)do if(isvalid(v))then if(table.HasValue(warptorio.GetModTable("harvester_blacklist"),v.name))then table.insert(blacktbl,v) ebs[k]=nil end end end

	--for k,v in pairs(ecs)do if(isvalid(v))then if(table.HasValue(warptorio.GetWarpBlacklist(),v.name))then table.insert(blacktbl,v) ecs[k]=nil end end end
	--for k,v in pairs(ecs)do if(isvalid(v))then if(table.HasValue(warptorio.GetModTable("harvester_blacklist"),v.name))then table.insert(blacktbl,v) ecs[k]=nil end end end


	if(ecsc>0)then for i=ecsc,1,-1 do if(not ecs[i] or not ecs[i].valid)then table.remove(ecs,i) end end end -- bad ents in table ?

	warptorio.Cloned_Entities={} warptorio.IsCloning=true
	f.clone_entities{entities=ecs,destination_surface=hf,destination_offset=vector.mul(vector.sub(self.deploy_position,self.position),-1),snap_to_grid=false}
	local fe=warptorio.Cloned_Entities warptorio.IsCloning=false warptorio.Cloned_Entities=nil


	if(ebsc>0)then for i=ebsc,1,-1 do if(not ebs[i] or not ebs[i].valid)then table.remove(ebs,i) end end end -- bad ents in table ?

	vector.LayTiles("warptorio-red-concrete",f,self:GetDeployArea())

	-- this doesnt really work

	warptorio.Cloned_Entities={} warptorio.IsCloning=true
	hf.clone_entities{entities=ebs,destination_surface=f,destination_offset=vector.mul(vector.sub(self.position,self.deploy_position),-1),snap_to_grid=false}
	local hfe=warptorio.Cloned_Entities warptorio.IsCloning=false warptorio.Cloned_Entities=nil

	local hfm={} for k,v in pairs(hfe)do if(isvalid(v.source) and isvalid(v.destination) and table.HasValue(ebs,v.source))then table.insert(hfm,v.source) end end
	local fm={} for k,v in pairs(fe)do if(isvalid(v.source) and isvalid(v.destination) and table.HasValue(ecs,v.source))then table.insert(fm,v.source) end end

	for k,v in pairs(fm)do if(isvalid(v) and v~=self.points[1].ent and v~=self.points[2].ent)then entity.destroy(v) end end
	for k,v in pairs(hfm)do if(isvalid(v) and v~=self.points[1].ent and v~=self.points[2].ent)then entity.destroy(v) end end

	for k,v in pairs(blacktbl)do if(v and v.valid)then v.destroy{raise_destroy=true} end end -- cleanup past entities

	vector.clearplayers(f,planetArea)

	self.deployed=true
	-- game.print("deployed")
	self:CheckTeleporterPairs()
end


