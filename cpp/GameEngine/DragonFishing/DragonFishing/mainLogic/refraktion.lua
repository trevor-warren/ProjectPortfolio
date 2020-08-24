
local resolution = GameObject.FrameBuffer.WindowSize

local meshes = GameObject("Object")
meshes.Name = "Meshes"
meshes:SetParent(Engine)

local assets = json.decode("./assets/json/refraktion.json", true)

local textures = GameObject("Textures")
textures.Name = "Textures"
textures:SetParent(Engine)

for name, path in pairs(assets.meshes) do
	print("loaded", name, path)
	GameObject.MeshLoader.NewAsset(name, path).Parent = meshes
end

for name, path in pairs(assets.textures) do
	print("loaded", name, path)
	textures:Add(textures:Create(path), name)
end

local editorScripts = GameObject("Object")
editorScripts.Name = "EditorScripts"
editorScripts.Parent = Engine

local explorerScript = GameObject("LuaScript")
explorerScript.Name = "ExplorerScript"
explorerScript.Parent = editorScripts

local explorerSource = GameObject("LuaSource")
explorerSource:LoadSource("./assets/scripts/explorer.lua")
explorerSource.Parent = explorerScript

explorerScript:SetSource(explorerSource)

local fonts = GameObject("Fonts")
fonts:SetParent(Engine)

local sans = GameObject("Font")
sans.Name = "Sans"
sans:Load("assets/fonts/Sans", "Sans")
sans:SetParent(fonts)

local environments = GameObject("Environments")
environments:SetParent(Engine)

local level = GameObject("Environment")
level.Name = "Level"
level:SetParent(environments)

local physicsEnvironment = GameObject("PhysicsEnvironment")
physicsEnvironment.Parent = level

local simulation = GameObject("Simulation")
simulation:SetParent(level)

local aspectRatio = GameObject.FrameBuffer.WindowSize.Width / GameObject.FrameBuffer.WindowSize.Height
local size = 5 / 3
local defaultWidth = aspectRatio * size
local defaultHeight = size
local defaultProjection = 1
local defaultNear = 0.1
local defaultFar = 10000

local camera = GameObject("Camera")
camera:SetParent(level)
camera:SetProperties(defaultWidth, defaultHeight, defaultProjection, defaultNear, defaultFar)--120, resolution.Width / resolution.Height, 0.1, 10000)
camera:SetTransformation(Matrix3(0, 0, 12))

local light = GameObject("Light")
light.Enabled = true
light.Direction = Vector3(0, 0, -1)
light.Brightness = 1.5
light.Diffuse = RGBA(0.5, 0.5, 0.5, 1)
light.Specular = RGBA(0.15, 0.15, 0.15, 1)
light.Ambient = RGBA(0.1, 0.1, 0.1, 1)
light.Type = Enum.LightType.Directional
light:SetParent(simulation)

local scene = GameObject("Scene")
scene:SetParent(level)
scene.CurrentCamera = camera
scene.GlobalLight = light

local collisionGroups = GameObject("Object")
collisionGroups.Name = "CollisionGroups"
collisionGroups.Parent = physicsEnvironment

local playerGroup = GameObject("CollisionGroup")
playerGroup.Name = "PlayerGroup"
playerGroup.Parent = collisionGroups
playerGroup:AddInteraction(playerGroup, Enum.InteractionType.None)

local wallGroup = GameObject("CollisionGroup")
wallGroup.Name = "WallGroup"
wallGroup.Parent = collisionGroups
wallGroup:AddInteraction(playerGroup, Enum.InteractionType.Resolve)
wallGroup:AddInteraction(wallGroup, Enum.InteractionType.None)

local enemyGroup = GameObject("CollisionGroup")
enemyGroup.Name = "EnemyGroup"
enemyGroup.Parent = collisionGroups
enemyGroup:AddInteraction(playerGroup, Enum.InteractionType.Detect)
enemyGroup:AddInteraction(wallGroup, Enum.InteractionType.Resolve)
enemyGroup:AddInteraction(enemyGroup, Enum.InteractionType.None)

local shieldGroup = GameObject("CollisionGroup")
shieldGroup.Name = "ShieldGroup"
shieldGroup.Parent = collisionGroups
shieldGroup:AddInteraction(playerGroup, Enum.InteractionType.Resolve)
shieldGroup:AddInteraction(wallGroup, Enum.InteractionType.Resolve)
shieldGroup:AddInteraction(enemyGroup, Enum.InteractionType.None)
shieldGroup:AddInteraction(wallGroup, Enum.InteractionType.None)

local colliders = GameObject("Object")
colliders.Name = "Colliders"
colliders.Parent = Engine

for i, name in pairs{ "Triangle", "Square", "Octagon", "Ship", "ChargerShield", "WormHead", "WormTail"} do
	local asset = GameObject("ColliderAsset")
	asset.Name = name
	asset["Configure"..name.."Mesh"](asset)
	asset.Parent = colliders
end

local materials = GameObject("Materials")
materials:SetParent(Engine)

local sceneDraw = GameObject("GlowingSceneOperation")
sceneDraw:SetParent(level)
sceneDraw:Configure(resolution.Width, resolution.Height, scene)
sceneDraw.Radius = 10
sceneDraw.Sigma = 20
sceneDraw.SkyBrightness = 1
sceneDraw.SkyBackgroundBrightness = 1
sceneDraw.SkyColor = RGBA(1, 1, 1, 1)
sceneDraw.SkyBackgroundColor = RGBA(0, 0, 0, 0)
sceneDraw.Resolution = Vector3(resolution.Width, resolution.Height)
sceneDraw.RenderAutomatically = true
sceneDraw.RangeFittingType = Enum.RangeFittingMode.Exposure
sceneDraw.Exposure = 0.1

local material = GameObject("Material")
material.Shininess = 10
material.Diffuse = RGBA(1, 1, 1, 0)
material.Specular = RGBA(1, 1, 1, 0)
material.Ambient = RGBA(1, 1, 1, 0)
material.Emission = RGBA(0, 0, 0, 0)
material:SetParent(Engine)

scene:AddLight(light)

--explorerScript:Run()

local backPanel = GameObject("Transform")
backPanel.Name = "BackPanel"
backPanel.Transformation = Matrix3(0, 0, -0.05) * Matrix3.NewScale(50, 50, 1)
backPanel.Parent = simulation

local backPanelModel = GameObject("Model")
backPanelModel.Asset = Engine.CoreMeshes.CoreSquare
backPanelModel.Parent = backPanel

local backPanelMaterial = GameObject("Material")
backPanelMaterial.Shininess = 10
backPanelMaterial.Diffuse = RGBA(0.1, 0.1, 0.1, 0)
backPanelMaterial.Specular = RGBA(0.2, 0.2, 0.2, 0)
backPanelMaterial.Ambient = RGBA(0.1, 0.1, 0.1, 0)
backPanelMaterial.Emission = RGBA(0, 0, 0, 0)
backPanelMaterial.Parent = backPanelModel

backPanelModel.MaterialProperties = backPanelMaterial

scene:AddObject(backPanelModel)

function newSprite(name, transformation, asset, colliderAsset, collisionGroup, parent)
	local transform = GameObject("Transform")
	
	local aspectRatio = asset:GetWidth() / asset:GetHeight()
	local width = 1
	local height = 1
	
	if aspectRatio > 1 then
		height = 1 / aspectRatio
	else
		width = aspectRatio
	end
	
	transform.Name = name
	transform.Transformation = transformation * Matrix3.NewScale(width, height, 1)
	transform.Parent = parent
	transform.IsStatic = false
	
	local model = GameObject("Model")
	model.Name = "Sprite"
	model.Asset = Engine.CoreMeshes.CoreSquare
	model.DiffuseTexture = asset
	model.MaterialProperties = material
	model.BlendTexture = false
	model.TextureColor = RGBA(1, 1, 1, 1)
	model.UVScale = Vector3(1, -1)
	model.UVOffset = Vector3(0, 1)
	model.Parent = transform
	
	local rigidBody = GameObject("RigidBody")
	rigidBody.Parent = transform
	
	local collider = GameObject("Collider2D")
	collider.Group = collisionGroup
	collider.Parent = rigidBody
	
	if colliderAsset == "circle" then
		collider.IsCircle = true
	else
		collider.Asset = colliderAsset
	end
	
	local mass = GameObject("PointMass")
	mass.Parent = collider
	
	rigidBody:AddMass(mass)
	scene:AddObject(model)
	physicsEnvironment:AddObject(collider)
	
	return transform
end

function container(name, parent)
	local object = GameObject("Object")
	object.Name = name
	object.Parent = parent
	
	return object
end

function newObject(name, parent, collisionGroup, colliderAsset, transformation, models, parentTransformation)
	local object = GameObject("Transform")

	object.Name = name
	object.Parent = parent
	object.IsStatic = false
	object.Transformation = parentTransformation or Matrix3()

	local rigidBody = GameObject("RigidBody")
	rigidBody.Parent = object
	
	local collider = GameObject("Collider2D")
	collider.Group = collisionGroup
	collider.Parent = rigidBody
	
	if colliderAsset == "circle" then
		collider.Asset = Engine.Colliders.Octagon--collider.IsCircle = true
	elseif colliderAsset ~= nil then
		collider.Asset = colliderAsset
	end
	
	local mass = GameObject("PointMass")
	mass.Parent = collider
	
	rigidBody:AddMass(mass)
	physicsEnvironment:AddObject(collider)
	
	local transform = GameObject("Transform")
	transform.Parent = object
	transform.Name = "Model"
	transform.IsStatic = false
	transform.Transformation = transformation
	
	for i, data in pairs(models) do
		local model = GameObject("Model")
		model.Name = data.Name
		model.Asset = meshes[data.Name]
		model.MaterialProperties = data.Material
		model.Color = data.Color
		model.Parent = transform
		
		scene:AddObject(model)
	end
	
	return object
end

function newMaterial(name, diffuse, specular, ambient, emissive, shininess, parent)
	local material = GameObject("Material")
	material.Name = name
	material.Shininess = shininess
	material.Diffuse = diffuse
	material.Specular = specular
	material.Ambient = ambient
	material.Emission = emissive
	material.Parent = parent
	
	return material
end

local enemyMaterials = container("EnemyMaterials", simulation)

newMaterial(
	"BasicEnemy",
	RGBA(206 / 255, 0.01, 0.01, 0),
	RGBA(1, 0.5, 0.5, 0),
	RGBA(206 / 255, 0.05, 0.05, 0),
	RGBA(0, 0, 0, 0),
	10,
	enemyMaterials
)

newMaterial(
	"SmartEnemyFan",
	RGBA(1, 233 / 255, 35 / 255, 0),
	RGBA(1, 233 / 255, 0.5, 0),
	RGBA(1, 233 / 255, 35 / 255, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"SmartEnemyCenter",
	RGBA(177 / 255, 188 / 255, 35 / 255, 0),
	RGBA(1, 0.85, 0.5, 0),
	RGBA(177 / 255, 188 / 255, 35 / 255, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"MineLayerEnemy",
	RGBA(0.5, 0.01, 0.5, 0),
	RGBA(1, 0.5, 1, 0),
	RGBA(0.5, 0.05, 0.5, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"MineEnemyShell",
	RGBA(0.01, 0.01, 1, 0),
	RGBA(0.5, 0.5, 1, 0),
	RGBA(0.05, 0.05, 1, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"MineEnemyCenter",
	RGBA(1, 0.01, 0.01, 0),
	RGBA(1, 0.5, 0.5, 0),
	RGBA(1, 0.05, 0.05, 0),
	RGBA(0.5, 0.01, 0.01, 0),
	50,
	enemyMaterials
)

newMaterial(
	"WormEnemy",
	RGBA(1, 0.5, 0.01, 0),
	RGBA(1, 0.01, 0.01, 0),
	RGBA(1, 0.5, 0.05, 0),
	RGBA(0, 0, 0, 0),
	10,
	enemyMaterials
)

newMaterial(
	"WormEnemyDead",
	RGBA(0.2, 0.1, 0.01, 0),
	RGBA(0.5, 0.01, 0.01, 0),
	RGBA(0.2, 0.1, 0.05, 0),
	RGBA(0, 0, 0, 0),
	10,
	enemyMaterials
)

newMaterial(
	"WormEyes",
	RGBA(0.01, 0.01, 0.01, 0),
	RGBA(0.5, 0.5, 1, 0),
	RGBA(0.05, 0.05, 0.05, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyCenter",
	RGBA(0.5, 0.01, 0.01, 0),
	RGBA(0.5, 0.25, 0.25, 0),
	RGBA(0.5, 0.05, 0.05, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyCenterActive",
	RGBA(1, 0.01, 0.01, 0),
	RGBA(1, 0.5, 0.5, 0),
	RGBA(1, 0.05, 0.05, 0),
	RGBA(0.5, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyFan",
	RGBA(1, 1, 0.01, 0),
	RGBA(1, 1, 0.5, 0),
	RGBA(1, 1, 0.05, 0),
	RGBA(0.25, 0.25, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyFanDisabled",
	RGBA(0.25, 0.25, 0.01, 0),
	RGBA(1, 1, 10.5, 0),
	RGBA(0.5, 0.5, 0.05, 0),
	RGBA(0, 0, 0, 0),
	50,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyShield",
	RGBA(1, 1, 1, 0),
	RGBA(1, 1, 1, 0),
	RGBA(1, 1, 1, 0),
	RGBA(0, 0, 0, 0),
	250,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyShieldWarming",
	RGBA(1, 0.5, 0.01, 0),
	RGBA(1, 0.75, 0.5, 0),
	RGBA(1, 0.5, 0.05, 0),
	RGBA(0, 0, 0, 0),
	250,
	enemyMaterials
)

newMaterial(
	"ChargerEnemyShieldOverheated",
	RGBA(1, 0.01, 0.01, 0),
	RGBA(1, 0.25, 0.25, 0),
	RGBA(1, 0.05, 0.05, 0),
	RGBA(0.5, 0, 0, 0),
	250,
	enemyMaterials
)

local laserMaterials = container("LaserMaterials", simulation)

newMaterial(
	"GreenLaser",
	RGBA(0.01, 1, 0.01, 0),
	RGBA(0.1, 1, 0.1, 0),
	RGBA(0.05, 1, 0.05, 0),
	RGBA(0, 0.5, 0, 0),
	50,
	laserMaterials
)

newMaterial(
	"RedLaser",
	RGBA(1, 0.01, 0.01, 0),
	RGBA(1, 0.25, 0.25, 0),
	RGBA(1, 0.05, 0.05, 0),
	RGBA(0.75, 0.25, 0.25, 0),
	50,
	laserMaterials
)

newMaterial(
	"ExplosionMaterial",
	RGBA(1, 0.01, 0.01, 0),
	RGBA(1, 0.25, 0.25, 0),
	RGBA(1, 0.05, 0.05, 0),
	RGBA(0.75, 0.25, 0.25, 0),
	50,
	laserMaterials
)

local enemies = container("Enemies", simulation)
local basicEnemies = container("BasicEnemies", enemies)
local smartEnemies = container("SmartEnemies", enemies)
local mineEnemies = container("MineEnemies", enemies)
local mineLayerEnemies = container("MineLayerEnemies", enemies)
local wormEnemies = container("WormEnemies", enemies)
local chargerEnemies = container("ChargerEnemies", enemies)

function newCollider(parent, rigidBody, collisionGroup, colliderAsset)
	local collider = GameObject("Collider2D")
	collider.Group = collisionGroup
	collider.Parent = parent
	
	if colliderAsset == "circle" then
		collider.Asset = Engine.Colliders.Octagon--collider.IsCircle = true
	elseif colliderAsset ~= nil then
		collider.Asset = colliderAsset
	end
	
	local mass = GameObject("PointMass")
	mass.Parent = collider
	
	rigidBody:AddMass(mass)
	physicsEnvironment:AddObject(collider)
	
	return collider
end

function newTransform(name, parent, transformation)
	local transform = GameObject("Transform")
	transform.Parent = parent
	transform.Name = name
	transform.IsStatic = false
	transform.Transformation = transformation
	
	return transform
end

function newEnemy(name, position)
	if name == "basic" then
		local enemy = newObject(
			"BasicEnemy",
			basicEnemies,
			enemyGroup,
			"circle",
			Matrix3.NewScale(0.4, 0.4, 0.2) * Matrix3.EulerAnglesRotation(-math.pi/2, 0, math.pi/2),
			{
				{ Name = "BasicEnemy", Material = enemyMaterials.BasicEnemy, Color = RGBA(1, 1, 1, 1) }
			},
			Matrix3(position) * Matrix3.NewScale(0.5, 0.5, 0.5)
		)
	elseif name == "smart" then
		local enemy = newObject(
			"SmartEnemy",
			smartEnemies,
			enemyGroup,
			"circle",
			Matrix3.NewScale(0.4, 0.4, 0.2) * Matrix3.EulerAnglesRotation(-math.pi/2, 0, math.pi/2),
			{
				{ Name = "SmartEnemyFan", Material = enemyMaterials.SmartEnemyFan, Color = RGBA(1, 1, 1, 1) },
				{ Name = "SmartEnemyCenter", Material = enemyMaterials.SmartEnemyCenter, Color = RGBA(1, 1, 1, 1) }
			},
			Matrix3(position) * Matrix3.NewScale(0.5, 0.5, 0.5)
		)
	elseif name == "mine" then
		local enemy = newObject(
			"MineEnemy",
			mineEnemies,
			enemyGroup,
			"circle",
			Matrix3.NewScale(2, 2, 1) * Matrix3.EulerAnglesRotation(-math.pi/2, 0, math.pi/2),
			{
				{ Name = "MineClosed", Material = enemyMaterials.MineEnemyShell, Color = RGBA(1, 1, 1, 1) },
				{ Name = "MineCenter", Material = enemyMaterials.MineEnemyCenter, Color = RGBA(1, 1, 1, 1) }
			},
			Matrix3(position) * Matrix3.NewScale(0.25, 0.25, 0.25)
		)
		
		enemy.Model.MineCenter.GlowColor = RGBA(1, 0, 0, 0)
	elseif name == "mineLayer" then
		local enemy = newObject(
			"MineLayerEnemy",
			mineLayerEnemies,
			enemyGroup,
			Engine.Colliders.Triangle,
			Matrix3.NewScale(0.4, 0.4, 0.2) * Matrix3.EulerAnglesRotation(-math.pi/2, 0, math.pi),
			{
				{ Name = "MineLayer", Material = enemyMaterials.MineLayerEnemy, Color = RGBA(1, 1, 1, 1) }
			},
			Matrix3(position) * Matrix3.NewScale(0.5, 0.5, 0.5)
		)
	elseif name == "worm" then
		local enemy = container("WormEnemy", wormEnemies)
		local head = newObject(
			"WormHead",
			enemy,
			enemyGroup,
			Engine.Colliders.WormHead,
			Matrix3.NewScale(0.5, 0.325, 0.25) * Matrix3.EulerAnglesRotation(math.pi/2, 0, 0),
			{
				{ Name = "WormHead", Material = enemyMaterials.WormEnemy, Color = RGBA(1, 1, 1, 1) },
				{ Name = "WormEyes", Material = enemyMaterials.WormEyes, Color = RGBA(1, 1, 1, 1) }
			},
			Matrix3(position) * Matrix3.NewScale(0.4, 0.525, 0.4)
		)
		local tail = newObject(
			"WormTail",
			enemy,
			enemyGroup,
			Engine.Colliders.WormTail,
			Matrix3.NewScale(0.8, 0.3, 0.1) * Matrix3.EulerAnglesRotation(math.pi/2, 0, 0),
			{
				{ Name = "WormTail", Material = enemyMaterials.WormEnemy, Color = RGBA(1, 1, 1, 1) }
			},
			Matrix3(position) * Matrix3.NewScale(0.3 * 0.835, 0.4 * 0.835, 1)
		)
		
		local headTag = container("WormHead", tail.RigidBody.Collider2D)
		local tailTag = container("WormTail", tail.RigidBody.Collider2D)
		local segments = container("WormSegments", enemy)
		
		for i = 1, 5 do
			local segment = newObject(
				"WormSegment",
				segments,
				enemyGroup,
				Engine.Colliders.Square,
				Matrix3.NewScale(0.75, 0.3, 0.1) * Matrix3.EulerAnglesRotation(math.pi/2, 0, 0),
				{
					{ Name = "WormBody", Material = enemyMaterials.WormEnemy, Color = RGBA(1, 1, 1, 1) }
				},
				Matrix3(position + Vector3(-math.cos(2 * math.pi / i) + 1, -math.sin(2 * math.pi / i))) * Matrix3.NewScale(0.3 * 0.835, 0.5 * 0.835, 1)
			)
			
			local segmentTag = container("WormSegment", segment.RigidBody.Collider2D)
		end
	elseif name == "charger" then
		local enemy = newTransform("ChargerEnemy", chargerEnemies, Matrix3(position) * Matrix3.NewScale(0.5, 0.5, 0.5))
		
		local rigidBody = GameObject("RigidBody")
		rigidBody.Parent = enemy
		
		local shield = newTransform("Shield", rigidBody, Matrix3(0, 1.25, 0) * Matrix3.NewScale(3.25, 1.25, 1))
		local shieldCollider = newCollider(shield, rigidBody, shieldGroup, Engine.Colliders.ChargerShield)
		
		local fanColliders = newTransform("Fans", rigidBody, Matrix3.NewScale(0.75*0.9, 0.75*0.9, 1))
		
		for i=1, 4 do
			local fan = newTransform("Fan", fanColliders, Matrix3(2 * math.cos(i * math.pi / 2), 2 * math.sin(i * math.pi / 2), 0) * Matrix3.NewScale(1.5, 1.5, 1))
			local fanCollider = newCollider(fan, rigidBody, enemyGroup, "circle")
			
			local fanTag = container("ChargerFan", fanCollider)
		end
		
		local models = newTransform("Model", enemy, Matrix3.NewScale(1, 1, 0.5) * Matrix3.EulerAnglesRotation(-math.pi/2, 0, 0))
		local fanModel = newTransform("Fans", models, Matrix3.NewScale(1.1*0.9, 1.1*0.9, 1.1*0.9))
		
		local modelData = {
			{ Name = "Shield", Material = enemyMaterials.ChargerEnemyShield, Color = RGBA(1, 1, 1, 1) },
			{ Name = "ShieldEnemyCenter", Material = enemyMaterials.ChargerEnemyCenter, Color = RGBA(1, 1, 1, 1) }
		}
		
		for i, data in pairs(modelData) do
			local model = GameObject("Model")
			model.Name = data.Name
			model.Asset = meshes[data.Name]
			model.MaterialProperties = data.Material
			model.Color = data.Color
			model.Parent = models
			
			scene:AddObject(model)
		end
		
		for i = 1, 4 do
			local fanTransform = newTransform("Fan", fanModel, Matrix3.EulerAnglesRotation(0, i * math.pi / 2, 0), 0)
			
			local model = GameObject("Model")
			model.Name = "Fan"
			model.Asset = meshes.ShieldEnemyFan
			model.MaterialProperties = enemyMaterials.ChargerEnemyFan
			model.Color = RGBA(1, 1, 1, 1)
			model.Parent = fanTransform
			
			scene:AddObject(model)
		end
	end
end

local lasers = {}
local maxLasers = 3
local laserContainer = GameObject("Object")
laserContainer.Name = "Lasers"
laserContainer.Parent = simulation

function newLaser()
	local transform = GameObject("Transform")
	
	transform.Name = "Laser"
	transform.Parent = laserContainer
	transform.IsStatic = false
	
	local model = GameObject("Model")
	
	model.MaterialProperties = laserMaterials.GreenLaser
	model.Asset = meshes.Laser
	model.Parent = transform
	
	scene:AddObject(model)
	
	lasers[#lasers + 1] = transform
end

local lightContainer = container("LaserLights", simulation)
local activeLights = 0
local laserLights = {}

function laserLight(position, glowColor)
	activeLights = activeLights + 1
	
	local light = laserLights[activeLights]
	
	if not light then
		light = GameObject("Light")
		light.Parent = lightContainer
		light.Specular = RGBA(0, 0, 0, 1)
		light.Type = Enum.LightType.Point
		light.Attenuation = Vector3(1, 0, 5)
		light.Brightness = 1
		
		scene:AddLight(light)
		
		laserLights[activeLights] = light
	end
	
	light.Diffuse = glowColor
	light.Ambient = glowColor
	light.Position = position
	light.Enabled = true
end

function drawLine(transform, start, finish, drawThick, glowColor)
	local offset = finish - start
	local length = offset:Length()
	
	transform.Transformation = Matrix3((start + finish) * 0.5 + Vector3(0, 0, -0.01)) * Matrix3.RollRotation(math.atan2(-offset.X, offset.Y)) * Matrix3.NewScale(drawThick and 0.1 or 0.05, length / 2, drawThick and 0.1 or 0.05)

	for i = 0, 1, 1 / length do
		laserLight(start + (finish - start) * i, glowColor)
	end
end

local player = newObject(
	"Player",
	simulation,
	playerGroup,
	Engine.Colliders.Ship,
	Matrix3.NewScale(0.2, 0.2, 0.2) * Matrix3.EulerAnglesRotation(-math.pi/2, math.pi, 0),
	{
		{ Name = "ShipBody", Material = material, Color = RGBA(40 / 255, 209 / 255, 33 / 255, 1) },
		{ Name = "ShipBar", Material = material, Color = RGBA(248 / 255, 248 / 255, 248 / 255, 1) },
		{ Name = "ShipEngine", Material = material, Color = RGBA(99 / 255, 95 / 255, 98 / 255, 1) },
		{ Name = "ShipLining", Material = material, Color = RGBA(17 / 255, 17 / 255, 17 / 255, 1) },
		{ Name = "ShipWings", Material = material, Color = RGBA(40 / 255, 155 / 255, 33 / 255, 1) }
	}
)

dofile("./assets/scripts/particleFactory.lua")

local emitters = loadEmitters("./assets/json/particleEffects/explosion.json", "rain")

local lastBounce

function ignore(hit)
	return hit:IsDescendantOf(player) and hit ~= lastBounce
end

function explode(object)
	local explosion = GameObject("Transform")
	explosion.Transformation = Matrix3(object:GetWorldPosition())
	explosion.Name = "Explosion"
	explosion.Parent = simulation
	
	local explosionEmitter = emitters.Explosion:Create(explosion, "Explosion", true)
	explosionEmitter.Asset = Engine.CoreMeshes.CoreCube
	explosionEmitter.MaterialProperties = laserMaterials.ExplosionMaterial
	
	scene:AddObject(explosionEmitter)
	
	explosionEmitter:FireParticles(75)
	
	local yellowExplosionEmitter = emitters.YellowExplosion:Create(explosion, "YellowExplosion", true)
	yellowExplosionEmitter.Asset = Engine.CoreMeshes.CoreCube
	yellowExplosionEmitter.MaterialProperties = laserMaterials.ExplosionMaterial
	
	scene:AddObject(yellowExplosionEmitter)
	
	yellowExplosionEmitter:FireParticles(75)
	
	local light = GameObject("Light")
	light.Parent = explosion
	light.Diffuse = RGBA(1, 0.25, 0, 1)
	light.Specular = RGBA(1, 0.5, 0, 1)
	light.Ambient = RGBA(0.8, 0.2, 0, 1)
	light.Type = Enum.LightType.Point
	light.Attenuation = Vector3(1, 0, 0.1)
	light.Position = object:GetWorldPosition()
	
	scene:AddLight(light)
	
	coroutine.wrap(function()
		local time = 0
		local constant = 10
		local offset = 0.2
		local scale = 1
		local deviation = 0.05
		
		while true do
			time = time + wait()
			
			local variable = scale * time - offset
			
			light.Brightness = constant * math.exp(-(variable * variable) / (2 * deviation))
			
			if time >= 1.9 then
				break
			end
		end
	end)()
	
	coroutine.wrap(function()
		wait(2)
		
		scene:RemoveObject(explosionEmitter)
		scene:RemoveObject(yellowExplosionEmitter)
		scene:RemoveLight(light)
		explosion:Remove()
	end)()
end

function attack(hit, attacking)
	if hit.Group == enemyGroup then
		if attacking then
			local deathTag = hit:GetByName("Dead")
			
			if not deathTag then
				explode(hit:GetComponent("Transform"))
				
				deathTag = container("Dead", hit)
			end
		end
		
		return true
	end
end

function fireLaser(start, direction, attacking, startIndex)
	if not startIndex then
		activeLights = 0
	end
	
	startIndex = startIndex or 1
	
	if startIndex > maxLasers then
		for i = activeLights + 1, #laserLights do
			laserLights[i].Enabled = false
		end
		
		return
	end
	
	local results = physicsEnvironment:CastRay(Ray(start, direction))
	local hit, distance, normal
	
	for i = 1, results:GetCount() do
		hit = results:GetHit(i - 1)
		distance = results:GetDistance(i - 1)
		
		if distance > -0.0001 and distance < 1.0001 and not ignore(hit) then
			normal = results:GetNormal(i - 1)
			
			break
		end
		
		hit = nil
		distance = nil
	end
	
	if not lasers[startIndex] then
		newLaser()
	end
	
	local isHitting = false
	
	if hit then
		if not attack(hit, attacking) then
			lastBounce = hit
			
			local dot = direction * normal
			local reflected = direction - normal * (dot * 2)
			
			isHitting = fireLaser(start + direction * distance, reflected, attacking, startIndex + 1)
		else
			isHitting = true
			
			for i = startIndex + 1, #lasers do
				lasers[i].Model.Visible = false
			end
			
			for i = activeLights + 1, #laserLights do
				laserLights[i].Enabled = false
			end
		end
	end
	if attacking then
		lasers[startIndex].Model.MaterialProperties = laserMaterials.RedLaser
		lasers[startIndex].Model.Color = RGBA(1, 1, 1, 0.99)
		lasers[startIndex].Model.GlowColor = RGBA(1, 0, 0, 0)
	else
		lasers[startIndex].Model.MaterialProperties = laserMaterials.GreenLaser
		lasers[startIndex].Model.Color = RGBA(1, 1, 1, isHitting and 0.8 or 0.4)
		lasers[startIndex].Model.GlowColor = RGBA(0, isHitting and 1 or 0.5, 0, 0)
	end
	
	drawLine(lasers[startIndex], start, start + direction * (distance or 1), attacking, lasers[startIndex].Model.GlowColor)
	
	lasers[startIndex].Model.Visible = true
	
	lastBounce = nil
	
	return isHitting
end

local walls = GameObject("Transform")

walls.Name = "Walls"
walls.Parent = simulation
walls.Transformation = Matrix3(0, 0, -0.1) * Matrix3.NewScale(36, 36, 1)

local rotatingWalls = GameObject("Transform")

rotatingWalls.Name = "RotatingWalls"
rotatingWalls.Parent = walls
rotatingWalls.Transformation = Matrix3.NewScale(0.5, 0.5, 0.5)
rotatingWalls.IsStatic = false

function newWall(transformation, parent)
	local transform = GameObject("Transform")
	
	transform.Name = "Wall"
	transform.Parent = parent
	transform.Transformation = transformation
	transform.IsStatic = parent.IsStatic
	
	local modelTransform = GameObject("Transform")
	modelTransform.Name = "Model"
	modelTransform.Parent = transform
	modelTransform.Transformation = Matrix3.PitchRotation(math.pi / 2)
	modelTransform.IsStatic = parent.IsStatic
	
	local model = GameObject("Model")
	
	model.MaterialProperties = material
	model.Asset = meshes.Wall
	model.Parent = modelTransform
	
	local rigidBody = GameObject("RigidBody")
	rigidBody.Parent = transform
	
	local collider = GameObject("Collider2D")
	collider.Asset = Engine.Colliders.Square
	collider.Group = wallGroup
	collider.Parent = rigidBody
	
	local mass = GameObject("PointMass")
	mass.Mass = 0
	mass.Parent = collider
	
	rigidBody:AddMass(mass)
	scene:AddObject(model)
	physicsEnvironment:AddObject(collider)
	
	return transform
end

do
	local sideLength = math.sin(math.pi / 8) / (math.cos(math.pi / 8) - 0.025)
	
	for i = 1, 8 do
		newWall(Matrix3.RollRotation(i * 2 * math.pi / 8) * Matrix3(0, 1, 0) * Matrix3.NewScale(sideLength, 0.025, 0.5), walls)
	end
	
	sideLength = math.sin(math.pi / 9) / (math.cos(math.pi / 9) - 0.025)
	
	for i = 1, 9 do
		if i % 3 ~= 0 then
			newWall(Matrix3.RollRotation(i * 2 * math.pi / 9) * Matrix3(0, 1, 0) * Matrix3.NewScale(sideLength, 0.025, 0.5), rotatingWalls)
		end
	end
end

local userInput = Engine.GameWindow.UserInput

local keyW = userInput:GetInput(Enum.InputCode.W)
local keyA = userInput:GetInput(Enum.InputCode.A)
local keyS = userInput:GetInput(Enum.InputCode.S)
local keyD = userInput:GetInput(Enum.InputCode.D)
local mousePosition = userInput:GetInput(Enum.InputCode.MousePosition)
local mouseLeft = userInput:GetInput(Enum.InputCode.MouseLeft)

local airDensity = 0.01
local speed = 1
local turnSpeedLimit = math.pi / 4

function computeDrag(velocity, collider, airDensity)
	local squareLength = velocity:SquareLength()
	
	if squareLength == 0 then
		return Vector3(0, 0, 0)
	end
	
	return -velocity:Unit() * (0.5 * collider:GetWidth(velocity) * squareLength * airDensity)
end

local lastAngle = 0
local wallAngle = 0
local wallSpeed = 0.1

local cm = Engine.CoreMeshes

local enemyTypes = { "basic", "basic", "basic", "basic", "smart", "smart", "mineLayer", "worm", "charger" }

function spawnRandom()
	local angle = 2 * math.pi * math.random()
	
	newEnemy(enemyTypes[math.random(1, #enemyTypes)], Vector3(math.sin(2 * math.pi / angle), math.cos(2 * math.pi / angle), 0) * 5)
end

function iterate(object, i)
	i = (i or -1) + 1
	
	if i < object:GetChildren() then
		return i, object:Get(i)
	end
end

function offset2D(point1, point2)
	local offset = point1 - point2
	
	return Vector3(offset.X, offset.Y, 0)
end

function rotate(object, angle)
	object.Transformation = Matrix3(object.Transformation:Translation()) * Matrix3.RollRotation(angle) * Matrix3.NewScale(object:GetScale())
end

function rotateYaw(object, angle)
	object.Transformation = Matrix3(object.Transformation:Translation()) * Matrix3.YawRotation(angle) * Matrix3.NewScale(object:GetScale())
end

function findWall(results)
	for i = 1, results:GetCount() do
		if results:GetHit(i - 1):IsDescendantOf(walls) then
			return results:GetDistance(i - 1)
		end
	end
	
	return 100
end

local time = 0

function died(queue, child)
	queue[#queue + 1] = child
end

function clean(parent,t)
	t = t.."\t"
	for i, child in iterate, parent do
		clean(child,t)
		
		if child:IsA("Model") then
			scene:RemoveObject(child)
		elseif child:IsA("Collider2D") then
			physicsEnvironment:RemoveObject(child)
		end
	end
end

function flushDead(queue)
	for i = 1, #queue do
		clean(queue[i],"")
		queue[i]:Remove()
	end
end

local nextSpawn = 5
local spawnRateMin = 1
local spawnRateMax = 8
local minSpawnCount = 1
local maxSpawnCount = 5

while true do
	local delta = wait()
	
	if delta > 1 / 55 then
		print("slow", delta)
	end
	
	player.RigidBody:AddForce(computeDrag(player.RigidBody.Velocity, player.RigidBody.Collider2D, airDensity), Vector3(0, 0, 0))
	
	if keyW:GetState() then
		player.RigidBody:AddForce(Vector3(0, speed, 0), Vector3(0, 0, 0))
	end
	
	if keyS:GetState() then
		player.RigidBody:AddForce(Vector3(0, -speed, 0), Vector3(0, 0, 0))
	end
	
	if keyA:GetState() then
		player.RigidBody:AddForce(Vector3(-speed, 0, 0), Vector3(0, 0, 0))
	end
	
	if keyD:GetState() then
		player.RigidBody:AddForce(Vector3(speed, 0, 0), Vector3(0, 0, 0))
	end
	
	local attacking = mouseLeft:GetState()
	
	local aimDirection = mousePosition:GetPosition() - Vector3(resolution.Width, resolution.Height) * 0.5
	local angle = math.atan2(-aimDirection.X, -aimDirection.Y)
	
	if lastAngle < angle - math.pi then
		lastAngle = lastAngle + 2 * math.pi
	elseif lastAngle > angle + math.pi then
		lastAngle = lastAngle - 2 * math.pi
	end
	
	angle = lastAngle + math.max(math.min(angle - lastAngle, turnSpeedLimit), -turnSpeedLimit)
	
	lastAngle = angle
	
	local playerDied = false
	
	for i = 0, player.RigidBody.Collider2D:GetCollisions() - 1 do
		local collision = player.RigidBody.Collider2D:GetCollision(i)
		
		if collision.OtherCollider then
			if collision.OtherCollider.Group == enemyGroup or collision.OtherCollider.Group == shieldGroup then
				playerDied = true
				
				break
			end
		end
	end
	
	if playerDied then
		explode(player)
		player.RigidBody.Velocity = Vector3(0, 0, 0)
		player:SetPosition(Vector3(0, 0, 0))
		
		nextSpawn = time + 5
	end
	
	local playerPosition = player:GetWorldPosition()
	
	rotate(player, angle)
	
	fireLaser(playerPosition, player:GetWorldTransformation():UpVector() * 100, attacking)
	
	camera:SetTransformation(Matrix3(playerPosition + Vector3(0, 0, 12)))
	
	wallAngle = (wallAngle + wallSpeed * delta) % (2 * math.pi)
	rotatingWalls.Transformation = Matrix3.RollRotation(wallAngle) * Matrix3.NewScale(0.5, 0.5, 0.5)
	
	if not playerDied and time >= nextSpawn then
		local spawning = math.random(minSpawnCount, maxSpawnCount)
		
		for i = 1, spawning do
			spawnRandom()
		end
		
		nextSpawn = time + math.random() * (spawnRateMax - spawnRateMin) + spawnRateMin
	end
	
	local deathQueue = {}
	
	for i, child in iterate, basicEnemies do
		local offset = offset2D(playerPosition, child:GetWorldPosition()):Unit()
		local angle = math.atan2(child.RigidBody.Velocity.Y, child.RigidBody.Velocity.X)
		
		child.RigidBody:AddForce(offset2D(playerPosition, child:GetWorldPosition()):Unit() * (speed * 0.75), Vector3(0, 0, 0))
		child.RigidBody:AddForce(computeDrag(child.RigidBody.Velocity, child.RigidBody.Collider2D, airDensity * 2), Vector3(0, 0, 0))
		
		rotate(child, angle)
		
		if playerDied or child.RigidBody.Collider2D:GetByName("Dead") then
			died(deathQueue, child)
		end
	end
	
	for i, child in iterate, smartEnemies do
		child.RigidBody:AddForce(offset2D(playerPosition + player.RigidBody.Velocity, child:GetWorldPosition()):Unit() * (speed * 0.9), Vector3(0, 0, 0))
		child.RigidBody:AddForce(computeDrag(child.RigidBody.Velocity, child.RigidBody.Collider2D, airDensity), Vector3(0, 0, 0))
		
		rotate(child, 2 * -time)
		
		if playerDied or child.RigidBody.Collider2D:GetByName("Dead") then
			died(deathQueue, child)
		end
	end
	
	for i, child in iterate, mineEnemies do
		local offset = offset2D(playerPosition, child:GetWorldPosition())
		
		if offset:SquareLength() < 25 then
			child.RigidBody:AddForce(offset:Unit() * (speed), Vector3(0, 0, 0))
			--child:SetScale(Vector3(0.4, 0.4, 1))
			child.Model.MineClosed.Asset = meshes.MineOpen
		else
			--child:SetScale(Vector3(0.3, 0.3, 1))
			child.Model.MineClosed.Asset = meshes.MineClosed
		end
		
		child.RigidBody:AddForce(computeDrag(child.RigidBody.Velocity, child.RigidBody.Collider2D, airDensity), Vector3(0, 0, 0))
		
		if playerDied or child.RigidBody.Collider2D:GetByName("Dead") then
			died(deathQueue, child)
		end
	end
	
	for i, child in iterate, mineLayerEnemies do
		local up = child:GetWorldTransformation():UpVector()
		local right = child:GetWorldTransformation():RightVector()
		local position = child:GetWorldPosition()
		
		local distance1 = findWall(physicsEnvironment:CastRay(Ray(position, (up + right) * 100)))
		local distance2 = findWall(physicsEnvironment:CastRay(Ray(position, (up - right) * 100)))
		
		if distance1 < distance2 then
			child.RigidBody:AddForce(-right * math.min(1 / distance1, 0.3), Vector3())
		else
			child.RigidBody:AddForce(right * math.min(1 / distance2, 0.3), Vector3())
		end
		
		child.RigidBody:AddForce(up * 0.3, Vector3())
		child.RigidBody:AddForce(computeDrag(child.RigidBody.Velocity, child.RigidBody.Collider2D, airDensity), Vector3(0, 0, 0))
		
		local spawnIteration1 = math.floor(time / 3.5)
		local spawnIteration2 = math.floor((time + delta) / 3.5)
		
		if spawnIteration1 ~= spawnIteration2 then
			newEnemy("mine", child:GetWorldPosition())
		end
		
		local angle = math.atan2(-child.RigidBody.Velocity.X, child.RigidBody.Velocity.Y)
		
		rotate(child, angle)
		
		if playerDied or child.RigidBody.Collider2D:GetByName("Dead") then
			died(deathQueue, child)
		end
	end
	
	for i, child in iterate, wormEnemies do
		local head = child.WormHead
		local up = head:GetWorldTransformation():UpVector()
		local right = head:GetWorldTransformation():RightVector()
		local position = head:GetWorldPosition()
		
		local distance1 = findWall(physicsEnvironment:CastRay(Ray(position, (up + right) * 100)))
		local distance2 = findWall(physicsEnvironment:CastRay(Ray(position, (up - right) * 100)))
		
		if distance1 < distance2 then
			head.RigidBody:AddForce(-right * math.min(1 / distance1, 0.3), Vector3())
		else
			head.RigidBody:AddForce(right * math.min(1 / distance2, 0.3), Vector3())
		end
		
		head.RigidBody:AddForce(up * 0.3, Vector3())
		head.RigidBody:AddForce(computeDrag(head.RigidBody.Velocity, head.RigidBody.Collider2D, airDensity), Vector3(0, 0, 0))
		
		local angle = math.atan2(-head.RigidBody.Velocity.X, head.RigidBody.Velocity.Y)
		
		rotate(head, angle)
		
		local previous = head
		local alive = 0
		
		for i, segment in iterate, child.WormSegments do
			local back = previous:GetWorldPosition() - previous:GetWorldTransformation():UpVector() * previous:GetScale().Y
			local position = segment:GetWorldPosition()
			local offset = back - position
			
			if offset:SquareLength() == 0 then
				offset = Vector3(0, -1, 0)
			end
			
			local desiredOffset = offset:Unit() * segment:GetScale().Y
			
			segment:Move(segment.Transformation * segment:GetWorldTransformationInverse() * (offset - desiredOffset))
			
			local angle = math.atan2(-offset.X, offset.Y)
			
			rotate(segment, angle)
			
			previous = segment
			
			if not segment.RigidBody.Collider2D:GetByName("Dead") then
				alive = alive + 1
			else
				segment.Model.WormBody.MaterialProperties = enemyMaterials.WormEnemyDead
			end
		end
		
		local tail = child.WormTail
		local back = previous:GetWorldPosition() - previous:GetWorldTransformation():UpVector() * previous:GetScale().Y
		local position = tail:GetWorldPosition()
		local offset = back - position
		
		if offset:SquareLength() == 0 then
			offset = Vector3(0, -1, 0)
		end
		
		local desiredOffset = offset:Unit() * tail:GetScale().Y
		
		tail:Move(tail.Transformation * tail:GetWorldTransformationInverse() * (offset - desiredOffset))
		
		local angle = math.atan2(-offset.X, offset.Y)
		
		rotate(tail, angle)
		
		if playerDied or alive == 0 then
			died(deathQueue, child)
		end
	end
	
	for i, child in iterate, chargerEnemies do
		rotate(child.RigidBody.Fans, time)
		rotateYaw(child.Model.Fans, -time)
		
		local iteration = math.floor(time / 6)
		local mode = iteration % 2
		local modeElapsed = time % 6
		
		if mode == 0 or (mode == 1 and modeElapsed > 4) then
			local position = child:GetWorldPosition()
			local offset = playerPosition - position
			
			if offset:SquareLength() == 0 then
				offset = Vector3(0, -1, 0)
			end
			
			local desiredOffset = offset:Unit() * 4
			
			child.RigidBody:AddForce((offset - desiredOffset):Unit() * 0.4, Vector3())
			
			local up = child:GetWorldTransformation():UpVector()
			
			local angle = math.atan2(-offset.X, offset.Y)
			local lastAngle = math.atan2(-up.X, up.Y)
			
			if angle < lastAngle - math.pi then
				angle = angle + 2 * math.pi
			elseif angle > lastAngle + math.pi then
				angle = angle - 2 * math.pi
			end
			
			angle = lastAngle + math.max(math.min(angle - lastAngle, 0.15), -0.15)
			
			rotate(child, angle)
			
			child.Model.Shield.GlowColor = RGBA(0, 0, 0, 0)
			child.Model.Shield.MaterialProperties = enemyMaterials.ChargerEnemyShield
		elseif mode == 1 then
			if modeElapsed < 0.5 then
				child.Model.Shield.GlowColor = RGBA(0.5, 0.25, 0, 0)
				child.Model.Shield.MaterialProperties = enemyMaterials.ChargerEnemyShieldWarming
			elseif modeElapsed < 2 then
				child.Model.Shield.GlowColor = RGBA(1, 0, 0, 0)
				child.Model.Shield.MaterialProperties = enemyMaterials.ChargerEnemyShieldOverheated
				child.RigidBody:AddForce(child:GetWorldTransformation():UpVector() * 5, Vector3())
			end
		end
		
		local alive = 0
		
		for i = 0, 3 do
			if not child.RigidBody.Fans:Get(i).Collider2D:GetByName("Dead") then
				alive = alive + 1
			else
				child.Model.Fans:Get((5 - i) % 4).Fan.MaterialProperties = enemyMaterials.ChargerEnemyFanDisabled
			end
		end
		
		child.RigidBody:AddForce(computeDrag(child.RigidBody.Velocity, child.RigidBody.Shield.Collider2D, airDensity), Vector3(0, 0, 0))
		
		if playerDied or alive == 0 then
			died(deathQueue, child)
		end
	end
	
	flushDead(deathQueue)
	
	time = time + delta
end