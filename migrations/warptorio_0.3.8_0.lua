warptorio.OnLoad()
if(global.warptorio)then
	local gwarptorio=global.warptorio
	local r=gwarptorio.Research["reactor"] or 0
	if(r>=6 and (not gwarptorio.warp_reactor or gwarptorio.warp_reactor==1))then
		local f=gwarptorio.Floors.main.f
		warptorio.cleanbbox(f,-3,-3,5,5)
		local e=gwarptorio.Floors.main.f.create_entity{name="warptorio-reactor",position={-1,-1},force=game.forces.player,player=game.players[1],raise_built=true}
		warptorio.cleanplayers(f,-3,-3,5,5)
		gwarptorio.warp_reactor=e
		e.minable=false
	end
end

game.print("Applied Warptorio Migration 0.3.8_0")