#pragma once

/*******************************************************************************
Project Name  : DragonFishing
File Name     : DSP.h
Team Name     : -
Creation Date : 2/22/2019
Purpose       : Defines what DSPs are to the Audio System
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

/*!
\file  ChannelGroup.h
\brief
  Defines the structure of a DSP which is used to modify channels or channel
  groups to provide certain affects to the playing sounds
*/


#include "fmod.hpp"

namespace Audio
{
  class DSP
  {
  public:
    FMOD::DSP* mDSP;
  };
}