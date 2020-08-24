#include "AudioSystem.h"
#include "Listener.h"

namespace Audio
{
  unsigned Listener::nextListenerID = 0;

  void Listener::Initialize()
  {
    listenerID = nextListenerID++;
    MakeActiveListener();
  }

  void Listener::Update(float dt)
  {
    // If not the active listner, don't update
    if (!IsActive())
      return;

    // Get the object's transform
    std::shared_ptr<Engine::Transform> trans = GetComponent<Engine::Transform>();
    if (trans == nullptr)
      return;
    
    // Get the transformation matrix and get the position, forward, and up vectors
    auto& tranformMat = trans->GetWorldTransformation();
    Vector3 pos     = trans->GetWorldPosition(),
            forward = tranformMat.FrontVector(),
            up      = tranformMat.UpVector();

    // Set the listener's position and orientation
    AUDIO_ENGINE->Set3DListenerAndOrientation(pos, forward, up);
  }

  void Listener::MakeActiveListener()
  {
    // Set this listener as the activer listener
    AUDIO_ENGINE->activeListenerID = listenerID;
  }

  bool Listener::IsActive()
  {
    // Checks if this is the active listener and returns true if it is
    if(AUDIO_ENGINE->activeListenerID == listenerID)
      return true;

    return false;
  }
}