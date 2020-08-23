#include "Listener.h"

// use these as shortcuts to open the other templates with reflection examples
// #include "TypeTemplate.meta.cpp"
// #include "InheritedTemplate.meta.cpp"

namespace Audio
{
  using Engine::Object;

  Reflect_Inherited(Listener, Object,
    Document_Class("");

    Bind_Function(MakeActiveListener,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

				Overload_Parameters();

				Bind_Parameters_No_Return(MakeActiveListener);
			);
		);

    Bind_Function(IsActive,

			Document("");
			Function_Overload
			(
				Document("");
				Overload_Returns(bool);

				Overload_Parameters();

				Bind_Parameters(IsActive);
			);
		);
  // To see an example of how to configure reflection data check "TypeTemplate.meta.cpp and InheritedTemplate.meta.cpp"
  );
}
