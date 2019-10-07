#!/usr/bin/python3
import pexpect
import threading
import socket
import time
import os
from datetime import datetime
import requests
import json
import remote_sock_parameters as par


# Log messages adding timestamp before the message
def logMsg(msg):
    now = datetime.now()

    with open(par.logFile, 'a') as fp:
        fp.write(now.ctime() + ": " + str(msg) + "\n")


################################################
# Routines to perform power cycle user IP SWITCH
################################################
def replace_str_index(text, index=0, replacement=''):
    return '%s%s%s' % (text[:index], replacement, text[index + 1:])


def lindySwitch(portNumber, status, switchIP):
    led = replace_str_index("000000000000000000000000", portNumber - 1, "1")

    if status == "On":
        url = 'http://' + switchIP + '/ons.cgi?led=' + led
    else:
        url = 'http://' + switchIP + '/offs.cgi?led=' + led
    payload = {
        "led": led,
    }
    headers = {
        "Host": switchIP,
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:56.0) Gecko/20100101 Firefox/56.0",
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate",
        "Referer": "http://" + switchIP + "/outlet.htm",
        "Authorization": "Basic c25tcDoxMjM0",
        "Connection": "keep-alive",
        "Content-Length": "0",
    }

    try:
        requestCode = requests.post(url, data=json.dumps(payload), headers=headers)
        requestCode.raise_for_status()
        return 0
    except requests.exceptions.RequestException as err:
        logMsg("Could not change Lindy IP switch status, portNumber: " + str(
            portNumber) + ", status" + status + ", switchIP:" + switchIP)
        print(str(err))
        return 1


def iceboxSwitch(portNumber, status, switchIP):
    """
    spawn telnet $srvrIP $srvrPort
    expect "Icebox login:"
    send "$loginID\r"
    expect "Password:"
    send "$loginPW\r"
    expect "#"
    send "power off 1\r"
    expect "OK"
    send "quit\r"
    """
    child = None
    try:
        child = pexpect.spawn('telnet {} {}'.format(switchIP, 23))
        child.expect('Icebox login:')
        child.sendline('admin')
        child.expect('Password:')
        child.sendline('icebox')
        child.expect('#')
        child.sendline('power {} {}'.format(status.lower(), portNumber))
        child.expect('OK')
        child.sendline('quit')
        return 0
    except Exception as err:
        logMsg("Could not change Icebox IP switch status, portNumber: " + str(
            portNumber) + ", status" + status + ", switchIP:" + switchIP)
        print("EXCEPTION icebox: {}\n{}".format(str(err), str(child)))
        return 1


class Switch:
    def __init__(self, ip, portCount):
        self.ip = ip
        self.portCount = portCount
        self.portList = []
        for i in range(0, self.portCount):
            self.portList.append(
                'pw%1dName=&P6%1d=%%s&P6%1d_TS=&P6%1d_TC=&' %
                (i + 1, i, i, i)
            )

    def cmd(self, port, c):
        assert (port <= self.portCount)

        cmd = 'curl --data \"'

        # the port list is indexed from 0, so fix it
        port -= 1

        for i in range(0, self.portCount):
            if i == port:
                cmd += self.portList[i] % c
            else:
                cmd += self.portList[i]

        cmd += '&Apply=Apply\" '
        cmd += 'http://%s/tgi/iocontrol.tgi ' % self.ip
        cmd += '-o /dev/null 2>/dev/null'
        return os.system(cmd)

    def on(self, port):
        return self.cmd(port, 'On')

    def off(self, port):
        return self.cmd(port, 'Off')


def setIPSwitch(portNumber, status, switchIP):
    if status == 'on' or status == 'On' or status == 'ON':
        cmd = 'On'
    elif status == 'off' or status == 'Off' or status == 'OFF':
        cmd = 'Off'
    else:
        return 1
    if par.SwitchIPtoModel[switchIP] == "default":
        s = Switch(switchIP, 4)
        return s.cmd(int(portNumber), cmd)
    elif par.SwitchIPtoModel[switchIP] == "lindy":
        return lindySwitch(int(portNumber), cmd, switchIP)
    elif par.SwitchIPtoModel[switchIP] == "icebox":
        return iceboxSwitch(int(portNumber), cmd, switchIP)


class RebootMachine(threading.Thread):
    def __init__(self, address):
        threading.Thread.__init__(self)
        self.address = address

    def run(self):
        port = par.IPtoSwitchPort[self.address]
        switchIP = par.IPtoSwitchIP[self.address]

        print("\tRebooting machine: " + self.address + ", switch IP: " + str(switchIP) + ", switch port: " + str(port))
        if setIPSwitch(port, "Off", switchIP) != 0:
            raise ValueError("setIPSwitch not working")

        time.sleep(par.onOffTime)
        if setIPSwitch(port, "On", switchIP) != 0:
            raise ValueError("setIPSwitch not working")


def startSocket():
    global serverSocket
    # Bind the socket to a public host, and a well-known port
    serverSocket.bind((par.serverIP, par.socketPort))
    print("\tServer bind to: ", par.serverIP)
    # Become a server socket
    serverSocket.listen(15)

    while True:
        # Accept connections from outside
        (clientSocket, address) = serverSocket.accept()
        now = datetime.now()
        if address[0] in par.IPtoNames:
            print("Connection from " + address[0] + " (" + par.IPtoNames[address[0]] + ") " + str(now))
        else:
            print("connection from " + str(address[0]) + " " + str(now))

        if address[0] in par.IPmachines:
            IPLastConn[address[0]] = time.time()  # Set new timestamp
            # If machine was set to not check again, now it's alive so start to check again
            IPActiveTest[address[0]] = True
        clientSocket.close()


################################################
# Routines to check machine status
################################################
def checkMachines():
    for address, timestamp in IPLastConn.copy().items():
        # If machine had a boot problem, stop rebooting it
        if not IPActiveTest[address]:
            continue

        # Check if machine is working fine
        now = datetime.now()
        then = datetime.fromtimestamp(timestamp)
        seconds = (now - then).total_seconds()
        # If machine is not working fine reboot it
        if par.IPtoDiffReboot[address] < seconds < 3 * par.IPtoDiffReboot[address]:
            reboot = datetime.fromtimestamp(rebooting[address])
            if (now - reboot).total_seconds() > par.IPtoDiffReboot[address]:
                rebooting[address] = time.time()
                if address in par.IPtoNames:
                    print("Rebooting IP " + address + " (" + par.IPtoNames[address] + ")")
                    logMsg("Rebooting IP " + address + " (" + par.IPtoNames[address] + ")")
                else:
                    print("Rebooting IP " + address)
                    logMsg("Rebooting IP " + address)
                # Reboot machine in another thread
                RebootMachine(address).start()
        # If machine did not reboot, log this and set it to not check again
        elif 3 * par.IPtoDiffReboot[address] < seconds < 10 * par.IPtoDiffReboot[address]:
            if address in par.IPtoNames:
                print("Boot Problem IP " + address + " (" + par.IPtoNames[address] + ")")
                logMsg("Boot Problem IP " + address + " (" + par.IPtoNames[address] + ")")
            else:
                print("Boot Problem IP " + address)
                logMsg("Boot Problem IP " + address)
            IPActiveTest[address] = False
        elif seconds > 10 * par.IPtoDiffReboot[address]:
            if address in par.IPtoNames:
                print("Rebooting IP " + address + " (" + par.IPtoNames[address] + ")")
                logMsg("Rebooting IP " + address + " (" + par.IPtoNames[address] + ")")
            else:
                print("Rebooting IP " + address)
                logMsg("Rebooting IP " + address)
            RebootMachine(address).start()


class handleMachines(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def run(self):
        print("\tStarting thread to check machine connections")
        while True:
            checkMachines()
            time.sleep(par.sleepTime)


################################################
# Main Execution
################################################

def main():
    global IPLastConn, IPActiveTest, rebooting, serverSocket

    # Test if curl is installed
    os_sys_return = os.system("curl --help > /dev/null 2>/dev/null")
    if os_sys_return != 0:
        raise ValueError("curl is not installed. Type sudo apt install curl to install it.")

    os_sys_return = os.system("ntpq --help > /dev/null 2>/dev/null")
    if os_sys_return != 0:
        raise ValueError("ntp is not installed. Type sudo apt install ntp to install it.")

    try:
        # Set the initial timestamp for all IPs
        for ip in par.IPmachines:
            rebooting[ip] = time.time()
            IPLastConn[ip] = time.time()  # Current timestamp
            IPActiveTest[ip] = True
            port = par.IPtoSwitchPort[ip]
            switchIP = par.IPtoSwitchIP[ip]
            setIPSwitch(port, "On", switchIP)

        handle = handleMachines()
        handle.setDaemon(True)
        handle.start()
        startSocket()
    except KeyboardInterrupt:
        serverSocket.close()
        raise EnvironmentError("\n\tKeyboardInterrupt detected, exiting gracefully!( at least trying :) )")


if __name__ == "__main__":
    ################################################
    # Socket server
    ################################################
    # Create an INET, STREAMing socket
    serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Set global vars to a void dict
    IPLastConn = dict()
    IPActiveTest = dict()
    rebooting = dict()

    main()
