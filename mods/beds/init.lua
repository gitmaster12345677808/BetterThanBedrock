beds = {}
beds.player = {}
beds.pos = {}
beds.spawn = {}

local is_sp = minetest.is_singleplayer() or false
local player_in_bed = 0
local form = "size[8,15;true]" ..
    "bgcolor[#080808BB; true]" ..
    "button_exit[2,12;4,0.75;leave;Leave Bed]"

-- Helper function to calculate the yaw (rotation) of the player based on the bed's orientation
local function get_look_yaw(pos)
    local n = minetest.get_node(pos)
    if n.param2 == 1 then
        return 7.9, n.param2
    elseif n.param2 == 3 then
        return 4.75, n.param2
    elseif n.param2 == 0 then
        return 3.15, n.param2
    else
        return 6.28, n.param2
    end
end

-- Check if all players are in bed
local function check_in_beds(players)
    local in_bed = beds.player
    if not players then
        players = minetest.get_connected_players()
    end

    for n, player in ipairs(players) do
        local name = player:get_player_name()
        if not in_bed[name] then
            return false
        end
    end

    return true
end

-- Handle laying down or standing up based on the state
local function lay_down(player, pos, bed_pos, state)
    local name = player:get_player_name()
    local hud_flags = player:hud_get_flags()

    if not player or not name then
        return
    end

    -- Stand up
    if state ~= nil and not state then
        local p = beds.pos[name] or nil
        if beds.player[name] ~= nil then
            beds.player[name] = nil
            player_in_bed = player_in_bed - 1
        end
        if p then
            player:setpos(p)
        end

        -- Reset physics and eye offset
        player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
        player:set_look_yaw(math.random(1, 180) / 100)
        player:set_physics_override({speed = 1, jump = 1, gravity = 1})

        -- Update HUD and animations (no dependency on 'default')
        hud_flags.wielditem = true
        -- Custom animation handling if needed (optional)
        -- player:set_animation("stand", 30)

    -- Lay down
    else
        beds.player[name] = 1
        beds.pos[name] = pos
        player_in_bed = player_in_bed + 1

        -- Set physics, eye offset, etc., for lying down
        player:set_eye_offset({x = 0, y = -13, z = 0}, {x = 0, y = 0, z = 0})
        local yaw, param2 = get_look_yaw(bed_pos)
        player:set_look_yaw(yaw)
        local dir = minetest.facedir_to_dir(param2)
        local p = {x = bed_pos.x + dir.x / 2, y = bed_pos.y, z = bed_pos.z + dir.z / 2}
        player:set_physics_override({speed = 0, jump = 0, gravity = 0})
        player:setpos(p)

        -- Update HUD and animations for laying down
        hud_flags.wielditem = false
        -- Custom animation handling if needed (optional)
        -- player:set_animation("lay", 0)
    end

    -- Update the player's HUD flags
    player:hud_set_flags(hud_flags)
end

-- Update the formspec that shows the number of players in bed
local function update_formspecs(finished)
    local ges = #minetest.get_connected_players()
    local form_n = ""
    local is_majority = (ges / 2) < player_in_bed

    if finished then
        form_n = form ..
            "label[2.7,11; Good morning.]"
    else
        form_n = form ..
            "label[2.2,11;" .. tostring(player_in_bed) .. " of " .. tostring(ges) .. " players are in bed]"
        if is_majority then
            form_n = form_n ..
                "button_exit[2,8;4,0.75;force;Force night skip]"
        end
    end

    -- Show formspec to players
    for name, _ in pairs(beds.player) do
        minetest.show_formspec(name, "beds_form", form_n)
    end
end

-- Public functions
function beds.kick_players()
    for name, _ in pairs(beds.player) do
        local player = minetest.get_player_by_name(name)
        lay_down(player, nil, nil, false)
    end
end

function beds.skip_night()
    minetest.set_timeofday(0.23)
    beds.set_spawns()
end

function beds.on_rightclick(pos, player)
    local name = player:get_player_name()
    local ppos = player:getpos()
    local tod = minetest.get_timeofday()

    if tod > 0.2 and tod < 0.805 then
        if beds.player[name] then
            lay_down(player, nil, nil, false)
        end
        minetest.chat_send_player(name, "You can only sleep at night.")
        return
    end

    -- Move to bed
    if not beds.player[name] then
        lay_down(player, ppos, pos)
    else
        lay_down(player, nil, nil, false)
    end

    if not is_sp then
        update_formspecs(false)
    end

    -- Skip the night and let all stand up
    if check_in_beds() then
        minetest.after(2, function()
            beds.skip_night()
            if not is_sp then
                update_formspecs(true)
            end
            beds.kick_players()
        end)
    end
end

-- Callbacks
minetest.register_on_joinplayer(function(player)
    beds.read_spawns()
end)

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local pos = beds.spawn[name] or nil
    if pos then
        player:setpos(pos)
        return true
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    lay_down(player, nil, nil, false)
    beds.player[name] = nil
    if check_in_beds() then
        minetest.after(2, function()
            beds.skip_night()
            update_formspecs(true)
            beds.kick_players()
        end)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "beds_form" then
        return
    end
    if fields.quit or fields.leave then
        lay_down(player, nil, nil, false)
        update_formspecs(false)
    end

    if fields.force then
        beds.skip_night()
        update_formspecs(true)
        beds.kick_players()
    end
end)

-- Nodes and respawn functions (if needed)
dofile(minetest.get_modpath("beds") .. "/nodes.lua")
dofile(minetest.get_modpath("beds") .. "/spawns.lua")

