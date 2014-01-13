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
    self.thread = threading.Thread(None, self.run, None, (), {})
    self.thread.start()


  def run(self):
    """
    Run I2C communications into a background thread. This function should not be called outside of this class.
    """
    while self.toTerminate == False:
      try:
        tmp = self.bus.read_i2c_block_data(self.address, 5)
        # Data from I2C slave is a 32 byte array. We just need the 5 firsts byte, which are (in order)
        #  - Light state (0: Off, 1: On)
        #  - Motor A current, from 0 (0 Ampere) to 255 (2 Amperes) 
        #  - Motor B current, from 0 (0 Ampere) to 255 (2 Amperes) 
        #  - Pan servo angle, in degrees
        #  - Tilt servo angle, in degrees
        self.data = str(tmp[0]) + "#" + str(tmp[1]) + "#" + str(tmp[2]) + "#" + str(tmp[3]) + "#" + str(tmp[4])
        
      except IOError:
        # Silently ignore error
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

      #time.sleep(0.2)

    except IOError:
      # Silently ignore error
      print ("**** I2C error ****")


  def stop(self):
    """
    Stops I2C communications.
    """
    self.toTerminate = True
    while self.terminated == False:
      # Just wait
      time.sleep(0.01)
