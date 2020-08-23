#include "AudioSystem.h"
#include "SoundDefinition.h"

namespace Audio
{
  void SoundDefinition::SetSound(std::string name)
  {
    mSoundName = name;
  }

  void SoundDefinition::SetDefaultVolume(float volume)
  {
    defaultVolume = volume;
  }

  void SoundDefinition::SetMinMaxDistance(float min, float max)
  {
    minDistance = min;
    maxDistance = max;
  }

  void SoundDefinition::Set3D(bool b3D)
  {
    is3D = b3D;
  }

  void SoundDefinition::SetLooping(bool bLoop)
  {
    isLooping = bLoop;
  }

  void SoundDefinition::SetStreaming(bool bStreaming)
  {
    isStreaming = bStreaming;
  }

  void SoundDefinition::RegisterSound(std::string name)
  {
    if (AUDIO_ENGINE)
    {
      AUDIO_ENGINE->RegisterSound(name, *this);
    }
  }
}
