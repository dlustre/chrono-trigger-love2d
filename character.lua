local Slab = require 'lib/Slab'
local tween = require 'lib/tween'

require "cooldown-bar"
require "health-bar"
require "shader"

CHARACTER_HEIGHT = 100
CHARACTER_WIDTH = 50

CHARACTER_ACTION_MENU_WIDTH = 25
CHARACTER_ACTION_MENU_HEIGHT = 100

CHARACTER_ACTION_OPTIONS = {"Attack", "Combo", "Item"}

function new_character(args)
    enemy = {
        x = 0,
        y = 0,
        w = CHARACTER_WIDTH,
        h = CHARACTER_HEIGHT,
        prev_cooldown_progress = 0,
        cooldown_progress = 0,
        cooldown_speed_sec = 0.8,
        units_per_second = 1000,
        name = "character",
        max_health_points = 100,
        health_points = 100,
        max_magic_points = 50,
        magic_points = 50,
        white_progress = 0
    }

    if args then
        for k, v in pairs(args) do
            enemy[k] = v
        end
    end

    return enemy
end

function character_display_health(character)
    return "HP: " .. character.health_points .. "/" .. character.max_health_points
end

function character_display_magic(character)
    return "MP: " .. character.magic_points .. "/" .. character.max_magic_points
end

function character_is_alive(character)
    return character.health_points > 0
end

function characters_alive(characters)
    result = {}

    for _, character in ipairs(characters) do
        if character_is_alive(character) then
            table.insert(result, character)
        end
    end

    return result
end

function character_reset_cooldown(character)
    character.cooldown_progress = 0
end

function draw_character(character)
    love.graphics.setColor(1, 1, 1)

    assert(character.animation)

    love.graphics.setShader(white_shader)
    white_shader:send("WhiteFactor", character.white_progress)

    character.animation:draw(chrono_sheet, character.x, character.y, 0, 4)

    love.graphics.setShader()

    love.graphics.print("x: " .. character.x, character.x, character.y + character.h + 50)
    love.graphics.print("y: " .. character.y, character.x, character.y + character.h + 70)

    draw_health_bar(character.health_points / character.max_health_points, character.x, character.y + character.h + 10)
    draw_cooldown_bar(character.cooldown_progress, character.x, character.y + character.h + 20)
end

function draw_character_if_alive(character)
    if character_is_alive(character) then
        draw_character(character)
    end
end

function character_is_ready(character)
    return character.cooldown_progress >= 1
end

function update_character(character, dt, index)
    character.animation:update(dt)

    local function update_idle(character, dt)
        character.prev_cooldown_progress = character.cooldown_progress
        character.cooldown_progress = math.min(1, character.cooldown_progress + dt * character.cooldown_speed_sec)

        if character.cooldown_progress >= 1 and character.prev_cooldown_progress < 1 then
            love.audio.play("assets/sounds/action-ready.ogg", "stream")
        end
    end

    local function update_action(character, dt)
    end

    if not character_is_alive(character) then
        return
    end

    if character_is_ready(character) then
        draw_character_action_menu(character, index)
    end

    if game_is_idle() then
        update_idle(character, dt)
        return
    end

    if game_is_action() then
        update_action(character, dt)
        return
    end
end

function draw_character_action_menu(character, index)
    window_id = "CharacterActionMenu" .. index

    Slab.BeginWindow(window_id, {
        AutoSizeWindow = true,
        AutoSizeContent = false,
        AllowResize = false,
        ShowMinimize = false,
        X = ANCHORS.BOTTOM_LEFT.x + (CHARACTER_ACTION_MENU_WIDTH * 6.4 * (index - 1)),
        Y = ANCHORS.BOTTOM_LEFT.y - CHARACTER_ACTION_MENU_HEIGHT * 1,
        W = CHARACTER_ACTION_MENU_WIDTH,
        H = CHARACTER_ACTION_MENU_HEIGHT,
        ContentW = CHARACTER_ACTION_MENU_WIDTH,
        ContentH = CHARACTER_ACTION_MENU_HEIGHT,
        ConstrainPosition = true
    })

    Slab.BeginListBox('Actions')
    for _, value in ipairs(CHARACTER_ACTION_OPTIONS) do
        Slab.BeginListBoxItem(value)
        Slab.Text(value)

        if Slab.IsListBoxItemClicked() then
            love.audio.play("assets/sounds/select.ogg", "stream")
            if value == "Attack" then
                character_reset_cooldown(character)

                selectable_enemies = enemies_alive(enemies)
                random_enemy = selectable_enemies[math.random(1, #selectable_enemies)]

                local prev_coordinates = {
                    x = character.x,
                    y = character.y
                }

                table.insert(action_queue, {
                    steps = {function()
                        table.insert(tweens, tween.new(0.5, character, {
                            x = random_enemy.x,
                            y = random_enemy.y + 30
                        }, "linear"))
                    end, function()
                        random_enemy.white_progress = 1
                        love.audio.play("assets/sounds/attack-alt.ogg", "stream")
                    end, function()
                        table.insert(tweens, tween.new(0.1, random_enemy, {
                            white_progress = 0
                        }, "linear"))
                        table.insert(tweens, tween.new(0.2, random_enemy, {
                            health_points = math.max(0, random_enemy.health_points - 10)
                        }, "linear"))
                    end, function()
                        table.insert(tweens, tween.new(0.5, character, {
                            x = prev_coordinates.x,
                            y = prev_coordinates.y
                        }, "linear"))
                    end}
                })
            end
        end

        Slab.EndListBoxItem()
    end
    Slab.EndListBox()

    Slab.EndWindow()
end
