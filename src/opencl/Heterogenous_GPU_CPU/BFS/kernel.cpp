/*
 * Copyright (c) 2016 University of Cordoba and University of Illinois
 * All rights reserved.
 *
 * Developed by:    IMPACT Research Group
 *                  University of Cordoba and University of Illinois
 *                  http://impact.crhc.illinois.edu/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * with the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 *      > Redistributions of source code must retain the above copyright notice,
 *        this list of conditions and the following disclaimers.
 *      > Redistributions in binary form must reproduce the above copyright
 *        notice, this list of conditions and the following disclaimers in the
 *        documentation and/or other materials provided with the distribution.
 *      > Neither the names of IMPACT Research Group, University of Cordoba, 
 *        University of Illinois nor the names of its contributors may be used 
 *        to endorse or promote products derived from this Software without 
 *        specific prior written permission.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH
 * THE SOFTWARE.
 *
 */

#include "/home/carol/radiation-benchmarks/src/opencl/Heterogenous_GPU_CPU/BFS/kernel.h"
#include <math.h>
#include <thread>
#include <vector>
#include <algorithm>

long atomic_maximum(std::atomic_long *maximum_value, long value) {
    long prev_value = (maximum_value)->load();
    while(prev_value < value && !(maximum_value)->compare_exchange_strong(prev_value, value))
        ;
    return prev_value;
}

// CPU threads-----------------------------------------------------------------
void run_cpu_threads(Node *h_graph_nodes, Edge *h_graph_edges, std::atomic_long *cost, std::atomic_long *color,
    long *q1, long *q2, long *n_t, std::atomic_long *head, std::atomic_long *tail,
    std::atomic_long *threads_end, std::atomic_long *threads_run, std::atomic_long *iter, long n_threads,
    long LIMIT, const long GPU) {
///////////////// Run CPU worker threads /////////////////////////////////
#if PRINT
    printf("Starting %d CPU threads\n", n_threads * CPU);
#endif
    std::vector<std::thread> cpu_threads;
    for(int k = 0; k < n_threads; k++) {
        cpu_threads.push_back(std::thread([=]() {

            long iter_local = (iter)->load(); // Current iteration/level

            long base = (head)->fetch_add(1); // Fetch new node from input queue
            while(base < *n_t) {
                long pid = q1[base];
                cost[pid].store(iter_local); // Node visited
                // For each outgoing edge
                for(long i = h_graph_nodes[pid].x; i < (h_graph_nodes[pid].y + h_graph_nodes[pid].x); i++) {
                    long id        = h_graph_edges[i].x;
                    long old_color = atomic_maximum(&color[id], BLACK);
                    if(old_color < BLACK) {
                        // Push to the queue
                        long index_o     = (tail)->fetch_add(1);
                        q2[index_o] = id;
                    }
                }
                base = (head)->fetch_add(1); // Fetch new node from input queue
            }

            if(k == 0) {
                (iter)->fetch_add(1);
            }
        }));
    }
    std::for_each(cpu_threads.begin(), cpu_threads.end(), [](std::thread &t) { t.join(); });
}
