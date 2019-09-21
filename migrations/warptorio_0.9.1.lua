local g=global.warptorio
if(g and g.Teleporters)then
	for k,v in pairs(g.Teleporters)do
		if(v.a and v.a.valid)then warptorio.InsertCache("power",v.a) end
		if(v.b and v.b.valid)then warptorio.InsertCache("power",v.b) end
	end
end
game.print("Warptorio Migration 0.9.1")