local level = Engine.Environments.Level

local camera = level.Camera

local emitters = loadEmitters("./assets/json/particleEffects/shipEngine.json", "shipEmitters")

local aspectRatio = GameObject.FrameBuffer.WindowSize.Width / GameObject.FrameBuffer.WindowSize.Height
local size = 5 / 3
local defaultWidth = aspectRatio * size
local defaultHeight = size
local defaultProjection = 1
local defaultNear = 0.1
local defaultFar = 5000
local resolution = GameObject.FrameBuffer.WindowSize

local camMovement = 0.05
local yawSpeed = 0.025
local pitchSpeed = 0.1
local drag = 0.99
local brakeDrag = 0.975
local acceleration = 20

local ship = GameObject("Transform")
ship.Name = "Ship"
ship.IsStatic = false
ship.Transformation = Matrix3(0, 50, 0)
ship:SetParent(level.Simulation)

local engineEmitter = emitters.EngineFire:Create(ship, "EngineFireEmitter", true)
engineEmitter.Asset = Engine.CoreMeshes.CoreBoundingVolume
engineEmitter.MaterialProperties = Engine.FireMaterial
engineEmitter.ConeParticleSpawner.SuperComponentHeight = 2

local shipModel = GameObject("Model")
shipModel.Asset = Engine.CoreMeshes.CoreCube
shipModel.MaterialProperties = Engine.Material
shipModel:SetParent(ship)

local shipPhysics = GameObject("PhysicsBody")
shipPhysics:SetParent(ship)

local targetTransform = GameObject("Transform")
targetTransform.Name = "CameraTarget"
targetTransform.IsStatic = false
targetTransform.InheritTransformation = true
targetTransform.Transformation = Matrix3(0, 7, 10) * Matrix3.PitchRotation(-math.pi/12)
targetTransform:SetParent(ship)

local ship_collider = GameObject("Collider")
ship_collider.DebugDrawer = Engine.DebugDraw
ship_collider:SetCollider(1, Matrix3() * 2)
ship_collider:SetCollisionGroup(1)
ship_collider:AddToCDU();
ship_collider:SetParent(ship)

local engineLight = GameObject("Light")
engineLight.Enabled = true
engineLight.Position = Vector3(0, 50, 0)
engineLight.Direction = Vector3(0, -1, 0)
engineLight.Diffuse = RGBA(1 / 5, 0.85 / 5, 0, 1)
engineLight.Specular = RGBA(1, 0.85, 0, 1)
engineLight.Ambient = RGBA(1 / 5, 0.85 / 5, 0, 1)
engineLight.Type = Enum.LightType.Spot
engineLight.InnerRadius = 0
engineLight.OuterRadius = math.pi / 3
engineLight.Attenuation = Vector3(1, 0, 0.05)
engineLight.Brightness = 5
engineLight:SetShadowsEnabled(false)
engineLight:SetParent(ship)

local ship_logic = GameObject("PlayerLogic")
ship_logic:SetParent(ship);

-- Adding a listener to the ship so you can hear things
local listener = GameObject("Listener")
listener:MakeActiveListener();
listener:SetParent(ship)

level.Scene:AddObject(shipModel)
level.Scene:AddObject(engineEmitter)
level.Scene:AddLight(engineLight)

function lerp(vec1, vec2, t)
	return vec1 * (1 - t) + vec2 * t
end

coroutine.wrap(function()
	local userInput = Engine.GameWindow.UserInput
	
	local mousePosition = userInput:GetInput(Enum.InputCode.MousePosition)
	local keyW = userInput:GetInput(Enum.InputCode.W)
	local keyS = userInput:GetInput(Enum.InputCode.S)
	local keyShift = userInput:GetInput(Enum.InputCode.LeftShift)
	
	local pitch = 0
	local yaw = 0

	local previousPosition = Vector3(0.5 * resolution.Width, 0.5 * resolution.Height)

	Engine.GameWindow:SetMousePosition(previousPosition)

	local lock = true
	local debounce = false
	
	while true do
		local delta = wait()
		local cursorPosition = mousePosition:GetPosition()

		local currentPosition = mousePosition:GetPosition()
		local mouseDelta = currentPosition - previousPosition

		if lock then
		yaw = (yaw - mouseDelta.X * delta * yawSpeed + 2 * math.pi) % (2 * math.pi)
		pitch = math.min(math.max(pitch - mouseDelta.Y * delta * pitchSpeed, -math.pi / 2), math.pi / 2) * 0.975
		end

		if keyShift:GetState() then
			if not debounce then
				lock = not lock
			end

			debounce = true
		else
			debounce = false
		end

		if lock then
			Engine.GameWindow:SetMousePosition(previousPosition)
		end

		--pitch = pitchSpeed * (cursorPosition.Y - 0.5 * resolution.Height) / resolution.Height
		--yaw = yaw + yawSpeed * delta * -(cursorPosition.X - 0.5 * resolution.Width) / resolution.Width
		
		local shipTransformation = ship.Transformation
		local shipRotation = shipTransformation:Rotation(Vector3())
		
		engineLight.Direction = shipTransformation:FrontVector()
		engineLight.Position = shipTransformation:Translation() + engineLight.Direction * 2
		ship.Transformation = Matrix3(shipTransformation:Translation()) * Matrix3.YawRotation(yaw) * Matrix3.PitchRotation(pitch)
		
		local cameraTransformation = camera:GetTransformation()
		local cameraRotation = cameraTransformation:Rotation(Vector3())
		local cameraPosition = cameraTransformation:Translation()
		local camQuat = Quaternion(cameraRotation)
		
		local targetTransformation = targetTransform:GetWorldTransformation()
		local targetRotation = targetTransformation:Rotation(Vector3())
		local targetPosition = targetTransformation:Translation()
		local targetQuat = Quaternion(targetRotation)
		
		local quat = camQuat:Slerp(targetQuat, camMovement)
		
		camera:SetProperties(defaultWidth, defaultHeight, defaultProjection, defaultNear, defaultFar)
		camera:SetTransformation(Matrix3(lerp(cameraPosition, targetPosition, camMovement)) * quat:Matrix())
		
		engineEmitter.Enabled = keyW:GetState()
		engineLight.Enabled = engineEmitter.Enabled

		if engineEmitter.Enabled then
			shipPhysics.Acceleration = ship.Transformation:FrontVector() * -acceleration
		else
			shipPhysics.Acceleration = Vector3()
		end
		
		shipPhysics.Velocity = shipPhysics.Velocity * (keyS:GetState() and brakeDrag or drag)
	end
end)()