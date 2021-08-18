--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_data_logic.lua
Purpose: data stage logic

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



local logic={}
logic.loading=true

function logic.seed(s)
	local n=tonumber(s) if(tostring(n)==s)then math.randomseed(n) return n end -- its just a number
	n=0 for i=1,string.len(s),1 do n=n+string.byte(s:sub(i,i)) end
	math.randomseed(n*24) for i=1,n,1 do local x=math.random() end
	return n
end

-- The original hand & starting conditions of the logic system
logic.origin={} local origin=logic.origin

-- Prototype types with their logic functions
logic.ent={}

-- The items, fluids, recipes, ents and everything and stuff currently in our hand & their logical status
logic.hand={} local hand=logic.hand
hand.recipes={} -- recipes in crafting menu
hand.recipescan={} -- recipes that have their item and entity results pushed to hand
hand.reciperead={} -- recipes that have had ingredients read
hand.techs={} -- technologies that we are able to finish thanks to labs, bottles etc
hand.techscan={} -- technologies that have been scanned and effects pushed to hand (recipes etc) aka we have "researched" this technology.
hand.ents={} -- Entities that we can place in the world
hand.entscan={} -- "usable" entities - we can fuel/operate them because we have neccessary items e.g. pipes needed for machines with fluidboxes
hand.items={} -- accessible and craftable items
hand.itemscan={} -- Items that have already been scanned and have fully pushed all potential uses
hand.fluids={}

hand.labpacks={} -- Science pack items (that are in hand) that we can put into a lab (if we have a labbable slot for it).
hand.labslots={} -- Labbable science packs.

-- Flags, e.g. has a power source, has power pole, has belts etc
hand.void=true -- void power
hand.power=false
hand.pole=false
hand.pipes=false
hand.pipe_to_ground=false
hand.belts=false
hand.underground_belts=false
hand.splitters=false
hand.inserters=false
hand.drill=false
hand.fluid_drill=false -- can be true for a drill accepting all fluids, or a table of drills with filtered fluidboxes
hand.rocket_silo=false -- Has a thing capable of launching items for rocket_launch_product

hand.heat=0 -- max heat capacity

hand.craft_cats={}
hand.burner_cats={} -- [cat]=n with n=burnt_inventory_size. Burnable Categories that we can burn, and their burnt inventory size.
hand.burnables={} -- Items that can be put in a burner
hand.resource_cats={}
hand.resource_scan={} -- Resources that have been scanned & added to our hand, e.g. iron-ore, but not uranium ore because it waits for sulfuric acid. [name]=0/1 automation
hand.fuel_types={}

logic.ignored={}
logic.is_bobs=false
logic.spaceblock=false
function logic.bobs(b) if(b)then logic.is_bobs=b end return logic.is_bobs end
function logic.Ignore(rcpname) logic.ignored[rcpname]=true end
function logic.ShouldIgnore(rcpname,rcp)
	if(rcp and rcp.subgroup)then
		if(logic.spaceblock and rcp.subgroup:find("spaceblock"))then return true end
	end
	return rcpname:find("void") or rcpname:find("converter") or logic.ignored[rcpname]
 --or (logic.bobs() and rcpname:find("alien"))
end 
function logic.Ignoring(rcp) return logic.ShouldIgnore(rcp.name,rcp) end

logic.seablock=false
logic.SeablockScience={
	["angels-ore3"]="sb-angelsore3-tool",
	["basic-circuit-board"]="sb-basic-circuit-board-tool",
	["algae-green"]="sb-algae-green-tool",
	["sulfur"]="sb-sulfur-tool",
	["lab"]="sb-lab-tool",
}

-- Other initial conditions
function logic.Seablock() hand.pole=true hand.power=true hand.pipes=true hand.belts=true hand.inserters=true
	-- And push some entities too?
	logic.seablock=true
	logic.bobs(true)
	logic.PushItem(data.raw.item["stone-furnace"],0,true) -- inv furnace
	logic.PushItem(data.raw.item["burner-ore-crusher"],0,true)
	logic.PushItem(data.raw.item["iron-plate"],0,true)
	logic.PushItem(data.raw.item["stone-brick"],0,true)
	logic.PushItem(data.raw.item["landfill-sand-3"],0,true)
	logic.PushItem(data.raw.item["small-electric-pole"],0,true)
	logic.PushItem(data.raw.item["copper-pipe"],0,true)
	logic.PushItem(data.raw.item["stone-pipe"],0,true)
	logic.PushItem(data.raw.item["stone-pipe-to-ground"],0,true)
	logic.PushItem(data.raw.item["wind-turbine-2"],0,true)
	logic.PushItem(data.raw.item["iron-stick"],0,true)
	logic.PushItem(data.raw.item["pipe"],0,true)
	logic.PushItem(data.raw.item["basic-circuit-board"],0,true)
	logic.PushItem(data.raw.item["electronic-circuit"],0,true)
	logic.PushItem(data.raw.item["iron-gear-wheel"],0,true)
	logic.PushItem(data.raw.item["small-lamp"],0,true)
	logic.PushItem(data.raw.item["stone"],0,true)
	logic.PushItem(data.raw.item["pipe-to-ground"],0,true)
	--logic.PushItem(data.raw.tool["sb-angelsore3-tool"],0,true) -- because apparently this is a special item you can't actually obtain. why.
	--logic.PushItem(data.raw.tool["sb-basic-circuit-board-tool"],0,true) -- because apparently this is a special item you can't actually obtain. why.
	--logic.PushItem(data.raw.tool["sb-algae-green-tool"],0,true) -- because apparently this is a special item you can't actually obtain. why.
	--logic.PushItem(data.raw.tool["sb-lab-tool"],0,true) -- because apparently this is a special item you can't actually obtain. why.


	--logic.Ignore("offshore-pump")
	--logic.Ignore("crystallizer")
	--logic.Ignore("electrolyzer")
end

function logic.HasMoreRecipes() for k,v in pairs(data.raw.recipe)do if(not hand.recipescan[k] and proto.UsedRecipe(k) and not logic.ShouldIgnore(k))then return true end end return false end



-- Easy check if Fluid (with temperatures) or Item is in our hand (by name)
-- fluids may need a min/max...
-- Todo push a temperature without a fluid
-- It is possible fluid temperature may be removed in future https://forums.factorio.com/viewtopic.php?f=34&t=64499
--function logic.CanFluid(fld,tmp) tmp=tmp or 15 local ft=hand.fluids[fld] if(ft)then for m in pairs(ft)do if(m>=tmp)then return true end end end return false end
function logic.CanFluid(d,n,x) n=n or 15 local ft=hand.fluids[d] if(ft)then if(not x)then for m in pairs(ft)do if(m>=n)then return true end end else
	for m in pairs(ft)do
		if(m==x or m==n or (m>n and m<x))then return true else
			if(m>x)then a=true elseif(m<n)then b=true end
			if(a and b)then return true end
		end
	end
	return false
end end end


function logic.Fluid(fld,tmp) tmp=tmp or 15 return hand.fluids[fld] and hand.fluids[fld][tmp] end
function logic.Item(n) return logic.hand.items[n] end
function logic.Can(n,x,y) return (x and rando.CanFluid(n,x,y) or (rando.Item(n) or rando.CanFluid(n))) end


--[[ Energy Sources & CanDoStuff() functions ]]--
-- logic.CanFuel(energy_source)


logic.CanFuel=setmetatable({},{__call=function(t,n,...)
	if(istable(n))then
		local pv=n.pipe_connections and "fluid" or (n.type or "burner") -- apparently there's "fuel_category=chemical" in there but no type? wat
		return t[pv](n,...)
	elseif(n)then
		return t[n](...)
	end
	return true
end})
function logic.CanFuel.void() return hand.void end
function logic.CanFuel.heat(fuel) return hand.heat>=(fuel.default_temperature or fuel.min_working_temperature or 1) end
function logic.CanFuel.electric(fuel) return hand.power and hand.pole end
function logic.CanFuel.burner(fuel)
	local fcats=proto.FuelCategories(fuel) if(not fcats)then return table_size(hand.burner_cats)>0 end
	local c=false for k,v in pairs(fcats)do if(hand.burner_cats[v])then c=true break end end if(c)then logic.PushBurner(fuel) return true end
end

-- Fluidbox fueling - note of future temperature changes
-- logic.CanFuelFluidbox(entity.input_fluid_box)
function logic.CanFuelFluidbox(fbox,min,max)
	if(not hand.pipes)then return false end
	local ft=fbox.filter min=(fbox.minimum_temperature or min) max=(fbox.maximum_temperature or max)
	--if(not ft)then return logic.CanFluidTemperature(min) end
	return logic.CanFluid(ft,min,max)
end
function logic.CanFuel.fluid(fuel) if(fuel.pipe_connections)then return logic.CanFuelFluidbox(fuel) else return logic.CanFuelFluidbox(fuel.fluid_box,nil,fuel.maximum_temperature) end end



function logic.CanMineResource(c)
	local cat=c.category or "basic-solid"
	if(not hand.resource_cats[cat])then return false end -- can we mine it by hand or auto?
	local min=c.minable if(not min)then error(cat .. " type resource without a .minable?\n" .. serpent.block(c)) end
	if(min.required_fluid and ((not logic.Fluid(min.required_fluid)) or (istable(hand.fluid_drill) and not hand.fluid_drill[min.required_fluid])))then return false end -- do we have the fluids needed for the resource?
	return hand.resource_cats[cat] -- return automation level
end

function logic.ScanResource(c) -- Scans a resource and pushes results if we can mine it. Odds are this will be called without need for further handling.
	local lvl=logic.CanMineResource(c) if(not lvl)then return false end
	if((hand.resource_scan[proto.Name(c)] or -1)<lvl)then
		for k,vx in pairs(proto.Results(c.minable) or {})do local v=proto.Result(vx) if(v)then
			if(v.type=="item")then logic.PushItem(proto.RawItem(v.name),lvl,true) end
			if(v.type=="fluid")then logic.PushFluid(data.raw.fluid[v.name],v.temperature,lvl) end
		end end
		hand.resource_scan[proto.Name(c)]=lvl
	end
	return lvl
end
function logic.ScanResources() for k,v in pairs(proto.GetRawResources())do logic.ScanResource(v.proto) end end -- Scans all resources (trees and rocks cannot be automated) and try to add them to hand if we can mine it.

function logic.OnItemScanned(c) end -- placeholder/override/event/hook

function logic.ScanItem(c) -- Items produced by a parent item are immediately added to hand if it can be made/accessed. Ran automatically on an item being pushed.
	local s=hand.itemscan[c.name] or {} if(s==true)then return true end hand.itemscan[c.name]=s
	--if(logic.ShouldIgnore(c.name))then hand.itemscan[c.name]=true logic.OnItemScanned(c) return true end
	if(c.rocket_launch_product)then if(hand.rocket_silo)then
		if(not s.rocket_product)then s.rocket_product=true local item=proto.RawItem(proto.Result(c.rocket_launch_product).name) logic.PushItem(item,1,true) end
	else s.rocket_product=false end end

	if(true)then if(not s.fuelcats)then s.fuelcats=true for k,v in pairs(proto.FuelCategories(c) or {})do logic.PushFuelCat(v,1) end end else s.fuelcats=false end
	if(c.burnt_result)then if(not s.burnt_result)then s.burnt_result=true logic.PushItem(proto.RawItem(c.burnt_result),1,true) end end

	if(c.place_result)then if(not s.place_result)then s.place_result=true local ent=proto.PlaceResultEntity(c.place_result) if(ent)then logic.PushEntity(ent,true) end end end
	if(proto.GetLabPacks()[c.name])then
		if(hand.labslots[c.name])then s.labpack=true logic.PushLabPack(c) else s.labpack=false end
	else
		for k,v in pairs(data.raw.technology)do local ving=proto.TechBottles(v) for i,e in pairs(ving)do
			if(not proto.LabPack(e))then if(e==c.name)then s.labpack=true logic.PushLabPack(c) end end
		end end
	end

	for k,v in pairs(s)do if(v==false)then hand.itemscan[c.name]=s return false end end
	hand.itemscan[c.name]=true
	logic.OnItemScanned(c)
	return true
end
function logic.ScanItems() for k in pairs(hand.items)do if(hand.itemscan[k]~=true)then logic.ScanItem(proto.RawItem(k)) end end end

function logic.CanResearchTechnology(t) if(hand.techscan[t.name])then return true end
	local reqs=t.prerequisites if(reqs)then for k,v in pairs(reqs)do if(not hand.techscan[v])then return false end end end
	return true
end
function logic.CanAffordTechnology(t) if(hand.techscan[t.name])then return true end
	for k in pairs(proto.TechBottles(t))do if(not hand.labpacks[k])then return false end end
	return true
end
function logic.CanRecursiveAffordTechnology(t) if(hand.techscan[t.name])then return true end
	for k in pairs(proto.RecursiveTechBottles(t))do if(not hand.labpacks[k])then return false end end
	return true
end
function logic.ScanTechnology(t) if(hand.techscan[t.name])then return true end
	local fx=proto.TechEffects(t) if(fx.c>0)then for k,v in pairs(fx.recipes)do logic.PushRecipe(data.raw.recipe[v]) end end
	hand.techscan[t.name]=true
	return true
end
function logic.ScanTechnologies() for k in pairs(hand.techs)do local r=data.raw.technology[k] if(logic.CanResearchTechnology(r) and logic.CanRecursiveAffordTechnology(r))then logic.PushTechnology(r) logic.ScanTechnology(r) end end end

function logic.CanAffordRecipe(c) local ing=proto.Ingredients(c) if(not ing)then return true end
	local can=true for k,ig in pairs(ing)do local v=proto.Ingredient(ig)
		if(v.type~="fluid")then if(not hand.items[v.name])then can=false break end elseif(not logic.CanFluid(v.name,v.temperature))then can=false break end
	end return can
end

function logic.CanCraftRecipe(c) return hand.craft_cats[c.category or "crafting"] end -- Return automation level. 0=handcraft. 1=automated.
function logic.ScanRecipe(c,bscan) if(hand.recipescan[c.name])then return true end
	if(logic.ShouldIgnore(c.name))then hand.recipescan[c.name]=true return true end
	for k,v in pairs(proto.Results(c))do local x=proto.Result(v) logic.PushResult(x,hand.craft_cats[v.category or "crafting"] or 0,bscan) end
	hand.recipescan[c.name]=true
	return true
end
function logic.ScanRecipes(bscan) for k,v in pairs(hand.recipes)do logic.ScanRecipe(v,bscan) end end

--[[ Push Functions ]]--
-- Push stuff into the hand

function logic.PushRecipe(c) local n=proto.Name(c) if(not hand.recipes[n])then hand.recipes[n]=c logic.HandChanged("recipe",c) end end
function logic.PushTechnology(c) local n=proto.Name(c) if(not hand.techs[n])then hand.techs[n]=c logic.HandChanged("technology",c) end end
function logic.PushEntity(c,s) local n=proto.Name(c) if(not hand.ents[n])then hand.ents[n]=c if(s)then logic.ScanEntity(c) end logic.HandChanged("entity",c) end end
function logic.PushFluid(c,m) m=m or 15 local n=proto.Name(c) hand.fluids[n]=hand.fluids[n] or {} hand.fluids[n][m]=c logic.HandChanged("fluid",c,m) end


function logic.PushCraftCat(v,n) if(not hand.craft_cats[v] or (n and hand.craft_cats[v]<n))then hand.craft_cats[v]=n or 0 logic.HandChanged("craft_cats",v,n) end end
function logic.PushFuelCat(c,n) if(not hand.burner_cats[c] or (n and hand.burner_cats[c]<n))then hand.burner_cats[c]=n or 0 logic.HandChanged("burner_cats",c,n) end end
function logic.PushResourceCat(c,n) if(not hand.resource_cats[c] or (n and hand.resource_cats[c]<n))then hand.resource_cats[c]=n or 0 logic.HandChanged("resource_cats",c,n) end end
function logic.PushLabPack(c) local n=proto.Name(c) if(not hand.labpacks[n])then hand.labpacks[n]=c logic.HandChanged("labpacks",c) end end
function logic.PushLabSlot(n) if(not hand.labslots[n])then hand.labslots[n]=true logic.HandChanged("labslots",n) end end
function logic.PushItem(c,x,s) local n=proto.Name(c) if(not hand.items[n])then hand.items[n]=x or 0 if(s)then logic.ScanItem(c) end logic.HandChanged("item",c,x,s) end end

function logic.PushHeat(buffer) if(hand.heat<buffer.max_temperature)then hand.heat=buffer.max_temperature logic.HandChanged("heat",buffer) end end
function logic.PushBurner(fuel) local iv=fuel.burnt_inventory_size for k,v in pairs(proto.FuelCategories(fuel))do logic.PushFuelCat(v,iv) end end
function logic.PushFuel(fuel) if(fuel.type=="electric")then if(not hand.power)then hand.power=true logic.HandChanged("power") end elseif(fuel.type=="burner")then logic.PushBurner(fuel) end end

function logic.PushBurnable(c) if(not hand.burnables[c])then hand.burnables[c]=true logic.HandChanged() end end

function logic.PushResult(x,lvl,bscan)
	if(x.type~="fluid")then
		local item=proto.RawItem(x.name) if(item)then logic.PushItem(proto.RawItem(x.name),lvl,bscan) end
	else local fd=data.raw.fluid[x.name] logic.PushFluid(fd,x.temperature,lvl)
	end
end
function logic.PushResults(rz,lvl,bscan) if(rz)then for k,v in pairs(rz)do local x=proto.Result(v) logic.PushResult(x,lvl,bscan) end end end

--[[ Entity Functions ]]--
-- Do logic for specific entities, and determine whether we can use/fuel them and then update our hand accordingly.
-- Return true if we can do ALL the things, or false if we need to re-scan this entity


-- https://wiki.factorio.com/Prototype/Generator
logic.ent["generator"]={
scan=function(t) local f=t.burner or t.fluid_box if(f and logic.CanFuel(f))then return true end end,
push=function(t) logic.PushFuel(t.energy_source) end,
}

-- https://wiki.factorio.com/Prototype/Boiler
logic.ent["boiler"]={
scan=function(t) if(logic.CanFuel(t.energy_source) and logic.CanFuel(t.fluid_box or t.input_fluid_box))then return true end end,
push=function(t) local f=t.output_fluid_box.filter if(f)then logic.PushFluid(data.raw.fluid[f],t.target_temperature) end end,
}

-- https://wiki.factorio.com/Prototype/AssemblingMachine
logic.ent["assembling-machine"]={
scan=function(t) if(logic.CanFuel(t.energy_source))then return true end end,
push=function(t) for k,v in pairs(proto.CraftingCategories(t.crafting_categories))do logic.PushCraftCat(v,1) end end,
}

-- https://wiki.factorio.com/Prototype/Furnace
logic.ent["furnace"]={
scan=function(t) if(not t.energy_source or logic.CanFuel(t.energy_source))then return true end end,
push=function(t) for k,v in pairs(proto.CraftingCategories(t.crafting_categories))do logic.PushCraftCat(v,1) end end,
}

-- https://wiki.factorio.com/Prototype/Lab
logic.ent["lab"]={ -- Pushes labslots on scan, which can be partially completed.
scan=function(t) if(logic.CanFuel(t.energy_source))then return true end end,
push=function(t) for k,v in pairs(t.inputs)do logic.PushLabSlot(v) end end,
}

-- https://wiki.factorio.com/Prototype/MiningDrill
logic.ent["mining-drill"]={
scan=function(t) if(logic.CanFuel(t.energy_source))then local fbox=t.input_fluid_box if(fbox and not logic.CanFuel(fbox))then return false end return true end end,
push=function(t)
	local fb=t.input_fluid_box if(fb)then local fd=hand.fluid_drill if(fd~=true)then
		if(fbox.filter)then fd=fd or {} hand.fluid_drill=fd if(not fd[fbox.filter])then fd[fbox.filter]=true logic.HandChanged() end else hand.fluid_drill=true logic.HandChanged() end
	end end
	for k,v in pairs(t.resource_categories)do logic.PushResourceCat(v,1) end
	return true
end,
}

-- https://wiki.factorio.com/Prototype/Pipe
logic.ent["pipe"]={
scan=function(t) return true end,
push=function(t) if(not hand.pipes)then hand.pipes=true logic.HandChanged() end end,
}

-- https://wiki.factorio.com/Prototype/PipeToGround
logic.ent["pipe-to-ground"]={
scan=function(t) return true end,
push=function(t) if(not hand.pipe_to_ground)then hand.pipe_to_ground=true logic.HandChanged() end end,
}


-- https://wiki.factorio.com/Prototype/Inserter
logic.ent["inserter"]={
scan=function(t) if(logic.CanFuel(t.energy_source))then return true end end,
push=function(t) if(not hand.inserters)then hand.inserters=true logic.HandChanged() end end,
}

-- https://wiki.factorio.com/Prototype/ElectricPole
logic.ent["electric-pole"]={
scan=function(t) return true end,
push=function(t) if(not hand.pole)then hand.pole=true logic.HandChanged("pole") end end,
}


-- https://wiki.factorio.com/Prototype/RocketSilo
logic.ent["rocket-silo"]={
scan=function(t)
	if(logic.CanFuel(t.energy_source))then
		if(not t.fixed_recipe)then return true end
		local rcp=data.raw.recipe[t.fixed_recipe]
		if(logic.CanAffordRecipe(rcp))then return true end
	end
	return false
end,
push=function(t) for k,v in pairs(proto.CraftingCategories(t.crafting_categories))do logic.PushCraftCat(v,1) end
	hand.rocket_silo=true
	if(t.fixed_recipe)then logic.PushRecipe(data.raw.recipe[t.fixed_recipe],1) end
	logic.HandChanged()
end,
}
-- https://wiki.factorio.com/Prototype/Reactor
logic.ent["reactor"]={
scan=function(t) if(logic.CanFuel(t.energy_source))then return true end end,
push=function(t) logic.PushHeat(t.heat_buffer) end,
}

-- https://wiki.factorio.com/Prototype/TransportBelt
logic.ent["transport-belt"]={
scan=function(t) return true end,
push=function(t) if(not hand.belts)then hand.belts=true logic.HandChanged() end return true end,
}

-- https://wiki.factorio.com/Prototype/UndergroundBelt
logic.ent["underground-belt"]={
scan=function(t) return true end,
push=function(t) if(not hand.underground_belts)then hand.underground_belts=true logic.HandChanged() end end,
}

-- https://wiki.factorio.com/Prototype/Splitter
logic.ent["splitter"]={
scan=function(t) return true end,
push=function(t) if(not hand.splitters)then hand.splitters=true logic.HandChanged() end end,
}

-- https://wiki.factorio.com/Prototype/ResourceEntity -- unused

-- https://wiki.factorio.com/Prototype/OffshorePump
logic.ent["offshore-pump"]={
scan=function(t) return true end,
push=function(t) if(t.fluid)then logic.PushFluid(data.raw.fluid[t.fluid]) end end,
}

function logic.OnEntityScanned(ent) end -- hook
function logic.ScanEntity(t)
	if(logic.ShouldIgnore(t.name))then return true end
if(not hand.entscan[t.name])then local x=logic.ent[t.type]
	if(x)then local y=x.scan(t) if(y)then hand.entscan[t.name]=true x.push(t) logic.OnEntityScanned(t) logic.HandChanged() end return y
	else hand.entscan[t.name]=true logic.OnEntityScanned(t) logic.HandChanged() return true
	end
end end
function logic.ScanEntities() for k,v in pairs(hand.ents)do logic.ScanEntity(v) end end

function logic.ForcePushEntity(t) if(not hand.entscan[t.name])then hand.entscan[v.name]=true if(logic.ent[v.type])then logic.ent[v.type].push(v) end logic.HandChanged() end end
function logic.ForcePushEntities() for k,v in pairs(hand.ents)do logic.ForcePushEntity(v) end end

--[[ Initial recipes/resources/entities/etc ]]--
function logic.debug(s)
	local t={}
	for k,v in pairs(logic.hand)do if(not k:find("ent"))then t[k]=v end end

	local mis={}
	for k,v in pairs(data.raw.recipe)do if(not hand.recipescan[k])then mis[k]=v end end
	error("Logic Debug: " .. tostring(s) .. ":\nHAND:"..serpent.block(t) .. "\n----MISSING RECIPES----:\n"..serpent.block(mis))
end


function logic.InitScanResources() -- Push hand-minable autoplacements (trees, resources and rocks). Later scans should only check resources, trees cannot be automated.
	for k,v in pairs(proto.GetRaw())do local p=v.proto local min=p.minable if(min and not min.required_fluid)then local rz=proto.Results(min) if(rz)then
		local can=true for x,y in pairs(rz)do local rsz=proto.Result(y) if(rsz.type=="fluid")then can=false end end
		if(can)then logic.PushResults(rz,0,true) end
	end end end
end
function logic.InitScanCraftCats() -- Push hand-crafting categories
	for n,v in pairs(data.raw.character)do local cc=proto.CraftingCategories(v.crafting_categories)
		for k,x in pairs(cc)do logic.PushCraftCat(x,0) end
	end
end
function logic.InitScanResourceCats() -- Push the hand-minable resource category
	logic.PushResourceCat("basic-solid",0)
end
function logic.InitScanRecipes() -- Push recipes that are enabled/unlocked from the start
	for n,v in pairs(data.raw.recipe)do if((not proto.IsDisabled(v)) or hand.recipes[v.name])then logic.PushRecipe(v) end end --if(hand.craft_cats[v.category or "crafting"])then push() end
end
function logic.InitScanTechnologies() -- Push technologies that are enabled/researched from the start
	for n,v in pairs(data.raw.technology)do if(not proto.IsDisabled(v) and logic.CanAffordTechnology(v))then logic.PushTechnology(v) logic.ScanTechnology(v) end end
end

function logic.lua()
	logic.InitScanResourceCats()
	logic.InitScanCraftCats()
	logic.InitScanResources()
	logic.InitScanRecipes()
	logic.InitScanTechnologies()
	logic.loading=false
	--logic.debug()
end

function logic.Walk(fcond,fact,max_iter) local iter=0 max_iter=max_iter or 4000 -- Walk like a dinosaur. Return true in action to break early.
	while(iter<max_iter and fcond(iter))do if(fact(iter)==true)then break end iter=iter+1 end
	if(iter==max_iter)then logic.debug("Max Iterations: " .. iter .. " / " .. max_iter .. "\n") end
end


--[[ Hand Changed function ]]--
-- Something in our hand has changed. This is called on every individual push.

function logic.HandChanged()

end


return logic