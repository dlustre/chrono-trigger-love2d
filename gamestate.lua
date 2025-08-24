STATE_IDLE = "idle"
STATE_ACTION = "action"

function game_is_idle()
    return game_state.kind == STATE_IDLE
end

function game_is_action()
    return game_state.kind == STATE_ACTION
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
