local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

if(g.Teleporters)then
for k,v in pairs(g.Teleporters)do v.loaderFilter={a={},b={}} end
end
if(g.Harvesters)then
for k,v in pairs(g.Harvesters)do v.loaderFilter={a={},b={}} end
end

end

game.print("Warptorio Migration 1.0.4")