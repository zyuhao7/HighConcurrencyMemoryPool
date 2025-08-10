#include <iostream>
#include <vector>
#include <time.h>
#include <stdlib.h> // malloc
#include <sys/mman.h>
#include <chrono>

using std::cout;
using std::endl;

inline static void *SystemAlloc(size_t kpage)
{

#ifdef _WIN32

    void *ptr = VirtualAlloc(0, kpage * (1 << 12), MEM_COMMIT | MEM_RESERVE,

                             PAGE_READWRITE);
#else
    // linux下brk mmap等
    void *ptr = mmap(nullptr, kpage * (1 << 12), PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

#endif

    if (ptr == nullptr)
        throw std::bad_alloc();
    return ptr;
}
template <typename T>
class ObjectPool
{
public:
    T *New()
    {
        T *obj = nullptr;
        // 优先使用还回来的内存块对象, 再次重复利用
        if (_freeList)
        {
            void *next = *(void **)_freeList;  // 获取下一个对象的指针
            obj = static_cast<T *>(_freeList); // 将当前对象转换为T类型
            _freeList = next;                  // 更新自由链表头指针
        }
        else
        {
            // 如果没有可用的对象, 则分配新的内存块
            if (_remainBytes < sizeof(T))
            {
                _remainBytes = 128 * 1024;
                // _memory = static_cast<char *>(malloc(_remainBytes));
                _memory = static_cast<char *>(SystemAlloc(_remainBytes >> 12)); // 分配页
                if (_memory == nullptr)
                    throw std::bad_alloc();
            }
            obj = reinterpret_cast<T *>(_memory);
            size_t objSize = sizeof(T) < sizeof(void *) ? sizeof(void *) : sizeof(T);
            _memory += objSize;      // 更新内存指针
            _remainBytes -= objSize; // 更新剩余字节数
        }
        new (obj) T(); // 使用定位new在分配的内存上构造对象
        return obj;
    }
    void Delete(T *ptr)
    {
        if (ptr == nullptr)
            return;

        ptr->~T();                 // 显式调用析构函数
        *(void **)ptr = _freeList; // 将当前对象链接到自由链表
        _freeList = ptr;           // 更新自由链表头指针
    }

private:
    char *_memory = nullptr;   // 指向大块内存的指针.
    size_t _remainBytes = 0;   // 大块内存在切分过程中剩余字节数.
    void *_freeList = nullptr; // 还回来的内存对象的自由链表.
};

struct TreeNode
{
    int _val;
    TreeNode *_left;
    TreeNode *_right;
    TreeNode()
        : _val(0), _left(nullptr), _right(nullptr)
    {
    }
};

void TestObjectPool()
{
    const size_t Rounds = 3;
    const size_t N = 100000;

    // 测试 new/delete
    auto start1 = std::chrono::high_resolution_clock::now();
    std::vector<TreeNode *> v1;
    v1.reserve(N);
    for (size_t j = 0; j < Rounds; ++j)
    {
        for (int i = 0; i < N; ++i)
            v1.push_back(new TreeNode);
        for (int i = 0; i < N; ++i)
            delete v1[i];
        v1.clear();
    }
    auto end1 = std::chrono::high_resolution_clock::now();

    // 测试 ObjectPool
    ObjectPool<TreeNode> TNPool;
    auto start2 = std::chrono::high_resolution_clock::now();
    std::vector<TreeNode *> v2;
    v2.reserve(N);
    for (size_t j = 0; j < Rounds; ++j)
    {
        for (int i = 0; i < N; ++i)
            v2.push_back(TNPool.New());
        for (int i = 0; i < N; ++i)
            TNPool.Delete(v2[i]);
        v2.clear();
    }
    auto end2 = std::chrono::high_resolution_clock::now();

    cout << "new cost time:" << std::chrono::duration_cast<std::chrono::microseconds>(end1 - start1).count() << " us\n";
    cout << "object pool cost time:" << std::chrono::duration_cast<std::chrono::microseconds>(end2 - start2).count() << " us\n";
}