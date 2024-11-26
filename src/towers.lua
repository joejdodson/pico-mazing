-- CONSTANTS
POPUP_MENU_WIDTH = 56
POPUP_MENU_HEIGHT = 26
POPUP_MENU_TOWER_STATS = 4
POPUP_MENU_TOWER_STAT_SEP = 7
MAX_TOWER_RANGE = 5 * CELL_SIZE
MIN_TOWER_RANGE = 1 * CELL_SIZE
MAX_TOWER_POWER = 8
MIN_TOWER_ATTACK_SPEED = 20 / 3
MAX_TOWER_ATTACK_SPEED = 80
SCALE_TOWER_ATTACK_SPEED = (MAX_TOWER_ATTACK_SPEED - MIN_TOWER_ATTACK_SPEED)


-- Variables
tower_menu_index = 1
towers = {}
tower_menu_shake = 0
tower_menu_open_delay = 0

-- Tower Update Functions
function update_towers()
    -- Don't aquire targets until units have finished spawning
    -- Unless it's a chicken
    if wave_units_to_spawn > 0 and wave_spawning_unit_type.name ~= 'Chicken' then
        return
    end

    for _, tower in pairs(towers) do
        if tower.cooldown > 0 then
            tower.cooldown -= 1
        end

        if tower.cooldown <= 0 then
            if tower.target_unit == nil or tower.target_unit.health <= 0 then
                tower.target_unit = find_nearest_unit_in_range(tower)
            elseif tower_distance_to_unit(tower, tower.target_unit) > tower.type.attack_range then
                tower.target_unit = find_nearest_unit_in_range(tower)
            end

            if tower.target_unit ~= nil then
                -- printh("tower: "..tower.type.name.." attacking: "..target_unit.type.name)
                -- printh("("..(tower.x * CELL_SIZE)..","..(tower.y * CELL_SIZE)..") -> ("..target_unit.px..","..target_unit.py..")")
                tower.cooldown = tower.type.attack_speed

                if tower.type.custom_attack then
                    tower.type.custom_attack(tower)
                else
                    create_projectile(tower, tower.target_unit)
                end
            end
        end
    end
end

function find_nearest_unit_in_range(tower)
    local nearest_unit = nil
    local nearest_distance = tower.type.attack_range + 1
    for unit in all(units) do
        local distance = tower_distance_to_unit(tower, unit)
        if distance < nearest_distance then
            nearest_unit = unit
            nearest_distance = distance
        end 
    end
    return nearest_unit
end

function tower_distance_to_unit(tower, unit)
    local dx = abs(unit.px - (tower.x - 1) * CELL_SIZE)
    local dy = abs(unit.py - (tower.y - 1) * CELL_SIZE)
    if dx <= tower.type.attack_range and dy <= tower.type.attack_range then
        return sqrt(dx * dx + dy * dy)
    end
    return tower.type.attack_range + 1
end


function get_tower_at(x, y)
    return towers[x..","..y]
end