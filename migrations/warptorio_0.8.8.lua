
if(global.warptorio)then
	local gwarptorio=global.warptorio local g=gwarptorio
	if(gwarptorio.Floors)then gwarptorio.floor=gwarptorio.Floors gwarptorio.Floors=nil
		for k,v in pairs(gwarptorio.floor)do
			local adx=0
			if((k=="main" or k=="b1" or k=="b2") and v.z)then v.z=v.z-1 if(v.z>40 and k=="main")then v.z=v.z+4 end end
			v.surface=v.f v.f=nil
			v.size=v.z v.z=nil
		end
	end
if(g.Teleporters)then for k,v in pairs(g.Teleporters)do v.loaderFilter={a={},b={}} end end
if(g.Harvesters)then for k,v in pairs(g.Harvesters)do v.loaderFilter={a={},b={}} end end

	warptorio.OnLoad()

	local ht
	if(gwarptorio.Teleporters)then
		ht={}
		local hasOffworld=game.forces.player.technologies["warptorio-teleporter-portal"].researched
		for k,v in pairs(gwarptorio.Teleporters)do if(k~="offworld" or (k=="offworld" and hasOffworld))then table.insert(ht,k) end
			if(v.logs)then for x,y in pairs(v.logs)do y.destroy() end end
			if(v.pipes)then for a,b in pairs(v.pipes)do for x,y in pairs(b)do y.destroy() end end end
			if(v.chests)then for a,b in pairs(v.chests)do for x,y in pairs(b)do y.destroy() end end end
			if(v.loaders)then for a,b in pairs(v.loaders)do for x,y in pairs(b)do y.destroy() end end end

			if(v.PointA and v.PointA.valid)then v.PointA.destroy() end
			if(v.PointB and v.PointB.valid)then v.PointB.destroy() end
		end
		gwarptorio.Teleporters={}
	end

	local rt={}
	if(gwarptorio.Rails)then
		rt={}
		for k,v in pairs(gwarptorio.Rails)do
			table.insert(rt,v.name)
		end
		for k,v in pairs(gwarptorio.floor.main.surface.find_entities_filtered{name="straight-rail"})do if(v.destructible==false)then v.destroy() end end

		gwarptorio.Rails={}
	end

	warptorio.OnLoad()
	warptorio.Migrate()

	warptorio.RebuildFloors()
	warptorio.CheckReactor()

	if(ht)then for k,v in pairs(ht)do warptorio.Teleporters[v]:Warpin() end end
	if(rt)then for k,v in pairs(rt)do warptorio.BuildRailCorner(v) end end


	if(research.has("warptorio-charting"))then local gf=gwarptorio.floor if(gf)then
		if(gf.b1)then gf.b1:CheckRadar() end
		if(gf.b2)then gf.b2:CheckRadar() end
		--if(gf.b3)then gf.b3:CheckRadar() end -- disabled for now ?
	end end


	for k,v in pairs(game.players)do if(v.valid and v.gui and v.gui.valid and v.gui.left.warptorio_frame)then v.gui.left.warptorio_frame.destroy() end end

	warptorio.ResetGui()

	--warptorio.MigrateTiles()

end

game.print("Warptorio Migration 0.8.8")