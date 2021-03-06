#!/usr/bin/python

import threading
import socket
import time
import os.path
import ConfigParser
import sys
import filecmp
import re
from datetime import datetime

# Commands to be executed by KillTest
# each command should be in this format:
# ["command", <hours to be executed>]
# for example: 
# commandList = [
# 	["./lavaMD 15 4 input1 input2 gold 10000", 1, "lavaMD"],
# 	["./gemm 1024 4 input1 input2 gold 10000", 2, "gemm"]
# ]
# will execute lavaMD for about one hour and then execute gemm for two hours
# When the list finish executing, it start to execute from the beginning
commandList = [
##darknetV1
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.caltech.1K.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.1K.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.1.1K.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.1.1K.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.1K.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.1K.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.caltech.1K.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.1K.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.1.1K.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.1.1K.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.1K.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.1K.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.caltech.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.caltech.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 0.016, "darknet_v1"],


##darknet V2
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.1K.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.1K.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.1.1K.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.1.1K.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.1K.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.1K.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.1K.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.1K.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.1.1K.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.1.1K.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.1K.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.1K.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],


##py-faster
#["sudo /home/carol/radiation-benchmarks/src/cuda/py-faster-rcnn/tools/py_faster_rcnn.py   --ite 1000  --iml /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.1K.txt  --gld /home/carol/radiation-benchmarks/data/py_faster_rcnn/py_faster_gold.caltech.1K.test  --log  daniel_logs " , 0.016, "py_faster_rcnn.py"],
#["sudo /home/carol/radiation-benchmarks/src/cuda/py-faster-rcnn/tools/py_faster_rcnn.py   --ite 1000  --iml /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.1.1K.txt  --gld /home/carol/radiation-benchmarks/data/py_faster_rcnn/py_faster_gold.urban.street.1.1K.test  --log  daniel_logs " , 0.016, "py_faster_rcnn.py"],
#["sudo /home/carol/radiation-benchmarks/src/cuda/py-faster-rcnn/tools/py_faster_rcnn.py   --ite 1000  --iml /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.1K.txt  --gld /home/carol/radiation-benchmarks/data/py_faster_rcnn/py_faster_gold.voc.2012.1K.test  --log  daniel_logs " , 0.016, "py_faster_rcnn.py"],

##lenet
#["sudo  /home/carol/radiation-benchmarks/bin/leNetCUDA   rad_test  /home/carol/radiation-benchmarks/data/lenet/t10k-images-idx3-ubyte /home/carol/radiation-benchmarks/data/lenet/t10k-labels-idx1-ubyte /home/carol/radiation-benchmarks/data/lenet/lenet_base.weights /home/carol/radiation-benchmarks/data/lenet/gold_t10k_images.test 1000 0 1000" , 0.016, "leNetCUDA"],

##resnet
#["sudo  /home/carol/radiation-benchmarks/src/cuda/resnet_torch/fb.resnet.torch/pretrained/classify_radiation.lua  /home/carol/radiation-benchmarks/data/resnet_torch/resnet-200.t7  rad_test  /home/carol/radiation-benchmarks/data/networks_img_list//caltech.pedestrians.1K.txt /home/carol/radiation-benchmarks/data/resnet_torch/gold.caltech.1K.csv 1000 log" , 0.016, "luajit"],
#["sudo  /home/carol/radiation-benchmarks/src/cuda/resnet_torch/fb.resnet.torch/pretrained/classify_radiation.lua  /home/carol/radiation-benchmarks/data/resnet_torch/resnet-200.t7  rad_test  /home/carol/radiation-benchmarks/data/networks_img_list//urban.street.1.1K.txt /home/carol/radiation-benchmarks/data/resnet_torch/gold.urban.street.1.1K.csv 1000 log" , 0.016, "luajit"],
#["sudo  /home/carol/radiation-benchmarks/src/cuda/resnet_torch/fb.resnet.torch/pretrained/classify_radiation.lua  /home/carol/radiation-benchmarks/data/resnet_torch/resnet-200.t7  rad_test  /home/carol/radiation-benchmarks/data/networks_img_list//voc.2012.1K.txt /home/carol/radiation-benchmarks/data/resnet_torch/gold.voc.2012.1K.csv 1000 log" , 0.016, "luajit"],

##nw
#["sudo /home/carol/radiation-benchmarks/bin/nw 4096 10 /home/carol/radiation-benchmarks/data/nw/input_4096 /home/carol/radiation-benchmarks/data/nw/gold_4096 1000000" , 0.016, "nw"],
#["sudo /home/carol/radiation-benchmarks/bin/nw 8192 10 /home/carol/radiation-benchmarks/data/nw/input_8192 /home/carol/radiation-benchmarks/data/nw/gold_8192 1000000" , 0.016, "nw"],
#["sudo /home/carol/radiation-benchmarks/bin/nw 16384 10 /home/carol/radiation-benchmarks/data/nw/input_16384 /home/carol/radiation-benchmarks/data/nw/gold_16384 1000000" , 0.016, "nw"],

##quicksort
#["sudo /home/carol/radiation-benchmarks/bin/quicksort -size=1048576 -input=/home/carol/radiation-benchmarks/data/quicksort/quicksort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/quicksort/quicksort_gold_1048576 -iterations=10000000" , 0.016, "quicksort"],
#["sudo /home/carol/radiation-benchmarks/bin/quicksort -size=33554432 -input=/home/carol/radiation-benchmarks/data/quicksort/quicksort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/quicksort/quicksort_gold_33554432 -iterations=10000000" , 0.016, "quicksort"],
#["sudo /home/carol/radiation-benchmarks/bin/quicksort -size=67108864 -input=/home/carol/radiation-benchmarks/data/quicksort/quicksort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/quicksort/quicksort_gold_67108864 -iterations=10000000" , 0.016, "quicksort"],
#["sudo /home/carol/radiation-benchmarks/bin/quicksort -size=134217728 -input=/home/carol/radiation-benchmarks/data/quicksort/quicksort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/quicksort/quicksort_gold_134217728 -iterations=10000000" , 0.016, "quicksort"],

##mergesort
#["sudo /home/carol/radiation-benchmarks/bin/mergesort -size=1048576 -input=/home/carol/radiation-benchmarks/data/mergesort/mergesort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/mergesort/mergesort_gold_1048576 -iterations=10000000" , 0.016, "mergesort"],
#["sudo /home/carol/radiation-benchmarks/bin/mergesort -size=33554432 -input=/home/carol/radiation-benchmarks/data/mergesort/mergesort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/mergesort/mergesort_gold_33554432 -iterations=10000000" , 0.016, "mergesort"],
#["sudo /home/carol/radiation-benchmarks/bin/mergesort -size=67108864 -input=/home/carol/radiation-benchmarks/data/mergesort/mergesort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/mergesort/mergesort_gold_67108864 -iterations=10000000" , 0.016, "mergesort"],
#["sudo /home/carol/radiation-benchmarks/bin/mergesort -size=134217728 -input=/home/carol/radiation-benchmarks/data/mergesort/mergesort_input_134217728 -gold=/home/carol/radiation-benchmarks/data/mergesort/mergesort_gold_134217728 -iterations=10000000" , 0.016, "mergesort"],


]

# Command used to kill application
killcmd="pkill -f "


timestampMaxDiff = 30 # Time in seconds
maxKill = 5 # Max number of kills allowed

sockServerIP = "192.168.1.5"
sockServerPORT = 8080

# Connect to server and close connection, kind of ping
def sockConnect():
	try:
		#create an INET, STREAMing socket
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		# Now, connect with IP (or hostname) and PORT
		# s.connect(("feliz", 8080)) or s.connect(("143.54.10.100", 8080))
		s.connect((sockServerIP, sockServerPORT))
		s.close()
	except socket.error as eDetail:
		print "could not connect to remote server, socket error"
		#logMsg("socket connect error: "+str(eDetail))

# Log messages adding timestamp before the message
def logMsg(msg):
	now = datetime.now()
	fp = open(logFile, 'a')
	print >>fp, now.ctime()+": "+str(msg)
	fp.close()
	print now.ctime()+": "+str(msg)

# Update the timestamp file with machine current timestamp
def updateTimestamp():
	command = "echo "+str(int(time.time()))+" > "+timestampFile
	retcode = os.system(command)


# Remove files with start timestamp of commands executing
def cleanCommandExecLogs():
	os.system("rm -f "+varDir+"command_execstart_*")
#	i=len(commandList)
#	while i >= 0:
#		if os.path.isfile(varDir+"command_execstart_"+str(i)):
#			os.remove(varDir+"command_execstart_"+str(i))
#		i -= 1

# Return True if the variable commandList from this file changed from the 
# last time it was executed. If the file was never executed returns False
def checkCommandListChanges():
	curList = varDir+"currentCommandList"
	lastList = varDir+"lastCommandList"
	fp = open(curList,'w')
	print >>fp, commandList
	fp.close()
	if not os.path.isfile(lastList):
		fp = open(lastList,'w')
		print >>fp, commandList
		fp.close()
		return True

	if filecmp.cmp(curList, lastList, shallow=False):
		return False
	else:
		fp = open(lastList,'w')
		print >>fp, commandList
		fp.close()
		return True

# Select the correct command to be executed from the commandList variable
def selectCommand():
	if checkCommandListChanges():
		cleanCommandExecLogs()

	# Get the index of last existent file	
	i=0
	while os.path.isfile(varDir+"command_execstart_"+str(i)):
		i += 1
	i -= 1

	# If there is no file, create the first file with current timestamp
	# and return the first command of commandList
	if i == -1:
		os.system("echo "+str(int(time.time()))+" > "+varDir+"command_execstart_0")
		return commandList[0][0]

	# Check if last command executed is still in its execution time window
	# and return it
	timeWindow = commandList[i][1] * 60 * 60 # Time window in seconds
	# Read the timestamp file
	try:
		fp = open(varDir+"command_execstart_"+str(i),'r')
		timestamp = int(float(fp.readline().strip()))
		fp.close()
	except ValueError as eDetail:
		logMsg("Rebooting, command execstart timestamp read error: "+str(eDetail))
		sockConnect()
		os.system("shutdown -r now")
		time.sleep(20)
	#fp = open(varDir+"command_execstart_"+str(i),'r')
	#timestamp = int(float(fp.readline().strip()))
	#fp.close()

	now = int(time.time())
	if (now - timestamp) < timeWindow:
		return commandList[i][0]

	i += 1
	# If all commands executed their time window, start all over again
	if i >= len(commandList):
		cleanCommandExecLogs()
		os.system("echo "+str(int(time.time()))+" > "+varDir+"command_execstart_0")
		return commandList[0][0]

	# Finally, select the next command not executed so far
	os.system("echo "+str(int(time.time()))+" > "+varDir+"command_execstart_"+str(i))
	return commandList[i][0]


def execCommand(command):
	try:
		updateTimestamp()
		if re.match(".*&\s*$", command):
			#print "command should be ok"
			return os.system(command)
		else:
			#print "command not ok, inserting &"
			return os.system(command+" &")
	except OSError as detail:
		logMsg("Error launching command '"+command+"'; error detail: "+str(detail))
		return None


################################################
# KillTest Main Execution
################################################
confFile = '/etc/radiation-benchmarks.conf'

if not os.path.isfile(confFile):
	print >> sys.stderr, "Configuration file not found!("+confFile+")"
	sys.exit(1)

try:
	config = ConfigParser.RawConfigParser()
	config.read(confFile)
	
	installDir = config.get('DEFAULT', 'installdir')+"/"
	varDir =  config.get('DEFAULT', 'vardir')+"/"
	logDir =  config.get('DEFAULT', 'logdir')+"/"
	tmpDir =  config.get('DEFAULT', 'tmpdir')+"/"
	
	#logDir = varDir+"log/"
	
	if not os.path.isdir(logDir):
		os.mkdir(logDir, 0777)
		os.chmod(logDir, 0777)
	
except IOError as e:
	print >> sys.stderr, "Configuration setup error: "+str(e)
	sys.exit(1)
	
logFile = logDir+"killtest.log"
timestampFile = varDir+"timestamp.txt"

# Start last kill timestamo with an old enough timestamp
lastKillTimestamp = int(time.time()) - 50*timestampMaxDiff

contTimestampReadError=0
try:
	killCount = 0 # Counts how many kills were executed throughout execution
	curCommand = selectCommand()
	execCommand(curCommand)
	while True:
		sockConnect()
		# Read the timestamp file
		try:
			#fp = open(timestampFile, 'r')
			#timestamp = int(float(fp.readline().strip()))
			#fp.close()
			timestamp = int(os.path.getmtime(timestampFile))
		except (ValueError, OSError) as eDetail:
			fp.close()
			updateTimestamp()
			contTimestampReadError += 1
			logMsg("timestamp read error(#"+str(contTimestampReadError)+"): "+str(eDetail))
			if contTimestampReadError > 1:
				logMsg("Rebooting, timestamp read error: "+str(eDetail))
				sockConnect()
				os.system("shutdown -r now")
				time.sleep(20)
			timestamp = int(float(time.time()))
			
		# Get the current timestamp
		now = int(time.time())
		timestampDiff = now - timestamp
		# If timestamp was not update properly
		if timestampDiff > timestampMaxDiff:
			# Check if last kill was in the last 60 seconds and reboot
			for cmd in commandList:
				os.system(killcmd+" "+cmd[2])
			os.system("sudo  /usr/bin/nvidia-smi -i 0 -r")
			now = int(time.time())
			if (now - lastKillTimestamp) < 3*timestampMaxDiff:
				logMsg("Rebooting, last kill too recent, timestampDiff: "+str(timestampDiff)+", current command:"+curCommand)
				sockConnect()
				os.system("shutdown -r now")
				time.sleep(20)
			else:
				lastKillTimestamp = now

			killCount += 1
			logMsg("timestampMaxDiff kill(#"+str(killCount)+"), timestampDiff:"+str(timestampDiff)+" command '"+curCommand+"'")
			# Reboot if we reach the max number of kills allowed 
			if killCount >= maxKill:
				logMsg("Rebooting, maxKill reached, current command:"+curCommand)
				sockConnect()
				os.system("shutdown -r now")
				time.sleep(20)
			else:
				curCommand = selectCommand() # select properly the current command to be executed
				execCommand(curCommand) # start the command
	
	
		time.sleep(1)	
except KeyboardInterrupt: # Ctrl+c
	print "\n\tKeyboardInterrupt detected, exiting gracefully!( at least trying :) )"
	for cmd in commandList:
		os.system(killcmd+" "+cmd[2])

	os.system("sudo  /usr/bin/nvidia-smi -i 0 -r")

	sys.exit(1)
