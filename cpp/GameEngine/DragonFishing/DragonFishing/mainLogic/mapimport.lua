print("abc")
	print("hi am thread",coroutine.running())

local resolution = GameObject.FrameBuffer.WindowSize

local meshes = GameObject("Object")
meshes.Name = "Meshes"
meshes.Parent = Engine --[[ meshes:SetParent(Engine) ]]

local assets
print("pcall", pcall(function() assets = json.decode("./assets/json/mapAssets.json", true) end))

for name, path in pairs(assets.meshes) do
	print(name, path)
	GameObject.MeshLoader.NewAsset(name, path).Parent = meshes --[[ GameObject.MeshLoader.NewAsset(name, path):SetParent(meshes) ]]
	print("loaded", name)
end

local textures = GameObject("Textures")
textures.Name = "Textures"
textures.Parent = Engine --[[ textures:SetParent(Engine) ]]

local robloxTextures = GameObject("Object")
robloxTextures:SetParent(textures)
robloxTextures.Name = "Roblox"
--[[
print("loading material textures")

local robloxMaterials = { "Aluminum", "Brick", "Cobblestone", "Concrete", "DiamondPlate", "Fabric", "Glass", "Granite", "Grass", "Ice", "Marble", "Metal", "Pebble", "Plastic", "Rust", "Sand", "Slate", "Wood", "WoodPlanks" }

print(pcall(function()
for i, name in pairs(robloxMaterials) do
	local material = GameObject("Object")
	material.Name = name
	material.Parent = robloxTextures
	print(name)
	
	do
		print(name, "diffuse")
		local path = "./assets/maps/textures/"..name:lower().."/diffuse.dds"
		
		local file = io.open(path, "r")
		
		if file then
			file:close()
			
			local texture = textures:Create(path, Enum.SampleType.Linear, Enum.WrapType.Repeat)
			
			texture.Parent = material
			texture.Name = "Diffuse"
		end
	end
	
	do
		print(name, "specular")
		local path = "./assets/maps/textures/"..name:lower().."/specular.dds"
		
		local file = io.open(path, "r")
		
		if file then
			file:close()
			
			local texture = textures:Create(path, Enum.SampleType.Linear, Enum.WrapType.Repeat)
			
			texture.Parent = material
			texture.Name = "Specular"
		end
	end
	
	do
		print(name, "normal")
		local path = "./assets/maps/textures/"..name:lower().."/normal.dds"
		
		local file = io.open(path, "r")
		
		if file then
			file:close()
			
			local texture = textures:Create(path, Enum.SampleType.Linear, Enum.WrapType.Repeat)
			
			texture.Parent = material
			texture.Name = "Normal"
		end
	end
end
end))

for name, path in pairs(assets.textures) do
	textures:Add(textures:Create(path), name)
end

textures:Add(textures:Create("assets/maps/textures/skyFront.Jpg", Enum.SampleType.Linear, Enum.WrapType.ClampExtend), "skyFront")
textures:Add(textures:Create("assets/maps/textures/skyBack.Jpg", Enum.SampleType.Linear, Enum.WrapType.ClampExtend), "skyBack")
textures:Add(textures:Create("assets/maps/textures/skyLeft.Jpg", Enum.SampleType.Linear, Enum.WrapType.ClampExtend), "skyLeft")
textures:Add(textures:Create("assets/maps/textures/skyRight.Jpg", Enum.SampleType.Linear, Enum.WrapType.ClampExtend), "skyRight")
textures:Add(textures:Create("assets/maps/textures/skyTop.Png", Enum.SampleType.Linear, Enum.WrapType.ClampExtend), "skyTop")
textures:Add(textures:Create("assets/maps/textures/skyBottom.Jpg", Enum.SampleType.Linear, Enum.WrapType.ClampExtend), "skyBottom")

]]
local fonts = GameObject("Fonts")
fonts.Parent = Engine

local sans = GameObject("Font")
sans.Name = "Sans"
sans:Load("assets/fonts/Sans", "Sans")
sans.Parent = fonts --[[ sans:SetParent(fonts) ]]

local environments = GameObject("Environments")
environments.Parent = Engine --[[ environments:SetParent(Engine) ]]

local level = GameObject("Environment")
level.Name = "Level"
level.Parent = environments

local simulation = GameObject("Simulation")
simulation.Parent = level --[[ simulation:SetParent(level) ]]

local aspectRatio = GameObject.FrameBuffer.WindowSize.Width / GameObject.FrameBuffer.WindowSize.Height
local size = 5 / 3
local defaultWidth = aspectRatio * size
local defaultHeight = size
local defaultProjection = 1
local defaultNear = 0.1
local defaultFar = 10000

local camera = GameObject("Camera")
camera.Parent = level --[[ camera:SetParent(level) ]]
camera:SetProperties(defaultWidth, defaultHeight, defaultProjection, defaultNear, defaultFar)--120, resolution.Width / resolution.Height, 0.1, 10000)
camera:SetTransformation(Matrix3(0, 200, 100))

local light = GameObject("Light")
light.Enabled = true
light.Direction = Vector3(0, -1, 0)
light.Brightness = 0.5
light.Diffuse = RGBA(0.6, 0.55, 0.85, 1)
light.Specular = RGBA(0.6, 0.55, 0.95, 1)
light.Ambient = RGBA(0.1, 0.1, 0.1, 1)
light.Type = Enum.LightType.Directional
--light.Ambient = RGBA(0.5, 0.5, 0.5, 1)
light.Parent = simulation --[[ light:SetParent(simulation) ]]
coroutine.wrap(function()
print("aaaaaa")
wait(10)
light.Parent = nil
print("lol",wait(10), light, simulation)
print("lol",pcall(function()
light.Parent = simulation
end))
end)()

local lightOrb = GameObject("Transform")
lightOrb.Parent = simulation --[[ lightOrb:SetParent(simulation) ]]
lightOrb.IsStatic = false
lightOrb.Transformation = Matrix3(0, 1000, 10) * Matrix3.PitchRotation(math.pi / 2) * Matrix3.NewScale(1, 1, 1)
lightOrb:Update(0)

local lightOrbModel = GameObject("Model")
lightOrbModel.Asset = Engine.Meshes.Sphere
lightOrbModel.Parent = lightOrb --[[ lightOrbModel:SetParent(lightOrb) ]]
lightOrbModel.Color = RGBA(1, 1, 1, 0.99)
lightOrbModel.GlowColor = RGBA(1, 1, 1, 0.99)

local testLight = GameObject("Light")
testLight.Enabled = true
testLight.Position = Vector3(0, 1000, 0)
testLight.Direction = Vector3(0, -1, 0)
testLight.Diffuse = RGBA(1, 1, 1, 1)
testLight.Specular = RGBA(1, 1, 1, 1)
testLight.Ambient = RGBA(1, 1, 1, 1)
testLight.Type = Enum.LightType.Spot
testLight.InnerRadius = math.pi / 5
testLight.OuterRadius = math.pi / 4
testLight.Attenuation = Vector3(1, 0, 0.00005)
testLight.Brightness = 1.5
testLight:SetShadowsEnabled(true, 1024, 1024)
testLight.Parent = lightOrb --[[ testLight:SetParent(lightOrb) ]]

local lightOrb2 = GameObject("Transform")
lightOrb2.Parent = simulation --[[ lightOrb2:SetParent(simulation) ]]
lightOrb2.IsStatic = false
lightOrb2:Update(0)

local lightOrbModel2 = GameObject("Model")
lightOrbModel2.Asset = Engine.Meshes.Sphere
lightOrbModel2.Parent = lightOrb2 --[[ lightOrbModel2:SetParent(lightOrb2) ]]
lightOrbModel2.Color = RGBA(0.2, 1, 0.4, 0.99)
lightOrbModel2.GlowColor = RGBA(0.2, 1, 0.4, 0.99)

local testLight2 = GameObject("Light")
testLight2.Enabled = true
testLight2.Diffuse = RGBA(0.2, 1, 0.4, 0.99)
testLight2.Specular = RGBA(0.2, 1, 0.4, 0.99)
testLight2.Ambient = RGBA(0.2, 1, 0.4, 0.99)
testLight2.Type = Enum.LightType.Spot
testLight2.InnerRadius = math.pi / 8
testLight2.OuterRadius = math.pi / 4
testLight2.Attenuation = Vector3(1, 0, 0.005)
testLight2.Brightness = 0.05
testLight2:SetShadowsEnabled(true, 1024, 1024)
testLight2.Parent = lightOrb2 --[[ testLight2:SetParent(lightOrb2) ]]

local scene = GameObject("Scene")
scene.Parent = level --[[ scene:SetParent(level) ]]
scene.CurrentCamera = camera
scene.GlobalLight = light

scene:AddLight(testLight)
scene:AddLight(testLight2)
scene:AddObject(lightOrbModel)

local sceneDraw = GameObject("GlowingSceneOperation")
sceneDraw.Parent = level --[[ sceneDraw:SetParent(level) ]]
sceneDraw:Configure(resolution.Width, resolution.Height, scene)
sceneDraw.Radius = 10
sceneDraw.Sigma = 20
sceneDraw.SkyBrightness = 1
sceneDraw.SkyBackgroundBrightness = 1
sceneDraw.SkyColor = RGBA(15/255, 5/255, 15/255, 1)--RGBA(1, 167/255 +.1, 124/255+.08, 1)
sceneDraw.SkyBackgroundColor = RGBA(0, 0, 0, 0)
sceneDraw.Resolution = Vector3(resolution.Width, resolution.Height)
sceneDraw.RenderAutomatically = true
sceneDraw.RangeFittingType = Enum.RangeFittingMode.Exposure
sceneDraw.Exposure = 0.5

--[=[local skybox = GameObject("CubeMapTexture")
skybox.Front = textures.skyFront
skybox.Back = textures.skyBack
skybox.Left = textures.skyLeft
skybox.Right = textures.skyRight
skybox.Top = textures.skyTop
skybox.Bottom = textures.skyBottom
skybox.Parent = sceneDraw --[[ skybox:SetParent(sceneDraw) ]]

sceneDraw.SkyBox = skybox
sceneDraw.DrawSkyBox = true]=]

--textures:Add(sceneDraw:GenerateNormalMap(textures.terrainHeight), "terrainNormals");

math.randomseed(os.time())

local materials = GameObject("Materials")
materials.Parent = Engine --[[ materials:SetParent(Engine) ]]

local material = GameObject("Material")
material.Shininess = 75
material.Diffuse = RGBA(0.5, 0.5, 0.5, 0)--RGBA(0.5, 0.5, 0.5, 0)
material.Specular = RGBA(0.5, 0.5, 0.5, 0)--RGBA(0.5, 0.5, 0.5, 0)
material.Ambient = RGBA(0.5, 0.5, 0.5, 0)--RGBA(0.5, 0.5, 0.5, 0)
material.Emission = RGBA(0, 0, 0, 0)

local waterMaterial = GameObject("Material")
waterMaterial.Name = "WaterMaterial"
waterMaterial.Shininess = 3
waterMaterial.Diffuse = RGBA(1, 1, 1, 1)--RGBA(0.5, 0.5, 0.5, 0)
waterMaterial.Specular = RGBA(1, 1, 1, 1)--RGBA(0.5, 0.5, 0.5, 0)
waterMaterial.Ambient = RGBA(1, 1, 1, 1)--RGBA(0.5, 0.5, 0.5, 0)
waterMaterial.Emission = RGBA(0, 0, 0, 0)

local fireMaterial = GameObject("Material")
fireMaterial.Name = "FireMaterial"
fireMaterial.Shininess = 250
fireMaterial.Diffuse = RGBA(0, 0, 0, 0)--RGBA(0.5, 0.5, 0.5, 0)
fireMaterial.Specular = RGBA(0, 0, 0, 0)--RGBA(0.5, 0.5, 0.5, 0)
fireMaterial.Ambient = RGBA(0, 0, 0, 0)--RGBA(0.5, 0.5, 0.5, 0)
fireMaterial.Emission = RGBA(0, 0, 0, 0)

local underwaterMaterial = GameObject("Material")
underwaterMaterial.Name = "UnderwaterMaterial"
underwaterMaterial.Shininess = 250
underwaterMaterial.Diffuse = RGBA(0.2, 0.2, 0.2, 0)--RGBA(0.5, 0.5, 0.5, 0)
underwaterMaterial.Specular = RGBA(0.1, 0.1, 0.1, 0)--RGBA(0.5, 0.5, 0.5, 0)
underwaterMaterial.Ambient = RGBA(1, 1, 1, 0)--RGBA(0.5, 0.5, 0.5, 0)
underwaterMaterial.Emission = RGBA(0, 0, 0, 0)

lightOrbModel.MaterialProperties = material

for i=1,0 do
	local transform = GameObject("Transform")
	transform.Parent = simulation --[[ transform:SetParent(simulation) ]]
	transform.Transformation = Matrix3(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)) * Matrix3.AxisRotation(Vector3(-1, 2, 0.5), 3*math.random())
	transform:Update(0)

	local model = GameObject("Model")
	model.MaterialProperties = material
	model.Asset = Engine.Meshes.DestroyerHead
	model.DiffuseTexture = Engine.Textures.palette
	model.Parent = transform --[[ model:SetParent(transform) ]]

	scene:AddObject(model)
end

material.Parent = Engine --[[ material:SetParent(Engine) ]]
waterMaterial.Parent = Engine --[[ waterMaterial:SetParent(Engine) ]]
fireMaterial.Parent = Engine --[[ fireMaterial:SetParent(Engine) ]]
underwaterMaterial.Parent = Engine --[[ underwaterMaterial:SetParent(Engine) ]]

math.randomseed(os.time())

if true then
	local meshes = {
		Block = Engine.CoreMeshes.CoreCube,
		Sphere = Engine.Meshes.Sphere,
		Ball = Engine.Meshes.Sphere,
		Cylinder = Engine.Meshes.Cylinder,
		Wedge = Engine.Meshes.Wedge,
		CornerWedge = Engine.Meshes.CornerWedge,
		Capsule = Engine.Meshes.Sphere
	}
	
	local file = io.open("./currentMap.txt","r")
	local mapName = file:read()
	file:close()
	print("loading "..mapName)
	--local mapOffset = Vector3(0, -7000, 1000)
	local mapOffset = Vector3(0, 0, 0)

	local mapContainer = GameObject("Object")
	
	mapContainer.Name = mapName
	mapContainer.Parent = Engine.Environments.Level.Simulation --[[ mapContainer:SetParent(Engine.Environments.Level.Simulation) ]]

	local file = io.open("./assets/maps/" .. mapName .. "/data.lvl", "r")

	local current = {}

	local lights = 0
	local pointlights = 0
	local spotlights = 0
	local shadowedLights = 0
	local objects = 0
	local aaa = false
	
	print(pcall(function()
	for line in file:lines() do
		local attribute, value = line:match("([^:]+):(.*)")
		local data, endMarker = value:match("(.*)([;,])")

		if attribute == "create" then
			objects = objects + 1

			if current.shape ~= "Truss" and current.shape ~= "AlternatingTruss" and current.shape ~= "BridgeTruss" then
				if current.shape == "Special" then
					current.shape = "Block"
				end
			
				local transform = GameObject("Transform")

				if current.shape == "Cylinder" and current.size[2] ~= current.size[3] then
					current.size[1] = current.size[2]
					current.size[2] = current.size[3]
				end

				local size = Vector3(tonumber(current.size[1]), tonumber(current.size[2]), tonumber(current.size[3]))
				local boxScale = size

				if current.shape == "Cylinder" or current.shape == "Sphere" then
					boxScale = Vector3(current.shape == "Sphere" and math.ceil(boxScale.X) or boxScale.X, math.ceil(boxScale.Y), math.ceil(boxScale.Z))
				end

				transform.Parent = mapContainer --[[ transform:SetParent(mapContainer) ]]
				transform.Transformation = Matrix3(
					Vector3(tonumber(current.pos[1]), tonumber(current.pos[2]), tonumber(current.pos[3]), 1) + mapOffset,
					Vector3(tonumber(current.right[1]), tonumber(current.right[2]), tonumber(current.right[3])),
					Vector3(tonumber(current.up[1]), tonumber(current.up[2]), tonumber(current.up[3])),
					Vector3(tonumber(current.front[1]), tonumber(current.front[2]), tonumber(current.front[3]))
				) * Matrix3.NewScale(size * 0.5)
				--transform.IsStatic = false

				transform:Update(0)

				local model = GameObject("Model")
				local a = tonumber(current.color[4])

				--if a ~= 1 then a = 0.5 end
				local color = RGBA(tonumber(current.color[1]), tonumber(current.color[2]), tonumber(current.color[3]), a)

				model.Parent = transform --[[ model:SetParent(transform) ]]
				model.Color = color
				model.GlowColor = current.material == "Neon" and color or RGBA(0, 0, 0, 0)
				model.TextureColor = color

				--[[local materialTextures = Engine.Textures.Roblox:GetByName(current.material)

				if materialTextures then
					model.DiffuseTexture = materialTextures:GetByName("Diffuse")
					model.NormalMap = materialTextures:GetByName("Normal")
					model.SpecularMap = materialTextures:GetByName("Specular")
				end]]

				model.BoxScale = boxScale
				model.CubeMapped = true
				model.BlendTexture = material == "Glass"
				model.FlipCubeMapV = true
				model.CompressedNormalMap = true
				model.MaterialProperties = material
				model.Asset = meshes[current.shape]

				local physicsBody = GameObject("PhysicsBody")
				physicsBody.Velocity = Vector3(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)):Unit() * 10
				physicsBody.Acceleration = Vector3(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)):Unit()
				physicsBody.Parent = transform --[[ physicsBody:SetParent(transform) ]]

				scene:AddObject(model)
			else
			end

			current = {}
		elseif attribute == "createpointlight" or attribute == "createspotlight" then
			lights = lights + 1

			if attribute == "createpointlight" then
				pointlights = pointlights + 1
			else
				spotlights = spotlights + 1
			end

			local light = GameObject("Light")

			light.Parent = mapContainer --[[ light:SetParent(mapContainer) ]]
			light.Position = Vector3(tonumber(current.pos[1]), tonumber(current.pos[2]), tonumber(current.pos[3]), 1)

			if current.dir then
				light.Direction = Vector3(tonumber(current.dir[1]), tonumber(current.dir[2]), tonumber(current.dir[3]), 0)
			end

			if current.angle then
				light.InnerRadius = math.rad(tonumber(current.angle)) / 4
				light.OuterRadius = math.rad(tonumber(current.angle)) / 2
			end

			light.Enabled = current.enabled == "t"
			light.Attenuation = Vector3(1, 0, 0.1 * 255 / (tonumber(current.range))^2)
			light.Diffuse = RGBA(tonumber(current.color[1]), tonumber(current.color[2]), tonumber(current.color[3]), 1)
			light.Specular = light.Diffuse
			light.Ambient = light.Diffuse
			light.Brightness = tonumber(current.brightness)
			light.Type = attribute == "createpointlight" and Enum.LightType.Point or Enum.LightType.Spot
			
			local color = light.Diffuse
			
			if tonumber(current.range) == 20 and current.shadows == "t" then
				shadowedLights = shadowedLights + 1

				light:SetShadowsEnabled(true, 128, 128)
			end

			scene:AddLight(light)

			current = {}
		elseif endMarker == ";" then
			current[attribute] = data
		elseif endMarker == "," then
			data = data .. endMarker

			local value = {}

			for item in data:gmatch("[^,]+") do
				value[#value + 1] = item
			end

			current[attribute] = value
		else
			current[attribute] = value
		end
	end
	end))
	print("objects: ", objects)
	print("lights: ", lights)
	print("point lights: ", pointlights)
	print("spot lights: ", spotlights)
	print("shadowed lights: ", shadowedLights)
end

local multiplier = 0.2
local globalLighting = RGBA(1, 1, 1, 1)
local blackColor = RGBA(0, 0, 0, 1)

coroutine.wrap(function()
	local userInput = Engine.GameWindow.UserInput
	local keyAlt = userInput:GetInput(Enum.InputCode.LeftAlt)

	while true do
		local delta = wait(1 / 60)
		testLight.ShadowDebugView = keyAlt:GetState()
		--testLight.Position = camera:GetTransformation():Translation()
		--testLight.Direction = -camera:GetTransformation():FrontVector()
	end
end)()

coroutine.wrap(function()
	print(pcall(function()
	local userInput = Engine.GameWindow.UserInput

	local keyW = userInput:GetInput(Enum.InputCode.W)
	local keyA = userInput:GetInput(Enum.InputCode.A)
	local keyS = userInput:GetInput(Enum.InputCode.S)
	local keyD = userInput:GetInput(Enum.InputCode.D)
	local keyQ = userInput:GetInput(Enum.InputCode.Q)
	local keyE = userInput:GetInput(Enum.InputCode.E)
	local keyLeftArrow = userInput:GetInput(Enum.InputCode.LeftArrow)
	local keyRightArrow = userInput:GetInput(Enum.InputCode.RightArrow)
	local keyUpArrow = userInput:GetInput(Enum.InputCode.UpArrow)
	local keyDownArrow = userInput:GetInput(Enum.InputCode.DownArrow)
	local keyShift = userInput:GetInput(Enum.InputCode.LeftShift)
	local keyShift2 = userInput:GetInput(Enum.InputCode.RightShift)
	local keyTab = userInput:GetInput(Enum.InputCode.Tab)
	local keySpace = userInput:GetInput(Enum.InputCode.Space)
	local keyAlt = userInput:GetInput(Enum.InputCode.LeftAlt)
	local mouseRight = userInput:GetInput(Enum.InputCode.MouseRight)
	local mousePosition = userInput:GetInput(Enum.InputCode.MousePosition)
	local mouseWheel = userInput:GetInput(Enum.InputCode.MouseWheel)

	local speed = 20
	local defaultSpeed = 20
	local fastSpeed = 100
	local aspectRatio = GameObject.FrameBuffer.WindowSize.Width / GameObject.FrameBuffer.WindowSize.Height
	local size = 5 / 3
	local defaultWidth = aspectRatio * size
	local defaultHeight = size
	local defaultProjection = 1
	local defaultNear = 0.1
	local defaultFar = 10000

	local pitch = 0
	local yaw = 0

	local previousPosition = mousePosition:GetPosition()
	
	local time = 0

	while true do
		local delta = wait(1 / 60)
		
		time = time + delta

		local x = 0
		local y = 0
		local z = 0

		if keyW:GetState() then
			z = -delta * speed
		end

		if keyS:GetState() then
			z = delta * speed
		end
		
		if keyA:GetState() then
			x = -delta * speed
		end

		if keyD:GetState() then
			x = delta * speed
		end

		if keyQ:GetState() then
			y = -delta * speed
		end
		
		if keyE:GetState() then
			y = delta * speed
		end
		
		if keySpace:GetState() then
			speed = fastSpeed
		else
			speed = defaultSpeed
		end
		
		
		if keyShift:GetState() then
			testLight.Position = camera:GetTransformation():Translation()
			testLight.Direction = -camera:GetTransformation():FrontVector()
			lightOrb:SetPosition(testLight.Position)
			lightOrb:Update(0)
		end

		if keyTab:GetState() then
			testLight2.Position = camera:GetTransformation():Translation()
			testLight2.Direction = -camera:GetTransformation():FrontVector()
			lightOrb2:SetPosition(testLight2.Position)
			lightOrb2:Update(0)
		end

		if keyShift2:GetState() then
			light.Direction = -camera:GetTransformation():FrontVector()
		end
		
		if mouseRight:GetState() then
			local currentPosition = mousePosition:GetPosition()
			local mouseDelta = currentPosition - previousPosition

			yaw = (yaw - mouseDelta.X * delta * 0.1 + 2 * math.pi) % (2 * math.pi)
			pitch = math.min(math.max(pitch - mouseDelta.Y * delta * 0.1, -math.pi / 2), math.pi / 2)

			Engine.GameWindow:SetMousePosition(previousPosition)
		else
			previousPosition = mousePosition:GetPosition()
		end

		local transform = camera:GetTransformation() * Matrix3(x, y, z)
		local rotation = (Matrix3.YawRotation(yaw) * Matrix3.PitchRotation(pitch)):TransformedAround(transform:Translation())
		
		camera:SetTransformation(rotation * Matrix3(transform:Translation()))

		scene:Update(0)
	end
	end))
end)()