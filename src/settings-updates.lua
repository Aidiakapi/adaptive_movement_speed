if type(data.raw['bool-setting']) == 'table' and data.raw['bool-setting']['qol-movement-speed-research-enabled'] then
    data.raw['bool-setting']['qol-movement-speed-research-enabled'].default_value = false
end