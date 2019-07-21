data:extend(
{
    {
        type = "int-setting",
        name = "warptorio_warp_charge_factor",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 999999,
        order = "d",
    },	
	{
        type = "double-setting",
        name = "warptorio_warp_polution_factor",
        setting_type = "runtime-global",
        default_value = 1.01,
        minimum_value = 1.01,
        maximum_value = 2,
        order = "e",
    },
})