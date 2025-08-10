# ptmalloc 源码分析

## 内存分配概述

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
## 内存回收概述 
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