if(global.warptorio)then
warptorio.OnLoad()
warptorio.Migrate()
local g=global.warptorio
if(g.Teleporters)then
for k,v in pairs(g.Teleporters)do v.loaderFilter={a={},b={}} end
end
if(g.Harvesters)then
for k,v in pairs(g.Harvesters)do v.loaderFilter={a={},b={}} end
end

warptorio.MigrateTiles()
end
game.print("Warptorio Migration 1.0.3")