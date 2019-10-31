-- This file isn't used at all lol, just old code / archiving

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








---- old loader code

function warptorio.on_tick.warp_loaders(ev)
	local cIn=gwarptorio.cache.ldinputf
	local cOut=gwarptorio.cache.ldoutputf

	for k,line in pairs(cIn)do local inv=line.get_contents() warptorio.DistributeLoaderLine(inv)
		for item_name,item_count in pairs(inv)do
			if(v and warptorio.OutputWarpLoader(v))then inv.remove{name=item_name

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



	local fk,fv=next(cout,nout)
	local noutID=gwarptorio.nextOutputFilter if(not cout[nout])then nout=nil end
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
