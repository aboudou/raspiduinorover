from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

from config import *
from i2ccom import *

import os
import signal

# Protocol for managing remote commands
class RaspiDuinoRover(Protocol):
  def connectionMade(self):
    reset()
    print("A client connected")

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
      self.transport.write(i2ccom.data)

    elif data == "reset":
      reset()

# Reset rover state
def reset():
  i2ccom.sendMessage(CMD_RESET, -1)

# Called on process interruption.
def endProcess(signalnum = None, handler = None):
  reset()
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
i2ccom = I2CCom(I2CBUS, ADDRESS)
i2ccom.start()

# Init and start server
factory = Factory()
factory.protocol = RaspiDuinoRover
reactor.listenTCP(PORT, factory, 50, IFACE)
reactor.run()
