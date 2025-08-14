#pragma once
#include "Common.h"

// 单例模式
class CentralCache
{

public:
    static CentralCache *GetInstance()
    {
        return &Inst;
    }

    // 获取一个非空的 span
    Span *GetOneSpan(SpanList *list, size_t bytes_size);
    // 从中心缓存获取一定数量的对象给 thread cache
    size_t FetchRangeObj(void *&start, void *&end, size_t batchNum, size_t size);

private:
    SpanList _spanLists[NFREELIST];

private:
    CentralCache() {}
    CentralCache(const CentralCache &) = delete;

    static CentralCache Inst;
};