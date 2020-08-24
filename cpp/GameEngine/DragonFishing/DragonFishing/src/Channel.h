#pragma once

/*******************************************************************************
Project Name  : DragonFishing
File Name     : Channel.h
Team Name     : -
Creation Date : 2/14/2019
Purpose       : Define what a Channel is in the audio engine
                FMOD System
Author        : Daniel Ospina

All content © 2019 DigiPen (USA) Corporation, all rights reserved.
*******************************************************************************/

// Doxygen style file header
/*!
\file  Channel.h
\brief
  Defines the structure of the Channel class used
  in the AudioEngine implementation
*/


#include "DSP.h"
#include "fmod.hpp"
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
  /******************************************************************************/
  /*!
  \class Channel
  \brief
  This class defines a single channel in the audio engine system. A channel is
  structured around the state machine defined by Guy Somberg in his CppCon 2017
  presentation "Game Audio Programming in C++" as well as his book titled
  "Game Audio Programming Principles and Practices"
  */
  /******************************************************************************/
  class Channel
  {
  public:
    enum class STATE { INITIALIZE, DEVIRTUALIZE, TOPLAY, LOADING, PLAYING, STOPPING, STOPPED, VIRTUALIZING, VIRTUAL };
    FMOD::Channel *mChannel;
    std::string soundID;
    Vector3     position;
    float       soundVolume;
    STATE       state;
    bool        stopRequested;
    float       stopFader;
    float       virtualizeFader;

    FMOD_RESULT result;

    Channel();
    Channel(const std::string& id, Vector3 pos, float vdB);
    void Update(float dtSeconds);
    void UpdateChannelParameters();
    bool ShouldBeVirtual(bool allowOneShot) const;
    bool IsPlaying() const;
    float GetVolume() const;
    void Stop();
  };
}

