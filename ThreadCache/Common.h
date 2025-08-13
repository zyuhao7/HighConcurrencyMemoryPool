#pragma once

#include <iostream>
#include <vector>
#include <thread>
#include <time.h>
#include <assert.h>

using std::cout;
using std::endl;

static const size_t MAX_BYTES = 256 * 1024; // 256KB
static const size_t NFREELIST = 208;        // 208个自由链表

static void *&NextObj(void *obj)
{
    assert(obj != nullptr);
    return *(void **)obj;
}

// 管理小对象的自由链表
class FreeList
{
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

private:
    void *_freeList = nullptr;
};

//  计算对象大小的对齐映射规则.
class SizeClass
{
public:
    // 整体控制在最多10%左右的内碎片浪费
    // [1,128]					    8byte对齐	     freelist[0,16)
    // [128+1,1024]				16byte对齐	     freelist[16,72)
    // [1024+1,8*1024]		     	128byte对齐	     freelist[72,128)
    // [8*1024+1,64*1024]	    	1024byte对齐     freelist[128,184)
    // [64*1024+1,256*1024]		8*1024byte对齐   freelist[184,208)

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