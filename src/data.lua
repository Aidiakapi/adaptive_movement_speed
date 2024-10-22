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
        icon = '__adaptive_movement_speed__/graphics/shortcut-bar.png',
        small_icon = '__adaptive_movement_speed__/graphics/shortcut-bar.png',
    }
})