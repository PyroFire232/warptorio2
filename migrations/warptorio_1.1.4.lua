local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

warptorio.ResetGui()

if(g.Harvesters)then

	for k,v in pairs(g.Harvesters)do v:Recall() end
	local f=g.floor.b3.surface.find_entities_filtered{name="warptorio-alt-combinator"}
	for k,v in pairs(f)do v.destroy() end

	warptorio.MigrateHarvesterFloor()
end
end
game.print("Warptorio Migration 1.1.4")