local g=global.warptorio
if(g)then
	warptorio.OnLoad()
	warptorio.Migrate()
	for k,self in pairs(global.warptorio.Harvesters)do local v=self
		self.loaders={a={},b={}}
		self.dir={a={},b={}} for i=1,6,1 do self.dir.a[i]="input" self.dir.b[i]="output" end
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
	end

	warptorio.BuildB1()
end
game.print("Warptorio Migration 0.9.7")
