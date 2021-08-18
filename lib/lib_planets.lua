--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2

This is the code you are looking for, if you want code that helps to IMPLEMENT planetorio and the planets it generates. This is not used when making planets. For that see planet_hijack.lua

Script: lib_planets.lua
Purpose: standalone planets thing. Easy-implementation standalone library thingy. require() on first line of control.lua, then call lib_planets_dot_lua() at the end.
This library specifically addresses the need to read the complete planets templates table during init and config changed, because template events are only raised once.
Knowing when templates need to be removed, or have been changed during on_configuration_changed, is managed internally by this library.

call planets.GetTemplates() to read the synced templates table.
call planets.GetTemplate(key) to read a specific template in the templates table.

Function: lib.planets.lua()
When to call: script.on_init() and script.on_configuration_changed(). Note this is automatically called by lib.lua()
Description: Registers planetorio events and reads data.
Call this function in on_init and on_configuration_changed if you want to read planetorio data as it is built & mods are loaded.
It is expected that you reset and rebuild your global tables on each instance of each event raised by this function.

Functions: planets.on_* EVENTS
When to call: after you called lib_planets_dot_lua() in on_init and on_config
Description: These functions are raised during every on_init and on_config_changed, regardless if it actually changed.
This is to re-syncronize this mods copy of the templates with planetorios + all planet mods.

planets.on_new_template(function) -- Raised whenever a planet is added to the templates, which should be during on_init and on_configuration_changed, but can also happen during runtime.
planets.on_template_updated(function) -- Raised whenever a planet template is changed during runtime
planets.on_template_removed(function) -- Raised whenever a planet template is removed, which should be during on_init and on_configuration_changed, but can also happen during runtime.



Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.

]]---------------------------------------

local planets=planets or {}
planets.templatefuncs={}
planets.templatermvfuncs={}
planets.templateupfuncs={}

--[[ Event: On New Template

call planets.on_new_template(function(event) local template=event.template end) to handle new templates.

]]

function planets.on_new_template(f) table.insert(planets.templatefuncs,f) end
function planets.on_template_updated(f) table.insert(planets.templateupfuncs,f) end
function planets.on_template_removed(f) table.insert(planets.templatermvfuncs,f) end

-- Internal function to raise the template events table
function planets.raise_template_removed(ev) for i,f in pairs(planets.templatermvfuncs)do f(ev) end global._planetorio.template[ev.template.key]=nil end
function planets.raise_template_event(ev) global._planetorio.template[ev.template.key]=ev.template for i,f in pairs(planets.templatefuncs)do f(ev) end end
function planets.raise_template_updated_event(ev) table.merge(global._planetorio.template[ev.template.key],ev.template) for i,f in pairs(planets.templateupfuncs)do f(ev) end end

function planets.GetTemplates() -- returns internal copy of synced templates
	return global._planetorio.template
end
function planets.GetTemplate(key) -- returns internal synced copy of a template
	return global._planetorio.template[key]
end
function planets.GetBySurface(f) return remote.call("planetorio","GetBySurface",f) end

function planets.lua()
	local pevents=remote.call("planetorio","GetEvents")

	global._planetorio=global._planetorio or {}
	script.on_event(pevents.on_new_template,planets.raise_template_event)
	script.on_event(pevents.on_template_updated,planets.raise_template_updated_event)
	script.on_event(pevents.on_template_removed,planets.raise_template_removed)

	local cur_data=remote.call("planetorio","GetTemplates")
	global._planetorio.template=global._planetorio.template or {}
	for key,val in pairs(global._planetorio.template)do
		if(not cur_data[key])then planets.raise_template_removed({template=val}) global._planetorio.template[key]=nil end
	end

	table.merge(global._planetorio,{template=cur_data})
	for k,v in pairs(cur_data)do planets.raise_template_event({template=v}) end
end

return planets