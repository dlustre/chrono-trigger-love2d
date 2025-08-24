require "sound-manager"
require "character"
require "enemy"
require "gamestate"

local anim8 = require 'lib/anim8'
local Slab = require 'lib/Slab'
local sparks_particle_effect = require 'particle-effects/sparks'

function init_or_reset_particles()
    for _, particle_data in ipairs(sparks_particle_effect) do
        -- Note that particle systems are already started when created, so we
        -- don't need to call particleSystem:start() at any point.
        local particle_system = particle_data.system

        particle_system:reset()
        particle_system:start()
        particle_system:setPosition(sparks_particle_effect.x + particle_data.x,
            sparks_particle_effect.y + particle_data.y)

        for step = 1, particle_data.kickStartSteps do -- kickStartSteps may be 0.
            particle_system:update(particle_data.kickStartDt)
        end

        particle_system:emit(particle_data.emitAtStart) -- emitAtStart may be 0.
    end
end

function rgb_to_love(r, g, b)
    return { r / 255, g / 255, b / 255 }
end

WINDOW_WIDTH = 256 * 4
WINDOW_HEIGHT = 223 * 4

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

CORNFLOWER_BLUE = { 0.392, 0.584, 0.929 }

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(CORNFLOWER_BLUE)

    game_state = {
        kind = STATE_IDLE
    }

    chrono_sheet = love.graphics.newImage("assets/sprites/chrono.png")

    chrono_down_grid = anim8.newGrid(20, 36, chrono_sheet:getWidth(), chrono_sheet:getHeight(), 275, 13, 6)
    chrono_grid = anim8.newGrid(20, 36, chrono_sheet:getWidth(), chrono_sheet:getHeight(), 277, 13 + 45, 6)

    up_animation = anim8.newAnimation(chrono_grid(1, 1), 0.7)
    down_animation = anim8.newAnimation(chrono_down_grid(1, 1), 0.7)

    character_1 = new_character({
        name = "Crono",
        x = 200,
        y = 500,
        animation = up_animation
    })
    character_2 = new_character({
        name = "Marley",
        x = 400,
        y = 500,
        cooldown_speed_sec = 0.4,
        animation = up_animation
    })
    character_3 = new_character({
        name = "Ayla",
        x = 600,
        y = 500,
        cooldown_speed_sec = 0.2,
        animation = up_animation
    })
    characters = { character_1, character_2, character_3 }

    enemy_1 = new_enemy({
        name = "Slime",
        x = 190,
        y = 200,
        cooldown_speed_sec = 0.4,
        animation = down_animation
    })
    enemy_2 = new_enemy({
        name = "Bat",
        x = 402,
        y = 200,
        cooldown_speed_sec = 0.3,
        animation = down_animation
    })
    enemy_3 = new_enemy({
        name = "Bug",
        x = 609,
        y = 200,
        cooldown_speed_sec = 0.35,
        animation = down_animation
    })
    enemies = { enemy_1, enemy_2, enemy_3 }

    action_queue = {}
    tweens = {}

    current_action = nil

    Slab.Initialize()

    bgm = love.audio.play("assets/sounds/battle.mp3", "stream", true)

    background = love.graphics.newImage("assets/backgrounds/background.png")

    particle_coordinates = {
        x = WINDOW_WIDTH * 4,
        y = WINDOW_HEIGHT * 4
    }
end

function love.update(dt)
    require("lurker").update()

    for index, tween in ipairs(tweens) do
        tween:update(dt)

        if tween.clock >= tween.duration then
            table.remove(tweens, index)
        end
    end

    for _, particle_data in ipairs(sparks_particle_effect) do
        particle_data.system:update(dt)
    end

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
        Slab.BeginListBoxItem(index)
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

        if #tweens > 0 then
            return
        end

        current_step = table.remove(current_action.steps, 1)

        if current_step == nil then
            current_action = nil
            change_state(STATE_IDLE)
            return
        end

        current_step()
    else
        error("unknown game state")
    end
end

function draw_diagnostics()
    love.graphics.setColor(0, 0.4, 0.6)
    love.graphics.print("state: " .. game_state.kind, 10, 10)

    love.graphics.print("action_queue: " .. #action_queue, 10, 50)
    for index, action in ipairs(action_queue) do
        love.graphics.print(action, 10, 70 * index)
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0, 0, 4)

    for _, particle_data in ipairs(sparks_particle_effect) do
        love.graphics.setBlendMode(particle_data.blendMode)
        love.graphics.setShader(particle_data.shader)
        love.graphics.draw(particle_data.system, particle_coordinates.x, particle_coordinates.y)
    end

    draw_diagnostics()

    love.graphics.setBlendMode("alpha")

    for _, character in ipairs(characters) do
        draw_character_if_alive(character)
    end

    for _, enemy in ipairs(enemies) do
        draw_enemy_if_alive(enemy)
    end

    Slab.Draw()
end
