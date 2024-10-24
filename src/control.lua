local -- Forward declarations
    reset_all_active_players,
    reset_active_player,
    register_on_tick_handler,
    on_tick,
    toggle_enabled,
    update_shortcut_bar

local is_tick_registered = false

reset_all_active_players = function ()
    storage.active_players = {}
    for _, player in pairs(game.players) do
        reset_active_player(player)
    end
end
reset_active_player = function (player)
    local global_settings = settings.global
    local player_settings = settings.get_player_settings(player)

    local is_active = global_settings['adaptive-movement-speed-global-enabled'].value and
        player_settings['adaptive-movement-speed-enabled'].value and
        player.connected

    if is_active then
        local maximum_speed = math.min(
            global_settings['adaptive-movement-speed-global-maximum-speed'].value,
            player_settings['adaptive-movement-speed-maximum-speed'].value
        )
        local base_speed = math.min(
            maximum_speed,
            player_settings['adaptive-movement-speed-base-speed'].value
        )
        local speed_up_rate = 1 / (player_settings['adaptive-movement-speed-speed-up-time'].value * 60)
        local cool_down_factor = math.pow(0.05, 1 / (player_settings['adaptive-movement-speed-cool-down-time'].value * 60))

        storage.active_players[player.index] = {
            player = player,
            progress = 0,

            base_speed = base_speed * 0.01,
            maximum_speed = maximum_speed * 0.01,
            speed_up_rate = speed_up_rate,
            cool_down_factor = cool_down_factor,
        }
    else
        storage.active_players[player.index] = nil
        if player.character then
            player.character_running_speed_modifier = 0
        end
    end

    update_shortcut_bar(player, player_settings)
end

on_tick = function (event)
    local global_settings = settings.global
    local disable_upon_taking_damage_ticks = math.floor(60 * global_settings['adaptive-movement-speed-global-disable-upon-taking-damage'].value + 0.5)
    for player_index, active_player in pairs(storage.active_players) do
        if not active_player.player then
            local new_player = game.get_player(player_index)
            if new_player then
                active_player.player = new_player
            else
                reset_all_active_players()
                register_on_tick_handler()
                return
            end
        end

        local character = active_player.player.character
        if character then
            if character.tick_of_last_damage + disable_upon_taking_damage_ticks >= event.tick then
                active_player.progress = 0
            elseif character.walking_state.walking then
                active_player.progress = math.min(
                    1,
                    active_player.progress + active_player.speed_up_rate
                )
            else
                active_player.progress = math.max(
                    0,
                    active_player.progress * active_player.cool_down_factor
                )
                if active_player.progress < 0.001 then
                    active_player.progress = 0
                end
            end

            character.character_running_speed_modifier =
                active_player.base_speed * (1 - active_player.progress) +
                active_player.maximum_speed * active_player.progress -
                1
        else
            active_player.progress = 0
        end
    end
end

register_on_tick_handler = function ()
    if next(storage.active_players) then
        if not is_tick_registered then
            is_tick_registered = true
            script.on_event(defines.events.on_tick, on_tick)
        end
    elseif is_tick_registered then
        is_tick_registered = false
        script.on_event(defines.events.on_tick, nil)
    end
end

toggle_enabled = function (player)
    local player_settings = settings.get_player_settings(player)
    player_settings['adaptive-movement-speed-enabled'] = {
        value = not player_settings['adaptive-movement-speed-enabled'].value
    }
end

update_shortcut_bar = function (player, player_settings)
    player_settings = player_settings or settings.get_player_settings(player)
    local globally_enabled = settings.global['adaptive-movement-speed-global-enabled'].value
    local is_enabled = globally_enabled and player_settings['adaptive-movement-speed-enabled'].value

    player.set_shortcut_toggled('adaptive-movement-speed-toggle-shortcut', is_enabled)
    player.set_shortcut_available('adaptive-movement-speed-toggle-shortcut', globally_enabled)
end

script.on_load(function ()
    register_on_tick_handler()
end)
script.on_init(function ()
    storage = {
         version = 1,
         -- Initialized by reset_all_active_players()
         active_players = false,
    }
    reset_all_active_players()
    register_on_tick_handler()
end)
script.on_configuration_changed(function ()
    reset_all_active_players()
    register_on_tick_handler()
end)
script.on_event(defines.events.on_runtime_mod_setting_changed, function (event)
    if event.setting:find('adaptive-movement-speed-', 1, true) ~= 1 then
        return
    end

    if event.setting_type == 'runtime-global' then
        reset_all_active_players()
        register_on_tick_handler()
        return
    end

    local changed_for_player = nil
    if event.player_index then
        changed_for_player = game.get_player(event.player_index)
    end

    if changed_for_player then
        reset_active_player(changed_for_player)
    else
        reset_all_active_players()
    end
    register_on_tick_handler()
end)

script.on_event(defines.events.on_player_created, function (event)
    log('player created')
    local player = game.get_player(event.player_index)
    if player then
        reset_active_player(player)
    else
        reset_all_active_players()
    end
    register_on_tick_handler()
end)
script.on_event(defines.events.on_player_removed, function (event)
    log('player removed')
    if storage.active_players[event.player_index] then
        storage.active_players[event.player_index] = nil
        register_on_tick_handler()
    end
end)

script.on_event(defines.events.on_player_joined_game, function (event)
    log('player joined game')
    local player = game.get_player(event.player_index)
    if player then
        reset_active_player(player)
    else
        reset_all_active_players()
    end
    register_on_tick_handler()
end)
script.on_event(defines.events.on_player_left_game, function (event)
    log('player left game')
    local player = game.get_player(event.player_index)
    if player then
        reset_active_player(player)
    else
        reset_all_active_players()
    end
    register_on_tick_handler()
end)

script.on_event('adaptive-movement-speed-toggle-input', function (event)
    local player = game.get_player(event.player_index)
    if player then
        toggle_enabled(player)
    end
end)

script.on_event(defines.events.on_lua_shortcut, function (event)
    if event.prototype_name ~= 'adaptive-movement-speed-toggle-shortcut' then return end
    local player = game.get_player(event.player_index)
    if player then
        toggle_enabled(player)
    end
end)
