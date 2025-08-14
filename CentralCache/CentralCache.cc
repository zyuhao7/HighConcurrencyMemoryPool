#include "CentralCache.h"

CentralCache CentralCache::Inst;

Span *CentralCache::GetOneSpan(SpanList &list, size_t size)
{
    return nullptr;
}

// 从中心缓存获取一定数量的对象给 thread cache
size_t CentralCache::FetchRangeObj(void *&start, void *&end, size_t batchNum, size_t size)
{
    size_t index = SizeClass::index(size);
    assert(index < NFREELIST);
    _spanLists[index]._mtx.lock();

    Span *span = GetOneSpan(_spanLists[index], size);
    assert(span);
    assert(span->_freeList);

    // 从 span中获取 batchNum(批数量)个对象, 如果不够 batchNum个, 有多少拿多少
    start = span->_freeList;
    end = start;

    size_t i = 0;
    size_t actualNum = 1;
    while (i < batchNum - 1 && NextObj(end))
    {
        end = NextObj(end);
        ++i;
        ++actualNum;
    }

    span->_freeList = NextObj(end);
    NextObj(end) = nullptr; // 断开链表连接
    span->_useCount += actualNum;

    _spanLists[index]._mtx.unlock();
}
