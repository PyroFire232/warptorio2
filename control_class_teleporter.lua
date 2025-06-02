function warptorio.GetPlatformTechLevel(nm)
	local tc = warptorio.platform.techs[nm]
	if (not tc) then return false end
	if (tc.level_range or tc.levels) then return research.level(tc.tech) else return research.has(tc.tech) end
end

function warptorio.GetPlatformTechAmount(nm)
	local tc = warptorio.platform.techs[nm]
	if (not tc) then return false end
	local lv = warptorio.GetPlatformTechLevel(nm) or 0
	if (tc.levels) then return tc.levels[lv] end
end

function warptorio.GetPlatformResearches() -- cache stuff
	if (warptorio.PlatformResearches) then return warptorio.PlatformResearches end
	warptorio.PlatformResearches = {}
	for vi, v in pairs(warptorio.platform.techs) do
		v.key = v.key or vi
		if (v.levels) then
			for k in pairs(v.levels) do warptorio.PlatformResearches[v.tech .. "-" .. k] = v end
		elseif (v.level_range) then
			for i = v.level_range[1], v.level_range[2] do warptorio.PlatformResearches[v.tech .. "-" .. i] = v end
		else
			warptorio.PlatformResearches[v.tech] = v
		end
	end
	return warptorio.PlatformResearches
end

function warptorio.GetPlatformResearch(nm) return warptorio.GetPlatformResearches()[nm] end

warptorio.ResearchEffects = {}


function warptorio.ResearchEffects.retile(floors)
	for k, v in pairs(floors) do warptorio.ConstructFloor(v, true) end
end

function warptorio.ResearchEffects.rehazard(floors)
	for k, v in pairs(floors) do warptorio.ConstructFloorHazard(v) end
end

function warptorio.ResearchEffects.unlock_teleporters(tpt)
	if (not istable(tpt)) then tpt = { tpt } end
	for i, nm in pairs(tpt) do
		local tpx = warptorio.platform.teleporters[nm]
		local gps = storage.Teleporters[nm]
		if (not gps) then
			--game.print("New teleporter: " .. tostring(nm))
			gps = new(warptorio.TeleporterMeta, tpx)
		end
		gps:CheckTeleporterPairs(true)
	end
end

function warptorio.ResearchEffects.unlock_rails(tpt)
	if (not istable(tpt)) then tpt = { tpt } end
	for i, nm in pairs(tpt) do
		local tpx = warptorio.platform.rails[nm]
		local gps = storage.Rails[nm]
		if (not gps) then
			--game.print("New Rails: " .. tostring(nm))
			gps = new(warptorio.RailMeta, tpx)
		end
		gps:DoMakes()
	end
end

function warptorio.ResearchEffects.harvesters(hvt)
	for i, nm in pairs(hvt) do
		local tpx = warptorio.platform.harvesters[nm]
		local gps = storage.Harvesters[nm]
		if (not gps) then
			gps = new(warptorio.HarvesterMeta, tpx)
		end
		gps:Upgrade()
	end
end

function warptorio.ResearchEffects.upgrade_energy(tgt)
	if (tgt == true) then
		for k, v in pairs(storage.Teleporters) do v:CheckTeleporterPairs(true) end
		for k, v in pairs(storage.Harvesters) do v:CheckTeleporterPairs(true) end
	else
		for k, v in pairs(tgt) do if (storage.Teleporters[v]) then storage.Teleporters[v]:CheckTeleporterPairs(true) end end
	end
end

function warptorio.ResearchEffects.upgrade_logistics(tgt)
	if (tgt == true) then
		for k, v in pairs(storage.Teleporters) do v:CheckTeleporterPairs(true) end
		for k, v in pairs(storage.Harvesters) do v:CheckTeleporterPairs(true) end
		for k, v in pairs(storage.Rails) do v:DoMakes() end
	else
		for k, v in pairs(tgt) do if (storage.Teleporters[v]) then storage.Teleporters[v]:CheckTeleporterPairs(true) end end
	end
end

function warptorio.ResearchEffects.do_combinators()
	for k, v in pairs(storage.Harvesters) do v:CheckCombo(true) end
end

function warptorio.ResearchEffects.special(spt)
	for k, v in pairs(spt) do warptorio.CheckPlatformSpecials(storage.floor[v]) end
end

function warptorio.ResearchEffects.reactor(b, lv)
	local m = storage.floor.main
	players.playsound("warp_in", m.host)
	for i = 1, 3, 1 do for x, ply in pairs(game.players) do ply.print { "warptorio_lore." .. lv .. "_" .. i } end end

	if (lv < 6) then storage.warp_auto_time = storage.warp_auto_time + 60 * 10 end

	if (lv >= 8) then warptorio.ResetHUD() end

	--warptorio.CheckPlatformSpecials(storage.floor.main)
end

function warptorio.ResearchEffects.ability(tgt)
	warptorio.ResetHUD()
end

function warptorio.ResearchEffects.unlock_homeworld()
	warptorio.ResetHUD()
end

function warptorio.ResearchEffects.unlock_toolbar()
	warptorio.ResetHUD()
end

function warptorio.DoResearchEffects(fx, lv)
	for k, v in pairs(fx) do
		if (warptorio.ResearchEffects[k]) then warptorio.ResearchEffects[k](v, lv) end
	end
end

function warptorio.ResearchFinished(ev)
	local rs = ev.research
	--game.print("researched_finished: " .. rs.name)
	local u = warptorio.GetPlatformResearch(rs.name)
	if (u) then
		local lv = warptorio.GetPlatformTechLevel(u.key) or 0
		--if(u.first_effect)then game.print("testing: " .. tostring(lv) .. " , " .. serpent.line(u)) end

		if (u.first_effect and (u.levels and (u.levels[0] and lv == 0 or lv == 1) or (u.level_range and lv == u.level_range[1]))) then
			warptorio.DoResearchEffects(u.first_effect, lv)
			--game.print("first effect")
		end
		if (u.effect) then warptorio.DoResearchEffects(u.effect, lv) end
		if (u.lv_effect) then
			local lvt = u.lv_effect[lv]
			if (lvt) then warptorio.DoResearchEffects(lvt, lv) end
		end
	end

	warptorio.ConstructHazards()
end

events.on_event(defines.events.on_research_finished, warptorio.ResearchFinished)


local platform = warptorio.platform

--[[ Warp Teleporters ]] --

local TELL = {}
TELL.__index = TELL
warptorio.TeleporterMeta = TELL
function TELL.__init(self, tbl, bHarvester)
	self.key = self.key or tbl.key
	--self.maxloader=(tbl.logs and 1 or 0)+(tbl.dualloader and 1 or 0)+(tbl.triloader and 1 or 0)
	--if(not tbl.prototype)then error(serpent.block(self)) end
	self.offloader = (tbl.prototype and 1 or 0)

	self.points = self.points or { {}, {} }
	self.chestcontents = self.chestcontents or { {}, {} }
	self.loaders = self.loaders or { {}, {} }
	self.pipes = self.pipes or { {}, {} }
	self.chests = self.chests or { {}, {} }
	if (not self.dir) then
		self.dir = { {}, {} }
		for i = 1, 6, 1 do
			self.dir[1][i] = "input"
			self.dir[2][i] = "output"
		end
	end
	self.loaderFilter = self.loaderFilter or { {}, {} }
	self.sprites = self.sprites or { {}, {} }
	self.sprite_arrows = self.sprite_arrows or { nil, nil }
	if (not bHarvester) then storage.Teleporters[self.key] = self end
end

function TELL:Data() return warptorio.platform.teleporters[self.key] end

function TELL:ValidA() return isvalid(self.points[1].ent) end

function TELL:ValidB() return isvalid(self.points[2].ent) end

function TELL:ConnectCircuit()
	local p = self.points
	if (self:ValidA() and self:ValidB()) then
		local red1 = p[1].ent.get_wire_connector(defines.wire_connector_id.circuit_red, true)
		local red2 = p[2].ent.get_wire_connector(defines.wire_connector_id.circuit_red, true)
		red1.connect_to(red2)
		local green1 = p[1].ent.get_wire_connector(defines.wire_connector_id.circuit_green, true)
		local green2 = p[2].ent.get_wire_connector(defines.wire_connector_id.circuit_green, true)
		green1.connect_to(green2)
	end
end

function TELL:CheckTeleporterPairs(bSound) -- Call updates and stuff. Automatically deals with logistics, upgrades and cleaning as-needed with good accuracy
	local tps = self:Data()
	if (tps.pair) then
		for i, t in pairs(tps.pair) do
			local pi = self.points[i]
			self:MakePointTeleporter(tps, i, t, (t.gate and isvalid(pi.ent)) and pi.ent.position or nil)
		end
	end
	local ca = cache.get_entity(self.points[1].ent)
	local cb = cache.get_entity(self.points[2].ent)
	if (ca and cb) then
		ca.teleport_dest = cb.host
		cb.teleport_dest = ca.host
	else
		if (ca) then ca.teleport_dest = nil end
		if (cb) then cb.teleport_dest = nil end
	end
	if (tps.circuit) then self:ConnectCircuit() end
end

--[[ Teleporter Logistics & Spawning Stuff ]] --

function TELL:DestroyPointTeleporter(i, rd)
	local e = self.points[i].ent
	if (isvalid(e)) then
		self.points[i].energy = e.energy
		entity.destroy(e, rd)
	end
	self:DestroyPointSprites(i)
end

function TELL:DestroyPointSprites(i)
	if (self.sprites and self.sprites[i]) then
		for k, v in pairs(self.sprites[i]) do
			if (v.valid) then
				v.destroy()
				self.sprites[i][k] = nil
			end
		end
	end
	if (self.sprite_arrows and self.sprite_arrows[i]) then
		if (self.sprite_arrows[i] ~= nil) then
			self.sprite_arrows[i].destroy()
			self.sprite_arrows[i] = nil
		end
	end
end

function TELL:CheckPointSprites(i)
	local tps = self:Data()
	local t = tps.pair[i]
	if (warptorio.setting("hide_sprites")) then
		self:DestroyPointSprites(i)
	else
		if (t.sprites) then self:MakePointSprites(tps, i, t.sprites) end
		if (t.sprite_arrow) then self:MakePointArrow(tps, i, t.sprite_arrow) end
	end
end

function TELL:MakePointTeleporter(tps, i, t, pos)
	local p = self.points[i]
	local f = storage.floor[t.floor].host
	local epos
	if (t.prototype) then
		local vproto = t.prototype
		if (tps.energy) then vproto = vproto .. "-" .. warptorio.GetPlatformTechLevel(tps.energy) end
		local e = p.ent
		if (isvalid(e)) then
			if (e.surface ~= f) then
				self:DestroyPointTeleporter(i)
				self:DestroyPointLogistics(i)
			elseif (e.name ~= vproto) then
				epos = e.position
				self:DestroyPointTeleporter(i)
			end
		end
		if (not isvalid(e)) then
			local vepos = epos or (pos or t.position)
			if (not vepos) then return end
			local vpos = ((t.gate and not epos) and f.find_non_colliding_position(vproto, vepos, 0, 1, true) or vepos)
			--error(serpent.line(vpos))
			local varea
			if (not t.gate) then
				varea = vector.square(vpos + vector(0.5, 0.5), vector(2, 2))
				vector.clean(f, varea)
			end
			e = entity.protect(entity.create(f, vproto, vpos), t.minable ~= nil and t.minable or false,
				t.destructible ~= nil and t.destructible or false)
			if (not t.gate) then vector.cleanplayers(f, varea) end
			p.ent = e
		end
		if (p.energy) then
			e.energy = e.energy + p.energy
			p.energy = nil
		end
		if (t.sprites) then self:MakePointSprites(tps, i, t.sprites) end
		if (t.sprite_arrow) then self:MakePointArrow(tps, i, t.sprite_arrow) end
	end
	if (epos or not t.gate) then self:CheckPointLogistics(i) end

	local ce = cache.force_entity(p.ent, "Teleporters", self.key, "points", i)
end

warptorio.arrowSprite = { sprite = "utility/medium_gui_arrow", target_offset = { 0.75, -0.75 }, x_scale = 0.5, y_scale = 0.5 }

function TELL:MakePointArrow(tps, i, arrow)
	local spid = self.sprite_arrows[i]
	if (spid and spid.valid) then return end
	local tp = self.points[i].ent
	local t = table.deepcopy(warptorio.arrowSprite)
	t.surface = tp.surface
	t.target = tp
	t.only_in_alt_mode = true
	t.render_layer = "higher-object-above"
	t.orientation = (arrow == "down" and 0.5 or 0)
	self.sprite_arrows[i] = rendering.draw_sprite(t)
end

function TELL:MakePointSprites(tps, i, sprites)
	for k, v in pairs(sprites) do
		local spid = self.sprites[i][k]
		if (not (spid and spid.valid)) then
			local tp = self.points[i].ent
			local t = table.deepcopy(v)
			t.surface = tp.surface
			t.target = tp
			t.only_in_alt_mode = true
			t.render_layer = "higher-object-under"
			self.sprites[i][k] = rendering.draw_sprite(t)
		end
	end
end

function TELL:GetLoaderDirection()
	local tps = self:Data()
	if (tps.dirsetting) then return warptorio.setting(tps.dirsetting) end
	return (tps.staticdir and tps.staticdir or (tps.top and warptorio.setting("loader_top") or warptorio.setting("loader_bottom"))) or
		"up"
end

function TELL:DestroyPointLogistics(o)
	if (self.chests) then
		for k, v in pairs(self.chests[o]) do
			self.chestcontents[o][k] = v.get_inventory(defines.inventory.chest).get_contents()
			entity.destroy(v)
			self.chests[o][k] = nil
		end
	end
	for k, v in pairs(self.loaders[o]) do
		if (v and isvalid(v)) then
			self.loaderFilter[o][k] = {}
			for i = 1, v.filter_slot_count, 1 do self.loaderFilter[o][k][i] = v.get_filter(i) end
			entity.destroy(v)
		end
		self.loaders[o][k] = nil
	end
	for k, v in pairs(self.pipes[o]) do
		entity.destroy(v)
		self.pipes[o][k] = nil
	end
end

function TELL:RemakeChestPair(o, k)
	local e = self.chests[o][k]
	local ex = warptorio.GetChest(self.dir[o][k])
	if (e and e.name ~= ex) then
		local v = entity.protect(entity.create(e.surface, ex, e.position), false, false)
		entity.copy.chest(e, v)
		entity.destroy(e)
		self.chests[o][k] = v
		if (self.dir[o][k] == "input") then entity.ChestRequestMode(v) end
		cache.get_raise_type("types", v.type, v, "Teleporters", self.key, "chests", o, k)
	end
end

function TELL:SwapLoaderChests(id)
	self:RemakeChestPair(1, id)
	self:RemakeChestPair(2, id)
end

function TELL:UpgradeChests() for i = 1, 6, 1 do self:SwapLoaderChests(i) end end

function TELL:GetTeleporterSize()
	local d = self:Data()
	return warptorio.GetTeleporterSize(d.logs, d.dualloader, d.triloader)
end

function TELL:GetLogisticsArea(o) return vector.square(o or self:Data().position, self:GetTeleporterSize()) end

function TELL:MakePointLoader(tps, i, id, ido, pos, f, belt, lddir, chesty, belty, vexdir)
	local offld = tps.pair[i].prototype and 1 or 0

	local v = self.loaders[i][id]
	if (isvalid(v) and v.name ~= belt) then v.destroy { raise_destroy = true } end
	if (not isvalid(v)) then
		local vpos = vector(pos) + vector((offld + ido) * vexdir, belty)
		local varea = vector.square(vpos + vector(0, 0.5), vector(1, 1))
		vector.clean(f, varea)
		v = entity.protect(entity.create(f, belt, vpos, lddir), false, false)
		vector.cleanplayers(f, varea)
		v.loader_type = self.dir[i][id]
		self.loaders[i][id] = v
		local inv = self.loaderFilter[i][id]
		if (inv) then for invx, invy in pairs(inv) do v.set_filter(invx, invy) end end
	end
	cache.force_entity(v, "Teleporters", self.key, "loaders", i, id)

	local v = self.chests[i][id]
	local chest = warptorio.GetChest(self.dir[i][id])
	if (isvalid(v) and v.name ~= chest) then
		self.chestcontents[i][id] = v.get_inventory(defines.inventory.chest).get_contents()
		v.destroy { raise_destroy = true }
	end
	if (not isvalid(v)) then
		local vpos = vector(pos) + vector((offld + ido) * vexdir, chesty)
		local varea = vector.square(vpos, vector(0.5, 0.5))
		vector.clean(f, varea)
		v = entity.protect(entity.create(f, chest, vpos), false, false)
		vector.cleanplayers(f, varea)
		self.chests[i][id] = v
		local inv = self.chestcontents[i][id]
		if (inv) then
			local cv = v.get_inventory(defines.inventory.chest)
			for x, y in pairs(inv) do cv.insert { name = y.name, count = y.count } end
			self.chestcontents[i][id] = nil
		end
		--if(v.type=="logistic-container")then entity.ChestRequestMode(r) end
	end
	cache.get_raise_type("types", v.type, v, "Teleporters", self.key, "chests", i, id)
end

function TELL:MakePointLoaders(tps, i, id, pos, f, belt, lddir, chesty, belty)
	if (not tps.oneside or tps.oneside == "right") then
		self:MakePointLoader(tps, i, id, id, pos, f, belt, lddir, chesty,
			belty, 1)
	end
	if (not tps.oneside or tps.oneside == "left") then
		self:MakePointLoader(tps, i, id + 3, id, pos, f, belt, lddir,
			chesty, belty, -1)
	end
end

function TELL:MakePointPipes(tps, i, id, pos, f, dist, vexdir, ido) -- TODO: Initial pipe dir & remember direction
	local pipe = "warptorio-logistics-pipe"
	local v = self.pipes[i][id]
	local vpos = vector(pos) + vector(dist * vexdir, 2 - ido)
	local pipedir = (vexdir == 1 and 3 or 6)
	if (isvalid(v) and (v.surface ~= f or v.position.x ~= vpos.x or v.position.y ~= vpos.y)) then
		pipedir = v.direction
		entity.destroy(v)
	end
	if (not isvalid(v)) then
		local varea = vector.square(vpos, vector(0.5, 0.5))
		vector.clean(f, varea)
		v = entity.protect(entity.create(f, pipe, vpos, pipedir * 2), false, false)
		vector.cleanplayers(f, varea)
		self.pipes[i][id] = v
	end

	cache.force_entity(v, "Teleporters", self.key, "pipes", i, id)
end

function TELL:CheckEmptyPipes()
	local ppr = {}
	for a, b in pairs(self.pipes) do for k, v in pairs(b) do if (isvalid(v) and table_size(v.neighbours[1]) >= 1) then ppr[k] = true end end end
	for a, b in pairs(self.pipes) do for k, v in pairs(b) do if (isvalid(v) and not ppr[k]) then v.clear_fluid_inside() end end end
end

function TELL:CheckPointLogistics(i, vxpos)
	local tps = self:Data()
	local t = tps.pair[i]
	if (not tps.logs and not tps.dualloader and not tps.triloader) then return end
	local belt = warptorio.GetBelt()
	local pos = vxpos or t.position + vector(0.5, 0.5)
	if (t.gate and not vxpos) then
		if (not isvalid(self.points[i].ent)) then return end
		pos = vector(self.points[i].ent.position)
	end
	local f = storage.floor[t.floor].host
	local offld = tps.pair[i].prototype and 1 or 0
	local lddir, chesty, belty
	if (self:GetLoaderDirection() == "up") then
		lddir = defines.direction.south
		chesty = -1
		belty = 0
	else
		lddir = defines.direction.north
		chesty = 1
		belty = -1
	end
	local ldl = 0
	local lvLogs = research.level("warptorio-logistics")
	if (tps.logs and lvLogs > 0) then ldl = ldl + 1 end
	if (tps.dualloader and research.has("warptorio-dualloader-1")) then ldl = ldl + 1 end
	if (tps.triloader and research.has("warptorio-triloader")) then ldl = ldl + 1 end
	local can = true
	if (t.gate) then -- check if placement area is clear
		local vsize = offld + ldl + (tps.dopipes and 1 or 0)
		local varea = vector.square(pos, vector(vsize * 2, 3))
		--		if(f.count_entities_filtered{area=varea,collision_mask={"object-layer"}} >1)then
		if (f.count_entities_filtered { area = varea, collision_mask = "object" } > 1) then
			--f.create_entity { name = "flying-text", position = pos, text = "Logistics blocked - Needs more space", color = { r = 1, g = 0.5, b = 0.5 } }
			game.print({ "warptorio.teleporter-blocked-error" })
			f.play_sound { path = "utility/cannot_build", position = pos }
			can = false
		end
	end
	if (can and ldl > 0) then
		for id = 1, ldl, 1 do
			self:MakePointLoaders(tps, i, id, pos, f, belt, lddir, chesty, belty)
		end
	end
	if (can and tps.dopipes and lvLogs > 0) then
		for id = 1, math.min(lvLogs, 3), 1 do -- pipes first, it removes the old ones
			if (not tps.oneside or tps.oneside == "right") then
				self:MakePointPipes(tps, i, id, pos, f, ldl + offld + 1,
					1, id)
			end
			if (not tps.oneside or tps.oneside == "left") then
				self:MakePointPipes(tps, i, id + 3, pos, f, ldl + offld +
					1, -1, id)
			end
		end
	end
end

--[[
function events.on_tick("logistics_teleporters",function(ev) for k,v in pairs(storage.Teleporters)do v:TickLogistics() end end end)

function TELL:TickLogistics()
	for k,v in pairs(self.chests[1])do if(isvalid(self.chests[2][k]))then
		if(self.dir[1][k]=="input")then warptorio.BalanceLogistics(v,self.chests[2][k]) else warptorio.BalanceLogistics(self.chests[2][k],v) end
	end end
	for k,v in pairs(self.pipes[1])do if(isvalid(self.pipes[2][k]))then
		warptorio.BalanceLogistics(v,self.pipes[2][k])
	end end
end]]
