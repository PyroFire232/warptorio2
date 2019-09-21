local g=global.warptorio
if(g and g.Teleporters)then
	warptorio.OnLoad()
	warptorio.Migrate()
	local f=game.forces.player.technologies["warptorio-logistics-1"].researched
	if(f)then for k,v in pairs(g.Teleporters)do v:Clean() v:SpawnLogs() end end
end
if(g and g.Harvesters)then
	for k,v in pairs({"east","west"})do local x=g.Harvesters[v] if(x)then g.next_size=g.next_size or g.floor.b3["harvest_"..k] or 10 end end
end
game.print("Warptorio Migration 0.9.5")