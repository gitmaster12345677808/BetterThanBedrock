-- Mod to add /stuck command and an undroppable teleport item
local modname = "stuck_helper"

-- Function to find a safe position above the player
local function find_safe_position(pos)
    local max_height = 10000 -- Maximum height to check above the player
    local new_pos = {x = pos.x, y = pos.y, z = pos.z}
    
    for y = pos.y, pos.y + max_height do
        new_pos.y = y
        local node = minetest.get_node(new_pos)
        local node_above = minetest.get_node({x = new_pos.x, y = new_pos.y + 1, z = new_pos.z})
        
        -- Check if the position is air and has air above it (safe to stand)
        if node.name == "air" and node_above.name == "air" then
            -- Ensure the block below is solid for standing
            local node_below = minetest.get_node({x = new_pos.x, y = new_pos.y - 1, z = new_pos.z})
            if minetest.registered_nodes[node_below.name] and minetest.registered_nodes[node_below.name].walkable then
                new_pos.y = new_pos.y + 0.5 -- Adjust to stand on the block
                return new_pos
            end
        end
    end
    
    return nil -- No safe position found
end

-- Register the /stuck command
minetest.register_chatcommand("stuck", {
    description = "Teleports the player out of the ground to a safe position",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end
        
        local pos = player:get_pos()
        local safe_pos = find_safe_position(pos)
        
        if safe_pos then
            player:set_pos(safe_pos)
            return true, "Teleported to a safe position!"
        else
            return false, "No safe position found nearby!"
        end
    end,
})

-- Register the teleport stick item
minetest.register_tool("stuck_helper:teleport_stick", {
    description = "Teleport Stick\nRight-click to teleport out of the ground",
    inventory_image = "default_stick.png^[colorize:#00FF00:128", -- Green-tinted stick
    stack_max = 1, -- Only one stick per stack
    groups = {not_in_creative_inventory = 1, not_in_craft_guide = 1}, -- Prevent appearing in crafting guides
    on_drop = function(itemstack, dropper, pos)
        -- Prevent dropping the item
        return itemstack
    end,
    on_use = function(itemstack, user, pointed_thing)
        -- Same functionality as /stuck command
        if not user then
            return itemstack
        end
        local pos = user:get_pos()
        local safe_pos = find_safe_position(pos)
        
        if safe_pos then
            user:set_pos(safe_pos)
            minetest.chat_send_player(user:get_player_name(), "Teleported to a safe position!")
        else
            minetest.chat_send_player(user:get_player_name(), "No safe position found nearby!")
        end
        return itemstack
    end,
})

-- Give the teleport stick to players when they join
minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    if not inv:contains_item("main", "stuck_helper:teleport_stick") then
        inv:add_item("main", "stuck_helper:teleport_stick")
        minetest.chat_send_player(player:get_player_name(), "You received a Teleport Stick! Right-click to teleport out of the ground.")
    end
end)

-- Prevent the teleport stick from being crafted
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if itemstack:get_name() == "stuck_helper:teleport_stick" then
        return ItemStack("") -- Prevent crafting
    end
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
