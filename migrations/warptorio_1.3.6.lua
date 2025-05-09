events.raise_load()
for k,v in pairs(global.Teleporters)do
	v:CheckTeleporterPairs()
end
game.print("Warptorio Migration 1.3.6")