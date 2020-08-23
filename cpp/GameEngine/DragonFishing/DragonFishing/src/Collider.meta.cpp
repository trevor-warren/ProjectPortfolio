#include "Collider.h"

namespace Engine
{
  Reflect_Inherited(Collider, Object,
    Document_Class("");

    Class_Member(std::weak_ptr<DebugDraw>, DebugDrawer);

    Bind_Function(SetCollider,

      Document("");
      Function_Overload
      (
        Document("");
        Returns_Nothing;
        
        Overload_Parameters
        (
          Document("");
          Function_Parameter(unsigned, type);

          Document("");
          Function_Parameter(Matrix3, transform);
        );

        Bind_Parameters_No_Return(SetCollider, type, transform);
      );
    );
    
    Bind_Function(ResetColliderType,

      Document("");
      Function_Overload
      (
        Document("");
        Returns_Nothing;
        
        Overload_Parameters
        (
          Document("");
          Function_Parameter(unsigned, type);
        );

        Bind_Parameters_No_Return(ResetColliderType, type);
      );
    );
    
    Bind_Function(ResetTransform,

      Document("");
      Function_Overload
      (
        Document("");
        Returns_Nothing;
        
        Overload_Parameters
        (
          Document("");
          Function_Parameter(Matrix3, transform);
        );

        Bind_Parameters_No_Return(ResetTransform, transform);
      );
    );
    
    Bind_Function(SetCollisionGroup,

      Document("");
      Function_Overload
      (
        Document("");
        Returns_Nothing;
        
        Overload_Parameters
        (
          Document("");
          Function_Parameter(unsigned, group);
        );

        Bind_Parameters_No_Return(SetCollisionGroup, group);
      );
    );
    
    Bind_Function(AddToCDU,

      Document("");
      Function_Overload
      (
        Document("");
        Returns_Nothing;
        
        Overload_Parameters();

        Bind_Parameters_No_Return(AddToCDU);
      );
    );
    
    Bind_Function(RemoveFromCDU,

      Document("");
      Function_Overload
      (
        Document("");
        Returns_Nothing;
        
        Overload_Parameters();

        Bind_Parameters_No_Return(RemoveFromCDU);
      );
    );

  );
}
