function rec(obj, tabs)
	tabs = tabs or ""
	
	print(tabs..tostring(obj))
	
	local newTabs = tabs .. "\t"
	
	for i=0, obj:GetChildren()-1 do
		rec(obj:Get(i), newTabs)
	end
end

rec(Engine)

print("Matrix3", Matrix3)
print("Vector3", Vector3)
print("RGBA", RGBA)
print("Quaternion", Quaternion)
print("Character", Character)

print(RGBA(1, 1, 1, 1))
print(Quaternion(1, 0, 0, 0))

--print("\n\n\n\n\n\n")

local transform = GameObject("Transform")

print(transform:GetPosition())

local vec = Vector3(0,1,0)

transform:SetPosition(Vector3(0,1,0))

print(transform:GetPosition())

print(transform:GetPosition() == vec)

transform.Transformation = Matrix3.NewScale(Vector3(1, 2, 3)) * Matrix3(5, 3, 1)
print(transform:GetPosition())

print(Matrix3.NewScale(Vector3(1, 2, 3)) * Matrix3(5, 3, 1))

print("Transformation")
print(transform.Transformation)