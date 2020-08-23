#include "AudioSystem.h"
#include "SoundEmitter.h"

namespace Audio
{
  void SoundEmitter::Initialize()
  {
    //mVolume = 1.0f;
  }

  void SoundEmitter::Update(float dt)
  {
    if (mChannelID < 0)
      return;

    // Get the object's transform
    std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      return;

    // Get the object's position
    Vector3 pos = trans->GetWorldPosition();

    AUDIO_ENGINE->SetChannel3DPosition(mChannelID, pos);
  }

  void SoundEmitter::PlaySound(std::string soundName, bool looping, std::string channelGroup)
  {
    mSoundName = soundName;
    mChannelGroupName = channelGroup;

    // If currently playing, stop playing the sound
    if (IsPlaying())
    {
      Stop();
    }

    // Get the object's transform
    std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      return;

    // Get the object's position
    Vector3 pos = trans->GetWorldPosition();
    mChannelID = AUDIO_ENGINE->PlaySound(mSoundName, mChannelGroupName, pos, mVolume);
  }

  void SoundEmitter::Pause()
  {
    if (IsPlaying())
      AUDIO_ENGINE->SetChannelPause(mChannelID, true);
    else
      AUDIO_ENGINE->SetChannelPause(mChannelID, false);
  }
  
  void SoundEmitter::Play()
  {
    // If currently playing, stop playing the sound
    if (IsPlaying())
    {
      Stop();
    }

    // Get the object's transform
    std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
    {
      mChannelID = AUDIO_ENGINE->PlaySound(mSoundName, mChannelGroupName, Vector3(0, 0, 0), mVolume);
      return;
    }
      

    // Get the object's position
    Vector3 pos = trans->GetWorldPosition();
    mChannelID = AUDIO_ENGINE->PlaySound(mSoundName, mChannelGroupName, pos, mVolume);
  }
  
  float SoundEmitter::GetVolume()
  {
    return mVolume;
  }
  
  void SoundEmitter::SetVolume(float volume)
  {
    mVolume = volume;
  }
  
  void SoundEmitter::SetSound(const std::string& name)
  {
    mSoundName = name;
  }
  
  void SoundEmitter::SetChannelGroup(const std::string& channelGroup)
  {
    mChannelGroupName = channelGroup;
  }
  
  void SoundEmitter::Stop()
  {
    AUDIO_ENGINE->StopChannel(mChannelID);
  }
  
  bool SoundEmitter::IsPlaying()
  {
    return AUDIO_ENGINE->IsPlaying(mChannelID);
  }
}