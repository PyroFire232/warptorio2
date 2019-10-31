local g=global.warptorio
if(g)then
warptorio.OnLoad()
warptorio.Migrate()

warptorio.ResetGui()

warptorio.RebuildFloors()

end
game.print("Warptorio Migration 1.1.5")