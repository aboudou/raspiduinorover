import threading
import time
import smbus

from messages import *

class I2CCom(threading.Thread):

  def __init__(self, i2cbus, address):
    """
    Init the I2CCom instance. Expected parameter is :
    - i2c bus number
    - address : the I2C address of the slave Arduino.
    """
    self.address = address
    self.bus = smbus.SMBus(i2cbus)
    self.terminated = False
    self.toTerminate = False
    self.data = 0;


  def start(self):
    """
    Start communicating with slave Arduino.
    """
    self.terminated = False
    self.toTerminate = False
    self.thread = threading.Thread(None, self.run, None, (), {})
    self.thread.start()


  def run(self):
    """
    Run I2C communications (grepping Arduino status) into a background thread. This function should not be called outside of this class.
    """
    while self.toTerminate == False:
      try:
        tmp = self.bus.read_i2c_block_data(self.address, 5)
        # Data from I2C slave is a 32 byte array. We just need the 5 firsts byte, which are (in order)
        #  - Light state (0: Off, 1: On)
        #  - Motor A current, from 0 to 255
        #  - Motor B current, from 0 to 255
        #  - Pan servo angle, in degrees
        #  - Tilt servo angle, in degrees
        #
        # Current is given by motor shield with a linear voltage :
        #  - 0 volt means 0 ampere (value from Arduino : 0)
        #  - 3.3 volts means 2 amperes (value from Arduino : 168) <-- max continuous current allowed by L298 motor driver
        #  - 5 volt means 8,25 amperes (value from Arduino : 255) <-- largely over L298 motor driver electrical specifications
        self.data = str(tmp[0]) + "#" + str(tmp[1]) + "#" + str(tmp[2]) + "#" + str(tmp[3]) + "#" + str(tmp[4])

      except IOError:
        # (Mostly) silently ignore error
        print ("**** I2C error ****")

      time.sleep(0.5)

    self.terminated = True


  def sendMessage(self, message, param):
    """
    Send a message to slave Arduino. Expected parameters are :
    - message : the message to send
    - param : the optionnal parameter. -1 for no parameter
    """
    try:
      if (param == -1):
        self.bus.write_byte(self.address, message)
      else:
        self.bus.write_i2c_block_data(self.address, message, [param])

    except IOError:
      # (Mostly) silently ignore error
      print ("**** I2C error ****")


  def stop(self):
    """
    Stops I2C communications.
    """
    self.toTerminate = True
    while self.terminated == False:
      # Just wait
      time.sleep(0.01)
