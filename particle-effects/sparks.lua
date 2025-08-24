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
local particles = {x=0, y=0}

local image1 = LG.newImage("assets/textures/arrow.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 6)
ps:setColors(1, 1, 1, 0, 1, 1, 1, 1)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(93.840621948242)
ps:setEmitterLifetime(0.0128906769678)
ps:setInsertMode("top")
ps:setLinearAcceleration(0.014703177846968, 0.014703177846968, 0.014703177846968, -0.014703177846968)
ps:setLinearDamping(0.00081658485578373, 0.0073492634110153)
ps:setOffset(50, 25.5)
ps:setParticleLifetime(0.44999998807907, 0.55000001192093)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.089517153799534)
ps:setSizeVariation(0)
ps:setSpeed(83.986022949219, 116.09776306152)
ps:setSpin(0, 0.0020523015409708)
ps:setSpinVariation(0)
ps:setSpread(3.1116726398468)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=4, blendMode="add", shader=nil, texturePath="assets/textures/arrow.png", texturePreset="arrow", shaderPath="", shaderFilename="", x=0, y=0})

return particles
