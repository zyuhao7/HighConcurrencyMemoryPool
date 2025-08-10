# ptmalloc 源码分析

`ptmalloc是glibc默认的内存分配器，基于Doug Lea的dlmalloc改进而来，支持多线程环境。以下是对ptmalloc关键实现的深入分析:`

## 一、整体架构
ptmalloc主要由以下部分组成：
* Arena管理：处理多线程竞争
* Chunk管理：内存块的组织方式
* Bins系统：空闲内存管理
* 系统调用封装：brk和mmap的使用

## 二、核心数据结构
### 1. malloc_chunk 结构

```c
struct malloc_chunk {
  size_t      mchunk_prev_size;  /* 前一个chunk的大小（如果前一个空闲） */
  size_t      mchunk_size;       /* 当前chunk的大小和标志位 */
  
  struct malloc_chunk* fd;       /* 空闲chunk的双向链表前向指针 */
  struct malloc_chunk* bk;       /* 空闲chunk的双向链表后向指针 */
  
  /* large bins  */
  struct malloc_chunk* fd_nextsize; /* 指向下一个不同大小的 chunk (前向指针) */
  struct malloc_chunk* bk_nextsize; /* 指向上一个不同大小的 chunk (后向指针) */
};
```

```text
large bin
│
├── [大小1] → chunkA → chunkB → chunkC (通过fd/bk连接)
├── [大小2] → chunkD → chunkE
├── [大小3] → chunkF
│
└── 大小排序链表: chunkA → chunkD → chunkF (通过fd_nextsize/bk_nextsize连接)
```
```c++
关键点：

使用边界标记法(Boundary Tag)管理内存

SIZE_SZ 依赖系统位数(32位4字节，64位8字节)

通过mchunk_size的最后3位存储标志：
PREV_INUSE (0x1)
IS_MMAPPED (0x2)
NON_MAIN_ARENA (0x4)
```
### 2. malloc_state 结构(arena)
```c
struct malloc_state {
  mutex_t mutex;                 /* 锁 */
  int flags;                     /* 标志位 */
  
  mfastbinptr fastbinsY[NFASTBINS];  /* 快速bin */
  mchunkptr top;                 /* top chunk */
  mchunkptr last_remainder;      /* 上次分割的剩余部分 */
  
  /* 常规bin */
  mchunkptr bins[NBINS * 2 - 2];
  
  unsigned int binmap[BINMAPSIZE]; /* bin位图 */
  
  struct malloc_state *next;     /* 链表指针 */
  INTERNAL_SIZE_T system_mem;    /* 分配的系统内存 */
  INTERNAL_SIZE_T max_system_mem;/* 最大系统内存 */
};
```

## 三、关键算法分析
### 1. 内存分配流程(_int_malloc)
```c++
fastbin处理：
1) 检查请求大小是否在fastbin范围(默认≤64字节)
2) 从对应 fastbin 链表取 chunk
3) 不分割，直接返回

smallbin处理：
1) 检查请求大小是否在smallbin范围(＜512字节)
2) 从对应 smallbin 取 chunk
3) 如果有剩余，放入 unsorted bin

unsorted bin处理：
1) 遍历unsorted bin 查找合适 chunk
2) 采用 FIFO 策略

largebin处理：
1) 使用最佳适应算法
2) 通过 binmap 加速查找

top chunk处理：
1) 分割 top chunk 满足请求
2) 不足时调用 sysmalloc 扩展
```

### 2. 内存释放流程(_int_free)
```c++

fastbin释放：
1) 直接插入对应 fastbin 链表
2) 不合并相邻空闲 chunk

合并操作：
1) 检查前一个 chunk 是否空闲
2) 检查后一个 chunk 是否空闲
3) 合并后放入 unsorted bin

mmap释放：
1) 直接munmap归还系统
```

### 3. sysmalloc系统调用
```c++

小内存(brk)：
1) 调整 program break
2) 需要处理前后虚拟内存页的对齐

大内存(mmap)：

1) 默认 >= 128KB 使用 mmap
2) 通过 MMAP_THRESHOLD 调整阈值
```

## 四、多线程实现
### 1. Arena管理
```C++
主arena：
1) 第一个线程使用主arena
2) 通过 brk 分配内存

非主arena：
1) 后续线程创建非主arena
2) 完全使用 mmap 分配
3) 默认最多 8 * CPU 核数个arena
```

### 2. 锁机制
```c++
arena锁：
1) 每个arena有自己的锁
2) 线程优先尝试当前arena

list_lock：
1) 全局arena链表锁
2) 创建新arena时使用
```

## 五、关键优化点
```c++

fastbin：
1) 单链表结构
2) LIFO策略
3) 不合并提高小内存分配速度

binmap：
1) 位图加速 largebin 查找
2) 避免遍历空bin

top chunk：
1) 保留剩余内存减少系统调用
```

## 六、典型问题分析
### 1. 内存碎片

```c++
外部碎片：
1) 频繁分配释放不同大小内存导致
解决方法：适当合并策略

内部碎片：
1) 对齐和 chunk 头开销
2) 最小 chunk 为 4 * SIZE_SZ
```

### 2. 性能问题
```c++
arena竞争：
1) 太多线程竞争少量 arena
解决方法：增加 arena数量

锁开销：
1) 频繁加锁解锁
解决方法：使用 thread cache
```


## 七、与tcmalloc对比
| 特性          | ptmalloc               | tcmalloc               |
|---------------|------------------------|------------------------|
| **线程模型**   | Arena + 全局锁          | Thread Local Cache     |
| **小内存分配** | Fast bins              | Size classes           |
| **大内存分配** | brk/mmap 混合策略       | 统一使用 mmap           |
| **内存碎片**   | 较高（外部碎片显著）     | 较低（精细大小分类）     |
| **锁竞争**     | 高（Arena间仍需竞争）   | 低（线程缓存无锁）       |
| **适用场景**   | 通用型应用              | 高并发服务器            |
| **额外功能**   | 支持MALLOC_CHECK_调试   | 内置堆性能分析工具       |
| **默认阈值**   | - Fast bin ≤80B        | - 小对象 ≤256KB        |
|               | - mmap ≥128KB默认      | - 大对象直接mmap        |

## 八、实验分析
```c++
// 1. chunk结构验证
void* p = malloc(24);
size_t* chunk = (size_t*)((char*)p - 2 * sizeof(size_t));
printf("chunk size: %zu\n", chunk[1] & ~0x7);

// 2. arena数量测试
#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h> // get_nprocs()
#include <malloc.h>      // malloc_stats()
#include <pthread.h>

void *thread_func(void *arg)
{
    malloc(1024); // 触发arena创建
    return NULL;
}

int main()
{
    // 获取系统CPU核心数
    int cores = get_nprocs();
    printf("CPU cores: %d\n", cores);

    // 计算最大arena数量（glibc规则）
    int arena_max = cores * (sizeof(void *) == 8 ? 2 : 1);
    printf("Max arena limit: %d\n", arena_max);

    // 创建线程测试实际arena数量
    pthread_t threads[100];
    for (int i = 0; i < 100; i++)
    {
        pthread_create(&threads[i], NULL, thread_func, NULL);
    }

    // 等待所有线程完成
    for (int i = 0; i < 100; i++)
    {
        pthread_join(threads[i], NULL);
    }

    // 打印实际arena数量（需glibc扩展）
    malloc_stats(); // 在输出中查找"arenas"字段
    return 0;
}
```

## 九、总结
* ptmalloc的设计平衡了通用性和性能
* 多线程环境下竞争可能成为瓶颈
* 理解实现细节有助于优化内存使用
* 特殊场景可考虑替换为tcmalloc/jemalloc

`进一步阅读glibc源码中的malloc.c文件，重点关注:`

```text
_int_malloc
_int_free
sysmalloc
arena_get2
```


### 内存分配概述

```c++
1. 分配算法概述，以 32 系统为例，64 位系统类似。 
 小于等于 64 字节：用 pool 算法分配。 
 64 到 512 字节之间：在最佳匹配算法分配和 pool 算法分配中取一种合适的。 
 大于等于 512 字节：用最佳匹配算法分配。 
 大于等于 mmap 分配阈值（默认值 128KB）：根据设置的 mmap 的分配策略进行分配，
   如果没有开启 mmap 分配阈值的动态调整机制，大于等于 128KB 就直接调用 mmap分配。否则，大于等于 mmap 分配阈值时才直接调用 mmap()分配。 
2. ptmalloc 的响应用户内存分配要求的具体步骤为: 
    1) 获取分配区的锁，为了防止多个线程同时访问同一个分配区，在进行分配之前需要
        取得分配区域的锁。线程先查看线程私有实例中是否已经存在一个分配区，如果存
        在尝试对该分配区加锁，如果加锁成功，使用该分配区分配内存，否则，该线程搜
        索分配区循环链表试图获得一个空闲（没有加锁）的分配区。如果所有的分配区都
        已经加锁，那么 ptmalloc 会开辟一个新的分配区，把该分配区加入到全局分配区循
        环链表和线程的私有实例中并加锁，然后使用该分配区进行分配操作。开辟出来的
        新分配区一定为非主分配区，因为主分配区是从父进程那里继承来的。开辟非主分
        配区时会调用 mmap()创建一个 sub-heap，并设置好 top chunk。
    2) 将用户的请求大小转换为实际需要分配的 chunk 空间大小。 
    3) 判断所需分配chunk的大小是否满足chunk_size <= max_fast (max_fast 默认为 64B)，
    如果是的话，则转下一步，否则跳到第 5 步。 
    4) 首先尝试在 fast bins 中取一个所需大小的 chunk 分配给用户。如果可以找到，则分
    配结束。否则转到下一步。 
    5) 判断所需大小是否处在 small bins 中，即判断 chunk_size < 512B 是否成立。如果
    chunk 大小处在 small bins 中，则转下一步，否则转到第 6 步。 
    6) 根据所需分配的 chunk 的大小，找到具体所在的某个 small bin，从该 bin 的尾部摘
    取一个恰好满足大小的 chunk。若成功，则分配结束，否则，转到下一步。 
    7) 到了这一步，说明需要分配的是一块大的内存，或者 small bins 中找不到合适的 
    chunk。于是，ptmalloc 首先会遍历 fast bins 中的 chunk，将相邻的 chunk 进行合并，
    并链接到 unsorted bin 中，然后遍历 unsorted bin 中的 chunk，如果 unsorted bin 只
    有一个 chunk，并且这个 chunk 在上次分配时被使用过，并且所需分配的 chunk 大
    小属于 small bins，并且 chunk 的大小大于等于需要分配的大小，这种情况下就直
    接将该 chunk 进行切割，分配结束，否则将根据 chunk 的空间大小将其放入 small 
    bins 或是 large bins 中，遍历完成后，转入下一步。 
    8) 到了这一步，说明需要分配的是一块大的内存，或者 small bins 和 unsorted bin 中
    都找不到合适的 chunk，并且 fast bins 和 unsorted bin 中所有的 chunk 都清除干净
    了。从 large bins 中按照“smallest-first，best-fit”原则，找一个合适的 chunk，从
    中划分一块所需大小的 chunk，并将剩下的部分链接回到 bins 中。若操作成功，则
    分配结束，否则转到下一步。 
    9) 如果搜索 fast bins 和 bins 都没有找到合适的 chunk，那么就需要操作 top chunk 来
    进行分配了。判断 top chunk 大小是否满足所需 chunk 的大小，如果是，则从 top 
    chunk 中分出一块来。否则转到下一步。 
    10) 到了这一步，说明 top chunk 也不能满足分配要求，所以，于是就有了两个选择: 如
    果是主分配区，调用 sbrk()，增加 top chunk 大小；如果是非主分配区，调用 mmap
    来分配一个新的 sub-heap，增加 top chunk 大小；或者使用 mmap()来直接分配。在
    这里，需要依靠 chunk 的大小来决定到底使用哪种方法。判断所需分配的 chunk
    大小是否大于等于 mmap 分配阈值，如果是的话，则转下一步，调用 mmap 分配，
    否则跳到第 12 步，增加 top chunk 的大小。 
    11) 使用 mmap 系统调用为程序的内存空间映射一块 chunk_size align 4kB 大小的空间。 
    然后将内存指针返回给用户。 
    12) 判断是否为第一次调用 malloc，若是主分配区，则需要进行一次初始化工作，分配
    一块大小为(chunk_size + 128KB) align 4KB 大小的空间作为初始的 heap。若已经初
    始化过了，主分配区则调用 sbrk()增加 heap 空间，非主分配区则在 top chunk 中切
    割出一个 chunk，使之满足分配需求，并将内存指针返回给用户。
    
```
### 内存回收概述 
```c++
    free() 函数接受一个指向分配区域的指针作为参数，释放该指针所指向的 chunk。而具
    体的释放方法则看该 chunk 所处的位置和该 chunk 的大小。free()函数的工作步骤如下：
    1) free()函数同样首先需要获取分配区的锁，来保证线程安全。 
    2) 判断传入的指针是否为 0，如果为 0，则什么都不做，直接 return。否则转下一步。 
    3) 判断所需释放的 chunk 是否为 mmaped chunk，如果是，则调用 munmap()释放
    mmaped chunk，解除内存空间映射，该该空间不再有效。如果开启了 mmap 分配
    阈值的动态调整机制，并且当前回收的 chunk 大小大于 mmap 分配阈值，将 mmap
    分配阈值设置为该 chunk 的大小，将 mmap 收缩阈值设定为 mmap 分配阈值的 2
    倍，释放完成，否则跳到下一步。 
    4) 判断 chunk 的大小和所处的位置，若 chunk_size <= max_fast，并且 chunk 并不位于
    heap 的顶部，也就是说并不与 top chunk 相邻，则转到下一步，否则跳到第 6 步。
    （因为与 top chunk 相邻的小 chunk 也和 top chunk 进行合并，所以这里不仅需要
    判断大小，还需要判断相邻情况） 
    5) 将 chunk 放到 fast bins 中，chunk 放入到 fast bins 中时，并不修改该 chunk 使用状
    态位 P。也不与相邻的 chunk 进行合并。只是放进去，如此而已。这一步做完之后
    释放便结束了，程序从 free()函数中返回。 
    6) 判断前一个 chunk 是否处在使用中，如果前一个块也是空闲块，则合并。并转下一
    步。 
    7) 判断当前释放 chunk 的下一个块是否为 top chunk，如果是，则转第 9 步，否则转
    下一步。 
    8) 判断下一个 chunk 是否处在使用中，如果下一个 chunk 也是空闲的，则合并，并将
    合并后的 chunk 放到 unsorted bin 中。注意，这里在合并的过程中，要更新 chunk
    的大小，以反映合并后的 chunk 的大小。并转到第 10 步。 
    9) 如果执行到这一步，说明释放了一个与 top chunk 相邻的 chunk。则无论它有多大，
    都将它与 top chunk 合并，并更新 top chunk 的大小等信息。转下一步。 
    10) 判断合并后的 chunk 的大小是否大于 FASTBIN_CONSOLIDATION_THRESHOLD（默认
    64KB），如果是的话，则会触发进行 fast bins 的合并操作，fast bins 中的 chunk 将被
    遍历，并与相邻的空闲 chunk 进行合并，合并后的 chunk 会被放到 unsorted bin 中。
    fast bins 将变为空，操作完成之后转下一步。 
    11) 判断 top chunk 的大小是否大于 mmap 收缩阈值（默认为 128KB），如果是的话，对
    于主分配区，则会试图归还 top chunk 中的一部分给操作系统。但是最先分配的
    128KB 空间是不会归还的，ptmalloc 会一直管理这部分内存，用于响应用户的分配
    请求；如果为非主分配区，会进行 sub-heap 收缩，将 top chunk 的一部分返回给操
    作系统，如果 top chunk 为整个 sub-heap，会把整个 sub-heap 还回给操作系统。做
    完这一步之后，释放结束，从 free() 函数退出。可以看出，收缩堆的条件是当前
    free 的 chunk 大小加上前后能合并 chunk 的大小大于 64k，并且要 top chunk 的大
    小要达到 mmap 收缩阈值，才有可能收缩堆。 

```