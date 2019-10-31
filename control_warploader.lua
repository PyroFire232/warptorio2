
warptorio.cache["warptorio-warploader"]={
	create=function(e) warptorio.InsertCacheLoader(e) end,
	destroy=function(e) warptorio.RemoveCacheLoader(e) end,
	rotate=function(e) warptorio.RemoveCacheLoader(e,true) warptorio.InsertCacheLoader(e) end,
	cloned=function(e) warptorio.InsertCacheLoader(e) end,
	gui_closed=function(e) warptorio.RemoveCacheLoader(e) warptorio.InsertCacheLoader(e) end,
	pre_settings_pasted=function(e) warptorio.RemoveCacheLoader(e) end,
	settings_pasted=function(e) warptorio.InsertCacheLoader(e) end,
}


function warptorio.RemoveCacheLoader(v,o) local ldt=v.loader_type if(o)then ldt=(ldt=="input" and "output" or "input") end warptorio.RemoveCache("ld"..ldt,v)
	if(ldt=="output")then warptorio.RemoveCacheFilter(e) else warptorio.RemoveCacheInput(e) end
end
function warptorio.InsertCacheLoader(v) warptorio.InsertCache("ld".. v.loader_type,v) if(v.loader_type=="output")then warptorio.InsertCacheFilter(v) else warptorio.InsertCacheInput(e) end end
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

function warptorio.RemoveCacheInput(v) local ct=gwarptorio.cache["ldinputf"] for i=1,2,1 do local x=v.get_transport_line(i) if(x.owner==v)then table.RemoveByValue(ct,x) end end end
function warptorio.InsertCacheInput(v) local ct=gwarptorio.cache["ldinputf"] for i=1,2,1 do table.insertExclusive(ct[f],v.get_transport_line(i)) end end


function warptorio.DistributeLoaderLine(inv) for item_name,item_count in pairs(inv)do
    	if(warptorio.OutputWarpLoader(item_name,item_count))then inv.remove{item_name,count=1} return true end
end end

function warptorio.OutputWarpLoader(item_name,item_count) local cOut=gwarptorio.cache.ldoutputf[item_name] if(not cOut)then return end
	local key=warptorio.nextLoader[item_name] local key,cv=next(cOut,key) gwarptorio.nextLoader[item_name]=key
	for i=1,table_size(cOut[item_name]) do
		if(warptorio.InsertWarpLane(cv,item_name))then return true else key,cv=next(cOut,key) gwarptorio.nextLoader[item_name]=key end
	end
	return false
end
function warptorio.InsertWarpLane(cv,item_name)
	if(cv.can_insert_at_back())then cv.insert_at_back({name=item_name,count=1}) return true end
	return false
end

function warptorio.on_tick.warp_loaders(ev)
	local cIn=gwarptorio.cache.ldinputf
	local cOut=gwarptorio.cache.ldoutputf
	local k,line=next(cIn,gwarptorio.nextLoaderIn) if(not k or not line)then k,line=next(cIn) gwarptorio.nextLoaderIn=k end
	for i=1,table_size(cIn) do
		k,line=next(cIn,gwarptorio.nextLoaderIn) gwarptorio.nextLoaderIn=k warptorio.DistributeLoaderLine(line.get_contents())
	end
end






