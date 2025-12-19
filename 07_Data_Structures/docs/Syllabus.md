# Course 7: Data Structures and Algorithms (数据结构与算法)

## 课程愿景 (Course Vision)
本课程对标 **MIT 6.006**、**Stanford CS166** 及 **UC Berkeley CS61B** 等顶尖名校课程，旨在培养学生的"算法思维"和"数据结构直觉"。
我们不仅要掌握各种数据结构的实现细节，更要理解何时、为何使用特定的数据结构来解决实际问题，从而编写出高效、优雅的代码。

> **核心哲学**: "选择合适的数据结构，算法问题往往会迎刃而解。" —— 数据结构是算法的基石，而算法是解决问题的灵魂。

---

## 课程大纲 (Syllabus)

### Module 1: 算法分析与复杂度理论 (Weeks 1-2)
**关键词**: *Time Complexity, Space Complexity, Big-O Notation, Asymptotic Analysis*
*   **核心内容**:
    *   **算法复杂度分析**: 最坏情况、平均情况、最好情况复杂度
    *   **渐进记号**: Big-O, Big-Ω, Big-Θ 的定义与区别
    *   **递归算法分析**: 主定理 (Master Theorem), 递归树方法
    *   **分摊分析**: 均摊时间复杂度的计算 (Amortized Analysis)
*   **💡 思考引导**:
    *   为什么我们通常关注最坏情况复杂度？
    *   为什么二分查找的时间复杂度是 O(log n)，而线性查找是 O(n)？
    *   什么是"常数因子"，它在实际编程中有什么意义？

### Module 2: 基本数据结构 (Weeks 3-5)
**关键词**: *Arrays, Linked Lists, Stacks, Queues, Deques*
*   **核心内容**:
    *   **数组 (Arrays)**: 静态数组 vs 动态数组 (Vector)
    *   **链表 (Linked Lists)**: 单链表、双链表、循环链表
    *   **栈 (Stacks)**: 后进先出 (LIFO) 结构，括号匹配、函数调用栈
    *   **队列 (Queues)**: 先进先出 (FIFO) 结构，广度优先搜索
    *   **双端队列 (Deques)**: 结合栈和队列的特性
*   **💡 思考引导**:
    *   数组和链表各有什么优缺点？在什么情况下使用哪种结构？
    *   如何用两个栈实现一个队列？
    *   为什么动态数组的扩容通常采用二倍扩容策略？

### Module 3: 树与二叉搜索树 (Weeks 6-8)
**关键词**: *Binary Trees, BST, AVL Trees, Red-Black Trees*
*   **核心内容**:
    *   **树的基本概念**: 节点、边、高度、深度、度
    *   **二叉树遍历**: 前序、中序、后序、层序遍历
    *   **二叉搜索树 (BST)**: 插入、删除、查找操作
    *   **平衡二叉树**: AVL树的旋转操作，红黑树的性质与实现
    *   **堆与优先队列**: 二叉堆、斐波那契堆
*   **💡 思考引导**:
    *   为什么需要平衡二叉树？不平衡的BST会带来什么问题？
    *   AVL树和红黑树有什么区别？各自适用于什么场景？
    *   优先队列在哪些算法中发挥重要作用？

### Module 4: 哈希表与散列技术 (Weeks 9-10)
**关键词**: *Hash Tables, Hash Functions, Collision Resolution, Load Factor*
*   **核心内容**:
    *   **哈希函数**: 设计原则，常见哈希算法
    *   **冲突解决**: 链地址法 (Chaining), 开放寻址法 (Open Addressing)
    *   **负载因子**: 动态扩容策略
    *   **哈希集合与映射**: HashSet, HashMap 的实现与应用
*   **💡 思考引导**:
    *   一个好的哈希函数应该具备哪些特性？
    *   链地址法和开放寻址法各有什么优缺点？
    *   为什么哈希表的平均查找时间复杂度是 O(1)？

### Module 5: 图算法基础 (Weeks 11-13)
**关键词**: *Graphs, BFS, DFS, Shortest Paths, Minimum Spanning Trees*
*   **核心内容**:
    *   **图的表示**: 邻接矩阵，邻接表
    *   **图的遍历**: 广度优先搜索 (BFS)，深度优先搜索 (DFS)
    *   **最短路径算法**: Dijkstra算法，Bellman-Ford算法，Floyd-Warshall算法
    *   **最小生成树**: Kruskal算法，Prim算法
    *   **强连通分量**: Kosaraju算法，Tarjan算法
*   **💡 思考引导**:
    *   邻接矩阵和邻接表各适用于什么类型的图？
    *   Dijkstra算法为什么不能处理负权边？
    *   最小生成树和最短路径有什么区别？

### Module 6: 高级数据结构与算法 (Weeks 14-16)
**关键词**: *Tries, Segment Trees, Fenwick Trees, Disjoint Set Union*
*   **核心内容**:
    *   **字典树 (Tries)**: 前缀树，用于字符串检索
    *   **线段树 (Segment Trees)**: 区间查询与更新
    *   **树状数组 (Fenwick Trees)**: 高效的前缀和查询与单点更新
    *   **并查集 (Disjoint Set Union)**: 用于处理集合合并与查询
    *   **高级排序算法**: 快速排序，归并排序，堆排序，计数排序
*   **💡 思考引导**:
    *   字典树在哪些实际应用中非常有用？
    *   线段树和树状数组有什么区别？各自的优势是什么？
    *   并查集如何高效解决连通性问题？

---

## 推荐实验项目 (Labs)

1.  **Lab 1: 动态数组与链表实现** - 实现动态数组 (Vector) 和双链表 (Doubly Linked List)，对比性能差异。
2.  **Lab 2: 二叉搜索树** - 实现 BST 的插入、删除、查找操作，验证其正确性。
3.  **Lab 3: 哈希表实现** - 使用链地址法实现哈希表，处理哈希冲突。
4.  **Lab 4: 图算法可视化** - 实现 BFS、DFS 和 Dijkstra 算法，并可视化执行过程。
5.  **Lab 5: 平衡二叉树** - 实现 AVL 树或红黑树，对比与普通 BST 的性能。
6.  **Lab 6: 高级数据结构应用** - 使用线段树或树状数组解决区间查询问题。
7.  **Lab 7: 综合项目** - 设计并实现一个文件系统或数据库索引结构。

---

## 顶级学习资源 (Top-Tier Resources)

### 1. 经典教材 (Textbooks)
*   **Introduction to Algorithms** (CLRS) - Thomas H. Cormen et al. - *算法领域的圣经，内容全面深入。*
*   **Algorithms** (Fourth Edition) - Robert Sedgewick & Kevin Wayne - *与 Java 实现相结合，适合实践。*
*   **The Art of Computer Programming** (TAOCP) - Donald E. Knuth - *算法领域的经典巨著，内容极其丰富。*
*   **Data Structures and Algorithm Analysis in C++/Java** - Mark Allen Weiss - *注重实现细节和性能分析。*

### 2. 在线课程
*   **MIT 6.006 Introduction to Algorithms** (Fall 2011) - Erik Demaine & Srini Devadas - *YouTube 上可免费观看，内容经典。*
*   **Stanford CS166 Data Structures** - Tim Roughgarden - *讲解清晰，注重原理与应用。*
*   **UC Berkeley CS61B Data Structures** - Josh Hug - *包含大量编程作业和项目。*

### 3. 编程练习平台
*   **LeetCode** - https://leetcode.com/ - *包含大量算法和数据结构题目，适合练习。*
*   **HackerRank** - https://www.hackerrank.com/ - *分难度和主题的编程挑战。*
*   **Codeforces** - https://codeforces.com/ - *算法竞赛平台，适合进阶。*

### 4. 辅助工具
*   **VisuAlgo** - https://visualgo.net/ - *数据结构和算法的可视化工具。*
*   **Algorithm Visualizer** - https://algorithm-visualizer.org/ - *交互式算法可视化。*
