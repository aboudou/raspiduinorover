from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

from config import *
from i2ccom import *

import os
import signal
import subprocess

# Protocol for managing remote commands
class RaspiDuinoRoverProtocol(Protocol):
  def connectionMade(self):
    # Start streaming
    if (self.factory.numProtocols == 0):
      try:
        p = subprocess.Popen(STREAM_START, stdout=subprocess.PIPE)
        connect()
      except OSError as detail:
        print ("Could not execute " + STREAM_START[0] + " ", detail)
    self.factory.numProtocols = self.factory.numProtocols + 1
    print("A client connected")

  def connectionLost(self, reason):
    # Stop streaming
    self.factory.numProtocols = self.factory.numProtocols - 1
    if (self.factory.numProtocols == 0):
      try:
        p = subprocess.Popen(STREAM_STOP, stdout=subprocess.PIPE)
        disconnect()
      except OSError as detail:
        print ("Could not execute " + STREAM_STOP[0] + " ", detail)
    print("A client disconnected")

  def dataReceived(self, data):
    if data == "light":
      i2ccom.sendMessage(CMD_LIGHT_SWITCH, -1)

    elif data == "forward":
      i2ccom.sendMessage(CMD_MOVE_FORWARD, -1)

    elif data == "reverse":
      i2ccom.sendMessage(CMD_MOVE_BACKWARD, -1)

    elif data == "left":
      i2ccom.sendMessage(CMD_TURN_LEFT, -1)

    elif data == "right":
      i2ccom.sendMessage(CMD_TURN_RIGHT, -1)

    elif data == "stop":
      i2ccom.sendMessage(CMD_MOVE_STOP, -1)

    elif data == "servoTiltUp":
      i2ccom.sendMessage(CMD_SERVO_TILT_UP, -1)

    elif data == "servoTiltDown":
      i2ccom.sendMessage(CMD_SERVO_TILT_DOWN, -1)

    elif data == "servoPanLeft":
      i2ccom.sendMessage(CMD_SERVO_PAN_LEFT, -1)

    elif data == "servoPanRight":
      i2ccom.sendMessage(CMD_SERVO_PAN_RIGHT, -1)

    elif data == "servoCenter":
      i2ccom.sendMessage(CMD_SERVO_CENTER, -1)

    elif data == "getData":
      data = i2ccom.data
      signal="-1"
      if WLAN_ADAPTER != "":
         try:
           process = subprocess.Popen([CONFIG_PATH + "/bin/signal_check.sh", WLAN_ADAPTER], stdout=subprocess.PIPE)
           out, err = process.communicate()
           if len(out.splitlines()) == 1: 
             signal = out.splitlines()[0]
         except OSError as detail:
           print ("Could not check signal strength ", detail)
      self.transport.write(data + "#" + signal)

    elif data == "reset":
      disconnect()

# Factory for RaspiDuinoRoverProtocol
class RaspiDuinoRoverFactory(Factory):
  protocol = RaspiDuinoRoverProtocol
  numProtocols = 0


# Connect to rover
def connect():
  i2ccom.start()
  time.sleep(0.5)
  i2ccom.sendMessage(CMD_CONNECT, -1)

# Disconnect from rover
def disconnect():
  i2ccom.sendMessage(CMD_DISCONNECT, -1)
  time.sleep(0.5)
  i2ccom.stop()

# Called on process interruption.
def endProcess(signalnum = None, handler = None):
  disconnect()
  i2ccom.stop()
  reactor.stop()

### Main section

# Get current pid
pid = os.getpid()

# Save current pid for later use
try:
  fhandle = open('/var/run/raspiduinorover.pid', 'w')
except IOError:
  print ("Unable to write /var/run/raspiduinorover.pid")
  exit(1)
fhandle.write(str(pid))
fhandle.close()

# Prepare handlers for process exit
signal.signal(signal.SIGTERM, endProcess)
signal.signal(signal.SIGINT, endProcess)
signal.signal(signal.SIGHUP, endProcess)

# Init I2CCom
global i2ccom
i2ccom = I2CCom(I2CBUS, ADDRESS)

# Init and start server
factory = RaspiDuinoRoverFactory()
factory.protocol = RaspiDuinoRoverProtocol
reactor.listenTCP(PORT, factory, 50, IFACE)
reactor.run()
