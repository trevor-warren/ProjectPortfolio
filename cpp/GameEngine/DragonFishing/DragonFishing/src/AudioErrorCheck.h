#pragma once

#include "fmod.hpp"

void PRINT_POS_fn(FMOD_VECTOR pos);
void FMOD_ERRCHECK_fn(FMOD_RESULT result, const char *file, int line, const char *msg = "");
#define FMOD_ERRCHECK(_result) FMOD_ERRCHECK_fn(_result, __FILE__, __LINE__);
#define FMOD_ERRCHECK_MSG(_result, _msg) FMOD_ERRCHECK_fn(_result, __FILE__, __LINE__, _msg);
#define PRINT_POS(_pos) PRINT_POS_fn(_pos);