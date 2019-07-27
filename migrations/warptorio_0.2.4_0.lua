

warptorio.OnLoad()

local gwarptorio=global.warptorio
if(gwarptorio and gwarptorio.Teleporters and gwarptorio.Teleporters.b2)then setmetatable(gwarptorio.Teleporters.b2,warptorio.TeleporterMeta) gwarptorio.Teleporters.b2:Warpin() end

game.print("Applied Warptorio Migration 0.2.4_0")