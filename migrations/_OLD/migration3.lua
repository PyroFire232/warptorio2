
	--****

	
		global.time_spent_start_tick = 0
		global.time_passed = 0
		
		if global.warp_teleporter ~= nil then global.warp_teleporter_research_level = 1 else global.warp_teleporter_research_level = 0 end
		
	mod_gui.get_frame_flow(game.players[1]).add{type = "label", name = "time_passed_label", caption = {"time-passed-label", "-"}}	
	
		game.players[1].print("Warptorio migration script applied")