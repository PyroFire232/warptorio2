--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_data_resize.lua
Purpose: proto code for resizing stuff

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

-- Todo: resize equipments to 1x1 https://mods.factorio.com/mod/Super_Pinky_Man_SmallPortableEquipment

local proto={}




proto.no_resize_types={"item","item-on-ground","item-entity","item-request-proxy","tile","resource","recipe",
"rail","locomotive","cargo-wagon","fluid-wagon","artillery-wagon","rail-chain-signal","rail-signal",
--"pipe","pipe-to-ground","infinity-pipe",
"underground-belt","transport-belt","splitter",
--"construction-robot","logistic-robot","combat-robot","electric-pole","rocket-silo","rocket-silo-rocket",
--"offshore-pump",
}

function proto.ShouldResize(pr) if(table.HasValue(proto.no_resize_types,pr.type))then return false end return true end


--[[ Basic pictures and layers and offsets resizing and rescaling ]]--

proto.scale_keys={"alert_icon_scale"} -- Stuff that is a single number. todo.


proto.offset_keys={
 -- Table keys that are offsets
"north_position","south_position","east_position","west_position","red","green","alert_icon_shift",
-- Spider keys
--[[
"light_positions",
]]
"ground_position",
"offset_deviation",
"mount_position",

}
function proto.IsImageLayer(k,v) if(v.filenames)then for i,e in pairs(v.filenames)do if(e:find(".png"))then return true end end end return v.layers or (v.filename and v.filename:find(".png")) or k=="animation" end
function proto.IsOffsetLayer(k,v) return (istable(v) and isstring(k) and (k:find("offset") or table.HasValue(proto.offset_keys,k))) end
function proto.IsRailLayer(k,v) return istable(v) and (v.metals or v.backplates) end
function proto.LoopFindImageLayers(prototype,lz) if(not prototype)then return end for key,val in pairs(prototype)do if(istable(val) and key~="sound")then
	if(proto.IsImageLayer(key,val))then if(val.layers)then for i,e in pairs(val.layers)do table.insert(lz.images,e) end else table.insert(lz.images,val) end
	elseif(proto.IsOffsetLayer(key,val))then table.insert(lz.offsets,val) elseif(proto.IsRailLayer(key,val))then table.insert(lz.rails,val) else proto.LoopFindImageLayers(val,lz)
	end
end end end
function proto.FindImageLayers(prototype) local imgz={images={},offsets={},rails={}} proto.LoopFindImageLayers(prototype,imgz) return imgz end
function proto.MergeImageTable(img,tbl) if(img.hr_version)then proto.MergeImageTable(img.hr_version,table.deepcopy(tbl)) end table.merge(img,table.deepcopy(tbl)) end
function proto.MultiplyOffsets(v,z) --if(v[1] and istable(v[1]) and not vector.is_zero(v[1]) and not vector.is_zero(v[2]))then
	for a,b in pairs(v)do if(istable(b))then for c,d in pairs(b)do if(type(d)=="table")then error(serpent.block(v)) end v[a][c]=d*z end else v[a]=b*z end end --else vector.set(v,vector(v)*z) --v[1]=v[1]*z v[2]=v[2]*z
end --end
function proto.MultiplyImageSize(img,z) if(img.hr_version)then proto.MultiplyImageSize(img.hr_version,z) end
	if(img.shift and istable(img.shift))then for i,e in pairs(img.shift)do if(istable(e))then for a,b in pairs(e)do e[a]=b*z end else img.shift[i]=e*z end end end
	img.scale=(img.scale or 1)*z img.y_scale=(img.y_scale or 1)*z img.x_scale=(img.x_scale or 1)*z
end

function proto.TintImages(pr,tint) local imgz=proto.FindImageLayers(pr) for k,v in pairs(imgz.images)do proto.MergeImageTable(v,{tint=table.deepcopy(tint)}) end end
function proto.MultiplyImages(pr,z) local imgz=proto.FindImageLayers(pr)
	for k,v in pairs(imgz.images)do proto.MultiplyImageSize(v,z) end
	for k,v in pairs(imgz.offsets)do proto.MultiplyOffsets(v,z) end
end




proto.bbox_keys={"collision_box","selection_box",  -- Table keys that are bounding boxes
	"drawing_box","window_bounding_box","horizontal_window_bounding_box","sticker_box","map_generator_bounding_box",
}
proto.ScalableBBoxes={"collision_box","selection_box"} -- Ordered pairs of bounding boxes we can make sized based calculations from
function proto.BBoxIsZero(bbox) if(bbox and bbox[1][1]==0 and bbox[1][2]==0 and bbox[2][1]==0 and bbox[2][2]==0)then return true end return false end
function proto.GetSizableBBox(pr) local b=pr[proto.ScalableBBoxes[1]] for i=2,#proto.ScalableBBoxes,1 do if(not b or proto.BBoxIsZero(b))then b=pr[proto.ScalableBBoxes[i]] else return b end end return b end
function proto.MultiplyBBox(b,z) if(not proto.BBoxIsZero(b))then b[1]=vector.raw(vector(b[1])*z) b[2]=vector.raw(vector(b[2])*z) end end
function proto.MultiplyBBoxes(t,z) for _,nm in pairs(proto.bbox_keys)do if(t[nm] and not proto.BBoxIsZero(t[nm]))then proto.MultiplyBBox(t[nm],z) end end end
function proto.AddBBox(b,f) b[1]=vector.raw(vector(b[1])-vector(f)) b[2]=vector.raw(vector(b[2])+vector(f)) end
function proto.AddBBoxes(t,f) for _,nm in pairs(proto.bbox_keys)do if(t[nm] and not proto.BBoxIsZero(t[nm]))then proto.AddBBox(t[nm],f) end end end
function proto.BBoxSize(b) return vector(b[2])-vector(b[1]) end
function proto.RecenterBBox(b) local len=proto.BBoxSize(b) b[2]=len/2 b[1]=-len/2 end


function proto.GetBBoxOrigin(bbox) -- This is to give us +0.5 origin if the bbox needs it, but i dont think this is needed idfk
	local bbx=proto.BBoxSize(bbox)
	local bv=vector(math.round(bbx.x),math.round(bbx.y))
	local forigin=vector(bv.x%2==0 and 0.5 or 0,bv.y%2==0 and 0.5 or 0)
	return forigin
end

function proto.SizeTo(pr,scale) -- Resizes something purely off a simple scale, this function simply does *scale
	proto.MultiplyBBoxes(pr,scale)
	proto.MultiplyImages(pr,scale)
end
function proto.SizeToTile(pr,tilesize) -- Resizes something to a tile size based off its scaleable bbox. This is a simple call function to do simple image/bbox/offset resizing.
	local bbox=proto.GetSizableBBox(pr) if(not bbox or proto.BBoxIsZero(bbox))then return end
	local bbx=proto.BBoxSize(bbox)
	proto.SizeTo(pr,tilesize/math.max(bbx.x,bbx.y))
end


--[[ Fluidbox Counter/Scanner ]]--


proto.fluidbox_keys={"fluid_boxes","fluid_box","input_fluid_box","output_fluid_box"}

function proto.ScanReadFluidbox(fbox,fb)
	if(not fbox.pipe_connections)then for k,v in pairs(fbox)do if(istable(v) and v.pipe_connections)then proto.ScanReadFluidbox(v,fb) end end return end
	for pipeid,pipe in pairs(fbox.pipe_connections)do
		if(pipe.position or pipe.positions)then fb.c=fb.c+1 end
		if(pipe.position)then
			local maxdir,maxkey=vector.MaxDir(vector(pipe.position))
			fb[maxdir.."ern"]=fb[maxdir.."ern"]+1
			fb[maxdir.."single"]=fb[maxdir.."single"]+1
			local id=#fb[maxdir]+1 fb[maxdir][id]=pipe.position
		elseif(pipe.positions)then
			fb["north".."single"]=fb["north".."single"]+1
			for i=1,4,1 do local dir=string.compassnum[i] fb[dir.."ern"]=fb[dir.."ern"]+1 local id=#fb[dir]+1 fb[dir][id]=pipe.positions[i] end
		end
	end
end
function proto.ScanFluidboxCounts(pr)
	local fbc={c=0,
		north={},east={},south={},west={}, -- Table of fluidbox datas based on direction. Fluidboxes always default to north (y=-5)
		northern=0,eastern=0,southern=0,western=0, -- Number of fluidboxes for each given direction total, for all pipe connections.
		northsingle=0,eastsingle=0,southsingle=0,westsingle=0, -- Number of fluidboxes for each given direction counting by only a single orientation (north)
	}
	for _,fbn in pairs(proto.fluidbox_keys)do if(pr[fbn] and istable(pr[fbn]))then proto.ScanReadFluidbox(pr[fbn],fbc) end end
	return fbc
end

function proto.SizeFluidboxesTo(pr,vecscale,fbc)
	fbc=fbc or proto.ScanFluidboxCounts(pr)
	for dir in pairs(string.strcompass)do
		for vi,fbox in pairs(fbc[dir])do
			local vfb=vector.raw(vector.floorEx(vector(fbox)*vecscale,2,true))

--if(proto.dbg)then error("FBOX:"..serpent.block(fbox) .. " \n NEW FBOX: " .. serpent.block(vfb) .. " \n ORIGIN: " .. serpent.block(origin) .. " \n BBOX: " .. serpent.block(bbround) .. " \n VECSCALE: " .. serpent.block(vecscale)) end

			vector.set(fbox,vfb)

		end
	end
end

function proto.ShiftFluidboxCenters(pr,bbox,fbc) -- Shift fluidboxes more towards the center if they're off-center as a sum.
	fbc=fbc or proto.ScanFluidboxCounts(pr)
	local shifts={north=vector(),east=vector(),south=vector(),west=vector()}
	for dir,vec in pairs(shifts)do
		for ktd,pos in pairs(fbc[dir])do --if(proto.dbg and dir=="north")then error("northtest" .. serpent.block(pos)) end
			shifts[dir]=shifts[dir]+vector(((dir=="north" or dir=="south") and vector.getx(pos) or 0),((dir=="east" or dir=="west") and vector.gety(pos) or 0))
		end
		if(not vector.is_zero(shifts[dir]))then shifts[dir]=shifts[dir]/fbc[dir.."ern"] end
	end
--if(proto.dbg)then error(serpent.block(shifts) .. ", " .. serpent.block(fbc)) end

	for dir,vec in pairs(shifts)do
		for vi,fbox in pairs(fbc[dir])do local vfb=vector(fbox)-vec vector.set(fbox,vfb) end
	end

end

function proto.AutoResize(pr,tilesize)
	--if(table.HasValue(proto.no_resize_types,pr.type))then return end
	local goalsize=tilesize
	local bbox=proto.GetSizableBBox(pr) if(not bbox or proto.BBoxIsZero(bbox))then return end
	local bbsize=vector.roundEx(proto.BBoxSize(bbox),2,true)
	local bbpipe=bbsize+vector(1,1) -- The size the bbox would be if it were 1 tile bigger (fluidbox size = {-0.5,-0.5},{0.5,0.5} bigger than regular bbox.)
	local bbmax=math.ceil(math.max(bbsize.x,bbsize.y))
	local pipemax=math.ceil(math.max(bbpipe.x,bbpipe.y))
	if(pr.type=="character" or pr.type=="character-corpse")then goalsize=0.75 end
	local fbc=proto.ScanFluidboxCounts(pr)

	--if(pr.name=="furnace")then proto.dbg=true end
	--if(pr.name=="boiler")then proto.dbg=true end
	--if(pr.name=="pumpjack")then proto.dbg=true end
	--if(pr.name=="offshore-pump")then proto.dbg=true end
	--if(pr.name=="oil-refinery")then proto.dbg=true end
	--if(pr.name=="chemical-plant")then proto.dbg=true end
	--if(pr.name=="pump")then proto.dbg=true end



	if(fbc.c>0)then -- Do the fluidbox thing
		local pipesizemin=math.max(goalsize,fbc.northern,fbc.southern,fbc.eastern,fbc.western) -- The minimum tile-size we can be due to fluidboxes
		goalsize=pipesizemin
		local pipesize=goalsize+1 -- the goal tile-size which we would use if we were resizing to the size of the bbox if it were 1 tile bigger in all directions
		local pipescale=vector(pipesize,pipesize)/pipemax
		local bbnewpipe=bbpipe*pipescale
		local bbnew=bbsize*(goalsize/bbmax)

		proto.ShiftFluidboxCenters(pr,bbsize,fbc) -- Shift fluidboxes to center of new bbox
		proto.SizeFluidboxesTo(pr,pipescale,fbc) -- Shift positions of fluidboxes

	--if(proto.dbg)then error("DEBUG: Size " .. goalsize .. ", bbmax: " .. pipemax .. ", scale: " .. goalsize/bbmax .. ", Pipescale: " .. serpent.block(pipescale) .. "\nData:\n"..serpent.block(pr).."\n---------------FB----------------\n"..serpent.block(fbc).."\n".."") end





	end

	proto.SizeTo(pr,goalsize/bbmax)

end



return proto