local tween = require 'lib/tween'

function lerp(a, b, t)
    return a + (b - a) * t
end

function melee_attack_steps(actor, target)
    local prev_coordinates = {
        x = actor.x,
        y = actor.y
    }

    return {
        function()
            local destination = {
                x = lerp(actor.x, target.x, 0.86),
                y = lerp(actor.y, target.y, 0.86)
            }

            table.insert(tweens, tween.new(0.5, actor, destination, "linear"))
        end,
        function()
            target.white_progress = 1
            love.audio.play("assets/sounds/attack-alt.ogg", "stream")
        end,
        function()
            table.insert(tweens, tween.new(0.4, target, {
                white_progress = 0
            }, "linear"))
            table.insert(tweens, tween.new(0.2, target, {
                health_points = math.max(0, target.health_points - 10)
            }, "linear"))
            target.damage_text = 10
            target.damage_text_opacity = 1
        end,
        function()
            table.insert(tweens, tween.new(0.5, actor, {
                x = prev_coordinates.x,
                y = prev_coordinates.y
            }, "linear"))
            table.insert(tweens, tween.new(0.1, target, {
                damage_text_opacity = 0
            }, "linear"))
        end
    }
end
