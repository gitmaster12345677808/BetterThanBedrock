-- Minecraft-like Wield Size Mod for Minetest
-- Adjusts the wield scale of tools to match Minecraft's larger appearance

minetest.register_on_mods_loaded(function()
    -- Define the new wield scale to mimic Minecraft's larger tool appearance
    local new_wield_scale = {x=2, y=2, z=2}

    -- Iterate through all registered items
    for name, def in pairs(minetest.registered_items) do
        -- Check if the item is a tool (has tool_capabilities)
        if def.tool_capabilities then
            -- Override the item definition to update wield_scale
            minetest.override_item(name, {
                wield_scale = new_wield_scale
            })
        end
    end
end)
