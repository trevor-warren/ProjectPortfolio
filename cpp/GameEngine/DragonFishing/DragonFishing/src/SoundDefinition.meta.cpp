#include "SoundDefinition.h"

// use these as shortcuts to open the other templates with reflection examples
// #include "TypeTemplate.meta.cpp"
// #include "InheritedTemplate.meta.cpp"

namespace Audio
{
  using Engine::Object;

  Reflect_Inherited(SoundDefinition, Object,
    Document_Class("");

    Bind_Function(SetSound,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(std::string, name);
        );

				Bind_Parameters_No_Return(SetSound, name);
			);
		);

    Bind_Function(SetDefaultVolume,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter_Default(float, volume, 1.0f);
        );

        Bind_Parameters_No_Return(SetDefaultVolume, volume);
			);
		);

    Bind_Function(SetMinMaxDistance,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter_Default(float, min, 1.0f);

          Document("");
          Function_Parameter_Default(float, max, 5000.f);
        );

        Bind_Parameters_No_Return(SetMinMaxDistance, min, max);
			);
		);

    Bind_Function(Set3D,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(bool, b3D);
        );

        Bind_Parameters_No_Return(Set3D, b3D);
			);
		);

    Bind_Function(SetLooping,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(bool, bLoop);
        );

        Bind_Parameters_No_Return(SetLooping, bLoop);
			);
		);

    Bind_Function(SetStreaming,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(bool, bStreaming);
        );

        Bind_Parameters_No_Return(SetStreaming, bStreaming);
			);
		);

    Bind_Function(RegisterSound,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(std::string, name);
        );

        Bind_Parameters_No_Return(RegisterSound, name);
			);
		);
  // To see an example of how to configure reflection data check "TypeTemplate.meta.cpp and InheritedTemplate.meta.cpp"
  );
}
