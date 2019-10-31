local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

for k,v in pairs(g.Harvesters)do
	v:Warpin()
end

for k,v in pairs(g.Teleporters)do
	v.sprites=v.sprites or {}
	v:CheckSprites()
end

end
game.print("Warptorio Migration 1.2.2")