
	--****
	--[[
if global.warp_reactor_logistic_research_level > 0 then	
	global.underground_level_1.upstairs.entities.chest_1 = global.underground_level_1.upstairs.entities.chest_in
	global.underground_level_1.upstairs.entities.chest_2 = global.underground_level_1.upstairs.entities.chest_out
	global.underground_level_1.downstairs.entities.chest_1 = global.underground_level_1.downstairs.entities.chest_in
	global.underground_level_1.downstairs.entities.chest_2 = global.underground_level_1.downstairs.entities.chest_out
	global.underground_level_2.upstairs.entities.chest_1 = global.underground_level_2.upstairs.entities.chest_in
	global.underground_level_2.upstairs.entities.chest_2 = global.underground_level_2.upstairs.entities.chest_out
	global.to_underground_entrance.entities.chest_1 = global.to_underground_entrance.entities.chest_in
	global.to_underground_entrance.entities.chest_2 = global.to_underground_entrance.entities.chest_out
	global.warp_teleporter_transport.entities.chest_1 = global.warp_teleporter_transport.entities.chest_in
	global.warp_teleporter_transport.entities.chest_2 = global.warp_teleporter_transport.entities.chest_out
	global.warp_teleporter_exit_transport.entities.chest_1 = global.warp_teleporter_exit_transport.entities.chest_in
	global.warp_teleporter_exit_transport.entities.chest_2 = global.warp_teleporter_exit_transport.entities.chest_out
end
]]--

		game.players[1].print("Warptorio migration script applied")