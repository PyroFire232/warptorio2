local g=global.warptorio
if(g and g.Teleporters)then
for k,v in pairs(g.Teleporters)do v.loaderFilter={a={},b={}} end
for k,v in pairs(g.Harvesters)do v.loaderFilter={a={},b={}} end
end

game.print("Warptorio Migration 1.0.4")