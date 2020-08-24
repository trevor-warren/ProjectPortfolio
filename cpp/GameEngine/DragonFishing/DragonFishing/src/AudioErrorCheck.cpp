#include "AudioErrorCheck.h"
#include "fmod_errors.h"
#include <cstdio>
#include <cstdlib>
#include <string>


void PRINT_POS_fn(FMOD_VECTOR pos)
{
  printf("Position is ( %.2f, %.2f, %.2f )\n\n", pos.x, pos.y, pos.z);
}

const char * FMOD_Result_ToString(FMOD_RESULT result)
{
  switch (result)
  {
  case FMOD_OK:                            return "FMOD_OK";
  case FMOD_ERR_BADCOMMAND:                return "FMOD_ERR_BADCOMMAND";
  case FMOD_ERR_CHANNEL_ALLOC:             return "FMOD_ERR_CHANNEL_ALLOC";
  case FMOD_ERR_CHANNEL_STOLEN:            return "FMOD_ERR_CHANNEL_STOLEN";
  case FMOD_ERR_DMA:                       return "FMOD_ERR_DMA";
  case FMOD_ERR_DSP_CONNECTION:            return "FMOD_ERR_DSP_CONNECTION";
  case FMOD_ERR_DSP_DONTPROCESS:           return "FMOD_ERR_DSP_DONTPROCESS";
  case FMOD_ERR_DSP_FORMAT:                return "FMOD_ERR_DSP_FORMAT";
  case FMOD_ERR_DSP_INUSE:                 return "FMOD_ERR_DSP_INUSE";
  case FMOD_ERR_DSP_NOTFOUND:              return "FMOD_ERR_DSP_NOTFOUND";
  case FMOD_ERR_DSP_RESERVED:              return "FMOD_ERR_DSP_RESERVED";
  case FMOD_ERR_DSP_SILENCE:               return "FMOD_ERR_DSP_SILENCE";
  case FMOD_ERR_DSP_TYPE:                  return "FMOD_ERR_DSP_TYPE";
  case FMOD_ERR_FILE_BAD:                  return "FMOD_ERR_FILE_BAD";
  case FMOD_ERR_FILE_COULDNOTSEEK:         return "FMOD_ERR_FILE_COULDNOTSEEK";
  case FMOD_ERR_FILE_DISKEJECTED:          return "FMOD_ERR_FILE_DISKEJECTED";
  case FMOD_ERR_FILE_EOF:                  return "FMOD_ERR_FILE_EOF";
  case FMOD_ERR_FILE_ENDOFDATA:            return "FMOD_ERR_FILE_ENDOFDATA";
  case FMOD_ERR_FILE_NOTFOUND:             return "FMOD_ERR_FILE_NOTFOUND";
  case FMOD_ERR_FORMAT:                    return "FMOD_ERR_FORMAT";
  case FMOD_ERR_HEADER_MISMATCH:           return "FMOD_ERR_HEADER_MISMATCH";
  case FMOD_ERR_HTTP:                      return "FMOD_ERR_HTTP";
  case FMOD_ERR_HTTP_ACCESS:               return "FMOD_ERR_HTTP_ACCESS";
  case FMOD_ERR_HTTP_PROXY_AUTH:           return "FMOD_ERR_HTTP_PROXY_AUTH";
  case FMOD_ERR_HTTP_SERVER_ERROR:         return "FMOD_ERR_HTTP_SERVER_ERROR";
  case FMOD_ERR_HTTP_TIMEOUT:              return "FMOD_ERR_HTTP_TIMEOUT";
  case FMOD_ERR_INITIALIZATION:            return "FMOD_ERR_INITIALIZATION";
  case FMOD_ERR_INITIALIZED:               return "FMOD_ERR_INITIALIZED";
  case FMOD_ERR_INTERNAL:                  return "FMOD_ERR_INTERNAL";
  case FMOD_ERR_INVALID_FLOAT:             return "FMOD_ERR_INVALID_FLOAT";
  case FMOD_ERR_INVALID_HANDLE:            return "FMOD_ERR_INVALID_HANDLE";
  case FMOD_ERR_INVALID_PARAM:             return "FMOD_ERR_INVALID_PARAM";
  case FMOD_ERR_INVALID_POSITION:          return "FMOD_ERR_INVALID_POSITION";
  case FMOD_ERR_INVALID_SPEAKER:           return "FMOD_ERR_INVALID_SPEAKER";
  case FMOD_ERR_INVALID_SYNCPOINT:         return "FMOD_ERR_INVALID_SYNCPOINT";
  case FMOD_ERR_INVALID_THREAD:            return "FMOD_ERR_INVALID_THREAD";
  case FMOD_ERR_INVALID_VECTOR:            return "FMOD_ERR_INVALID_VECTOR";
  case FMOD_ERR_MAXAUDIBLE:                return "FMOD_ERR_MAXAUDIBLE";
  case FMOD_ERR_MEMORY:                    return "FMOD_ERR_MEMORY";
  case FMOD_ERR_MEMORY_CANTPOINT:          return "FMOD_ERR_MEMORY_CANTPOINT";
  case FMOD_ERR_NEEDS3D:                   return "FMOD_ERR_NEEDS3D";
  case FMOD_ERR_NEEDSHARDWARE:             return "FMOD_ERR_NEEDSHARDWARE";
  case FMOD_ERR_NET_CONNECT:               return "FMOD_ERR_NET_CONNECT";
  case FMOD_ERR_NET_SOCKET_ERROR:          return "FMOD_ERR_NET_SOCKET_ERROR";
  case FMOD_ERR_NET_URL:                   return "FMOD_ERR_NET_URL";
  case FMOD_ERR_NET_WOULD_BLOCK:           return "FMOD_ERR_NET_WOULD_BLOCK";
  case FMOD_ERR_NOTREADY:                  return "FMOD_ERR_NOTREADY";
  case FMOD_ERR_OUTPUT_ALLOCATED:          return "FMOD_ERR_OUTPUT_ALLOCATED";
  case FMOD_ERR_OUTPUT_CREATEBUFFER:       return "FMOD_ERR_OUTPUT_CREATEBUFFER";
  case FMOD_ERR_OUTPUT_DRIVERCALL:         return "FMOD_ERR_OUTPUT_DRIVERCALL";
  case FMOD_ERR_OUTPUT_FORMAT:             return "FMOD_ERR_OUTPUT_FORMAT";
  case FMOD_ERR_OUTPUT_INIT:               return "FMOD_ERR_OUTPUT_INIT";
  case FMOD_ERR_OUTPUT_NODRIVERS:          return "FMOD_ERR_OUTPUT_NODRIVERS";
  case FMOD_ERR_PLUGIN:                    return "FMOD_ERR_PLUGIN";
  case FMOD_ERR_PLUGIN_MISSING:            return "FMOD_ERR_PLUGIN_MISSING";
  case FMOD_ERR_PLUGIN_RESOURCE:           return "FMOD_ERR_PLUGIN_RESOURCE";
  case FMOD_ERR_PLUGIN_VERSION:            return "FMOD_ERR_PLUGIN_VERSION";
  case FMOD_ERR_RECORD:                    return "FMOD_ERR_RECORD";
  case FMOD_ERR_REVERB_CHANNELGROUP:       return "FMOD_ERR_REVERB_CHANNELGROUP";
  case FMOD_ERR_REVERB_INSTANCE:           return "FMOD_ERR_REVERB_INSTANCE";
  case FMOD_ERR_SUBSOUNDS:                 return "FMOD_ERR_SUBSOUNDS";
  case FMOD_ERR_SUBSOUND_ALLOCATED:        return "FMOD_ERR_SUBSOUND_ALLOCATED";
  case FMOD_ERR_SUBSOUND_CANTMOVE:         return "FMOD_ERR_SUBSOUND_CANTMOVE";
  case FMOD_ERR_TAGNOTFOUND:               return "FMOD_ERR_TAGNOTFOUND";
  case FMOD_ERR_TOOMANYCHANNELS:           return "FMOD_ERR_TOOMANYCHANNELS";
  case FMOD_ERR_TRUNCATED:                 return "FMOD_ERR_TRUNCATED";
  case FMOD_ERR_UNIMPLEMENTED:             return "FMOD_ERR_UNIMPLEMENTED";
  case FMOD_ERR_UNINITIALIZED:             return "FMOD_ERR_UNINITIALIZED";
  case FMOD_ERR_UNSUPPORTED:               return "FMOD_ERR_UNSUPPORTED";
  case FMOD_ERR_VERSION:                   return "FMOD_ERR_VERSION";
  case FMOD_ERR_EVENT_ALREADY_LOADED:      return "FMOD_ERR_EVENT_ALREADY_LOADED";
  case FMOD_ERR_EVENT_LIVEUPDATE_BUSY:     return "FMOD_ERR_EVENT_LIVEUPDATE_BUSY";
  case FMOD_ERR_EVENT_LIVEUPDATE_MISMATCH: return "FMOD_ERR_EVENT_LIVEUPDATE_MISMATCH";
  case FMOD_ERR_EVENT_LIVEUPDATE_TIMEOUT:  return "FMOD_ERR_EVENT_LIVEUPDATE_TIMEOUT";
  case FMOD_ERR_EVENT_NOTFOUND:            return "FMOD_ERR_EVENT_NOTFOUND";
  case FMOD_ERR_STUDIO_UNINITIALIZED:      return "FMOD_ERR_STUDIO_UNINITIALIZED";
  case FMOD_ERR_STUDIO_NOT_LOADED:         return "FMOD_ERR_STUDIO_NOT_LOADED";
  case FMOD_ERR_INVALID_STRING:            return "FMOD_ERR_INVALID_STRING";
  case FMOD_ERR_ALREADY_LOCKED:            return "FMOD_ERR_ALREADY_LOCKED";
  case FMOD_ERR_NOT_LOCKED:                return "FMOD_ERR_NOT_LOCKED";
  case FMOD_ERR_RECORD_DISCONNECTED:       return "FMOD_ERR_RECORD_DISCONNECTED";
  case FMOD_ERR_TOOMANYSAMPLES:            return "FMOD_ERR_TOOMANYSAMPLES";
  case FMOD_RESULT_FORCEINT:               return "FMOD_RESULT_FORCEINT";
  default:
    break;
  }

  return "";
}

void FMOD_ERRCHECK_fn(FMOD_RESULT result, const char *file, int line, const char *msg)
{
  if (result != FMOD_OK)
  {
    if (std::string(msg).empty())
      printf("%s(%d): %s - %s \n", file, line, FMOD_Result_ToString(result), FMOD_ErrorString(result));

    else
      printf("%s(%d): %s - %s \n"
        "%s \n", file, line, FMOD_Result_ToString(result), FMOD_ErrorString(result), msg);
    //abort();
  }
}