--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib_data.lua
Purpose: data library

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

--[[ Prototype/data stage libraries ]]--

local proto={}




--[[ Prototyping Data Stuff ]]--



-- All the different things an item can be
-- See also data.raw["item-subgroup"][k].name

proto.ItemGroups={"item","tool","gun","ammo","capsule","armor","repair-tool","car","module","locomotive","cargo-wagon","artillery-wagon","fluid-wagon","rail-planner","item-with-entity-data"}

-- All the different things an item can be place_result'd as
proto.PlacementGroups={
"accumulator","ammo-turret","arithmetic-combinator","artillery-turret","artillery-wagon","assembling-machine",
"beacon","boiler",
"car","cargo-wagon","character","constant-combinator","container",
"decider-combinator",
"electric-energy-interface","electric-turret","electric-pole",
"fluid-turret","fluid-wagon","furnace",
"gate","generator",
"heat-pipe",
"inserter",
"lab","loader","logistic-container","logistic-robot",
"mining-drill",
"offshore-pump",
"pipe","pipe-to-ground","power-switch","programmable-speaker","pump",
"radar","reactor","roboport","rocket-silo",
"simple-entity","simple-entity-with-force","simple-entity-with-owner","solar-panel","splitter","storage-tank",
"train-stop","transport-belt",
"underground-belt",
"wall",
}

function proto.Recache() proto._items=nil proto._placeables=nil proto._labpacks=nil proto._used=nil proto._furnacecat=nil end

function proto.CacheItems() local t={} for k,v in pairs(proto.ItemGroups)do for x,y in pairs(data.raw[v])do t[y.name]=y end end proto._items=t return t end
function proto.Items(b) return (proto._items and (not b and proto._items or proto.CacheItems()) or proto.CacheItems()) end
function proto.RawItem(n,b) return proto.Items(b)[n] end

function proto.CacheLabPacks() local tx={} for k,v in pairs(data.raw.lab)do local vin=v.inputs for i,e in pairs(vin)do tx[e]=e end end proto._labpacks=tx return tx end
function proto.GetLabPacks(b) return (proto._labpacks and (not b and proto._labpacks or proto.CacheLabPacks()) or proto.CacheLabPacks()) end
function proto.LabPack(n,b) return proto.GetLabPacks(b)[n] end

function proto.CachePlaceables() local t={} for k,v in pairs(proto.PlacementGroups)do for x,y in pairs(data.raw[v])do t[y.name]=y end end proto._placeables=t return t end
function proto.Placeables(b) return (proto._placeables and (not b and proto._placeables or proto.CachePlaceables()) or proto.CachePlaceables()) end
function proto.RawPlaceable(n,b) return proto.Placeables(b)[n] end -- place_result_entity
proto.PlaceResultEntity=proto.RawPlaceable --alias

function proto.CacheUsedRecipes() local t={}
	for k,v in pairs(data.raw.technology)do local fx=proto.TechEffects(v) for i,rcp in pairs(fx.recipes)do t[rcp]=true end end
	for k,v in pairs(data.raw.recipe)do if(proto.IsEnabled(v))then t[v.name]=true end end
proto._used=t return t end
function proto.UsedRecipes() return (proto._used and (not b and proto._used or proto.CacheUsedRecipes()) or proto.CacheUsedRecipes()) end
function proto.UsedRecipe(n,b) return proto.UsedRecipes(b)[n] end
function proto.CountUsedRecipes() return table_size(proto.UsedRecipes()) end
function proto.CountUnsedRecipes() return table_size(data.raw.recipe)-proto.CountUsedRecipes() end

function proto.IsAutoplaceControl(t) local dra=data.raw["autoplace-control"] if(dra[t.name] or dra[t.type] or (t.autoplace and t.autoplace.control))then return true end return false end

function proto.HasFluidbox(t) return t.fluid_box or t.fluid_boxes or t.input_fluid_box or t.output_fluid_box end

function proto.CacheFurnaceCats() local t={} for k,v in pairs(data.raw.furnace)do for cc in pairs(proto.CraftingCategories(v))do t[cc]=cc end end proto._furnacecat=t return t end
function proto.FurnaceCats(b) return (proto._furnacecat and (not b and proto._furnacecat or proto.CacheFurnaceCats()) or proto.CacheFurnaceCats()) end
function proto.FurnaceCat(n,b) return proto.FurnaceCats(b)[n] end

function proto.Name(t) return (isstring(t) and t or (t.name and t.name or (isstring(t[1]) and t[1] or false))) end

function proto.Fluids() return data.raw.fluid end
function proto.Recipes() return data.raw.recipe end
function proto.Techs() return data.raw.technology end

function proto.IsEnabled(v) local c=false
	if(tostring(v.enabled)=="true")then c=true end
	if(v.normal and tostring(v.normal.enabled)=="true")then c=true end
	if(v.expensive and tostring(v.expensive.enabled)=="true")then c=true end
	--if(v.enabled==nil and (not v.normal or v.normal and v.normal.enabled==nil) and (not v.expensive or v.expensive and v.expensive.enabled==nil))then return true end
	return c
end
function proto.IsDisabled(v) local c=false
	if(tostring(v.enabled)=="false")then c=true end
	if(v.normal and tostring(v.normal.enabled)=="false")then c=true end
	if(v.expensive and tostring(v.expensive.enabled)=="false")then c=true end
	--if(v.enabled==nil and (not v.normal or v.normal and v.normal.enabled==nil) and (not v.expensive or v.expensive and v.expensive.enabled==nil))then return true end
	return c
end

proto.IsTechnologyEnabled=proto.IsEnabled -- alias

function proto.IsHidden(v)
	if(tostring(v.hidden)=="true")then return true end
	if(v.normal and tostring(v.normal.hidden)=="true")then return true end
	if(v.expensive and tostring(v.expensive.hidden)=="true")then return true end
	return false
end



proto.Difficulties={[0]="standard",[1]="normal",[2]="expensive"}
function proto.Normal(t) local v=t if(t.normal)then v=t.normal elseif(t.expensive)then v=t.expensive end return v end
function proto.FetchDifficultyLayer(tx,seek)
	local t=tx if(t)then for k,v in pairs(seek)do if(t[v])then return t,0 end end end
	local t=tx.normal if(t)then for k,v in pairs(seek)do if(t[v])then return t,1 end end end
	local t=tx.expensive if(t)then for k,v in pairs(seek)do if(t[v])then return t,2 end end end
end

function proto.Result(t) if(t[1] and t[2])then return {type="item",name=t[1],amount=t[2]} else return t end end
function proto.Results(tx) local t,dfc=proto.FetchDifficultyLayer(tx,{"result","results"}) if(t)then if(t.results)then rs=t.results else rs={{t.result,t.result_count or 1}} end end return rs,dfc end
function proto.Ingredient(t) return proto.Result(t) end
function proto.Ingredients(tx) local t,dfc=proto.FetchDifficultyLayer(tx,{"ingredients"}) return (t and t.ingredients),dfc end

-- Fetch the raw item/object/etc
function proto.CraftingObject(rs) local raw=proto.RawItem(rs.name) return raw or data.raw.fluid[rs.name] end
function proto.ResultObject(t) local rs=proto.Result(t) return proto.CraftingObject(rs) end
function proto.IngredientObject(t) local rs=proto.Ingredient(t) return proto.CraftingObject(rs) end

function proto.TechBottles(tz) local t,dfc=proto.FetchDifficultyLayer(tz,{"unit"}) if(not t or not t.unit or not t.unit.ingredients)then return end
	local tx={} for k,v in pairs(t.unit.ingredients)do local rs=proto.Ingredient(v) tx[rs.name]=rs.name end return tx
end
function proto.LoopTech(n,p) p=p or {} p[n]=true local r=data.raw.technology[n] for k,v in pairs(r.prerequisites or {})do if(not p[v])then proto.LoopTech(v,p) end end return p end
function proto.RecursiveTechBottles(g) local t={} for n in pairs(proto.LoopTech(g.name))do local c,u=data.raw.technology[n] u=proto.TechBottles(c) for k,v in pairs(u)do t[v]=true end end return t end

function proto.TechEffects(g) local t={recipes={},items={},c=0} if(not g.effects)then return t end
	for k,v in pairs(g.effects)do local x=v.type if(x=="unlock-recipe")then table.insert(t.recipes,v.recipe) t.c=t.c+1 elseif(x=="give-item")then table.insert(x.items,v.item) t.c=t.c+1 end end
	return t
end

function proto.CraftingCategories(t) if(isstring(t))then return {t} end return t end
function proto.FuelCategories(t) local x
	if(t.fuel_category)then x={} table.insert(x,t.fuel_category) end
	if(t.fuel_categories)then x=x or {} for k,v in pairs(t.fuel_categories)do table.insertExclusive(x,v) end end
	return x
end

function proto.MinableResults(tx)
	return {}
end

function proto.GetRawAutoplacers(raw,vfunc) local t={} -- data.raw.resource,data.raw.tree vfunc(v) return true_is_valid end
	for n,rsc in pairs(raw)do if(rsc.minable and proto.IsAutoplaceControl(rsc) and (not vfunc or (vfunc and vfunc(rsc))) )then
		local rs=proto.Results(rsc.minable)
		if(rs)then for k,v in pairs(rs)do local rso=proto.ResultObject(v)
			if(not t[rso.name])then t[rso.name]={type=(rso.type~="fluid" and "item" or "fluid"),name=rso.name,proto=rsc} end
		end end
	end end
	return t
end
function proto.GetRawResources() return proto.GetRawAutoplacers(data.raw.resource) end
function proto.GetRawTrees() return proto.GetRawAutoplacers(data.raw.tree) end
function proto.GetRawRocks() return proto.GetRawAutoplacers(data.raw["simple-entity"],function(v) return v.count_as_rock_for_filtered_deconstruction end) end
function proto.GetRaw() local t={} for k,v in pairs({proto.GetRawResources(),proto.GetRawTrees(),proto.GetRawRocks()})do for i,e in pairs(v)do table.insertExclusive(t,e) end end return t end


function proto.Copy(a,b,x) local t=table.deepcopy(data.raw[a][b]) if(x)then table.deepmerge(t,x) end return t end

function proto.ExtendBlankEntityItems(ent)
	local rcp=proto.Copy("recipe","nuclear-reactor")
	rcp.enabled=false rcp.name=ent.name rcp.ingredients={{"steel-plate",1}} rcp.result=ent.name

	local item=proto.Copy("item","nuclear-reactor")
	item.name=ent.name item.place_result=ent.name
	data:extend{rcp,item}
end


proto.VanillaPacks={red="automation-science-pack",green="logistic-science-pack",blue="chemical-science-pack",black="military-science-pack",
	purple="production-science-pack",yellow="utility-science-pack",white="space-science-pack"}

function proto.SciencePacks(x) local t={} for k,v in pairs(x)do table.insert(t,{proto.VanillaPacks[k],v}) end return t end
function proto.ExtendTech(t,d,s) local x=table.merge(t,d) if(s)then x.unit.ingredients=proto.SciencePacks(s) end data:extend{x} return x end

function proto.Icons(p) if(p.icons)then return p.icons end if(p.icon)then return {{icon=p.icon,icon_size=p.icon_size}} end end

return proto