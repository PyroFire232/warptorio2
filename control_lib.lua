function warptorio.TickLogistics(e)
	for k,v in pairs(gwarptorio.Teleporters)do v:BalanceLogistics() end
	for k,v in pairs(gwarptorio.Rails)do v:BalanceLogistics() end
end




script.on_event(defines.events.on_entity_settings_pasted,warptorio.OnEntSettingsPasted)
script.on_event(defines.events.on_gui_selection_state_changed,function(ev)  end)
script.on_event(defines.events.on_gui_click,function(ev) end)
script.on_event(defines.events.on_entity_cloned, warptorio.OnEntityCloned)
--script.on_event(defines.events.on_player_rotated_entity,warptorio.OnRotatedEntity)

script.on_event(defines.events.on_chunk_deleted,warptorio.OnChunkDeleted)

script.on_event(defines.events.on_tick,warptorio.Tick)

 script.on_event(defines.events.on_chunk_generated,warptorio.OnChunkGenerated)

function warptorio.Tick(ev) local e=ev.tick
	local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_tick",ev) end
end

function warptorio.on_entity_died.planet(ev) local p=gwarptorio.planet if(p)then warptorio.CallPlanetEvent(p,"on_entity_died",ev) end end

warptorio.cache["warptorio-warploader"]={
	create=function(e) warptorio.InsertCacheLoader(e) end,
	destroy=function(e) warptorio.RemoveCacheLoader(e) end,
	rotate=function(e) warptorio.RemoveCacheLoader(e,true) warptorio.InsertCacheLoader(e) end,
	cloned=function(e) warptorio.InsertCacheLoader(e) end,
	gui_closed=function(e) warptorio.RemoveCacheLoader(e) warptorio.InsertCacheLoader(e) end,
	pre_settings_pasted=function(e) warptorio.RemoveCacheLoader(e) end,
	settings_pasted=function(e) warptorio.InsertCacheLoader(e) end,
}


function warptorio.RemoveCacheLoader(v,o) local ldt=v.loader_type if(o)then ldt=(ldt=="input" and "output" or "input") end warptorio.RemoveCache("ld"..ldt,v) if(ldt=="output")then warptorio.RemoveCacheFilter(e) end end
function warptorio.InsertCacheLoader(v) warptorio.InsertCache("ld".. v.loader_type,v) if(v.loader_type=="output")then warptorio.InsertCacheFilter(v) end end
function warptorio.RemoveCacheFilter(v) local ct=gwarptorio.cache["ldoutputf"]
	for cidx,tbl in pairs(ct)do
		local rd=false
		for id,e in pairs(tbl)do if(e.owner==v)then table.insert(rdxt,e) end end
		for k,v in pairs(rdxt)do table.RemoveByValue(tbl,v) end
		if(table_size(tbl)==0)then tbl[cidx]=nil end
	end
end
function warptorio.InsertCacheFilter(v) local ct=gwarptorio.cache["ldoutputf"]
	for i=1,5,1 do local f=v.get_filter(i)
		if(f)then ct[f]=ct[f] or {}
			table.insertExclusive(ct[f],v.get_transport_line(1))
			table.insertExclusive(ct[f],v.get_transport_line(2))
		end
	end
end


function warptorio.on_tick.warp_loaders(ev)
	local cin=gwarptorio.cache.ldinput
	local inpool={}
	for k,v in pairs(cin)do for i,line in ipairs{v.get_transport_line(1),v.get_transport_line(2)} do local inv=line.get_contents() for n,m in pairs(inv)do
		inpool[n]=inpool[n] or {} table.insert(inpool[n],line)
	end end end

	local outpool={}
	local cout=gwarptorio.cache.ldoutputf
	for i=1,table_size(cout),1 do
		local flt,tbl=next(cout,cnext)
		local fnext=gwarptorio.nextOutputFilter if(not tbl[fnext])then fnext=nil end
		if(inpool[flt])then

	for filt,tbl in pairs(cout)do
		
	for pri,tbl in pairs(cout)do
		for flt,lines in pairs(tbl)do
			if(inpool[flt])then
				local nout=gwarptorio.nextOutputFilter[pri][flt] if(not lines[nout])then nout=nil end
				local lk,lv=next(lines,nout) nout=lk
				if(lv.can_insert_at_back())then
					
				end
			end
		end
	end

	local noutID=gwarptorio.nextOutputFilter if(not cout[nout])then nout=nil end

	local fk,fv=next(cout,nout)
	local t={}


-- loop filters
	local fk,fv=next(cout,nout)
	local nid=gwarptorio.nextOutputFilterID[fk] if(not fv[math.floor(nid/2)])then nid=nil end
-- loop ents for filters, stopping to wait when no items to keep perfect balance
	local ek,ev=next(fv,math.floor(nid/2))

	
	for fi=1,5,1 do local ft=fv[fi] if(ft)then

	for k,v in pairs(gwarptorio.cache.ldoutput)do
		for i=1,5,1 do
			local ldf=v.get_filter(i)
			if(gwarptorio.ldinputf[ldf])then
				local fk,fv=next(cin[ldf],gwarptorio.nextCacheInput) gwarptorio.nextCacheInput=fk
			end
		end
	end

	for i=(gwarptorio.lastCacheOutput%2)+1

	local fk,fv=next(cout,gwarptorio.nextCacheOutput) gwarptorio.nextCacheOutput=fk
	

	for i=1,table_size(cout)*2,2 do
		local fk,fv=next(cout,gwarptorio.nextCacheOutput) gwarptorio.nextCacheOutput=fk
		if(cin[ldinput[fk]])then
			for a=1,table_size(cin[ldinput[fk]])*2,2 do
				local tk,tv=next(cin,gwarptorio.nextCacheInput) gwarptorio.nextCacheInput=tk
				

		for a=1,table_size(ldinputf)do

	for k,v in pairs(cin)do
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
