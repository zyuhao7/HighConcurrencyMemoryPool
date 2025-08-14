#pragma once

#include <iostream>
#include <vector>
#include <thread>
#include <algorithm>
#include <time.h>
#include <assert.h>
#include <mutex>

using std::cout;
using std::endl;

static const size_t MAX_BYTES = 256 * 1024; // 256KB
static const size_t NFREELIST = 208;        // 208个自由链表

#ifdef _WIN64
typedef unsigned long long PAGE_ID;
#elif _WIN32
typedef size_t PAGE_ID;
#else
typedef unsigned long PAGE_ID;
#endif

static void *&NextObj(void *obj)
{
    assert(obj != nullptr);
    return *(void **)obj;
}

// 管理小对象的自由链表
class FreeList
{
public:
    void Push(void *obj)
    {
        assert(obj != nullptr);
        NextObj(obj) = _freeList;
        _freeList = obj;
    }
    void *Pop()
    {
        assert(_freeList != nullptr);
        void *obj = _freeList;
        _freeList = NextObj(obj);
        return obj;
    }
    bool Empty()
    {
        return _freeList == nullptr;
    }

    size_t &MaxSize()
    {
        return _maxSize;
    }

private:
    void *_freeList = nullptr;
    size_t _maxSize = 1;
};

//  计算对象大小的对齐映射规则.
class SizeClass
{
public:
    // 整体控制在最多10%左右的内碎片浪费
    // [1,128]					    8byte对齐	     freelist[0,16)
    // [128+1,1024]				    16byte对齐	     freelist[16,72)
    // [1024+1,8*1024]		     	128byte对齐	     freelist[72,128)
    // [8*1024+1,64*1024]	    	1024byte对齐     freelist[128,184)
    // [64*1024+1,256*1024]		    8*1024byte对齐   freelist[184,208)

    static inline size_t _RoundUp(size_t bytes, size_t align)
    {
        return (bytes + align - 1) & ~(align - 1);
    }

    static inline size_t RoundUp(size_t size)
    {
        if (size <= 128)
            return _RoundUp(size, 8); // 8字节对齐
        else if (size <= 1024)
            return _RoundUp(size, 16); // 16字节对齐
        else if (size <= 8 * 1024)
            return _RoundUp(size, 128); // 128字节对齐
        else if (size <= 64 * 1024)
            return _RoundUp(size, 1024); // 1024字节对齐
        else if (size <= 256 * 1024)
            return _RoundUp(size, 8 * 1024); // 8*1024字节对齐
        else
        {
            assert(false);
            return -1;
        }
    }

    static inline size_t _Index(size_t bytes, size_t align_shift)
    {
        return (bytes + (1 << align_shift) - 1) >> align_shift - 1;
    }
    // 计算映射的哪一个自由链表桶.
    static inline size_t index(size_t bytes)
    {
        assert(bytes <= MAX_BYTES);
        // 每个区块链数
        static int group_array[4] = {16, 56, 56, 56};
        if (bytes <= 128)
            return _Index(bytes, 3); // 8字节对齐, 2^3=8
        else if (bytes <= 1024)
            return _Index(bytes - 128, 4) + group_array[0]; // 16字节对齐, 2^4=16
        else if (bytes <= 8 * 1024)
            return _Index(bytes - 1024, 7) + group_array[0] + group_array[1]; // 128字节对齐, 2^7=128
        else if (bytes <= 64 * 1024)
            return _Index(bytes - 8 * 1024, 10) + group_array[0] + group_array[1] + group_array[2];                   // 1024字节对齐, 2^10=1024
        else if (bytes <= 256 * 1024)                                                                                 // if (bytes <= 256 * 1024)
            return _Index(bytes - 64 * 1024, 13) + group_array[0] + group_array[1] + group_array[2] + group_array[3]; // 8*1024字节对齐, 2^13=8192
        else
            assert(false);
        return -1;
    }
};

// new Add
// 以此 thread cache 从中心缓存获取多少个对象
static size_t NumMoveSize(size_t size)
{
    assert(size > 0);
    // [2, 512] 一次批量移动多少个对象的上限值
    int num = MAX_BYTES / size;
    if (num < 2)
        num = 2; // 最少移动2个对象
    else if (num > 512)
        num = 512; // 最多移动512个对象
    return num;
}
// 管理多个连续页大块内存跨度结构
struct Span
{
    PAGE_ID _pageId = 0;
    size_t _n = 0;
    Span *_next = nullptr;
    Span *_prev = nullptr;

    size_t _useCount = 0;
    void *_freeList = nullptr; // 自由链表头指针
};

// 带头双向循环链表
class SpanList
{
public:
    SpanList()
    {
        _head = new Span();
        _head->_next = _head;
        _head->_prev = _head;
    }
    void Insert(Span *pos, Span *newSpan)
    {
        assert(pos != nullptr && newSpan != nullptr);
        Span *prev = pos->_prev;
        // prev  newSpan pos
        prev->_next = pos;
        pos->_prev = newSpan;
        newSpan->_next = pos;
        newSpan->_prev = prev;
    }

    void Erase(Span *pos)
    {
        assert(pos != nullptr && pos != _head);
        Span *prev = pos->_prev;
        Span *next = pos->_next;
        prev->_next = next;
        next->_prev = prev;
        // delete pos;
    }

private:
    Span *_head;

public:
    std::mutex _mtx;
};