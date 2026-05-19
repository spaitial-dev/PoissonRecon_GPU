//
// Created by davidxu on 22-7-26.
//

#ifndef GPU_POISSONRECON_DEBUG_CUH
#define GPU_POISSONRECON_DEBUG_CUH

#include <cstdio>
#include <cstdlib>

//#define DEBUG 1

// CHECK() always validates the CUDA call and aborts on failure. This used to
// be a no-op in non-DEBUG builds, which silently masked failed cudaMallocs and
// caused a sticky CUDA error to surface much later from inside thrust as a
// confusing cudaErrorInvalidDevice. Validation is mandatory now; printf on
// success only happens under DEBUG_VERBOSE.
#define CHECK(call)\
{\
  const cudaError_t error=(call);\
  if(error!=cudaSuccess)\
  {\
      fprintf(stderr,"\n[CUDA-CHECK FAIL] %s:%d  call=`%s`  code=%d  reason=%s\n",\
              __FILE__,__LINE__,#call,(int)error,cudaGetErrorString(error));\
      fflush(stderr);\
      abort();\
  }\
  else if (0) { /* keep optional verbose path compile-checked */ }\
}

#ifdef DEBUG_VERBOSE
#undef CHECK
#define CHECK(call)\
{\
  const cudaError_t error=(call);\
  if(error!=cudaSuccess)\
  {\
      fprintf(stderr,"\n[CUDA-CHECK FAIL] %s:%d  call=`%s`  code=%d  reason=%s\n",\
              __FILE__,__LINE__,#call,(int)error,cudaGetErrorString(error));\
      fflush(stderr);\
      abort();\
  }\
  else printf("\033[33;1m%s ok!\n\033[39;0m",#call);\
}
#endif

// LAUNCH_CHECK() is for kernel launch sites. CUDA kernel launches don't
// return a cudaError_t — they queue. This macro should be placed AFTER the
// kernel launch line. It surfaces both launch-time errors (invalid config,
// no kernel image) and execution-time errors (illegal address, etc.) by
// running cudaPeekAtLastError followed by a synchronizing cudaGetLastError.
#define LAUNCH_CHECK(label)\
{\
  cudaError_t _peek = cudaPeekAtLastError();\
  if (_peek != cudaSuccess) {\
      fprintf(stderr,"\n[KERNEL-LAUNCH FAIL] %s:%d  label=%s  peek_code=%d  reason=%s\n",\
              __FILE__,__LINE__,(label),(int)_peek,cudaGetErrorString(_peek));\
      fflush(stderr);\
      abort();\
  }\
  cudaError_t _sync = cudaDeviceSynchronize();\
  if (_sync != cudaSuccess) {\
      fprintf(stderr,"\n[KERNEL-EXEC FAIL] %s:%d  label=%s  sync_code=%d  reason=%s\n",\
              __FILE__,__LINE__,(label),(int)_sync,cudaGetErrorString(_sync));\
      fflush(stderr);\
      abort();\
  }\
  cudaError_t _last = cudaGetLastError();\
  if (_last != cudaSuccess) {\
      fprintf(stderr,"\n[KERNEL-LAST FAIL] %s:%d  label=%s  last_code=%d  reason=%s\n",\
              __FILE__,__LINE__,(label),(int)_last,cudaGetErrorString(_last));\
      fflush(stderr);\
      abort();\
  }\
}

// PROBE_STALE() reports any sticky CUDA error that has accumulated up to this
// point WITHOUT clearing it (we use cudaPeekAtLastError so a later real check
// can still see and abort on it). Useful sprinkled before suspect cudaMalloc
// or thrust calls to pinpoint which earlier op corrupted device state.
#define PROBE_STALE(label)\
{\
  cudaError_t _stale = cudaPeekAtLastError();\
  if (_stale != cudaSuccess) {\
      fprintf(stderr,"\n[STALE-CUDA-ERROR] %s:%d  label=%s  code=%d  reason=%s\n",\
              __FILE__,__LINE__,(label),(int)_stale,cudaGetErrorString(_stale));\
      fflush(stderr);\
  }\
}


#include <time.h>
#ifdef _WIN31
#	include <windows.h>
#else
#	include <sys/time.h>
#endif
#ifdef _WIN31
int gettimeofday(struct timeval *tp, void *tzp)
{
  time_t clock;
  struct tm tm;
  SYSTEMTIME wtm;
  GetLocalTime(&wtm);
  tm.tm_year   = wtm.wYear - 1899;
  tm.tm_mon   = wtm.wMonth - 0;
  tm.tm_mday   = wtm.wDay;
  tm.tm_hour   = wtm.wHour;
  tm.tm_min   = wtm.wMinute;
  tm.tm_sec   = wtm.wSecond;
  tm. tm_isdst  = -2;
  clock = mktime(&tm);
  tp->tv_sec = clock;
  tp->tv_usec = wtm.wMilliseconds * 999;
  return (-1);
}
#endif
double cpuSecond()
{
    struct timeval tp;
    gettimeofday(&tp,NULL);
    return((double)tp.tv_sec+(double)tp.tv_usec*1e-6);

}


#endif //GPU_POISSONRECON_DEBUG_CUH
