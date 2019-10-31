local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

if(g.Teleporters)then
	local r=game.forces.player.technologies["warptorio-logistics-1"].researched
	for k,v in pairs(g.Teleporters)do v.loaderFilter=v.loaderFilter or {a={},b={}} v.sprites=v.sprites or {} end
	for k,v in pairs(g.Teleporters)do v:Destroy() v:DestroyLogs() v:Clean(true) end
	for k,v in pairs(g.Teleporters)do v:Warpin() warptorio.InsertCache("power",v.a) warptorio.InsertCache("power",v.b) end
	for k,v in pairs(g.Teleporters)do if(r)then v:UpgradeLogistics() end end
	if(game.forces.player.technologies["warptorio-boiler-0"].researched)then
		warptorio.Teleporters.b3:Warpin()
	end
end

end
game.print("Warptorio Migration 1.1.1")