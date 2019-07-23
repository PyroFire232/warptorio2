game.print("Applying: Warptorio Migration 0.2.2_0")

if(not global.warptorio)then -- migrate from pre-0.2.2

warptorio.Initialize()
global.warptorio.time_spent_start_tick=game.tick

local cm=global.current_surface
if(cm)then
	local cp=game.surfaces[cm]
	local cf=game.surfaces["underground-level-1"]
	local cb=game.surfaces["underground-level-2"]

	local t=game.forces.player.technologies
	t["warptorio-platform-size-1"].researched=true
	t["warptorio-platform-size-2"].researched=true
	t["warptorio-platform-size-3"].researched=true
	t["warptorio-platform-size-4"].researched=true
	t["warptorio-platform-size-5"].researched=true
	warptorio.DoUpgrade{name="warptorio-platform-size-5",level=5}

	t["warptorio-factory-0"].researched=true
	warptorio.DoUpgrade{name="warptorio-factory-0",level=0}
	t["warptorio-factory-1"].researched=true
	t["warptorio-factory-2"].researched=true
	t["warptorio-factory-3"].researched=true
	t["warptorio-factory-4"].researched=true
	t["warptorio-factory-5"].researched=true
	t["warptorio-factory-6"].researched=true
	warptorio.DoUpgrade{name="warptorio-factory-6",level=6}

	t["warptorio-boiler-0"].researched=true
	warptorio.DoUpgrade{name="warptorio-boiler-0",level=0}
	t["warptorio-boiler-1"].researched=true
	t["warptorio-boiler-2"].researched=true
	t["warptorio-boiler-3"].researched=true
	t["warptorio-boiler-4"].researched=true
	t["warptorio-boiler-5"].researched=true
	t["warptorio-boiler-6"].researched=true
	warptorio.DoUpgrade{name="warptorio-boiler-6",level=6}

	t["warptorio-logistics-1"].researched=true
	warptorio.DoUpgrade{name="warptorio-logistics-1",level=1}


	local m=global.warptorio.Floors.main
	local df=m:GetSurface()
	local etbl=cp.find_entities_filtered{type="character",name={"loader","fast-loader","express-loader"},invert=true,area={{-96,-96},{96,96}}}
	local et={} for k,v in pairs(etbl)do if(v.last_user)then table.insert(et,v) end end
	cp.clone_entities{entities=et,destination_offset={0,0},destination_surface=df,destination_force=game.forces.player}
	for k,v in pairs(game.players)do if(v and v.valid and v.character)then warptorio.safeteleport(v.character,{0,0},df) end end

	local m=global.warptorio.Floors.b1
	local df=m:GetSurface()
	local etbl=cf.find_entities_filtered{type="character",name={"loader","fast-loader","express-loader"},invert=true,area={{-96,-96},{96,96}}}
	local et={} for k,v in pairs(etbl)do if(v.last_user)then table.insert(et,v) end end
	cf.clone_entities{entities=et,destination_offset={0,0},destination_surface=df,destination_force=game.forces.player}

	local m=global.warptorio.Floors.b2
	local df=m:GetSurface()
	local etbl=cb.find_entities_filtered{type="character",name={"loader","fast-loader","express-loader"},invert=true,area={{-96,-96},{96,96}}}
	local et={} for k,v in pairs(etbl)do if(v.last_user)then table.insert(et,v) end end
	cb.clone_entities{entities=et,destination_offset={0,0},destination_surface=df,destination_force=game.forces.player}
end global.current_surface=nil

if(mod_gui)then
for k,p in pairs(game.players)do
	local ui=mod_gui.get_frame_flow(p)
	if(ui and ui.valid)then
		local x=ui.warp if(x and x.valid)then x.destroy() end
		local x=ui.time_passed_label if(x and x.valid)then x.destroy() end
		local x=ui.time_left if(x and x.valid)then x.destroy() end
		local x=ui.number_of_warps_label if(x and x.valid)then x.destroy() end
	end
end
end

for k,p in pairs(game.players)do warptorio.BuildGui(p) end

for k,v in pairs(global.warptorio.Teleporters)do v:DestroyPointA() v:DestroyPointB() v:Warpin() end

end

local gwarptorio=global.warptorio
if(not gwarptorio.warp_last)then gwarptorio.warp_last=game.tick end


game.print("Finished: Warptorio Migration 0.2.2_0")