#!/bin/bash

while ((1))
do
        cd /home/carol/vinicius/radiation-benchmarks/bin/page_rank; sudo /home/carol/vinicius/radiation-benchmarks/bin/page_rank/page_rank_hsa -i input/csr_4096_10.txt
done
