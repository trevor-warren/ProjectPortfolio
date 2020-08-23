#include "WormSegment.h"

namespace GameLogic
{
  using Engine::Object;
  Reflect_Inherited(WormSegment, Object,
    Document_Class("");

    Class_Member(std::weak_ptr<Object>, PreviousSegment);

    Bind_Function(SetSpeed,
    
			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(float, speed);
        );

        Bind_Parameters_No_Return(SetSpeed, speed);
      );
    );
    
    Bind_Function(SetAcceleration,
    
			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(float, acceleration);
        );

        Bind_Parameters_No_Return(SetAcceleration, acceleration);
      );
    );
    
    Bind_Function(SetBoundaries,
    
			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(Vector3, bounds);
        );

        Bind_Parameters_No_Return(SetBoundaries, bounds);
      );
    );
    
  );
}