local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

if(g.floor and g.floor.b2)then for k,v in pairs(g.floor.b2.surface.find_entities_filtered{type="accumulator"})do v.destroy{raise_destroy=true} end end



if(g.Harvesters)then
	for k,v in pairs(g.Harvesters)do local self=v

		if(not v.loaderFilter)then v.loaderFilter={a={},b={}} end
		self.loaders=self.loaders or {a={},b={}} v.loaders.a=v.loaders.a or {} v.loaders.b=v.loaders.b or {}

		self.dir=self.dir or {} self.dir.a=self.dir.a or {} self.dir.b=self.dir.b or {} for i=1,6,1 do self.dir.a[i]=self.dir.a[i] or "input" self.dir.b[i]=self.dir.b[i] or "output" end
		local dpf,dpp
		if(v.deployed)then
			v:Recall()
			v:DestroyB()
		end
		if(game.forces.player.technologies["warptorio-logistics-1"].researched)then
			self:SpawnLogs()
		end
		v.next_size=v.next_size or g.floor.b3["harvest_"..v.name]
		v:Upgrade()

		warptorio.InsertCache("power",v.a) warptorio.InsertCache("power",v.b) v:DestroyCombos() v:CheckCombo()
	end
end


warptorio.MigrateTiles()



end
game.print("Warptorio Migration 1.0.7")