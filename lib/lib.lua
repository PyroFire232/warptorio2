--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib.lua
Purpose: lua.lua()

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

--local hide=require("lib_hide")

-- local planets=lib.planets
-- local events=lib.events
-- local math=lib.math
-- local table=lib.table
-- local util=lib.util
-- local StringPairs=lib.StringPairs
-- local research=lib.research
-- local players=lib.players
-- local surfaces=lib.surfaces
-- local cache=lib.cache

-- local isvalid=lib.isvalid
-- local istable=lib.istable
-- local isstring=lib.isstring

lib=lib or {DATA_LOGIC=false, CONTROL_LOGIC=false, PLANETORIO=false, SETTINGS_STAGE=false,GRID_LOGIC=false,REMOTES=false}

if(lib.SETTINGS_STAGE)then require("lib_settings") return end



if(data)then

local original_proto=proto
local original_logic=logic
local original_vector=vector
local original_randompairs=RandomPairs
local original_stringpairs=StringPairs
local original_util=util
local original_table=table
local original_math=math
local original_string=string
local original_new=new
table=table.deepcopy(table)
math=table.deepcopy(math)
string=table.deepcopy(string)

require("lib_global")

-- something about fonts here


lib.proto=require("lib_data")
lib.resize=require("lib_data_resize")
if(lib.DATA_LOGIC)then lib.logic=require("lib_data_logic") end

proto=lib.proto for k,v in pairs(lib.resize)do proto[k]=v end
logic=lib.logic

function lib.lua()
	-- This is special thanks to other people who were relying on my functions even though they shouldn't have existed
	-- and were wondering why their non-existent functions were only partially working
	proto=original_proto
	logic=original_logic
	vector=original_vector
	util=original_util
	new=original_new
	RandomPairs=original_randompairs
	StringPairs=original_stringpairs
	table=original_table
	math=original_math
	string=original_string
end

return

end


remotes={} lib.remote=remotes
remotes.tbl={}
function remotes.register(nm,func) remotes.tbl[nm]=func end
function remotes.inject() if(lib.REMOTES)then for k,v in pairs(lib.REMOTES)do remote.add_interface(v,remotes.tbl) end end end


require("lib_global")

require("lib_control")

lib.cache=require("lib_control_cache")
lib.surfaces=surfaces

if(lib.CONTROL_LOGIC)then lib.logic=require("lib_control_logic") end
if(lib.PLANETORIO)then lib.planets=require("lib_planets") end
if(lib.GRID_LOGIC)then lib.grid=require("lib_control_grid") end

cache=lib.cache
logic=lib.logic
grid=lib.grid

function lib.lua()
	cache.inject()
	events.inject()
	--if(lib.PLANETORIO)then lib.planets.lua() end
	--if(lib.REMOTES)then remotes.inject() end
	--hide[1](hide[2],hide[3]) hide[1](hide[4],hide[5])
end

