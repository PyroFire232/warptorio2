local g=global.warptorio
if(g and g.Teleporters)then
	warptorio.OnLoad()
	warptorio.Migrate()
	for k,v in pairs(g.Teleporters)do v:Clean() end
end
game.print("Warptorio Migration 0.9.4")