# Intrusive red-black tree

The tree nodes are embedded into the elements that we index, which makes the memory footprint low.
The tree is "grown" on the stack each time we do a search or insert.
I took the code from *Zephyr* project and slightly modified it. Source:

https://github.com/zephyrproject-rtos/zephyr/blob/main/include/zephyr/sys/rb.h
https://github.com/zephyrproject-rtos/zephyr/blob/main/lib/os/rb.c

