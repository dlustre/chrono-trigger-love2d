STATE_IDLE = "idle"
STATE_ACTION = "action"

function game_is_idle()
    return game_state.kind == STATE_IDLE
end

function game_is_action()
    return game_state.kind == STATE_ACTION
end
