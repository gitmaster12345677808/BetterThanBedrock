-- Mod: restrict_hotbar
-- Prevents scrolling to and using the last hotbar slot (slot 7)

-- Disable last slot usage and manage inventory
minetest.register_globalstep(function(dtime)
    -- Get all connected players
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local inv = player:get_inventory()
        local wielded_item = player:get_wielded_item()
        local hotbar = inv:get_list("main")
        
        -- Check if the wielded item corresponds to slot 7
        if hotbar and #hotbar >= 7 and inv:get_stack("main", 7):get_name() == wielded_item:get_name() and not wielded_item:is_empty() then
            -- Clear the wielded item to prevent usage
            player:set_wielded_item(ItemStack(""))
            minetest.chat_send_player(player_name, "The last hotbar slot is disabled!")
        end

        -- Move any item in slot 7 to an earlier slot
        if hotbar and #hotbar >= 7 then
            local last_slot_item = inv:get_stack("main", 7)
            if not last_slot_item:is_empty() then
                for i = 1, 6 do
                    if inv:get_stack("main", i):is_empty() then
                        inv:set_stack("main", i, last_slot_item)
                        inv:set_stack("main", 7, ItemStack(""))
                        minetest.chat_send_player(player_name, "The last hotbar slot cannot hold items!")
                        break
                    end
                end
            end
        end
    end
end)

-- Log mod initialization for debugging
minetest.log("action", "[restrict_hotbar] Mod loaded successfully")
