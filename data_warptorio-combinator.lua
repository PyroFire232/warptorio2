local name="warptorio-combinator"
local entity = table.deepcopy( data.raw["constant-combinator"]["constant-combinator"] )
entity.name = name
entity.enabled=false
entity.minable.result = name
data:extend({entity})
