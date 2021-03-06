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

#darknetv1 NO SAVE LAYERS: no smartpooling and smartpooling########################################################################
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.caltech.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],

##darknetv1 SAVE LAYERS: no smartpooling and smartpooling##########################################################################
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.caltech.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.urban.street.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v1 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v1.cfg  -b /home/carol/radiation-benchmarks/src/cuda/darknet  -e yolo  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v1_gold.voc.2012.10.csv  -m valid  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v1.weights  -x 0" , 1, "darknet_v1"],

#darknetv2 NO SAVE LAYERS: no smartpooling and smartpooling########################################################################
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 0  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 0  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],

##darknetv2 SAVE LAYERS: no smartpooling and smartpooling##########################################################################
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 0  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 0.016, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.caltech.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.urban.street.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],
#["sudo /home/carol/radiation-benchmarks/bin/darknet_v2 test_radiation  -c /home/carol/radiation-benchmarks/data/darknet/yolo_v2.cfg  -d /home/carol/radiation-benchmarks/data/darknet/darknet_v2_gold.voc.2012.10.csv  -l /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  -n 10000  -s 1  -a 2  -w /home/carol/radiation-benchmarks/data/darknet/yolo_v2.weights" , 1, "darknet_v2"],




##py-faster
#["sudo /home/carol/radiation-benchmarks/src/cuda/py-faster-rcnn/tools/py_faster_rcnn.py   --ite 1000  --iml /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.10.txt  --gld /home/carol/radiation-benchmarks/data/py_faster_rcnn/py_faster_gold.caltech.10.test  --log  daniel_logs " , 0.016, "py_faster_rcnn.py"],
#["sudo /home/carol/radiation-benchmarks/src/cuda/py-faster-rcnn/tools/py_faster_rcnn.py   --ite 1000  --iml /home/carol/radiation-benchmarks/data/networks_img_list/urban.street.10.txt  --gld /home/carol/radiation-benchmarks/data/py_faster_rcnn/py_faster_gold.urban.street.10.test  --log  daniel_logs " , 0.016, "py_faster_rcnn.py"],
#["sudo /home/carol/radiation-benchmarks/src/cuda/py-faster-rcnn/tools/py_faster_rcnn.py   --ite 1000  --iml /home/carol/radiation-benchmarks/data/networks_img_list/voc.2012.10.txt  --gld /home/carol/radiation-benchmarks/data/py_faster_rcnn/py_faster_gold.voc.2012.10.test  --log  daniel_logs " , 0.016, "py_faster_rcnn.py"],


##gemm double
["sudo /home/carol/radiation-benchmarks/bin/cudaDGEMM -size=1024 -input_a=/home/carol/radiation-benchmarks/data/dgemm/dgemmA_8192.matrix -input_b=/home/carol/radiation-benchmarks/data/dgemm/dgemmB_8192.matrix -gold=/home/carol/radiation-benchmarks/data/dgemm/dgemmGOLD_1024.matrix -iterations=10000000" , 1, "cudaDGEMM"],
["sudo /home/carol/radiation-benchmarks/bin/cudaDGEMM -size=2048 -input_a=/home/carol/radiation-benchmarks/data/dgemm/dgemmA_8192.matrix -input_b=/home/carol/radiation-benchmarks/data/dgemm/dgemmB_8192.matrix -gold=/home/carol/radiation-benchmarks/data/dgemm/dgemmGOLD_2048.matrix -iterations=10000000" , 1, "cudaDGEMM"],
["sudo /home/carol/radiation-benchmarks/bin/cudaDGEMM -size=4096 -input_a=/home/carol/radiation-benchmarks/data/dgemm/dgemmA_8192.matrix -input_b=/home/carol/radiation-benchmarks/data/dgemm/dgemmB_8192.matrix -gold=/home/carol/radiation-benchmarks/data/dgemm/dgemmGOLD_4096.matrix -iterations=10000000" , 1, "cudaDGEMM"],

## gemm half
["sudo /home/carol/radiation-benchmarks/bin/cudaHGEMM -size=1024 -input_a=/home/carol/radiation-benchmarks/data/hgemm/hgemmA_8192.matrix -input_b=/home/carol/radiation-benchmarks/data/hgemm/hgemmB_8192.matrix -gold=/home/carol/radiation-benchmarks/data/hgemm/hgemmGOLD_1024.matrix -iterations=10000000" , 1, "cudaHGEMM"],
["sudo /home/carol/radiation-benchmarks/bin/cudaHGEMM -size=2048 -input_a=/home/carol/radiation-benchmarks/data/hgemm/hgemmA_8192.matrix -input_b=/home/carol/radiation-benchmarks/data/hgemm/hgemmB_8192.matrix -gold=/home/carol/radiation-benchmarks/data/hgemm/hgemmGOLD_2048.matrix -iterations=10000000" , 1, "cudaHGEMM"],
["sudo /home/carol/radiation-benchmarks/bin/cudaHGEMM -size=8192 -input_a=/home/carol/radiation-benchmarks/data/hgemm/hgemmA_8192.matrix -input_b=/home/carol/radiation-benchmarks/data/hgemm/hgemmB_8192.matrix -gold=/home/carol/radiation-benchmarks/data/hgemm/hgemmGOLD_8192.matrix -iterations=10000000" , 1, "cudaHGEMM"],

#hotspot float
["sudo /home/carol/radiation-benchmarks/bin/hotspot -size=1024 -sim_time=1000 -streams=1 -temp_file=/home/carol/radiation-benchmarks/data/hotspot/temp_1024 -power_file=/home/carol/radiation-benchmarks/data/hotspot/power_1024 -gold_file=/home/carol/radiation-benchmarks/data/hotspot/gold_float_1024_1000 -iterations=10000000" , 1, "hotspot"],

#hotspot half
["sudo /home/carol/radiation-benchmarks/bin/hhotspot -size=1024 -sim_time=1000 -streams=1 -temp_file=/home/carol/radiation-benchmarks/data/hhotspot/temp_1024 -power_file=/home/carol/radiation-benchmarks/data/hhotspot/power_1024 -gold_file=/home/carol/radiation-benchmarks/data/hhotspot/gold_half_1024_1000 -iterations=10000000" , 1, "hhotspot"],

#lava double
["sudo /home/carol/radiation-benchmarks/bin/lava -boxes=10 -input_distances=/home/carol/radiation-benchmarks/data/lava/input_distances_double_10 -input_charges=/home/carol/radiation-benchmarks/data/lava/input_charges_double_10 -output_gold=/home/carol/radiation-benchmarks/data/lava/gold_double_10 -iterations=10000000 -streams=1" , 1, "lava"],
["sudo /home/carol/radiation-benchmarks/bin/lava -boxes=15 -input_distances=/home/carol/radiation-benchmarks/data/lava/input_distances_double_15 -input_charges=/home/carol/radiation-benchmarks/data/lava/input_charges_double_15 -output_gold=/home/carol/radiation-benchmarks/data/lava/gold_double_15 -iterations=10000000 -streams=1" , 1, "lava"],

#lava half
["sudo /home/carol/radiation-benchmarks/bin/hlava -boxes=10 -input_distances=/home/carol/radiation-benchmarks/data/hlava/input_distances_half_10 -input_charges=/home/carol/radiation-benchmarks/data/hlava/input_charges_half_10 -output_gold=/home/carol/radiation-benchmarks/data/hlava/gold_half_10 -iterations=10000000 -streams=1" , 1, "hlava"],
["sudo /home/carol/radiation-benchmarks/bin/hlava -boxes=15 -input_distances=/home/carol/radiation-benchmarks/data/hlava/input_distances_half_15 -input_charges=/home/carol/radiation-benchmarks/data/hlava/input_charges_half_15 -output_gold=/home/carol/radiation-benchmarks/data/hlava/gold_half_15 -iterations=10000000 -streams=1" , 1, "hlava"],


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
	print command
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
