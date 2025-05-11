require("lib/lib")

local reqpth = "prototypes/"
--require("technology/warp-technology")
require("sound/sound")
require(reqpth .. "data_warptorio-heatpipe")
require(reqpth .. "data_warptorio-warpport")
require(reqpth .. "data_warptorio-logistics-pipe")
require(reqpth .. "data_warptorio-warpstation")
require(reqpth .. "data_warpnuke")
require(reqpth .. "data_warptorio-warploader")
require(reqpth .. "data_warptorio-townportal")
require(reqpth .. "data_warptorio-combinator")
require(reqpth .. "data_warptorio-warpspider")
--require("data_nauvis_preset")
--require("data_accumulators") -- This would be included here if it weren't for factorioextended ruining the accumulator tables >:|


require("data_warptorio")

lib.lua()
