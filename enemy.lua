require "cooldown-bar"
require "health-bar"

ENEMY_HEIGHT = 100
ENEMY_WIDTH = 50

function new_enemy(args)
    enemy = {
        x = 0,
        y = 0,
        w = ENEMY_WIDTH,
        h = ENEMY_HEIGHT,
        prev_cooldown_progress = 0,
        cooldown_progress = 0,
        cooldown_speed_sec = 0.8,
        units_per_second = 1000,
        name = "enemy",
        max_health_points = 100,
        health_points = 100,
        max_magic_points = 50,
        magic_points = 50,
        is_getting_attacked = false
    }

    if args then
        for k, v in pairs(args) do
            enemy[k] = v
        end
    end

    return enemy
end

function draw_enemy(enemy)
    love.graphics.setColor(1, 1, 1)

    assert(enemy.animation)

    love.graphics.setShader(white_shader)
    white_shader:send("WhiteFactor", enemy.is_getting_attacked and 1 or 0)

    enemy.animation:draw(chrono_sheet, enemy.x, enemy.y, 0, 4)

    love.graphics.setShader()

    love.graphics.print(enemy.name .. " " .. "(" .. enemy.health_points .. "/" .. enemy.max_health_points .. ")",
        enemy.x, enemy.y - 20)
    love.graphics.print("x: " .. enemy.x, enemy.x, enemy.y + enemy.h + 50)
    love.graphics.print("y: " .. enemy.y, enemy.x, enemy.y + enemy.h + 70)

    draw_health_bar(enemy.health_points / enemy.max_health_points, enemy.x, enemy.y + enemy.h + 10)
    draw_cooldown_bar(enemy.cooldown_progress, enemy.x, enemy.y + enemy.h + 20)
end

function draw_enemy_if_alive(enemy)
    if enemy_is_alive(enemy) then
        draw_enemy(enemy)
    end
end

function enemy_is_ready(enemy)
    return enemy.cooldown_progress >= 1
end

function enemy_is_alive(enemy)
    return enemy.health_points > 0
end

function enemies_alive(enemies)
    result = {}

    for _, enemy in ipairs(enemies) do
        if enemy_is_alive(enemy) then
            table.insert(result, enemy)
        end
    end

    return result
end

function enemy_reset_cooldown(enemy)
    enemy.cooldown_progress = 0
end

function update_enemy(enemy, dt, index)
    local function update_idle(enemy, dt)
        enemy.prev_cooldown_progress = enemy.cooldown_progress
        enemy.cooldown_progress = math.min(1, enemy.cooldown_progress + dt * enemy.cooldown_speed_sec)
    end

    local function update_action(enemy, dt)
    end

    if not enemy_is_alive(enemy) then
        return
    end

    if enemy_is_ready(enemy) then
        enemy_reset_cooldown(enemy)

        selectable_characters = characters_alive(characters)
        random_character = selectable_characters[math.random(1, #selectable_characters)]

        table.insert(action_queue, new_action({
            kind = "attack",
            actor_entity = enemy,
            target_entity = random_character,
            damage = 5,
            did_fx = false
        }))
    end

    if game_is_idle() then
        update_idle(enemy, dt)
        return
    end

    if game_is_action() then
        update_action(enemy, dt)
        return
    end
end
