data:extend({
    {
        type = 'custom-input',
        name = 'adaptive-movement-speed-toggle-input',
        key_sequence = 'CONTROL + SPACE',
    },
    {
        type = 'shortcut',
        name = 'adaptive-movement-speed-toggle-shortcut',
        action = 'lua',
        toggleable = true,
        associated_control_input = 'adaptive-movement-speed-toggle-input',
        icon =
        {
            filename = '__adaptive_movement_speed__/graphics/shortcut-bar.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 1,
            flags = {'icon'}
        },
        icon =
        {
            filename = '__adaptive_movement_speed__/graphics/shortcut-bar.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 1,
            flags = {'icon'}
        },
        disabled_icon =
        {
            filename = '__adaptive_movement_speed__/graphics/shortcut-bar-disabled.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 1,
            flags = {'icon'}
        },
    }
})