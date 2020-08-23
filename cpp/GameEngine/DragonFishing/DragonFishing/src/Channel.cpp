/*******************************************************************************
Project Name  : DragonFishing
File Name     : Channel.cpp
Team Name     : -
Creation Date : 2/14/2019
Purpose       : Implementation of Audio System's Channel object
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

// Doxygen style file header
/*!
\file  Channel.cpp
\brief
  Contains implementation for Channel class
*/


#include "Channel.h"
#include "AudioSystem.h"

namespace Audio
{
  Channel::Channel()
  {
  }

  Channel::Channel(const std::string& id, Vector3 pos, float vol)
  {
    mChannel = nullptr;
    soundID = id;
    position = pos;
    soundVolume = vol;
    state = STATE::INITIALIZE;
    stopRequested = false;

    stopFader = 0.f;
    virtualizeFader = 0.f;
  }

  void Channel::Update(float dtSeconds)
  {
    switch (state)
    {
    case STATE::INITIALIZE:   // Fallthrough to next case
    case STATE::DEVIRTUALIZE: // Fallthrough to next case
    case STATE::TOPLAY:
    {
      // Check if stop requested
      if (stopRequested)
      {
        state = STATE::STOPPING;
        return;
      }
      // Check if should be virtual


      // Check if loaded
      if (!AUDIO_ENGINE->SoundIsLoaded(soundID))
      {
        state = STATE::LOADING;
        return;
      }

      // Play the sound
      mChannel = nullptr;
      auto sound = AUDIO_ENGINE->mSounds.find(soundID);

      if (sound != AUDIO_ENGINE->mSounds.end())
      {
        result = AUDIO_ENGINE->mSystem->playSound(sound->second->mSound, nullptr, true, &mChannel);
        FMOD_ERRCHECK(result);
      }

      if (mChannel)
      {
        state = STATE::PLAYING;
        FMOD_VECTOR fVP = V3toFmodV(position);
        FMOD_VECTOR fVel{ 0.0f, 0.0f, 0.0f };
        result = mChannel->set3DAttributes(&fVP, &fVel);
        FMOD_ERRCHECK(result);
        result = mChannel->setVolume(soundVolume);
        FMOD_ERRCHECK(result);
        result = mChannel->setPaused(false);
        FMOD_ERRCHECK(result);
      }
      else
        state = STATE::STOPPING;
    }
    break;
    case STATE::LOADING:
      // Check to see if the sound is loaded
      if (AUDIO_ENGINE->SoundIsLoaded(soundID))
      {
        // If so, switch to TOPLAY state
        state = STATE::TOPLAY;
        return;
      }
      break;
    case STATE::PLAYING:
      // Update the Channel Parameters
      UpdateChannelParameters();
      // If it's done playing or a stop has been requested
      if (!IsPlaying() || stopRequested)
      {
        // Switch to stopping
        state = STATE::STOPPING;
        return;
      }

      // If the sound should be virtual
      // Fade out to virtual
      break;
    case STATE::STOPPING:
      // If the sound is finished
      stopFader -= dtSeconds;
      UpdateChannelParameters();
      if (stopFader <= 0.f)
      {
        result = mChannel->stop();
        FMOD_ERRCHECK(result);
      }
      if (!IsPlaying())
      {
        // Switch to STOPPED state
        state = STATE::STOPPED;
        return;
      }
      break;
    case STATE::STOPPED:
      break;
    case STATE::VIRTUALIZING:
      // Update the Channel Parameters
      // If the channel should no longer be virtual
      // Fade in to playing
      // If the sound is done virtualizing
      // Switch to the VIRTUAL state
      break;
    case STATE::VIRTUAL:
      // If a stop has been requested
      // Switch to stopping state
      // If it should no longer be virtual
      // Change to devirtualize state
    default:
      break;
    }
  }

  void Channel::UpdateChannelParameters()
  {
    FMOD_VECTOR fVP = V3toFmodV(position);
    FMOD_VECTOR fVel{ 0.0f, 0.0f, 0.0f };
    result = mChannel->set3DAttributes(&fVP, &fVel);
    FMOD_ERRCHECK(result);
    result = mChannel->setVolume(soundVolume);
    FMOD_ERRCHECK(result);
  }

  bool Channel::ShouldBeVirtual(bool allowOneShot) const
  {
    return false;
  }

  bool Channel::IsPlaying() const
  {
    bool playing = true;
    auto ok = mChannel->isPlaying(&playing); // Have to make a new FMOD_RESULT to maintain the const condition of the function
    FMOD_ERRCHECK(ok);
    return playing;
  }

  float Channel::GetVolume() const
  {
    return soundVolume;
  }

  void Channel::Stop()
  {
    stopRequested = true;
  }
}
