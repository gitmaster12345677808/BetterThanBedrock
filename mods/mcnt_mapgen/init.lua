minetest.register_biome({
	name = "grasslands",
	node_top = "minecraft:grass",
	depth_top = 1,
	node_filler = "minecraft:dirt",
	depth_filler = 3,
	node_riverbed = "minecraft:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 4,
	heat_point = 50,
	humidity_point = 12,
})

minetest.register_biome({
	name = "beach",
	node_top = "minecraft:sand",
	depth_top = 1,
	node_filler = "minecraft:sand",
	depth_filler = 2,
	node_riverbed = "minecraft:sand",
	depth_riverbed = 2,
	y_max = 4,
	y_min = -2,
	heat_point = 50,
	humidity_point = 35,
})

minetest.register_biome({
	name = "sea",
	node_top = "minecraft:dirt",
	depth_top = 1,
	node_filler = "minecraft:dirt",
	depth_filler = 2,
	y_max = -1,
	y_min = -50,
	heat_point = 50,
	humidity_point = 35,
})

-- Register the savanna biome
minetest.register_biome({
    name = "spruce",
    node_top = "minecraft:1_grass", -- Use the custom grass block
    depth_top = 1, -- 1 node deep for the grass layer
    node_filler = "minecraft:dirt", -- Dirt beneath the grass
    depth_filler = 3, -- 3 nodes deep for dirt
    node_stone = "minecraft:stone", -- Stone beneath dirt
    node_water = "minecraft:water_source", -- Default water
    node_river_water = "minecraft:water_source", -- Default river water
    y_min = 20, -- Start above sea level
    y_max = 31000, -- Up to max height
    heat_point = 60, -- Warm climate, typical for savanna
    humidity_point = 35, -- Moderately dry
})

-- Optional: Ensure biome generation by clearing existing biomes (use with caution)
-- minetest.clear_registered_biomes()
-- minetest.clear_registered_decorations()

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"minecraft:grass","minecraft:1_grass"},
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {"grasslands","spruce"},
	y_max = 200,
	y_min = 1,
	decoration = "minecraft:rose",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"minecraft:grass","minecraft:1_grass"},
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {"grasslands","spruce"},
	y_max = 200,
	y_min = 1,
	decoration = "minecraft:flower",
})
-- Spruce Trees Mod for Minetest
-- Generates spruce trees in the existing spruce biome using minecraft:1_leaves and minecraft:oak



dofile(minetest.get_modpath("mcnt_mapgen") .. "/bedrock.lua")
dofile(minetest.get_modpath("mcnt_mapgen") .. "/ores.lua")
