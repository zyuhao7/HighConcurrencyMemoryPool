#pragma once

#include "Common.h"

class ThreadCache
{
public:
    // 申请和释放内存对象.
    void *Allocate(size_t size);
    void Deallocate(void *ptr, size_t size);

    // 从中心缓存获取对象.
    void *FetchFromCentralCache(size_t index, size_t size);

private:
    FreeList _freeLists[NFREELIST];
};

#if defined(_WIN32) || defined(_WIN64)
#define TLS_STORAGE __declspec(thread)
#else
#define TLS_STORAGE __thread // 或 thread_local
#endif

static TLS_STORAGE ThreadCache *pTLSThreadCache = nullptr;
