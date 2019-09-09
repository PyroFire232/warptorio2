--[[ disabled in 0.8.8
if(global.warptorio)then
warptorio.OnLoad()
warptorio.Migrate()
local gwarptorio=global.warptorio

for k,v in pairs(gwarptorio.Teleporters)do
	if(v.name=="b1" or v.name=="nw" or v.name=="ne")then v.top=true end
	v:UpgradeLogistics()
end

end


game.print("Applied Warptorio Migration 0.5.5")
]]