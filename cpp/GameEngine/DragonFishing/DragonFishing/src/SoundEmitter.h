#pragma once

#include "ObjectReflection.h"

#include "Object.h"
#include "AudioSystem.h"
#include "Transform.h"

/*****
TODO: Register new type to ObjectRegistration.cpp. Use the #include as a shortcut to open it.

Remove this once registered.

Warning: order of registration is crucial. Register this before any item that depends on it.
*****/

// #include "ObjectRegistration.cpp" // Remove this once registered

/*
Quick note about reflected objects and Lua:
Objects are expected to be passed around by reference using Handles and Lua will cache objects in its registry for lookup whenever they are referenced.
If you need an item to be passed around by value consider turning it into a type instead of a game object.
Only explicitly reflected items will be usable from Lua and file I/O. Reflection isn't a requirement for every item in a class.

Object creation and internal Lua referencing is automatically handled, as well as object destruction.

Objects will be automatically garbage collected if they have no references, so make sure that you don't leave dangling references to unneeded objects.

Objects were built to be highly mutable to make them compatible with a scripting environment. If you need const-correctness to be respected, create
a wrapper object to wrap around an internal class that respects the class's const correctness.

Objects have a built in parent-child hierarchy, which makes them incredibly useful for easy book keeping.

Objects do not need to have unique names per instance, even within the same parent.

It is highly recommended to create a separate .meta.cpp file for each reflected enum, type, and object class.
*/

// Objects can be defined in any namespace as long as they are reflected within the Engine namespace
namespace Audio
{
  class SoundEmitter : public Engine::Object
  {
  public:
    // These 2 functions need to be defined. If they aren't defined then the parent class's versions will be called twice.
    void Initialize();
    void Update(float);

    /******************************************************************************/
    /*!
    \fn PlaySound
    \brief Plays the specified sound. Can be used to make the sound loop and determine
    a channel group

    \param soundName
    The name of the sound to play. If no sound exists by this name, no sound will
    play

    \param looping
    Should the sound loop. Default to false and currently doesn't work.

    \param channelGroup
    The name of the channel group this sound should belong to. Defaults to the
    empty string which represents the master channel group.

    \return
    True if the channel is playing its sound, false otherwise
    */
    /******************************************************************************/
    void PlaySound(std::string soundName, bool looping = false, std::string channelGroup = "");
    
    /******************************************************************************/
    /*!
    \fn Pause
    \brief Pauses the sound if it's playing

    */
    /******************************************************************************/
    void Pause();
    
    /******************************************************************************/
    /*!
    \fn Play
    \brief Plays the sound this emitter is set to play
    */
    /******************************************************************************/
    void Play();

    /******************************************************************************/
    /*!
    \fn GetVolume
    \brief Gets the volume of the sound emitter

    \return
    The float value representing this emitter's volume
    */
    /******************************************************************************/
    float GetVolume();
    
    /******************************************************************************/
    /*!
    \fn SetVolume
    \brief Sets the volume of this emitters sound

    \param volume
    A float value to represent the volume. Ranges from 0 to 1 for silent to full
    volume. Can technically go above 1 to add volume gain to the sound.

    */
    /******************************************************************************/
    void SetVolume(float volume);
    
    /******************************************************************************/
    /*!
    \fn SetSound
    \brief Sets the sound to be played

    \param name
    The name of the sound

    */
    /******************************************************************************/
    void SetSound(const std::string& name);
    
    /******************************************************************************/
    /*!
    \fn SetChannelGroup
    \brief Sets the channel group that this emitter's sound should belong to

    \param channelGroup
    The name of the channel group the sound should belong to

    */
    /******************************************************************************/
    void SetChannelGroup(const std::string& channelGroup);
    
    /******************************************************************************/
    /*!
    \fn Stop
    \brief Stops the playing sound completely

    */
    /******************************************************************************/
    void Stop();

    /******************************************************************************/
    /*!
    \fn IsPlaying
    \brief Used to determine if the sound emitter is currently playing a sound

    \return
    True if the emitter is playing its sound, false otherwise
    */
    /******************************************************************************/
    bool IsPlaying();


    // Allows creation with the object factory. Use "NonInstantiable" for singletons/base types.
    Instantiable;

    // This must match the parent type.
    Inherits_Class(Object);

    Reflected(SoundEmitter);

  private:
    std::string mSoundName;
    std::string mChannelGroupName;
    int mChannelID = -1;
    float mVolume;
    bool play = false;
  };
}

namespace Engine
{
  /*
  These must be in namespace Engine.
  These register class inheritance hierarchy meta data for Handles to use internally in type deduction.
  These are required to be used before using any Handles that reference that type.
  To make an object that contains handles that reference its own type, look at Object & ObjectBase's base class workaround.
  */
  //Class_Inherits(Audio::SoundEmitter, Object);
}
