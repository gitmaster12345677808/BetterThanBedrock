-- Mod: spruce
-- Adds a spruce sapling that instantly grows into a spruce tree using spruce.mts schematic
-- and spawns spruce trees as decorations in the world

-- Check if a sapling can grow at the given position
local function can_grow(pos)
    local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
    if not node_under then
        minetest.log("error", "[spruce] Node under sapling not found at " .. minetest.pos_to_string(pos))
        return false
    end
    if minetest.get_item_group(node_under.name, "soil") == 0 then
        minetest.log("error", "[spruce] Sapling not placed on soil at " .. minetest.pos_to_string(pos))
        return false
    end
    local light_level = minetest.get_node_light(pos)
    if not light_level or light_level < 8 then
        minetest.log("error", "[spruce] Insufficient light level (" .. light_level .. ") at " .. minetest.pos_to_string(pos))
        return false
    end
    return true
end

-- Function to grow the spruce tree
local function grow_spruce(pos)
    if not can_grow(pos) then
        return
    end
    local modpath = minetest.get_modpath("spruce")
    if not modpath then
        minetest.log("error", "[spruce] Mod path not found!")
        return
    end
    local schematic = modpath .. "/schems/spruce.mts"
    -- Verify schematic file exists
    local file = io.open(schematic, "r")
    if not file then
        minetest.log("error", "[spruce] Schematic file not found: " .. schematic)
        return
    end
    file:close()
    -- Log and place the schematic
    minetest.log("action", "[spruce] A spruce sapling grows into a tree at " .. minetest.pos_to_string(pos))
    minetest.remove_node(pos)
    -- Adjust position to center the schematic (assuming spruce.mts is 5x5 base)
    pos.x = pos.x - 2
    pos.z = pos.z - 2
    minetest.place_schematic({x = pos.x, y = pos.y - 1, z = pos.z}, schematic, "random", nil, false)
end

-- Register the spruce sapling node
minetest.register_node("spruce:sapling", {
    description = "Spruce Sapling",
    drawtype = "plantlike",
    tiles = {"spruce_sapling.png"},
    inventory_image = "spruce_sapling.png",
    wield_image = "spruce_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    
    on_place = function(itemstack, placer, pointed_thing)
        -- Place the sapling node
        local success = minetest.item_place(itemstack, placer, pointed_thing)
        if success and pointed_thing.type == "node" then
            local pos = pointed_thing.above
            -- Immediately attempt to grow the tree
            grow_spruce(pos)
        end
        return success
    end,
})

-- Register craft recipe for the sapling
minetest.register_craft({
    output = "spruce:sapling",
    recipe = {
        {"", "default:leaves", ""},
        {"", "default:stick", ""},
        {"", "", ""}
    }
})

-- Register spruce tree decoration with debugging
local modpath = minetest.get_modpath("spruce")
if not modpath then
    minetest.log("error", "[spruce] Mod path not found for decorations!")
else
    local schematic = modpath .. "/schems/spruce.mts"
    local file = io.open(schematic, "r")
    if not file then
        minetest.log("error", "[spruce] Decoration schematic not found: " .. schematic)
    else
        file:close()
        minetest.log("info", "[spruce] Registering spruce tree decoration with schematic: " .. schematic)
        minetest.register_decoration({
            name = "spruce:tree",
            deco_type = "schematic",
            place_on = {"default:dirt_with_grass", "minecraft:1_grass"}, -- Add your game's grass node
            sidelen = 16,
            fill_ratio = 0.01, -- Increased for more frequent spawning
            biomes = {"spruce", "grasslands", "coniferous_forest"}, -- Add fallback biomes
            y_max = 31000,
            y_min = 1,
            schematic = schematic,
            flags = "place_center_x, place_center_z",
            rotation = "random",
        })
    end
end




-- Mod: spruce
-- Adds a spruce sapling that instantly grows into a spruce tree using spruce.mts schematic
-- and spawns spruce trees as decorations in the world

-- Check if a sapling can grow at the given position
local function can_grow(pos)
    local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
    if not node_under then
        minetest.log("error", "[spruce] Node under sapling not found at " .. minetest.pos_to_string(pos))
        return false
    end
    if minetest.get_item_group(node_under.name, "soil") == 0 then
        minetest.log("error", "[spruce] Sapling not placed on soil at " .. minetest.pos_to_string(pos))
        return false
    end
    local light_level = minetest.get_node_light(pos)
    if not light_level or light_level < 8 then
        minetest.log("error", "[spruce] Insufficient light level (" .. light_level .. ") at " .. minetest.pos_to_string(pos))
        return false
    end
    return true
end

-- Function to grow the spruce tree
local function grow_spruce(pos)
    if not can_grow(pos) then
        return
    end
    local modpath = minetest.get_modpath("spruce")
    if not modpath then
        minetest.log("error", "[spruce] Mod path not found!")
        return
    end
    local schematic = modpath .. "/schems/birch.mts"
    -- Verify schematic file exists
    local file = io.open(schematic, "r")
    if not file then
        minetest.log("error", "[spruce] Schematic file not found: " .. schematic)
        return
    end
    file:close()
    -- Log and place the schematic
    minetest.log("action", "[spruce] A spruce sapling grows into a tree at " .. minetest.pos_to_string(pos))
    minetest.remove_node(pos)
    -- Adjust position to center the schematic (assuming spruce.mts is 5x5 base)
    pos.x = pos.x - 2
    pos.z = pos.z - 2
    minetest.place_schematic({x = pos.x, y = pos.y - 1, z = pos.z}, schematic, "random", nil, false)
end

-- Register the spruce sapling node
minetest.register_node(":minecraft:birch_sapling", {
    description = "Birch Sapling",
    drawtype = "plantlike",
    tiles = {"spruce_sapling.png"},
    inventory_image = "spruce_sapling.png",
    wield_image = "spruce_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    
    on_place = function(itemstack, placer, pointed_thing)
        -- Place the sapling node
        local success = minetest.item_place(itemstack, placer, pointed_thing)
        if success and pointed_thing.type == "node" then
            local pos = pointed_thing.above
            -- Immediately attempt to grow the tree
            grow_spruce(pos)
        end
        return success
    end,
})

-- Register craft recipe for the sapling
minetest.register_craft({
    output = ":minecraft:birch_sapling",
    recipe = {
        {"", "default:leaves", ""},
        {"", "default:stick", ""},
        {"", "", ""}
    }
})

-- Register spruce tree decoration with debugging
local modpath = minetest.get_modpath("spruce")
if not modpath then
    minetest.log("error", "[spruce] Mod path not found for decorations!")
else
    local schematic = modpath .. "/schems/birch.mts"
    local file = io.open(schematic, "r")
    if not file then
        minetest.log("error", "[spruce] Decoration schematic not found: " .. schematic)
    else
        file:close()
        minetest.log("info", "[spruce] Registering spruce tree decoration with schematic: " .. schematic)
        minetest.register_decoration({
            name = ":minecraft:birch_tree",
            deco_type = "schematic",
            place_on = {"minecraft:grass"}, -- Add your game's grass node
            sidelen = 16,
            fill_ratio = 0.01, -- Increased for more frequent spawning
            biomes = {"grasslands"}, -- Add fallback biomes
            y_max = 31000,
            y_min = 1,
            schematic = schematic,
            flags = "place_center_x, place_center_z",
            rotation = "random",
        })
    end
end
