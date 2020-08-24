#pragma once

/*******************************************************************************
Project Name  : DragonFishing
File Name     : SoundDefinition.h
Team Name     : Modern Family
Creation Date : 2/14/2019
Purpose       : Defines the structure of the SoundDefinition which is used when
                loading and playing sounds
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

#include "fmod.hpp"
#include "ObjectReflection.h"
#include "Object.h"
#include <string>

/******************************************************************************/
/*!
\namespace Audio

\brief
The namespace for all things audio

*/
/******************************************************************************/
namespace Audio
{
  /******************************************************************************/
  /*!
  \struct SoundDefinition
  \brief Used when defining a sound that can be loaded

  /******************************************************************************/
  class SoundDefinition : public Engine::Object
  {
  public:
    std::string mSoundName; //!< The path name of the sound
    float defaultVolume;    //!< The default volume, values range from 0 to 1
    float minDistance;      //!< The distance in which the sound can be heard at full volume
    float maxDistance;      //!< The maximum distance at which the sound can be heard
    bool  is3D;             //!< Is the sound a 3D sound?
    bool  isLooping;        //!< Does the sound loop?
    bool  isStreaming;      //!< Is the sound streamed in?


    // These 2 functions need to be defined. If they aren't defined then the parent class's versions will be called twice.
    void Initialize()  {};
    void Update(float) {};

    void SetSound(std::string name);
    void SetDefaultVolume(float volume = 1.0f);
    void SetMinMaxDistance(float min = 1.0f, float max = 5000.0f);
    void Set3D(bool b3D);
    void SetLooping(bool bLoop);
    void SetStreaming(bool bStreaming);

    void RegisterSound(std::string name);

    Instantiable;
    Inherits_Class(Object);
    Reflected(SoundDefinition);
  };

  /******************************************************************************/
  /*!
  \struct Sound
  \brief A combination struct that contains both a SoundDefinition and a pointer
  to an FMOD sound

  */
  /******************************************************************************/
  struct Sound
  {
    FMOD::Sound*    mSound = nullptr;
    SoundDefinition mSoundDefinition;
  };
}

namespace Engine
{
  //Class_Inherits(Audio::SoundDefinition, Engine::Object);
}