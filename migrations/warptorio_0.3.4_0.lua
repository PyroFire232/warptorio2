
warptorio.OnLoad()
warptorio.Migrate()
if(global.warptorio)then
	local gwarptorio=global.warptorio
	warptorio.BuildPlatform()
	warptorio.BuildB1()
	warptorio.BuildB2()
	gwarptorio.Research.dualloader=math.min(gwarptorio.Research.dualloader or 0,1)
	for k,v in pairs(gwarptorio.Teleporters)do
		if(v.logs)then for i,w in pairs(v.logs)do w.destroy() end v.logs=nil v:SpawnLogistics() end
	end
end

game.print("Applied Warptorio Migration 0.3.4_0")