-- Mod: Limited World (1000x1000)
-- Description: Creates a normal Minetest world limited to a 1000x1000 node area, super optimized for near-instant load time and low server lag with admin bypass and surface-only spawning with 5+ air blocks and light level 15

-- Define the world boundaries (1000x1000 centered at 0,0)
local WORLD_MIN_X = -256
local WORLD_MAX_X = 256
local WORLD_MIN_Z = -256
local WORLD_MAX_Z = 256
local BARRIER_Y_MIN = -50
local BARRIER_Y_MAX = 50
local MIN_AIR_BLOCKS = 5 -- Minimum number of vertical air blocks required
local REQUIRED_LIGHT_LEVEL = 15 -- Required light level for spawn
local CHECK_INTERVAL = 2 -- Check boundaries every 2 seconds to reduce CPU usage

-- Ensure v7 mapgen is used for default terrain
minetest.set_mapgen_setting("mg_name", "v7", true)
minetest.set_mapgen_setting("chunksize", "5", true) -- Default chunk size (80 nodes)

-- Register an invisible, indestructible barrier node
minetest.register_node("limited_world:barrier", {
    description = "World Barrier",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = true, -- Overridden for admins
    pointable = false,
    diggable = false,
    buildable_to = false,
    drop = "",
    groups = {not_in_creative_inventory = 1},
    -- Override collision for admins
    collision_box = {
        type = "fixed",
        fixed = function(pos, node, player)
            if minetest.check_player_privs(player:get_player_name(), {privs = true}) then
                return nil -- No collision for admins
            else
                return {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5} -- Full collision for non-admins
            end
        end
    }
})

-- Cache content IDs for performance (after node registration)
local AIR_ID = minetest.get_content_id("air")
local BARRIER_ID = minetest.get_content_id("limited_world:barrier")

-- Function to check if a position has at least MIN_AIR_BLOCKS air blocks above a solid node and light level 15
local function has_enough_air_and_light(pos)
    local solid_nodes = {
        "minecraft:grass",
        "minecraft:dirt",
        "minecraft:stone",
        "minecraft:sand",
    }
    local node = minetest.get_node(pos)
    -- Check if the base node is solid
    for _, solid_node in ipairs(solid_nodes) do
        if node.name == solid_node then
            -- Check for MIN_AIR_BLOCKS air blocks above
            for y = pos.y + 1, pos.y + MIN_AIR_BLOCKS do
                local check_pos = {x = pos.x, y = y, z = pos.z}
                if minetest.get_node(check_pos).name ~= "air" then
                    return false
                end
            end
            -- Check light level at the spawn position (y + 1)
            local light_level = minetest.get_node_light({x = pos.x, y = pos.y + 1, z = pos.z}, 0.5) or 0
            if light_level == REQUIRED_LIGHT_LEVEL then
                return true
            end
        end
    end
    return false
end

-- Function to find a safe spawn point with at least 5 air blocks above and light level 15
local function find_spawn_pos()
    local center = {x = 0, z = 0}
    local y_max = BARRIER_Y_MAX
    local y_min = BARRIER_Y_MIN
    -- First try the center
    for y = y_max, y_min, -1 do
        local pos = {x = center.x, y = y, z = center.z}
        if has_enough_air_and_light(pos) then
            return {x = pos.x, y = pos.y + 1, z = pos.z}
        end
    end
    -- If center is not suitable, search nearby within world limits
    local search_radius = 5
    local step = 3 -- Smaller step for faster search
    for r = step, 50, step do -- Reduced search radius for performance
        for x = center.x - r, center.x + r, step do
            for z = center.z - r, center.z + r, step do
                -- Ensure within world limits
                if x >= WORLD_MIN_X and x <= WORLD_MAX_X and z >= WORLD_MIN_Z and z <= WORLD_MAX_Z then
                    for y = y_max, y_min, -1 do
                        local pos = {x = x, y = y, z = z}
                        if has_enough_air_and_light(pos) then
                            return {x = pos.x, y = pos.y + 1, z = pos.z}
                        end
                    end
                end
            end
        end
    end
    -- Fallback to center at y=2 if no suitable position found
    return {x = center.x, y = 2, z = center.z}
end

-- Prevent mapgen and clear nodes outside the 1000x1000 area
minetest.register_on_generated(function(minp, maxp, seed)
    -- Skip generation for chunks completely outside the 1000x1000 area
    if maxp.x < WORLD_MIN_X or minp.x > WORLD_MAX_X or
       maxp.z < WORLD_MIN_Z or minp.z > WORLD_MAX_Z then
        -- Set entire chunk to air
        local vm = minetest.get_voxel_manip()
        local emin, emax = vm:read_from_map(minp, maxp)
        local data = {}
        local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
        for i in area:iterp(emin, emax) do
            data[i] = AIR_ID
        end
        vm:set_data(data)
        vm:write_to_map()
        vm:update_map()
        return
    end

    -- Clear nodes outside the 1000x1000 area in partially overlapping chunks
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(minp, maxp)
    local data = vm:get_data()
    local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            if x < WORLD_MIN_X or x > WORLD_MAX_X or z < WORLD_MIN_Z or z > WORLD_MAX_Z then
                for y = minp.y, maxp.y do
                    local vi = area:index(x, y, z)
                    data[vi] = AIR_ID
                end
            end
        end
    end

    -- Place barrier nodes only at chunk edges
    for x = math.max(minp.x, WORLD_MIN_X - 1), math.min(maxp.x, WORLD_MAX_X + 1) do
        for z = math.max(minp.z, WORLD_MIN_Z - 1), math.min(maxp.z, WORLD_MAX_Z + 1) do
            if x == WORLD_MIN_X - 1 or x == WORLD_MAX_X + 1 or
               z == WORLD_MIN_Z - 1 or z == WORLD_MAX_Z + 1 then
                for y = BARRIER_Y_MIN, BARRIER_Y_MAX do
                    local vi = area:index(x, y, z)
                    data[vi] = BARRIER_ID
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map()
    vm:update_map()
end)

-- Teleport non-admin players back if they leave the area (optimized)
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < CHECK_INTERVAL then
        return
    end
    timer = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        -- Skip admins with privs privilege
        if not minetest.check_player_privs(player_name, {privs = true}) then
            local pos = player:get_pos()
            if pos.x < WORLD_MIN_X or pos.x > WORLD_MAX_X or
               pos.z < WORLD_MIN_Z or pos.z > WORLD_MAX_Z then
                -- Teleport to a safe spawn point
                player:set_pos(find_spawn_pos())
                minetest.chat_send_player(player_name,
                    "You have reached the world boundary and have been teleported back!")
            end
        end
    end
end)

-- Set spawn point to a safe surface position for new players
minetest.register_on_newplayer(function(player)
    player:set_pos(find_spawn_pos())
end)

-- Handle respawn to ensure players respawn on the surface within world limits
minetest.register_on_respawnplayer(function(player)
    player:set_pos(find_spawn_pos())
    return true -- Override default respawn behavior
end)
