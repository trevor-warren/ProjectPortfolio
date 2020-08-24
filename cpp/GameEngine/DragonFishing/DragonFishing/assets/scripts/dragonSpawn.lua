--pcall(
  local level = Engine.Environments.Level

  local speed = 5.0
  local acceleration = 10.0;
  
  for k = 1,5 do

    -- making the first dragon segment, the head
    local dragon_head = GameObject("Transform")
    dragon_head.Name = "Dragon_Head"
    dragon_head.IsStatic = false
    dragon_head.Transformation = Matrix3(-50 + 10 * k, 30 + 5 * k, 20)
    dragon_head:SetParent(level.Simulation);
    
    local dragon_head_model = GameObject("Model")
    dragon_head_model.Asset = Engine.CoreMeshes.CoreCube
    dragon_head_model.MaterialProperties = Engine.Material
    dragon_head_model.Color = RGBA(1, 0, 0, 1)
    dragon_head_model:SetParent(dragon_head)
    
    local dragon_head_physics = GameObject("PhysicsBody")
    dragon_head_physics:SetParent(dragon_head)
    
    local dragon_head_AI = GameObject("WormSegment")
    dragon_head_AI:SetSpeed(speed)
    dragon_head_AI:SetBoundaries(Vector3(200, 50, 200))
    dragon_head_AI:SetParent(dragon_head)
    
    local emitters = loadEmitters("./assets/json/particleEffects/dragonBreath.json", "breathEmitters")
    
    local yellowBreathEmitter = emitters.FireBreathYellow:Create(dragon_head, "yellowBreathEmitter", true)
    yellowBreathEmitter.Asset = Engine.CoreMeshes.CoreBoundingVolume
    yellowBreathEmitter.MaterialProperties = Engine.FireMaterial
    yellowBreathEmitter.ConeParticleSpawner.SuperComponentHeight = 2
    
    local redBreathEmitter = emitters.FireBreathYellow:Create(dragon_head, "redBreathEmitter", true)
    redBreathEmitter.Asset = Engine.CoreMeshes.CoreBoundingVolume
    redBreathEmitter.MaterialProperties = Engine.FireMaterial
    redBreathEmitter.ConeParticleSpawner.SuperComponentHeight = 2
    
    local blueBreathEmitter = emitters.FireBreathYellow:Create(dragon_head, "blueBreathEmitter", true)
    blueBreathEmitter.Asset = Engine.CoreMeshes.CoreBoundingVolume
    blueBreathEmitter.MaterialProperties = Engine.FireMaterial
    blueBreathEmitter.ConeParticleSpawner.SuperComponentHeight = 2
    
    local fireLight = GameObject("Light")
    fireLight.Enabled = true
    fireLight.Position = Vector3(0, 50, 0)
    fireLight.Direction = Vector3(0, -1, 0)
    fireLight.Diffuse = RGBA(1 / 5, 0.85 / 5, 0, 1)
    fireLight.Specular = RGBA(1, 0.85, 0, 1)
    fireLight.Ambient = RGBA(1 / 5, 0.85 / 5, 0, 1)
    fireLight.Type = Enum.LightType.Spot
    fireLight.InnerRadius = math.pi / 4
    fireLight.OuterRadius = math.pi / 2
    fireLight.Attenuation = Vector3(1, 0, 0.025)
    fireLight.Brightness = 25
    fireLight:SetShadowsEnabled(false)
    fireLight:SetParent(dragon_head)
    
    local fireLight2 = GameObject("Light")
    fireLight2.Enabled = true
    fireLight2.Position = Vector3(0, 50, 0)
    fireLight2.Direction = Vector3(0, -1, 0)
    fireLight2.Diffuse = RGBA(0.93 / 5, 0.2 / 5, 0.015 / 5, 1)
    fireLight2.Specular = RGBA(0.93, 0.2, 0.015, 1)
    fireLight2.Ambient = RGBA(0.93 / 5, 0.2 / 5, 0.015 / 5, 1)
    fireLight2.Type = Enum.LightType.Spot
    fireLight2.InnerRadius = math.pi / 4
    fireLight2.OuterRadius = math.pi / 2
    fireLight2.Attenuation = Vector3(1, 0, 0.03)
    fireLight.Brightness = 15
    fireLight2:SetShadowsEnabled(false)
    fireLight2:SetParent(dragon_head)
    
    level.Scene:AddObject(dragon_head_model)
    level.Scene:AddObject(blueBreathEmitter)
    level.Scene:AddObject(redBreathEmitter)
    level.Scene:AddObject(yellowBreathEmitter)
    level.Scene:AddLight(fireLight)
    level.Scene:AddLight(fireLight2)
    
    local dragon_head_collider = GameObject("Collider")
    dragon_head_collider.DebugDrawer = Engine.DebugDraw
    dragon_head_collider:SetCollider(1, Matrix3() * 2)
    dragon_head_collider:SetCollisionGroup(2)
    dragon_head_collider:AddToCDU();
    dragon_head_collider:SetParent(dragon_head)
    
    local emitter = GameObject("SoundEmitter")
    emitter:SetParent(dragon_head)
    emitter:SetSound("adventurousMus")
    emitter:SetVolume(0.75)
    emitter:Play()
    
    local previous_dragon_segment = dragon_head_AI
    
    --Adding in all the other segments
    for i=1,20 do
    
      -- Transform
      local dragon_segment = GameObject("Transform")
      dragon_segment.Name = "Dragon_Segment"
      dragon_segment.IsStatic = false
      dragon_segment.Transformation = Matrix3(-50 + 10 * k, 30 + 5 * k, 20 - 2 * i)
      dragon_segment:SetParent(level.Simulation);
      
      -- Model
      local dragon_segment_model = GameObject("Model")
      dragon_segment_model.Asset = Engine.CoreMeshes.CoreCube
      dragon_segment_model.MaterialProperties = Engine.Material
      dragon_segment_model:SetParent(dragon_segment)
    
      -- Color
      if i % 2 == 0 then
        dragon_segment_model.Color = RGBA(0, 1, 0, 1)
      else
        dragon_segment_model.Color = RGBA(0, 0, 1, 1)
      end
    
      -- PhysicsBody
      local dragon_segment_physics = GameObject("PhysicsBody")
      dragon_segment_physics:SetParent(dragon_segment)
      
      -- WormSegment
        local dragon_segment_AI = GameObject("WormSegment")
        dragon_segment_AI:SetSpeed(0)
        --dragon_segment_AI:SetAcceleration(0)
        dragon_segment_AI:SetParent(dragon_segment)
        dragon_segment_AI.PreviousSegment = previous_dragon_segment
        previous_dragon_segment = dragon_segment_AI
    
      -- Collider
      local dragon_segment_collider = GameObject("Collider")
      dragon_segment_collider.DebugDrawer = Engine.DebugDraw
      dragon_segment_collider:SetCollider(1, Matrix3() * 2)
      dragon_segment_collider:SetCollisionGroup(2)
      dragon_segment_collider:AddToCDU();
      dragon_segment_collider:SetParent(dragon_segment)
    
      level.Scene:AddObject(dragon_segment_model)
    end
  end
--)

coroutine.wrap(function()
	while true do
		local delta = wait()

		local headTransformation = dragon_head:GetWorldTransformation()
		
		fireLight.Enabled = yellowBreathEmitter.Enabled
		fireLight.Direction = -headTransformation:FrontVector()
		fireLight.Position = headTransformation:Translation() + fireLight.Direction * 2
		
		fireLight2.Enabled = yellowBreathEmitter.Enabled
		fireLight2.Direction = fireLight.Direction
		fireLight2.Position = fireLight.Position
	end
end)()