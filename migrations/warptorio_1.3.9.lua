events.raise_load()
for k,v in pairs(global.Harvesters)do
	v:DestroyPointLogistics(1)
	v:DestroyPointLogistics(2)
	v:CheckTeleporterPairs()
end
game.print("Warptorio Migration 1.3.9")