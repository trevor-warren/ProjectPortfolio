return function(size, cframe)
	local collider = {
		vertexBuffer = {
			Vector3.new( 0.5, -0.5, -0.5),
			Vector3.new(-0.5, -0.5, -0.5),
			Vector3.new( 0.5, -0.5,  0.5),
			Vector3.new(-0.5, -0.5,  0.5),
			Vector3.new(-0.5,  0.5,  0.5),
			Vector3.new( 0.5,  0.5,  0.5)
		},
		faces = {
			{
				normal = Vector3.new(0, 0.707106781, -0.707106781),
				indexBuffer = { 5, 6, 1 }
			},
			{
				normal = Vector3.new(0, 0.707106781, -0.707106781),
				indexBuffer = { 5, 1, 2 }
			},
			{
				normal = Vector3.new(-1, 0, 0),
				indexBuffer = { 5, 2, 4 }
			},
			{
				normal = Vector3.new(0, 0, 1),
				indexBuffer = { 6, 5, 4 }
			},
			{
				normal = Vector3.new(0, 0, 1),
				indexBuffer = { 6, 4, 3 }
			},
			{
				normal = Vector3.new(1, 0, 0),
				indexBuffer = { 6, 3, 1 }
			},
			{
				normal = Vector3.new(0, -1, 0),
				indexBuffer = { 3, 4, 2 }
			},
			{
				normal = Vector3.new(0, -1, 0),
				indexBuffer = { 3, 2, 1 }
			},
		}
	}
	
	for i, v in pairs(collider.vertexBuffer) do
		collider.vertexBuffer[i] = cframe * Vector3.new(v.x * size.x, v.y * size.y, v.z * size.z)
	end
	
	for i, face in pairs(collider.faces) do
		local a = collider.vertexBuffer[face.indexBuffer[1]]
		local b = collider.vertexBuffer[face.indexBuffer[2]]
		local c = collider.vertexBuffer[face.indexBuffer[3]]
		
		face.normal = (b - a):Cross(c - a).unit--cframe * face.normal - cframe.p
	end
	
	return collider
end