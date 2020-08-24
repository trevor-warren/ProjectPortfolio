#pragma once

#include "Object.h"
#include "Vector3.h"
#include "AabbTree.h"

namespace Engine
{
	class PhysicsBody : public Object
	{
	public:
		Vector3 Velocity;
		Vector3 Acceleration;

    int mID;
    static AabbTree PhysicsScene;

    //PhysicsBody();
    ~PhysicsBody();
    void Initialize();
		void Update(float delta);
    Aabb GetBoundingBox() const;

		Instantiable;

		Inherits_Class(Object);

		Reflected(PhysicsBody);
	};

	//Class_Inherits(PhysicsBody, Object);
}
