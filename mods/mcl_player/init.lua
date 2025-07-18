-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.
mcla_player = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

mcla_player.registered_player_models = { }

-- Local for speed.
local models = mcla_player.registered_player_models

function mcla_player.player_register_model(name, def)
	models[name] = def
end

-- Default player appearance
mcla_player.player_register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png", },
	animations = {
		-- Standard animations.
		stand		= {x=  0, y= 79},
		lay		= {x=162, y=166},
		walk		= {x=168, y=187},
		mine		= {x=189, y=198},
		walk_mine	= {x=200, y=219},
		sit		= {x= 81, y=160},
		sneak_stand	= {x=222, y=302},
		sneak_mine	= {x=346, y=366},
		sneak_walk	= {x=304, y=323},
		sneak_walk_mine	= {x=325, y=344},
		run_walk	= {x=440, y=460},
		run_walk_mine	= {x=461, y=481},
	},
})

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}
mcla_player.player_attached = {}

function mcla_player.player_get_animation(player)
	local name = player:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

-- Called when a player's appearance needs to be updated
function mcla_player.player_set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		player:set_properties({
			mesh = model_name,
			textures = player_textures[name] or model.textures,
			visual = "mesh",
			visual_size = model.visual_size or {x=1, y=1},
			damage_texture_modifier = "^[colorize:red:130",
		})
		mcla_player.player_set_animation(player, "stand")
	else
		player:set_properties({
			textures = { "player.png", "player_back.png", },
			visual = "upright_sprite",
		})
	end
	player_model[name] = model_name
end

function mcla_player.player_set_textures(player, textures, preview)
	local name = player:get_player_name()
	player_textures[name] = textures
	player:set_properties({textures = textures,})
	if preview then
		player:get_meta():set_string("mcla:preview", preview)
	end
end

function mcla_player.player_get_preview(player)
	local preview = player:get_meta():get_string("mcla:preview")
	if preview == nil or preview == "" then
		return "player.png"
	else
		return preview
	end
end

function mcla_player.get_player_formspec_model(player, x, y, w, h, fsname)
	local name = player:get_player_name()
	local model = player_model[name]
	local anim = models[model].animations[player_anim[name]]
	return "model[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. fsname .. ";" .. model .. ";" .. table.concat(player_textures[name], ",") .. ";0," .. 180 .. ";false;false;" .. anim.x .. "," .. anim.y .. "]"
end

function mcla_player.player_set_animation(player, anim_name, speed)
	local name = player:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	player_anim[name] = anim_name
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	mcla_player.player_attached[player:get_player_name()] = false
	mcla_player.player_set_model(player, "character.b3d")
	--player:set_local_animation({x=0, y=79}, {x=168, y=187}, {x=189, y=198}, {x=200, y=219}, 30)
	player:set_fov(86.1) -- see <https://minecraft.gamepedia.com/Options#Video_settings>>>>
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
end)

-- Localize for better performance.
local player_set_animation = mcla_player.player_set_animation
local player_attached = mcla_player.player_attached

-- Check each player and apply animations
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local model_name = player_model[name]
        local model = model_name and models[model_name]
        if model and not player_attached[name] then
            local controls = player:get_player_control()
            local velocity = player:get_velocity() -- Get player velocity
            local animation_speed_mod = model.animation_speed or 30

            -- Determine if the player is walking
            local walking = controls.up or controls.down or controls.left or controls.right

            -- Determine if the player is sneaking, and reduce animation speed if so
            if controls.sneak then
                animation_speed_mod = animation_speed_mod / 2
            end

            -- Check if player's head is in water
            local head_in_water = minetest.get_item_group(mcla_playerinfo[name].node_head, "water") ~= 0

            -- Check if player is sprinting (based on Mineclonia's sprint mechanic)
            local is_sprinting = controls.aux1 and not controls.sneak -- Assuming aux1 is sprint key

            -- Apply animations based on what the player is doing
            if player:get_hp() == 0 then
                player_set_animation(player, "lay", animation_speed_mod)
            elseif walking then
                if player_sneak[name] ~= controls.sneak then
                    player_anim[name] = nil
                    player_sneak[name] = controls.sneak
                end
                if controls.LMB and not controls.sneak and head_in_water and is_sprinting then
                    player_set_animation(player, "swim_walk_mine", animation_speed_mod)
                elseif not controls.sneak and head_in_water and is_sprinting then
                    player_set_animation(player, "swim_walk", animation_speed_mod)
                elseif is_sprinting and controls.LMB and not controls.sneak and not head_in_water then
                    player_set_animation(player, "run_walk_mine", animation_speed_mod)
                elseif controls.LMB and not controls.sneak then
                    player_set_animation(player, "walk_mine", animation_speed_mod)
                elseif controls.LMB and controls.sneak then
                    player_set_animation(player, "sneak_walk_mine", animation_speed_mod)
                elseif is_sprinting and not controls.sneak and not head_in_water then
                    player_set_animation(player, "run_walk", animation_speed_mod)
                elseif controls.sneak and not controls.LMB then
                    player_set_animation(player, "sneak_walk", animation_speed_mod)
                else
                    player_set_animation(player, "walk", animation_speed_mod)
                end
            elseif controls.LMB and not controls.sneak and head_in_water and is_sprinting then
                player_set_animation(player, "swim_mine", animation_speed_mod)
            elseif not controls.LMB and not controls.sneak and head_in_water and is_sprinting then
                player_set_animation(player, "swim_stand", animation_speed_mod)
            elseif controls.LMB and not controls.sneak then
                player_set_animation(player, "mine", animation_speed_mod)
            elseif controls.LMB and controls.sneak then
                player_set_animation(player, "sneak_mine", animation_speed_mod)
            elseif not controls.sneak and head_in_water and is_sprinting then
                player_set_animation(player, "swim_stand", animation_speed_mod)
            elseif not controls.sneak then
                player_set_animation(player, "stand", animation_speed_mod)
            else
                player_set_animation(player, "sneak_stand", animation_speed_mod)
            end
        end
    end
end)
