minetest.register_node("zfz_nr:nether_reactor_core", {
    description = "Nether Reactor Core",
    tiles = {"nrc.png"}, -- Placeholder texture name
    groups = {cracky = 1, level = 2},
    sounds = minetest.get_modpath("default") and minetest.registered_nodes["default:dirt_with_grass"].sounds or nil,
    is_ground_content = false,
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local function get_node(p)
            return minetest.get_node_or_nil(p).name
        end
        local base_y = pos.y - 1
        local gold = "minecraft:gold_block"
        local cobble = "minecraft:cobble"
        local core = "zfz_nr:nether_reactor_core"
        -- Check bottom layer (Y-1)
        local corners = {
            {x=pos.x-1, y=base_y, z=pos.z-1},
            {x=pos.x+1, y=base_y, z=pos.z-1},
            {x=pos.x-1, y=base_y, z=pos.z+1},
            {x=pos.x+1, y=base_y, z=pos.z+1},
        }
        for _,p in ipairs(corners) do
            if get_node(p) ~= gold then
                minetest.chat_send_player(clicker:get_player_name(), "Structure incorrect: gold blocks missing at corners.")
                return
            end
        end
        -- Check cobble in other base spots
        local base_cobble = {
            {x=pos.x, y=base_y, z=pos.z-1},
            {x=pos.x-1, y=base_y, z=pos.z},
            {x=pos.x, y=base_y, z=pos.z},
            {x=pos.x+1, y=base_y, z=pos.z},
            {x=pos.x, y=base_y, z=pos.z+1},
        }
        for _,p in ipairs(base_cobble) do
            if get_node(p) ~= cobble then
                minetest.chat_send_player(clicker:get_player_name(), "Structure incorrect: cobblestone missing in base.")
                return
            end
        end
        -- Check middle layer (Y)
        local mid_air = {
            {x=pos.x-1, y=pos.y, z=pos.z},
            {x=pos.x+1, y=pos.y, z=pos.z},
            {x=pos.x, y=pos.y, z=pos.z-1},
            {x=pos.x, y=pos.y, z=pos.z+1},
        }
        for _,p in ipairs(mid_air) do
            if get_node(p) ~= "air" then
                minetest.chat_send_player(clicker:get_player_name(), "Structure incorrect: middle layer sides must be air (entry points).")
                return
            end
        end

        -- Check that the four corners of the middle layer are cobblestone
        local mid_corners = {
            {x=pos.x-1, y=pos.y, z=pos.z-1},
            {x=pos.x+1, y=pos.y, z=pos.z-1},
            {x=pos.x-1, y=pos.y, z=pos.z+1},
            {x=pos.x+1, y=pos.y, z=pos.z+1},
        }
        for _,p in ipairs(mid_corners) do
            if get_node(p) ~= cobble then
                minetest.chat_send_player(clicker:get_player_name(), "Structure incorrect: middle layer corners must be cobblestone.")
                return
            end
        end
        -- Check top layer (Y+1): cobble cross, air in corners
        local top_y = pos.y + 1
        local top_cobble = {
            {x=pos.x, y=top_y, z=pos.z},
            {x=pos.x-1, y=top_y, z=pos.z},
            {x=pos.x+1, y=top_y, z=pos.z},
            {x=pos.x, y=top_y, z=pos.z-1},
            {x=pos.x, y=top_y, z=pos.z+1},
        }
        for _,p in ipairs(top_cobble) do
            if get_node(p) ~= cobble then
                minetest.chat_send_player(clicker:get_player_name(), "Structure incorrect: cobblestone missing in top cross.")
                return
            end
        end
        local top_corners = {
            {x=pos.x-1, y=top_y, z=pos.z-1},
            {x=pos.x+1, y=top_y, z=pos.z-1},
            {x=pos.x-1, y=top_y, z=pos.z+1},
            {x=pos.x+1, y=top_y, z=pos.z+1},
        }
        for _,p in ipairs(top_corners) do
            if get_node(p) ~= "air" then
                minetest.chat_send_player(clicker:get_player_name(), "Structure incorrect: top corners must be air.")
                return
            end
        end
        -- Success! Activate reactor
        minetest.set_node(pos, {name="zfz_nr:inether_reactor_core"})
        minetest.chat_send_player(clicker:get_player_name(), "Nether Reactor Activated!")

        -- Create Nether Spire (faithful, with random holes)
        local spire_height = 15
        local spire_radius = 3
        local core_x, core_y, core_z = pos.x, pos.y + 2, pos.z
        math.randomseed(os.time())
        for y = 0, spire_height - 1 do
            for dx = -spire_radius, spire_radius do
                for dz = -spire_radius, spire_radius do
                    local dist = math.sqrt(dx*dx + dz*dz)
                    -- Make it roughly cylindrical, but keep corners
                    if dist <= spire_radius + 0.3 then
                        local px = core_x + dx
                        local py = core_y + y
                        local pz = core_z + dz
                        -- Solid base, more holes higher up
                        local hole_chance = 0
                        if y == 0 then
                            hole_chance = 0 -- solid base
                        elseif y < 4 then
                            hole_chance = 0.10
                        elseif y < 8 then
                            hole_chance = 0.20
                        else
                            hole_chance = 0.35
                        end
                        if math.random() > hole_chance then
                            minetest.set_node({x=px, y=py, z=pz}, {name="minecraft:obsidian"})
                        end
                    end
                end
            end
        end
    end,
})

minetest.register_node("zfz_nr:inether_reactor_core", {
    description = "Initialized Nether Reactor Core",
    tiles = {"nrc.png"}, -- Placeholder texture name
    groups = {cracky = 1, level = 2},
    sounds = minetest.get_modpath("default") and minetest.registered_nodes["default:dirt_with_grass"].sounds or nil,
    is_ground_content = false,
})

minetest.register_node("zfz_nr:fnether_reactor_core", {
    description = "Finished Nether Reactor Core",
    tiles = {"nrc.png"}, -- Placeholder texture name
    groups = {cracky = 1, level = 2},
    sounds = minetest.get_modpath("default") and minetest.registered_nodes["default:dirt_with_grass"].sounds or nil,
    is_ground_content = false,
})
