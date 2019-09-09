--[[ disabled in 0.8.8
if(global.warptorio)then
warptorio.OnLoad()
warptorio.Migrate()
local gwarptorio=global.warptorio

local r=game.forces.player.technologies["warptorio-boiler-water-1"]
if(r.researched==true and (not gwarptorio.waterboiler or gwarptorio.waterboiler<1))then gwarptorio.waterboiler=1 warptorio.BuildB2() end



end


game.print("Applied Warptorio Migration 0.6.5")
]]