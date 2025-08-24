function draw_health_bar(progress, x, y)
    local WIDTH = 60
    local HEIGHT = 10
    local BORDER_COLOR = rgb_to_love(155, 150, 162)
    local BACKDROP_COLOR = rgb_to_love(255, 0, 0)
    local PROGRESS_COLOR = rgb_to_love(0, 255, 0)
    local BORDER_RADIUS = 2.5

    love.graphics.setColor(BACKDROP_COLOR)
    love.graphics.rectangle("fill", x + 2, y + 2, WIDTH - 4, HEIGHT - 4, BORDER_RADIUS)
    love.graphics.setColor(BORDER_COLOR)
    love.graphics.rectangle("line", x, y, WIDTH, HEIGHT, BORDER_RADIUS)

    if progress > 0 then
        love.graphics.setColor(PROGRESS_COLOR)
        love.graphics.rectangle("fill", x + 2, y + 2, (WIDTH - 4) * progress, HEIGHT - 4, BORDER_RADIUS)
    end
end
