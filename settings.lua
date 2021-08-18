data:extend(
{

	{type="double-setting",name="warptorio_votewarp_multi",order="11b",
	setting_type="runtime-global",default_value=0.51,
	minimum_value=0,maximum_value=1},

	{type="bool-setting",name="warptorio_no_blueprint",order="1a",
	setting_type="runtime-global",default_value=false,},



	{type="bool-setting",name="warptorio_combinator_offset",order="1e",
	setting_type="runtime-global",default_value=false,},


	{type="string-setting",name="warptorio_loader_top",order="aaaa",
	setting_type="runtime-global",default_value="up",
	allowed_values={"up","down"}},

	{type="string-setting",name="warptorio_loader_bottom",order="aaab",
	setting_type="runtime-global",default_value="down",
	allowed_values={"up","down"}},

	{type="string-setting", name="warptorio_loaderchest_provider",order="aaac",
	setting_type="runtime-global", default_value="logistic-chest-active-provider",
	allowed_values={"logistic-chest-active-provider","logistic-chest-buffer","logistic-chest-passive-provider","logistic-chest-storage","steel-chest"},
	},

	{type="string-setting",name="warptorio_loaderchest_requester",order="aaad",
	setting_type="runtime-global",default_value="logistic-chest-requester",
	allowed_values={"logistic-chest-requester","logistic-chest-buffer","steel-chest"},
	},

	{type="bool-setting",name="warptorio_carebear",order="aab2a",
	setting_type="runtime-global",default_value=false},

	{type="int-setting",name="warptorio_warpchance",order="aab3a",
	setting_type="runtime-global",default_value=30,
	minimum_value=1,maximum_value=100},

	{type="double-setting",name="warptorio_solar_multiplier",order="aab4a",
	setting_type="runtime-global",default_value=0.5,
	minimum_value=0,maximum_value=10},

	{type="bool-setting",name="warptorio_no_lootchest",order="aab4c",
	setting_type="runtime-global",default_value=false,},


	{type="bool-setting",name="warptorio_autowarp_always",order="aaba",
	setting_type="runtime-global",default_value=false,},

	{type="bool-setting",name="warptorio_autowarp_disable",order="aabb",
	setting_type="runtime-global",default_value=false,},

	{type="double-setting",name="warptorio_autowarp_time",order="aabc",
	setting_type="runtime-global",default_value=20,
	minimum_value=10},



	{type="bool-setting",name="warptorio_water",order="aad",
	setting_type="runtime-global",default_value=false},

	{type="bool-setting",name="warptorio_robot_warping",order="aae",
	setting_type="runtime-global",default_value=false},

	{type="bool-setting",name="warptorio_biter_warping",order="aaf",
	setting_type="runtime-global",default_value=false},

	{type = "bool-setting", name = "warptorio_pollution_disable",order="abaa",
	setting_type = "runtime-global",default_value =false},

	{type = "int-setting", name = "warptorio_pollution_tickrate",order="abab",
	setting_type = "runtime-global",default_value = 3,
	minimum_value=1,maximum_value=30},

	{type = "double-setting", name = "warptorio_pollution_exponent",order="abba",
	setting_type = "runtime-global",default_value = 0.225,
	minimum_value = 0.01,maximum_value = 0.4},


	{type = "double-setting", name = "warptorio_pollution_multiplier",order="abbb",
	setting_type = "runtime-global",default_value = 0.75,
	minimum_value = 0.1,maximum_value = 4},


	{type = "bool-setting", name = "warptorio_biter_disable",order="abc",
	setting_type = "runtime-global",default_value =false},

	{type = "double-setting", name = "warptorio_biter_expansion",order="adab",
	setting_type = "runtime-global",default_value = 1.009,
	minimum_value = 1.0001,maximum_value = 2},

	{type = "double-setting", name = "warptorio_biter_redux",order="adb",
	setting_type = "runtime-global",default_value = 1,
	minimum_value = 0},

	{type = "double-setting", name = "warptorio_biter_min",order="adc",
	setting_type = "runtime-global",default_value = 5,
	minimum_value = 3},

	{type = "double-setting", name = "warptorio_biter_max",order="add",
	setting_type = "runtime-global",default_value = 15,
	minimum_value = 3},


	{type = "bool-setting", name = "warptorio_biter_wave_disable",order="aea1a",
	setting_type = "runtime-global",default_value =false},

	{type = "double-setting", name = "warptorio_biter_wavestart",order="aea1b",
	setting_type = "runtime-global",default_value = 5,
	minimum_value = 1,maximum_value=10},

	{type = "double-setting", name = "warptorio_biter_wavemin",order="aea2",
	setting_type = "runtime-global",default_value = 700,
	minimum_value = 10},

	{type = "double-setting", name = "warptorio_biter_wavemax",order="aeb",
	setting_type = "runtime-global",default_value = 7000,
	minimum_value = 10,},

	{type = "int-setting", name = "warptorio_biter_waverng",order="aec",
	setting_type = "runtime-global",default_value = 10,
	minimum_value = 1},

	{type = "int-setting", name = "warptorio_biter_wavesize",order="aed",
	setting_type = "runtime-global",default_value = 1,
	minimum_value = 1},

	{type = "int-setting", name = "warptorio_biter_wavesizemax",order="aee",
	setting_type = "runtime-global",default_value = 500,
	minimum_value = 0},



	{type="int-setting",name="warptorio_warpcharge_max",order="ca",
	setting_type="runtime-global",default_value=15,
	minimum_value=5,maximum_value=1000},

	{type="int-setting",name="warptorio_warpcharge_zone",order="cb",
	setting_type="runtime-global",default_value=70,
	minimum_value=5,maximum_value=1000},

	{type="int-setting",name="warptorio_warpcharge_zonegain",order="cc",
	setting_type="runtime-global",default_value=8,
	minimum_value=5,maximum_value=1000},


	{type="int-setting",name="warptorio_warp_charge_factor",order="cd",
	setting_type="runtime-global",default_value=70,
	minimum_value=1},

	{type="double-setting",name="warptorio_warpcharge_multi",order="ce",
	setting_type="runtime-global",default_value=0.5},


	{type="double-setting",name="warptorio_ability_cooldown",order="daa",
	setting_type="runtime-global",default_value=5,
	minimum_value=1,maximum_value=30},

	{type="double-setting",name="warptorio_ability_drain",order="dab",
	setting_type="runtime-global",default_value=0.00001,
	minimum_value=0.000000001,maximum_value=0.01},

	{type="double-setting",name="warptorio_ability_timegain",order="db",
	setting_type="runtime-global",default_value=2.5,
	minimum_value=1,maximum_value=30},

	{type="double-setting",name="warptorio_ability_warp",order="dc",
	setting_type="runtime-global",default_value=2,
	minimum_value=1,maximum_value=30},



	--[[ used in nauvis preset -- unused -- {type="int-setting",name="warptorio_nauvis_override",order="e1aa",
	setting_type="startup",default_value=12,
	minimum_value=1},]]


	--[[ {type="int-setting",name="warptorio_planet_void",order="em",
	setting_type="startup",default_value=1,
	minimum_value=0}, ]]

})