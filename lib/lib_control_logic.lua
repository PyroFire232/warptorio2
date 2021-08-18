--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_control_logic.lua
Purpose: control stage logic

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



--[[ Unused


function warptorio.GetFastestLoader() -- currently unused
	if(warptorio.FastestLoader)then return warptorio.FastestLoader end if(true)then return "express-loader" end
	local ld={} local topspeed=game.entity_prototypes["express-loader"].belt_speed local top="express-loader"
	for k,v in pairs(game.entity_prototypes)do if(v.type=="loader")then table.insert(ld,v) end end
	for k,v in pairs(ld)do if(not v.name:match("warptorio") and not v.name:match("mini") and v.belt_speed>=topspeed)then topspeed=v.belt_speed top=v.name end end
	warptorio.FastestLoader=top return top
end

]]