# I2C message to keep Arduino alive
CMD_KEEP_ALIVE = 1

# I2C message to switch light status (on/off)
CMD_LIGHT_SWITCH = 10

# I2C message to move pan servo to left
CMD_SERVO_PAN_LEFT = 20
# I2C message to move pan servo to right
CMD_SERVO_PAN_RIGHT = 21
# I2C message to move tilt servo to up
CMD_SERVO_TILT_UP = 22
# I2C message to move tilt servo to down
CMD_SERVO_TILT_DOWN = 23
# I2C message to center servos
CMD_SERVO_CENTER = 24

# I2C message to stop all moves
CMD_MOVE_STOP = 30
# I2C message to move forward
CMD_MOVE_FORWARD = 31
# I2C message to move backward
CMD_MOVE_BACKWARD = 32
# I2C message to turn left
CMD_TURN_LEFT = 33
# I2C message to turn right
CMD_TURN_RIGHT = 34


# I2C message to handle connection to rover
#  - Light off
#  - Pan & tilt servos to 90 degrees
#  - Motors off
CMD_CONNECT = 254
# I2C message to handle disconnection from rover
#  - Light off
#  - Detach servo motors
#  - Motors off
CMD_DISCONNECT = 255
