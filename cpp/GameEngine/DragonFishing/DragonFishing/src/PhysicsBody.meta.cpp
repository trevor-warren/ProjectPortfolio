#include "PhysicsBody.h"

namespace Engine
{
	using Engine::Object;

	Reflect_Inherited(PhysicsBody, Object,
		Document_Class("");
		
		Document("");
		Archivable Class_Member(Vector3, Velocity);
		
		Document("");
		Archivable Class_Member(Vector3, Acceleration);
	);
}
