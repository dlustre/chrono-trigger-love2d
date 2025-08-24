white_shader = love.graphics.newShader [[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    return outputcolor;
}
]]

color_shader = love.graphics.newShader [[
    extern number time;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
        return vec4((1.0+sin(time))/2.0, abs(cos(time)), abs(sin(time)), 1.0);
    }
]]
