#pragma once

/*******************************************************************************
Project Name  : DragonFishing
File Name     : ChannelGroup.h
Team Name     : -
Creation Date : 2/14/2019
Purpose       : Defines what a ChannelGroup is to the audio system in relation
                to the FMOD ChannelGroup
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

/*!
\file  ChannelGroup.h
\brief
  Defines the structure of the ChannelGroup class used
  in the AudioEngine implementation
*/


#include "Channel.h"
#include "DSP.h"
#include "fmod.hpp"
#include <string>
#include <vector>
#include "Vector3.h"

namespace Audio
{
  class ChannelGroup
  {
  public:
    //std::vector<Channel*> mChannels;
    FMOD::ChannelGroup* mChannelGroup = nullptr;
    Vector3 position;
    float defaultVolume = 0;
    FMOD_RESULT result = FMOD_ERR_UNINITIALIZED;

    ChannelGroup() {};
    ChannelGroup(const std::string& name, const Vector3& pos, float dVol);

    void AddChannel(Channel& channel);
    void SetPosition(Vector3 pos);
    void SetVolume(float vol);
    void Update();
  };


  extern FMOD_VECTOR V3toFmodV(const Vector3& v);
}