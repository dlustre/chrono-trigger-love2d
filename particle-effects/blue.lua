--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = { x = 0, y = 0 }

local image1    = LG.newImage("assets/textures/light.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 569)
ps:setColors(0.2109375, 0.61163330078125, 1, 0, 0.095138549804688, 0.12422859668732, 0.83984375, 1, 0.11402893066406,
	0.58544075489044, 0.62109375, 0.5)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("uniform", 100, 100, 0, false)
ps:setEmissionRate(246.09384155273)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(75, 73.660713195801)
ps:setParticleLifetime(1.7999999523163, 2.2000000476837)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.72162609100342)
ps:setSizeVariation(0.5175718665123)
ps:setSpeed(12.7591381073, 37.746635437012)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0.31415927410126)
ps:setTangentialAcceleration(1212.7305908203, 485.97006225586)
table.insert(particles,
	{
		system = ps,
		kickStartSteps = 0,
		kickStartDt = 0,
		emitAtStart = 0,
		blendMode = "add",
		shader = nil,
		texturePath =
		"assets/textures/light.png",
		texturePreset = "light",
		shaderPath = "",
		shaderFilename = "",
		x = 0,
		y = 0
	})

return particles
