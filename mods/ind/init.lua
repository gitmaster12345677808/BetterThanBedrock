-- Ensure hudbars is loaded
if not minetest.get_modpath("hudbars") then
    minetest.log("error", "[move_healthbar] This mod requires hudbars to function!")
    return
end

-- Register on mod load to adjust HUD bar position
minetest.register_on_mods_loaded(function()
    -- Override hudbars settings for health bar position
    minetest.settings:set("hudbars_pos_left_x", "0.5") -- Default x position
    minetest.settings:set("hudbars_pos_right_x", "0.5") -- Default x position for right bars
    minetest.settings:set("hudbars_start_offset_left_x", "965") -- Move 965 pixels right
    minetest.settings:set("hudbars_start_offset_right_x", "965") -- Move 965 pixels right for zigzag mode
end)

-- Ensure all players' HUD bars are updated
minetest.register_on_joinplayer(function(player)
    if minetest.get_modpath("hudbars") then
        local hudbars = rawget(_G, "hb") -- Access hudbars API
        if hudbars then
            hudbars.refresh_hud(player) -- Refresh HUD to apply new position
        end
    end
end)
