require "sound-manager"
require "character"
require "enemy"

local SlabRegion = require 'lib/Slab/Internal/UI/Region'
local SlabDebug = require 'lib/Slab/SlabDebug'
local SlabWindow = require 'lib/Slab/Internal/UI/Window'

function rgb_to_love(r, g, b)
    return {r / 255, g / 255, b / 255}
end

WINDOW_WIDTH = 1920 / 1.5
WINDOW_HEIGHT = 1080 / 1.5

ANCHORS = {
    CENTER = {
        x = WINDOW_WIDTH / 2,
        y = WINDOW_HEIGHT / 2
    },
    TOP_LEFT = {
        x = 0,
        y = 0
    },
    TOP_RIGHT = {
        x = WINDOW_WIDTH,
        y = 0
    },
    BOTTOM_LEFT = {
        x = 0,
        y = WINDOW_HEIGHT
    },
    BOTTOM_RIGHT = {
        x = WINDOW_WIDTH,
        y = WINDOW_HEIGHT
    }
}

STATE_IDLE = "idle"
STATE_ACTION = "action"

CORNFLOWER_BLUE = {0.392, 0.584, 0.929}

CHARACTER_ACTION_OPTIONS = {"Attack", "Combo", "Item"}

local Slab = require 'lib/Slab'

function new_action(args)
    action = {
        kind = "attack",
        duration_sec = 1,
        actor_entity = nil,
        target_entity = nil
    }

    if args then
        for k, v in pairs(args) do
            action[k] = v
        end
    end

    return action
end

function change_state(kind)
    if kind == STATE_IDLE then
        game_state = {
            kind = STATE_IDLE
        }
    elseif kind == STATE_ACTION then
        assert(current_action)

        game_state = {
            kind = STATE_ACTION,
            current_action = current_action
        }
    end
end

function game_is_idle()
    return game_state.kind == STATE_IDLE
end

function game_is_action()
    return game_state.kind == STATE_ACTION
end

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(CORNFLOWER_BLUE)

    game_state = {
        kind = STATE_IDLE
    }

    character_1 = new_character({
        name = "Crono",
        x = 200,
        y = 250
    })
    character_2 = new_character({
        name = "Marley",
        x = 400,
        y = 250,
        cooldown_speed_sec = 0.4
    })
    character_3 = new_character({
        name = "Ayla",
        x = 600,
        y = 250,
        cooldown_speed_sec = 0.2
    })
    characters = {character_1, character_2, character_3}

    enemy_1 = new_enemy({
        name = "Slime",
        x = 190,
        y = 80,
        cooldown_speed_sec = 0.4
    })
    enemy_2 = new_enemy({
        name = "Bat",
        x = 402,
        y = 80,
        cooldown_speed_sec = 0.3
    })
    enemy_3 = new_enemy({
        name = "Bug",
        x = 609,
        y = 80,
        cooldown_speed_sec = 0.35
    })
    enemies = {enemy_1, enemy_2, enemy_3}

    action_queue = {}

    current_action = nil

    Slab.Initialize()

    -- bgm = love.audio.play("assets/sounds/battle.mp3", "stream", true)
end

function love.update(dt)
    require("lurker").update()
    Slab.Update(dt)

    Slab.BeginWindow('CharacterWindow', {
        AutoSizeWindow = false,
        AutoSizeContent = false,
        AllowResize = false,
        ShowMinimize = false,
        X = ANCHORS.BOTTOM_LEFT.x + (CHARACTER_ACTION_MENU_WIDTH * 6.4 * 3),
        Y = ANCHORS.BOTTOM_LEFT.y - CHARACTER_ACTION_MENU_HEIGHT * 1,
        W = WINDOW_WIDTH * .34,
        H = CHARACTER_ACTION_MENU_HEIGHT,
        ContentW = WINDOW_WIDTH * .34,
        ContentH = CHARACTER_ACTION_MENU_HEIGHT,
        ConstrainPosition = true
    })

    Slab.BeginListBox('CharacterListBox', {
        StretchW = true
    })
    for index, value in ipairs(characters) do
        Slab.BeginListBoxItem(index, {
            Selected = Selected == index
        })
        Slab.Text(value.name .. " " .. character_display_health(value) .. " " .. character_display_magic(value))

        Slab.EndListBoxItem()
    end
    Slab.EndListBox()

    Slab.EndWindow()

    for index, character in ipairs(characters) do
        update_character(character, dt, index)
    end

    for index, enemy in ipairs(enemies) do
        update_enemy(enemy, dt, index)
    end

    if game_is_idle() then
        current_action = table.remove(action_queue, 1)

        if current_action then
            change_state(STATE_ACTION)
        end
    elseif game_is_action() then
        assert(current_action)

        current_action.duration_sec = math.max(0, current_action.duration_sec - dt)

        if current_action.duration_sec <= 0 then
            target_entity = current_action.target_entity

            assert(target_entity.health_points and target_entity.health_points > 0 and current_action.damage and
                       current_action.damage >= 0)

            target_entity.health_points = math.max(0, target_entity.health_points - current_action.damage)
            change_state(STATE_IDLE)
            current_action = nil
        end
    else
        error("unknown game state")
    end
end

function draw_diagnostics()
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.print("state: " .. game_state.kind, 10, 10)

    if current_action then
        assert(current_action.actor_entity.name)
        assert(current_action.target_entity.name)

        love.graphics.print("current_action: " .. (current_action.actor_entity.name) .. " " .. (current_action.kind) ..
                                " -> " .. (current_action.target_entity.name) .. " " .. (current_action.duration_sec),
            10, 30)
    end

    love.graphics.print("action_queue: " .. #action_queue, 10, 50)
    for index, action in ipairs(action_queue) do
        love.graphics.print(action, 10, 70 * index)
    end

    love.graphics.print("Hot region: " .. SlabRegion.GetHotInstanceId(), 10, 100)
end

function love.draw()
    draw_diagnostics()

    love.graphics.setColor(0, 0.4, 0.4)

    for _, character in ipairs(characters) do
        draw_character_if_alive(character)
    end

    for _, enemy in ipairs(enemies) do
        draw_enemy_if_alive(enemy)
    end

    Slab.Draw()
end
