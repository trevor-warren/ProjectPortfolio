#include "SoundEmitter.h"

// use these as shortcuts to open the other templates with reflection examples
// #include "TypeTemplate.meta.cpp"
// #include "InheritedTemplate.meta.cpp"

namespace Audio
{
  using Engine::Object;

  Reflect_Inherited(SoundEmitter, Object,
    Document_Class("");

    Bind_Function(PlaySound,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(std::string, name);
          
          Document("");
          Function_Parameter_Default(bool, looping, false);
          
          Document("");
          Function_Parameter_Default(std::string, channelGroup, "");
        );

				Bind_Parameters_No_Return(PlaySound, name, looping, channelGroup);
			);
		);

    Bind_Function(Pause,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

				Overload_Parameters();

				Bind_Parameters_No_Return(Pause);
			);
		);

    Bind_Function(Play,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

				Overload_Parameters();

				Bind_Parameters_No_Return(Play);
			);
		);

    Bind_Function(GetVolume,

			Document("");
			Function_Overload
			(
				Document("");
        Overload_Returns(float);

				Overload_Parameters();

				Bind_Parameters(GetVolume);
			);
		);

    Bind_Function(SetVolume,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(float, volume)
        );

				Bind_Parameters_No_Return(SetVolume, volume);
			);
		);

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

    Bind_Function(SetChannelGroup,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

        Overload_Parameters
        (
          Document("");
          Function_Parameter(std::string, channelGroup)
        );

				Bind_Parameters_No_Return(SetChannelGroup, channelGroup);
			);
		);

    Bind_Function(Stop,

			Document("");
			Function_Overload
			(
				Document("");
        Returns_Nothing;

				Overload_Parameters();

				Bind_Parameters_No_Return(Stop);
			);
		);

    Bind_Function(IsPlaying,

      Document("");
      Function_Overload
      (
        Document("");
        Overload_Returns(bool);
      
        Overload_Parameters();
      
        Bind_Parameters(IsPlaying);
      );
    );
  // To see an example of how to configure reflection data check "TypeTemplate.meta.cpp and InheritedTemplate.meta.cpp"
  );
}
