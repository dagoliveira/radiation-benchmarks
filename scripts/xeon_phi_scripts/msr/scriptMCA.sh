#!/bin/sh

rdmsr 0x400
rdmsr 0x17b
for i in $(seq 0 227)
do

	
	wrmsr 0x400 -p $i 0x0
	wrmsr 0x404 -p $i 0x0
	wrmsr 0x408 -p $i 0x0
	wrmsr 0x17b -p $i 0x0
	wrmsr 0x17a -p $i 0x0
#	wrmsr 0x8007D3090 -p $i 0x0
#	wrmsr 0x8007D3094 -p $i 0x0
#	wrmsr 0x8007C0340 -p $i 0x0
#	wrmsr 0x800620340 -p $i 0x0
#	wrmsr 0x8007A005C -p $i 0x0
#	wrmsr 0x8007A0060 -p $i 0x0
#	wrmsr 0x80079005C -p $i 0x0
#	wrmsr 0x800790060 -p $i 0x0
#	wrmsr 0x80070005C -p $i 0x0
#	wrmsr 0x800700060 -p $i 0x0
#	wrmsr 0x8006F005C -p $i 0x0
#	wrmsr 0x8006F0060 -p $i 0x0
#	wrmsr 0x8006D005C -p $i 0x0
#	wrmsr 0x8006D0060 -p $i 0x0
#	wrmsr 0x8006C005C -p $i 0x0
#	wrmsr 0x8006C0060 -p $i 0x0
#	wrmsr 0x8006B005C -p $i 0x0
	
#	rdmsr 0x8006A005C -p $i

#	wrmsr 0x8006B0060 -p $i 0x0
#	wrmsr 0x8006A005C -p $i 0x0
#	wrmsr 0x8006A0060 -p $i 0x0

#	rdmsr 0x8006A005C -p $
done
