events.raise_load()
for k,v in pairs(global.Harvesters)do
	v.recalling=false
	v:CheckTeleporterPairs()
end
game.print("Warptorio Migration 1.2.7")