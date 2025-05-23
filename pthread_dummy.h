#pragma once

#if defined(IN_WINPTHREAD)
#  if defined(DLL_EXPORT)
#    define WINPTHREAD_API  __declspec(dllexport)  /* building the DLL  */
#  else
#    define WINPTHREAD_API  /* building the static library  */
#  endif
#else
#  if defined(WINPTHREADS_USE_DLLIMPORT)
#    define WINPTHREAD_API  __declspec(dllimport)  /* user wants explicit `dllimport`  */
#  else
#    define WINPTHREAD_API  /* the default; auto imported in case of DLL  */
#  endif
#endif

#ifdef __cplusplus
extern "C" {
#endif
typedef int pthread_rwlock_t;

WINPTHREAD_API int pthread_rwlock_rdlock(pthread_rwlock_t *l);
WINPTHREAD_API int pthread_rwlock_unlock(pthread_rwlock_t *l);
WINPTHREAD_API int pthread_rwlock_wrlock(pthread_rwlock_t *l);

#ifdef __cplusplus
}
#endif

#ifndef AcquireSRWLockShared

#define AcquireSRWLockShared(_lock) do { return pthread_rwlock_rdlock(reinterpret_cast<pthread_rwlock_t*>(_lock)) == 0;  } while(0)
#define ReleaseSRWLockShared(_lock) do { return pthread_rwlock_unlock(reinterpret_cast<pthread_rwlock_t*>(_lock)) == 0; } while(0)
#define AcquireSRWLockExclusive(_lock) do { return pthread_rwlock_wrlock(reinterpret_cast<pthread_rwlock_t*>(_lock)) == 0; } while(0)
#define ReleaseSRWLockExclusive(_lock) do { return pthread_rwlock_unlock(reinterpret_cast<pthread_rwlock_t*>(_lock)) == 0; } while(0)
#define SRWLOCK_INIT {reinterpret_cast<void*>(-1)} // PTHREAD_RWLOCK_INITIALIZER (pthread_rwlock_t)(-1)

#endif
