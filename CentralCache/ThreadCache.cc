#include "ThreadCache.h"

void *ThreadCache::FetchFromCentralCache(size_t index, size_t size)
{
    return nullptr;
}

void *ThreadCache::Allocate(size_t size)
{
    assert(size <= MAX_BYTES);
    size_t align = SizeClass::RoundUp(size);
    size_t index = SizeClass::index(size);

    if (!_freeLists[index].Empty())
    {
        return _freeLists[index].Pop();
    }
    else
    {
        return FetchFromCentralCache(index, align);
    }
}

void ThreadCache::Deallocate(void *ptr, size_t size)
{
    assert(size <= MAX_BYTES);
    size_t index = SizeClass::index(size);
    _freeLists[index].Push(ptr);
}