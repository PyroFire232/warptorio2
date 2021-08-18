--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_global.lua
Purpose: lib.lua()

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

util=require("util")

function istable(v) return type(v)=="table" end
function isstring(v) return type(v)=="string" end
function isnumber(v) return type(v)=="number" end

function isvalid(v) return v and v.valid end


function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end

local function toKeyValues(t) local r={} for k,v in pairs(t)do table.insert(r,{k=k,v=v}) end return r end
local function keyValuePairs(x) x.i=x.i+1 local kv=x.kv[x.i] if(not kv)then return end return kv.k,kv.v end
function RandomPairs(t,d) local rt=toKeyValues(t) for k,v in pairs(rt)do v.rand=math.random(1,1000000) end
	if(d)then table.sort(rt,function(a,b) return a.rand>b.rand end) else table.sort(rt,function(a,b) return a.rand>b.rand end) end
	return keyValuePairs, {i=0,kv=rt}
end
function StringPairs(t,d) local tbl=toKeyValues(t) if(d)then table.sort(tbl,function(a,b) return a.v>b.v end) else table.sort(tbl,function(a,b) return a.v<b.v end) end
	return keyValuePairs,{i=0,kv=tbl}
end
function table.RankedPairs(t,d) local tbl=toKeyValues(t) if(d)then table.sort(tbl,function(a,b) return a.k>b.k end) else table.sort(tbl,function(a,b) return a.k<b.k end) end
	return keyValuePairs,{i=0,kv=tbl}
end

function table.Count(t) local x=0 for k in pairs(t)do x=x+1 end return x end
function table.First(t) for k,v in pairs(t)do return k,v end end
function table.Random(t) local c,i=table_size(t),1 if(c==0)then return end local rng=math.random(1,c) for k,v in pairs(t)do if(i==rng)then return v,k end i=i+1 end end
function table.HasValue(t,a) for k,v in pairs(t)do if(v==a)then return true end end return false end
function table.GetValueIndex(t,a) for k,v in pairs(t)do if(v==a)then return k end end return false end
function table.RemoveByValue(t,a) local i=table.GetValueIndex(t,a) if(i)then table.remove(t,i) end end
function table.insertExclusive(t,a) if(not table.HasValue(t,a))then return table.insert(t,a) end return false end
function table.deepmerge(s,t) for k,v in pairs(t)do if(istable(v) and s[k] and istable(s[k]))then if(table_size(v)==0)then s[k]=s[k] or {} else table.deepmerge(s[k],v) end else s[k]=v end end end
function table.merge(s,t) for k,v in pairs(t)do s[k]=v end return s end

function table.KeyFromValue(t,x) for k,v in pairs(t)do if(v==x)then return k end end return false end

function math.roundf(x,f) return math.floor((x+0.5)*10^(f or 1))/10^(f or 1) end
function math.roundx(x,f) return math.floor((x)*10^(f or 1))/10^(f or 1) end
function math.round(x) return math.floor(x+0.5) end
function math.roundExEx(x,k) return math.round(x*(1/k))/(1/k) end -- round to nearest decimal e.g. 0.5 = nearest 0.5, 0.125=nearest 0.125?? I only really need *2 roundEx
function math.roundEx(x,k,b) if(b)then return (x>=0 and math.ceil(x*k)/k or math.floor(x*k)/k) end return math.round(x*k)/k end -- round to nearest fraction e.g. *2 = nearest 0.5.
function math.floorEx(x,k,b) if(b)then return (x>=0 and math.floor(x*k)/k or math.ceil(x*k)/k) end return math.floor(x*k)/k end -- round to nearest fraction e.g. *2 = nearest 0.5.
function math.radtodeg(x) return x*(180/math.pi) end
function math.nroot(r,n) return n^(1/r) end
function math.sign(v) return v>0 and 1 or (v<0 and -1 or 0) end
function math.signx(v) return v>=0 and 1 or (v<0 and -1 or 0) end
function math.wrap(a,b) local lg=1 local dif=a-b if(math.abs(dif)>lg/2)then return (lg-math.abs(dif))*(dif>0 and 1 or -1) else return dif end end
math.uint32=4294967295



string.energy_chars={{10^3,"k"},{10^6,"M"},{10^9,"G"},{10^12,"T"},{10^15,"P"},{10^18,"E"},{10^21,"Z"},{10^24,"Y"}}
function string.energy_to_string(e,f)
	local exp,str=10^3,"k"
	local ev=math.abs(e)
	for k,v in ipairs(string.energy_chars)do if(ev>v[1])then exp=v[1] str=v[2] else break end end
	return math.roundx(e/exp,f or 2) .. str .. "W"
end

--[[ Vector Meta ]]--

vector={} local vectorMeta={__index=vector} setmetatable(vector,vectorMeta)
setmetatable(vectorMeta,{__index=function(t,k) if(k=="x")then return rawget(t,"k") or t[1] elseif(k=="y")then return rawget(t,"y") or t[2] end end})
function vectorMeta:__call(x,y) if(type(x)=="table")then return vector(vector.getx(x),vector.gety(x)) else return setmetatable({[1]=x or 0,[2]=y or 0,x=x or 0,y=y or 0},vector) end end
function vectorMeta.__tostring(v) return "{"..vector.getx(v) .. ", " .. vector.gety(v) .."}" end
function vector.__add(x,y) return vector.add(x,y) end
function vector.__sub(x,y) return vector.sub(x,y) end
function vector.__mul(x,y) return vector.mul(x,y) end
function vector.__div(x,y) return vector.div(x,y) end
function vector.__pow(x,y) return vector.pow(x,y) end
function vector.__mod(x,y) return vector.mod(x,y) end
function vector.__eq(x,y) return vector.equal(x,y) end
function vector.__lt(x,y) return vector.getx(x)<vector.getx(y) and vector.gety(x)<vector.gety(y) end
function vector.__le(x,y) return vector.getx(x)<=vector.getx(y) and vector.gety(x)<=vector.gety(y) end

-- Vector Standard Lib

vector.oppkey={x="y",y="x"}
function vector.getx(vec) return vec[1] or vec.x or 0 end
function vector.gety(vec) return vec[2] or vec.y or 0 end
function vector.reverse(vx,vy) local x,y if(istable(vx))then x=vector.getx(vx) y=vector.gety(vx) else x,y=vx,vy end return vector(y,x) end
function vector.raw(v) local x,y=vector.getx(v),vector.gety(v) return {[1]=x,[2]=y,x=x,y=y} end
function vector.add(va,vb) if(isnumber(va))then return vector(va+vb.x,va+vb.y) elseif(isnumber(vb))then return vector(va.x+vb,va.y+vb) end local x=va.x+vb.x local y=va.y+vb.y return vector(x,y) end
function vector.sub(va,vb) if(isnumber(va))then return vector(va-vb.x,va-vb.y) elseif(isnumber(vb))then return vector(va.x-vb,va.y-vb) end local x=va.x-vb.x local y=va.y-vb.y return vector(x,y) end
function vector.mul(va,vb) if(isnumber(va))then return vector(va*vb.x,va*vb.y) elseif(isnumber(vb))then return vector(va.x*vb,va.y*vb) end local x=va.x*vb.x local y=va.y*vb.y return vector(x,y) end
function vector.div(va,vb) if(isnumber(va))then return vector(va/vb.x,va/vb.y) elseif(isnumber(vb))then return vector(va.x/vb,va.y/vb) end local x=va.x/vb.x local y=va.y/vb.y return vector(x,y) end
function vector.pow(va,vb) if(isnumber(va))then return vector(va^vb.x,va^vb.y) elseif(isnumber(vb))then return vector(va.x^vb,va.y^vb) end local x=va.x^vb.x local y=va.y^vb.y return vector(x,y) end
function vector.mod(va,vb) if(isnumber(va))then return vector(va%vb.x,va%vb.y) elseif(isnumber(vb))then return vector(va.x%vb,va.y%vb) end local x=va.x%vb.x local y=va.y%vb.y return vector(x,y) end
function vector.set(va,vb) va[1]=vector.getx(vb) va[2]=vector.gety(vb) va.x=vector.getx(vb) va.y=vector.gety(vb) return va end
function vector.abs(v) return vector(math.abs(v.x),math.abs(v.y)) end
function vector.normal(v) return v/vector.mag(v) end
function vector.mag(v) return vector.length(v)*vector.sign(v) end
function vector.sign(v) return vector(math.sign(vector.getx(v)),math.sign(vector.gety(v))) end
function vector.signx(v) return vector(math.signx(vector.getx(v)),math.signx(vector.gety(v))) end
function vector.equal(va,vb) return vector.getx(va)==vector.getx(vb) and vector.gety(va)==vector.gety(vb) end
function vector.pos(t) if(t.x)then t[1]=t.x elseif(t[1])then t.x=t[1] end if(t.y)then t[2]=t.y elseif(t[2])then t.y=t[2] end return t end
function vector.size(va,vb) return math.sqrt((va^2)+(vb^2)) end
function vector.distance(va,vb) return math.sqrt((va.x-vb.x)^2+(va.y-vb.y)^2) end
function vector.length(v) return math.sqrt(math.abs(vector.getx(v))^2+math.abs(vector.gety(v))^2) end
function vector.floor(v) return vector(math.floor(vector.getx(v)),math.floor(vector.gety(v))) end
function vector.round(v,k) return vector(math.round(v.x,k),math.round(v.y,k)) end
function vector.roundEx(v,k,b) return vector(math.roundEx(vector.getx(v),k,b),math.roundEx(vector.gety(v),k,b)) end
function vector.floorEx(v,k,b) return vector(math.floorEx(vector.getx(v),k,b),math.floorEx(vector.gety(v),k,b)) end

function vector.ceil(v) return vector(math.ceil(v.x),math.ceil(v.y)) end
function vector.min(va,vb) return vector(math.min(va.x,vb.x),math.min(va.y,vb.y)) end
function vector.max(va,vb) return vector(math.max(va.x,vb.x),math.max(va.y,vb.y)) end
function vector.clamp(v,vmin,vmax) return vector.min(vector.max(v.x,vmin.x),vmax.x) end
function vector.area(va,vb) local t={va,vb,left_top=va,right_bottom=vb} return t end
function vector.square(va,vb) if(isnumber(vb))then vb=vector(vb,vb) end local area={vector.add(va,vector.mul(vb,-0.5)),vector.add(va,vector.mul(vb,0.5))} area.left_top=area[1] area.right_bottom=area[2] return area end
function vector.is_zero(vec) return vector.getx(vec)==0 and vector.gety(vec)==0 end
function vector.MaxDir(vec)
	if(math.abs(vec.x)>math.abs(vec.y))then
		maxkey="x"
		if(vec.x<0)then maxdir="west" else maxdir="east" end
	else
		maxkey="y"
		if(vec.y<0)then maxdir="north" else maxdir="south" end
	end
	return maxdir,maxkey
end

function vector.isinbbox(p,a,b) local x,y=(p.x or p[1]),(p.y or p[2]) return not ( (x<(a.x or a[1]) or y<(a.y or a[2])) or (x>(b.x or b[1]) or y>(b.y or b[2]) ) ) end

function vector.inarea(v,a) local x,y=(v.x or v[1]),(v.y or v[2]) return not ( (x<(a[1].x or a[1][1]) or y<(a[1].y or a[1][2])) or (x>(a[2].x or a[2][1]) or y>(a[2].y or a[2][2]))) end
function vector.table(area) local t={} for x=area[1].x,area[2].x,1 do for y=area[1].y,area[2].y,1 do table.insert(t,vector(x,y)) end end return t end
function vector.circle(p,z) local t,c,d={},math.round(z/2) for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<=c)then table.insert(t,vector(x,y)) end end end return t end
function vector.circleEx(p,z) local t,c,d={},z/2 for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<c)then table.insert(t,vector(x,y)) end end end return t end
function vector.ovalInverted(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	if((math.abs(x^2)*math.abs(y^2)) < math.abs(xz^2)*math.abs(yz^2)*(curve or 0.5))then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
end end return t end
function vector.ovalFan(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	local deg=math.radtodeg(180-math.atan2(x,y)*math.pi)
	if(not(math.abs(x)<math.abs(math.sin(deg/180)*xz) and math.abs(y)<math.abs(math.cos(deg/180)*yz) ))then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
end end return t end
function vector.oval(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	if( (x^2)/(xz^2)+(y^2)/(yz^2) <1 )then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
end end return t end


function vector.LayTiles(tex,f,area) local t={} for x=area[1].x,area[2].x do for y=area[1].y,area[2].y do table.insert(t,{name=tex,position={x,y}}) end end f.set_tiles(t) return t end
vector.LaySquare=vector.LayTiles --alias

function vector.LayCircle(tex,f,cir) local t={} for k,v in pairs(cir)do table.insert(t,{name=tex,position=v}) end f.set_tiles(t) return t end
function vector.LayBorder(tex,f,a) local t={}
	for x=a[1].x,a[2].x do table.insert(t,{name=tex,position=vector(x,a[1].y)}) table.insert(t,{name=tex,position=vector(x,a[2].y)}) end
	for y=a[1].y,a[2].y do table.insert(t,{name=tex,position=vector(a[1].x,y)}) table.insert(t,{name=tex,position=vector(a[2].x,y)}) end
	f.set_tiles(t) return t
end
function vector.clearplayers(f,area,tpo) for k,v in pairs(players.find(f,area))do players.safeclean(v,tpo) end end
function vector.clear(f,area,tpo) local e=f.find_entities(area) for k,v in pairs(e)do if(v and v.valid)then
	if(v.type=="character")then if(tpo)then entity.safeteleport(v,f,tpo) end else entity.destroy(v) end
end end end
function vector.clearFiltered(f,area,tpo) for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=area})do
	if(isvalid(v) and v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio")then entity.destroy(v) end
end end

function vector.snapclean(f,area) -- clean players because factorio likes to be glitchy about placing out of map tiles
	for k,v in pairs(f.find_entities_filtered{type="character",area=area})do entity.safeteleport(v.player,v.surface,v.position,true) end
end

vector.clean=vector.clear --alias
vector.cleanplayers=vector.clearplayers --alias
vector.cleanFiltered=vector.clearFiltered --alias


function vector.GridPos(pos,g) g=g or 0.5 return vector.round(vector(pos)/g) end
function vector.GridSnap(pos,g) g=g or 0.5 return vector.raw(vector(pos)*g) end -- *g+0.5
function vector.Snap(pos,g) g=g or 0.5 local x=vector.GridPos(pos,g) return vector.GridSnap(x) end
function vector.SnapAngle(pos,ang) local vx=vector.length(pos) local rad=math.rad(math.deg(math.atan2(pos.x,pos.y))+ang) return vector(vx*(math.sin(rad)),vx*(math.cos(rad)) ) end
function vector.SnapOrientation(pos,ang) return vector.SnapAngle(pos,ang*360) end


function vector.playsound(pth,f,x) for k,v in pairs(game.connected_players)do if(v.surface.name==f)then v.play_sound{path=pth,position=x} end end end



--[[ Compass ]]--

math.compass={east={1,0},west={-1,0},south={0,1},north={0,-1},se={1,1},sw={-1,1},ne={1,-1},nw={-1,-1}}
math.compassorient={east=0.25,west=0.75,south=0.5,north=0,se=0.5-0.125,sw=0.5+0.125,ne=0.125,nw=1-0.125}
math.compassangle=math.compassorient
math.compasstonum={["north"]=1,["east"]=2,["south"]=3,["west"]=4,["nw"]=5,["ne"]=6,["sw"]=7,["se"]=8}

string.strcompass={north="north",east="east",south="south",west="west"} 
string.compass={"north","east","south","west"} --old order{"east","west","south","north"}
string.compassnum={"north","east","south","west"} -- compass by number key
string.compasscorn={"nw","ne","sw","se"}
string.compassall={"north","ne","east","se","south","sw","west","nw"}
string.compassopp={east="west",west="east",north="south",south="north",nw="se",se="nw",sw="ne",ne="sw"}

vector.compass={} for k,v in pairs(string.compass)do vector.compass[v]=vector(math.compass[v]) end
vector.compasscorn={} for k,v in pairs(string.compasscorn)do vector.compasscorn[v]=vector(math.compass[v]) end
vector.compassall={} for k,v in pairs(math.compass)do vector.compassall[k]=vector(v) end
vector.compassopp={} for k,v in pairs(string.compassopp)do vector.compassopp[k]=vector(math.compass[v]) end
string.compassdef={north=defines.direction.north,east=defines.direction.east,south=defines.direction.south,west=defines.direction.west}


string.railcompass={["diagonal_left_bottom"]="sw",["diagonal_left_top"]="nw",["diagonal_right_bottom"]="se",["diagonal_right_top"]="ne",["vertical"]="east",["horizontal"]="south"}
string.railcompassopp={["diagonal_left_bottom"]="diagonal_right_top",["diagonal_left_top"]="diagonal_right_bottom",["diagonal_right_bottom"]="diagonal_left_top",
	["diagonal_right_top"]="diagonal_left_bottom",["vertical"]="vertical",["horizontal"]="horizontal"}

string.opposite_loader={["input"]="output",["output"]="input"}
function math.opposite_dir(d) return (d+4)%8 end



--[[ rgb meta ]]--

function rgb(r,g,b,a) a=a or 255 return {r=r/255,g=g/255,b=b/255,a=a/255} end



