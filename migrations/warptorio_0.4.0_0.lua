
if(global.warptorio)then
warptorio.OnLoad()
warptorio.Migrate()
local gwarptorio=global.warptorio
if(gwarptorio.charting)then gwarptorio.Floors.b1:CheckRadar() gwarptorio.Floors.b2:CheckRadar() end


end

game.print("Applied Warptorio Migration 0.4.0")