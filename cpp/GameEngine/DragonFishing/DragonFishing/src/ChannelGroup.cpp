/*******************************************************************************
Project Name  : DragonFishing
File Name     : ChannelGroup.cpp
Team Name     : -
Creation Date : 2/14/2019
Purpose       : Implementation of Audio System's ChannelGroup object
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

// Doxygen style file header
/*!
\file  ChannelGroup.cpp
\brief
  Contains implementation for ChannelGroup class
*/

#include "AudioSystem.h"
#include "ChannelGroup.h"

namespace Audio
{
  ChannelGroup::ChannelGroup(const std::string& name, const Vector3& pos, float dVol) : position(pos), defaultVolume(dVol)
  {
    result = AUDIO_ENGINE->mSystem->createChannelGroup(name.c_str(), &mChannelGroup);
    FMOD_ERRCHECK(result);
  }

  void ChannelGroup::AddChannel(Channel& channel)
  {
    result = channel.mChannel->setChannelGroup(mChannelGroup);
    FMOD_ERRCHECK(result);
  }
  void ChannelGroup::SetPosition(Vector3 pos)
  {
    position = pos;
  }
  void ChannelGroup::SetVolume(float vol)
  {
    defaultVolume = vol;
  }
  void ChannelGroup::Update()
  {
    FMOD_VECTOR pos, vel = { 0.f, 0.f, 0.f };
    pos = V3toFmodV(position);

    result = mChannelGroup->set3DAttributes(&pos, &vel);
    FMOD_ERRCHECK(result);
    result = mChannelGroup->setVolume(defaultVolume);
    FMOD_ERRCHECK(result);
  }
}