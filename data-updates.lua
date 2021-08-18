--[[

Add research for mod loaders

]]



--[[

Add emissions to all entities

]]

local reqpth="prototypes-updates/"
require(reqpth.."data_accumulators") -- include accumulator data AFTER factorioextended ruins the data.raw.accumulator tables, so that it doesn't break our mcnuggets.
require(reqpth.."data_warptorio-harvester") -- include accumulator data AFTER factorioextended ruins the data.raw.accumulator tables, so that it doesn't break our mcnuggets.


local entTbl={
"accumulator",
"ammo-turret",
"arithmetic-combinator",
"artillery-turret",
--"artillery-wagon",
"assembling-machine",
"beacon",
"boiler",
--"car",
--"cargo-wagon",
--"character",
"constant-combinator",
"container",
"decider-combinator",
--"electric-energy-interface",
"electric-turret",
"fluid-turret",
--"fluid-wagon",
"furnace",
"gate",
"generator",
"heat-pipe",
"inserter",
"lab",
"loader",
--"locomotive",
"logistic-container",
"logistic-robot",
"mining-drill",
--"pipe",
--"pipe-to-ground",
"power-switch",
"programmable-speaker",
--"pump",
"radar",
"reactor",
"roboport",
"rocket-silo",
--"simple-entity",
--"simple-entity-with-force",
--"simple-entity-with-owner",
"solar-panel",
"splitter",
"storage-tank",
--"train-stop",
"transport-belt",
"underground-belt",
"wall",
}


local entIgnore={
"big-electric-pole",
}


local s=""
for u,n in pairs(entTbl)do
	for k,v in pairs(data.raw[n])do
		if(v.name~="big-electric-pole" and not v.emissions_per_second and not v.emissions_per_tick)then
			s=s .. "Added: " .. v.name
			v.emissions_per_second=0.000005
			if(not v.energy_source)then v.energy_source={type="void",drain="100kW"} end
			if(v.energy_source and (not v.energy_source.emissions_per_minute or v.energy_source.emissions_per_minute==0))then
				s = s .. " & emissions"
				v.energy_source.emissions_per_minute=0.0005
			end
			s=s .. "\n"
		end
	end
end
--error(s)

