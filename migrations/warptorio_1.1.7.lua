local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

for k,v in pairs(g.floor)do
	v:CheckSpecial()
end


end
game.print("Warptorio Migration 1.1.7")