/*******************************************************************************
Project Name  : BasicFMOD
File Name     : AudioSystem.cpp
Team Name     : -
Creation Date : 2/14/2019
Purpose       : Make a full audio engine sturcture instead of manually handling
                FMOD System
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

// Doxygen style file header
/*!
\file  AudioEngine.cpp
\brief
  Contains implementation of Audio System
*/

#include "AudioSystem.h"
#include "Vector3.h"

namespace Audio
{
  AudioEngine* AUDIO_ENGINE = nullptr;

  FMOD::System * AudioEngine::mSystem = nullptr;

  FMOD_VECTOR V3toFmodV(const Vector3& v)
  {
    return FMOD_VECTOR{ v.X, v.Y, v.Z };
  }

  AudioEngine::AudioEngine() : mChannels(), mSounds(), nextChannelID(0), activeListenerID(0)
  {
    AUDIO_ENGINE = this;
  }

  void AudioEngine::Initialize()
  {
    result = FMOD::System_Create(&mSystem);
    FMOD_ERRCHECK(result);
    result = mSystem->init(128, FMOD_INIT_NORMAL, nullptr);
    FMOD_ERRCHECK(result);
    result = mSystem->set3DNumListeners(1);
    FMOD_ERRCHECK(result);
    result = mSystem->set3DSettings(1.0f, 1.0f, 1.0f);
    FMOD_ERRCHECK(result);

    FMOD_3D_ATTRIBUTES attributes;

    // Default values in case no listener is made
    attributes.position = { 0.f, 0.f, -1.f };
    attributes.velocity = { 0.f, 0.f, 0.f };
    attributes.forward = { 0.f, 0.f, 1.f };
    attributes.up = { 0.f, 1.f, 0.f };

    result = mSystem->set3DListenerAttributes(0, &attributes.position,
      &attributes.velocity,
      &attributes.forward,
      &attributes.up);
    FMOD_ERRCHECK(result);
  }

  void AudioEngine::Update(float dtSeconds)
  {
    std::vector<ChannelMap::iterator> stoppedChannels;
    for (auto it = mChannels.begin(), itEnd = mChannels.end(); it != itEnd; ++it)
    {
      it->second.Update(dtSeconds);
      if (it->second.state == Channel::STATE::STOPPED)
      {
        stoppedChannels.push_back(it);
      }

    }

    for (auto& it : stoppedChannels)
    {
      mChannels.erase(it);
    }

    result = mSystem->update();
    FMOD_ERRCHECK(result);
  }

  void AudioEngine::Shutdown()
  {
    // Release all the sounds
    for (auto& sound : mSounds)
    {
      if (sound.second->mSound)
      {
        result = sound.second->mSound->release();
        FMOD_ERRCHECK(result);
        sound.second->mSound = nullptr;
      }
    }

    // Release the system
    result = mSystem->close();
    FMOD_ERRCHECK(result);
    result = mSystem->release();
    FMOD_ERRCHECK(result);
  }

  void AudioEngine::RegisterSound(const std::string& name, const SoundDefinition& soundDefinition, bool bLoad)
  {
    // If the sound is already registered, don't re-register it
    if(mSounds.find(name) != mSounds.end())
    {
      return;
    }

    // Make a sound object using the given definition
    mSounds[name] = std::make_unique<Sound>();
    mSounds[name]->mSoundDefinition = soundDefinition;

    // If the sound should be loaded immediately, load it
    if (bLoad)
    {
      LoadSound(name);
    }

  }

  void AudioEngine::UnRegisterSound(const std::string& soundID)
  {
    auto toErase = mSounds.find(soundID);

    if (toErase != mSounds.end())
      mSounds.erase(toErase);
  }

  void AudioEngine::LoadSound(const std::string& name)
  {
    auto toLoad = mSounds.find(name);

    // Couldn't find the sound
    if (toLoad == mSounds.end())
      return;

    // If the sound is loaded
    if (toLoad->second->mSound)
      return;

    FMOD_MODE mode = FMOD_NONBLOCKING;
    mode |= toLoad->second->mSoundDefinition.is3D ? (FMOD_3D | FMOD_3D_INVERSETAPEREDROLLOFF) : FMOD_2D; // Is it 3D
    mode |= toLoad->second->mSoundDefinition.isLooping ? FMOD_LOOP_NORMAL : FMOD_LOOP_OFF;                   // Does the sound loop?
    mode |= toLoad->second->mSoundDefinition.isStreaming ? FMOD_CREATESTREAM : FMOD_CREATECOMPRESSEDSAMPLE;     // Should the sound be streamed?

    if (toLoad->second->mSoundDefinition.isStreaming)
    {
      result = mSystem->createStream(toLoad->second->mSoundDefinition.mSoundName.c_str(), mode, nullptr, &toLoad->second->mSound);
    }

    else
    {
      result = mSystem->createSound(toLoad->second->mSoundDefinition.mSoundName.c_str(), mode, nullptr, &toLoad->second->mSound);
    }

    FMOD_ERRCHECK(result);

    if (result == FMOD_OK)
    {
      result = toLoad->second->mSound->set3DMinMaxDistance(toLoad->second->mSoundDefinition.minDistance, toLoad->second->mSoundDefinition.maxDistance);
      FMOD_ERRCHECK_MSG(result, name.c_str());
    }
  }

  void AudioEngine::UnLoadSound(const std::string& soundID)
  {
    auto toUnload = mSounds.find(soundID);

    // Couldn't find the sound
    if (toUnload == mSounds.end())
      return;

    // If the sound is already unloaded
    if (!toUnload->second->mSound)
      return;


    result = toUnload->second->mSound->release();
    FMOD_ERRCHECK(result);
    toUnload->second->mSound = nullptr;
  }

  void AudioEngine::Set3DListenerAndOrientation(const Vector3& position, const Vector3& forward, const Vector3& up)
  {
    FMOD_VECTOR pos = V3toFmodV(position), fwd = V3toFmodV(forward), u = V3toFmodV(up);

    result = mSystem->set3DListenerAttributes(0, &pos, 0, &fwd, &u);
    FMOD_ERRCHECK(result);
  }

  int AudioEngine::PlaySound(const std::string& soundID, const std::string& channelGroupName, const Vector3& position, float volumedB)
  {
    int nChannelID = nextChannelID++;

    auto sound = mSounds.find(soundID);

    // If the sound is registered
    if (sound != mSounds.end())
    {
      // If the sound is not loaded, load it
      if (!sound->second->mSound)
      {
        LoadSound(soundID);
      }

      mChannels[nChannelID] = Channel(soundID, position, volumedB);

      if (!channelGroupName.empty())
      {
        if (mChannelGroups.find(channelGroupName) == mChannelGroups.end())
        {
          mChannelGroups[channelGroupName] = ChannelGroup(channelGroupName, Vector3(), 1.0f);
        }

        mChannelGroups.at(channelGroupName).AddChannel(mChannels[nChannelID]);
      }
      
    }

    return nChannelID;
  }

  void AudioEngine::StopChannel(int channelID, float fadeTimeSeconds)
  {
    if (mChannels.find(channelID) != mChannels.end())
    mChannels.at(channelID).stopFader = fadeTimeSeconds;
    mChannels.at(channelID).state = Channel::STATE::STOPPING;
  }

  void AudioEngine::SetChannelPause(int channelID, bool paused)
  {
    if (mChannels.find(channelID) != mChannels.end())
    {
      result = mChannels.at(channelID).mChannel->setPaused(paused);
      FMOD_ERRCHECK(result);
    }
  }

  void AudioEngine::StopAllChannels()
  {
    for (auto& channel : mChannels)
    {
      channel.second.state = Channel::STATE::STOPPED;
    }
  }

  void AudioEngine::SetChannel3DPosition(int channelID, const Vector3& pos)
  {
    if (mChannels.find(channelID) != mChannels.end())
      mChannels.at(channelID).position = pos;
  }

  void AudioEngine::SetChannelVolume(int channelID, float volume)
  {
    if (mChannels.find(channelID) != mChannels.end())
      mChannels.at(channelID).soundVolume = volume;
  }

  void AudioEngine::SetChannelGroup3DPosition(const std::string & channelGroup, const Vector3 & pos)
  {
    if (mChannelGroups.find(channelGroup) != mChannelGroups.end())
      mChannelGroups.at(channelGroup).position = pos;
  }

  void AudioEngine::SetChannelGroupVolume(const std::string & channelGroup, float volume)
  {
    if (mChannelGroups.find(channelGroup) != mChannelGroups.end())
      mChannelGroups.at(channelGroup).defaultVolume = volume;
  }

  void AudioEngine::SetChannelGroupPause(const std::string & channelGroup, bool paused)
  {
    if (mChannelGroups.find(channelGroup) != mChannelGroups.end())
    {
      result = mChannelGroups.at(channelGroup).mChannelGroup->setPaused(paused);
      FMOD_ERRCHECK(result);
    }
  }

  void AudioEngine::StopChannelGroup(const std::string & channelGroup)
  {
    if (mChannelGroups.find(channelGroup) != mChannelGroups.end())
    {
      result = mChannelGroups.at(channelGroup).mChannelGroup->stop();
      FMOD_ERRCHECK(result);
    }
  }

  bool AudioEngine::IsPlaying(int channelID) const
  {
    if(mChannels.find(channelID) != mChannels.end())
      return mChannels.at(channelID).IsPlaying();

    return false;
  }

  bool AudioEngine::SoundIsLoaded(const std::string& soundID)
  {
   if (mSounds.find(soundID) != mSounds.end() && mSounds.at(soundID)->mSound)
      return true;

    return false;
  }

}