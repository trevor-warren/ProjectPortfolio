#pragma once

/*******************************************************************************
Project Name  : DragonFishing
File Name     : AudioSystem.h
Team Name     : Modern Family
Creation Date : 2/14/2019
Purpose       : Defines the structure of the AudioSystem class which handles all
                audio events
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

#include "AudioErrorCheck.h"
#include "Channel.h"
#include "ChannelGroup.h"
#include "fmod.hpp"
#include <memory>
#include "SoundDefinition.h"
#include <string>
#include <unordered_map>
#include <vector>
#include "Vector3.h"


/******************************************************************************/
/*!
\namespace Audio

\brief
The namespace for all things audio

*/
/******************************************************************************/
namespace Audio
{
  typedef std::unordered_map<unsigned, Channel> ChannelMap;  // <== I want to change this to be ChannelGroups
  typedef std::unordered_map<std::string, std::unique_ptr<Sound>> SoundMap;  
  typedef std::unordered_map<std::string, ChannelGroup> ChannelGroupMap;

  /******************************************************************************/
  /*!
  \class AudioEngine
  \brief
  This class is the main way in which you would interact with the  audio system
  */
  /******************************************************************************/
  class AudioEngine
  {
  public:
    // Basic constructor destructor stuff
    AudioEngine();  //!< Basic constructor
    ~AudioEngine() {} //!< Basic destructor

    // Main functions of the audio engine

    /******************************************************************************/
    /*!
    \fn Initialize
    \brief

    */
    /******************************************************************************/
    /*static*/ void Initialize();

    /******************************************************************************/
    /*!
    \fn Update
    \brief

    */
    /******************************************************************************/
    /*static*/ void Update(float dtSeconds);

    /******************************************************************************/
    /*!
    \fn Shutdown
    \brief

    */
    /******************************************************************************/
    /*static*/ void Shutdown();

    /******************************************************************************/
    /*!
    \fn RegisterSound
    \brief Registers a sound so that it can be loaded

    \param soundDefinition
    A \c SoundDefinition struct containing the data for a sound that could be loaded

    \param bLoad
    A boolean that I assume determines whether the sound should be loaded in
    immediately after registering

    \return
    An ID that can be used to reference the sound, used in unregisteirng
    */
    /******************************************************************************/
    void RegisterSound(const std::string& name, const SoundDefinition& soundDefinition, bool bLoad = true);

    /******************************************************************************/
    /*!
    \fn UnRegisterSound
    \brief Unregisters a sound

    \param soundId
    The ID of the sound to unregister

    */
    /******************************************************************************/
    void UnRegisterSound(const std::string& soundID);


    /******************************************************************************/
    /*!
    \fn LoadSound
    \brief Loads a sound so that it can be played

    \param soundID
    The ID of the sound to load

    */
    /******************************************************************************/
    void LoadSound(const std::string& name);

    /******************************************************************************/
    /*!
    \fn UnLoadSound
    \brief UnLoads a sound when it is done being used

    \param soundID
    The ID of the sound to unload

    */
    /******************************************************************************/
    void UnLoadSound(const std::string& soundID);

    /******************************************************************************/
    /*!
    \fn Set3DListenerAndOrientation
    \brief Sets the 3D listener's position and orientation

    \param position
    The position of the 3D listener

    \param forward
    The forward or "look" direction of the listener

    \param up
    The upwards direction of the listener

    */
    /******************************************************************************/
    void Set3DListenerAndOrientation(const Vector3& position, const Vector3& forward, const Vector3& up);

    /******************************************************************************/
    /*!
    \fn PlaySound
    \brief Plays a sound on a new channel

    \param soundID
    The ID of the sound to play

    \param position
    The 3D position of the sound, defaults to (0, 0, 0)

    \param volumedB
    The volume of the sound in decibels, defaults to 0.0f

    \return
    The channelID that is playing the sound

    */
    /******************************************************************************/
    int PlaySound(const std::string& soundID, const std::string& channelGroupName = "", const Vector3& position = Vector3(0, 0, 0), float volume = 1.0f);

    /******************************************************************************/
    /*!
    \fn StopChannel
    \brief Stops the specified channel. Fades out in the specified amount of seconds

    \param channelID
    The channel to stop

    \param fadeTimeSeconds
    The amount of time before the channel should be completely stopped during
    which it will fade out

    */
    /******************************************************************************/
    void StopChannel(int channelID, float fadeTimeSeconds = 0.0f);

    /******************************************************************************/
    /*!
    \fn PauseChanel
    \brief Pauses the specified channel.

    \param channelID
    The channel to pause

    */
    /******************************************************************************/
    void SetChannelPause(int channelID, bool paused);

    /******************************************************************************/
    /*!
    \fn StopAllChannels
    \brief Immediately stops all playing channels

    */
    /******************************************************************************/
    void StopAllChannels();

    /******************************************************************************/
    /*!
    \fn SetChannel3DPosition
    \brief Sets the position of the channel in 3D space

    \param channelID
    The channel being modified

    \param position
    The new position of the channel

    */
    /******************************************************************************/
    void SetChannel3DPosition(int channelID, const Vector3& position);

    /******************************************************************************/
    /*!
    \fn SetChannelVolume
    \brief Sets the volume of channel

    \param channelID
    The channel being modified

    \param volumedB
    The new volume of the channel

    */
    /******************************************************************************/
    void SetChannelVolume(int channelID, float volumedB);

    void SetChannelGroup3DPosition(const std::string& channelGroup, const Vector3& pos);

    void SetChannelGroupVolume(const std::string& channelGroup, float volume);

    void SetChannelGroupPause(const std::string& channelGroup, bool paused);

    void StopChannelGroup(const std::string& channelGroup);

    /******************************************************************************/
    /*!
    \fn IsPlaying
    \brief Used to determine if a channel is currently playing a sound

    \param channelID
    The channel to check

    \return
    True if the channel is playing its sound, false otherwise
    */
    /******************************************************************************/
    bool IsPlaying(int channelID) const;

    bool SoundIsLoaded(const std::string& soundID);

    static FMOD::System *mSystem;
    ChannelGroupMap mChannelGroups;
    ChannelMap      mChannels;
    SoundMap        mSounds;
    unsigned        nextChannelID;
    unsigned        activeListenerID;

    FMOD_RESULT result;
  };

  extern FMOD_VECTOR V3toFmodV(const Vector3& v);

  extern AudioEngine* AUDIO_ENGINE;

}