#include <Wire.h>
#include <Servo.h>

// I2C message to keep Arduino alive
#define CMD_KEEP_ALIVE 1

// I2C message to switch light status (on/off)
#define CMD_LIGHT_SWITCH 10

// I2C message to move pan servo to left
#define CMD_SERVO_PAN_LEFT 20
// I2C message to move pan servo to right
#define CMD_SERVO_PAN_RIGHT 21
// I2C message to move tilt servo to up
#define CMD_SERVO_TILT_UP 22
// I2C message to move tilt servo to down
#define CMD_SERVO_TILT_DOWN 23
// I2C message to center servos
#define CMD_SERVO_CENTER 24

// I2C message to stop all moves
#define CMD_MOVE_STOP 30
// I2C message to move forward
#define CMD_MOVE_FORWARD 31
// I2C message to move backward
#define CMD_MOVE_BACKWARD 32
// I2C message to turn left
#define CMD_TURN_LEFT 33
// I2C message to turn right
#define CMD_TURN_RIGHT 34

// I2C message to handle connection to rover
//  - Light off
//  - Pan & tilt servos to 90 degrees
//  - Motors off
#define CMD_CONNECT 254
// I2C message to handle disconnection from rover
//  - Light off
//  - Detach servo motors
//  - Motors off
#define CMD_DISCONNECT 255

// Definition of useful pins
#define PIN_LIGHT 6
#define PIN_SERVO_PAN 4
#define PIN_SERVO_TILT 5
#define PIN_MOTOR_PWM_A 3
#define PIN_MOTOR_PWM_B 11
#define PIN_MOTOR_DIR_A 12
#define PIN_MOTOR_DIR_B 13
#define PIN_MOTOR_CURRENT_A A0
#define PIN_MOTOR_CURRENT_B A1

// Definition of min and max servos angles
// You might have to switch left/right and up/down values
//   depending on servos placement
#define MAX_LEFT_ANGLE 180
#define MAX_RIGHT_ANGLE 0
#define MAX_DOWN_ANGLE 120
#define MAX_UP_ANGLE 0


// Servo objects
Servo servoPan;
Servo servoTilt;

// I2C communication variables (master to slave)
volatile byte cmd = 0;
volatile byte param = 0;

// I2C communication variables (slave to master)
volatile byte motorCurrentA;
volatile byte motorCurrentB;
volatile byte lightState;
volatile int panAngle;  // To understand use of int instead of byte, see below
volatile int tiltAngle; // To understand use of int instead of byte, see below

/*
 * I use int for servoAngle values because of the way I use constrain() to limit
 * servo angle values. The issue is when I decrease angle value, and minimum angle
 * values of 0.
 *
 * The behavior is the following:
 * - Decrease current angle by 1
 * - Constrain value between min and max angle values
 *
 * With byte values, and minimum angle value of 0, I got the following behavior:
 * currentAngle = 0
 * currentAngle - 1 = 255 (byte range is from 0 to 255, no negative values possible)
 * after constrain: currentAngle = maxAngle value
 * You will see the servo jump from its min angle position to its max angle position.
 *
 * With int values, and minimum angle value of 0, I got the following behavior:
 * currentAngle = 0
 * currentAngle - 1 = -1 (int range is from -32,768 to 32,767)
 * after constrain: currentAngle = 0
 * The servo will stay at its current position.
 */

void setup() {
  // Start as I2C slave device, with adress 0x42 (we don't know the question yet)
  Wire.begin(0x42);

  // Register callback for received events
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);

  // Disable internal pull-ups on I2C pins  
  #ifndef cbi
  #define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
  #endif
  #if defined(__AVR_ATmega168__) || defined(__AVR_ATmega8__) || defined(__AVR_ATmega328P__)
    // deactivate internal pull-ups for twi
    // as per note from atmega8 manual pg167
    cbi(PORTC, 4);
    cbi(PORTC, 5);
  #else
    // deactivate internal pull-ups for twi
    // as per note from atmega128 manual pg204
    cbi(PORTD, 0);
    cbi(PORTD, 1);
  #endif
  
  // Init pin modes and servo objects
  pinMode(PIN_LIGHT, OUTPUT);

  pinMode(PIN_MOTOR_PWM_A, OUTPUT);
  pinMode(PIN_MOTOR_PWM_B, OUTPUT);

  pinMode(PIN_MOTOR_DIR_A, OUTPUT);
  pinMode(PIN_MOTOR_DIR_B, OUTPUT);
  
  // Switch to default state
  roverDisconnect();
}

void loop() {
  // Execute received commands
  if (cmd != 0) {
    switch (cmd) {
      case CMD_KEEP_ALIVE:
        // Do nothing
        break;
      
      case CMD_LIGHT_SWITCH:
        switchLight();
        break;
      
      case CMD_MOVE_STOP:
        moveStop();
        break;
  
      case CMD_MOVE_FORWARD:
        moveForward();
        break;
  
      case CMD_MOVE_BACKWARD:
        moveBackward();
        break;
  
      case CMD_TURN_LEFT:
        turnLeft();
        break;
  
      case CMD_TURN_RIGHT:
        turnRight();
        break;
  
      case CMD_DISCONNECT:
        roverDisconnect();
        break;
  
      case CMD_CONNECT:
        roverConnect();
        break;
  
      case CMD_SERVO_PAN_LEFT:
        moveServoPanLeft();
        break;
  
      case CMD_SERVO_PAN_RIGHT:
        moveServoPanRight();
        break;

      case CMD_SERVO_TILT_UP:
        moveServoTiltUp();
        break;
  
      case CMD_SERVO_TILT_DOWN:
        moveServoTiltDown();
        break;

      case CMD_SERVO_CENTER:
        moveServoCenter();
        break;

    }
    // Reset command
    cmd = 0;
  }
  
  // Get light and motor statuses
  lightState = (byte)(digitalRead(PIN_LIGHT));
  motorCurrentA = (byte)map(analogRead(PIN_MOTOR_CURRENT_A), 0, 1023, 0, 255);
  motorCurrentB = (byte)map(analogRead(PIN_MOTOR_CURRENT_B), 0, 1023, 0, 255);

}

// Callback function for I2C events
void receiveEvent(int msgSize) {
  if (msgSize == 1) {
    // Case of one byte message
    cmd = Wire.read();
          
  } else if (msgSize == 2) {
    // Case of two bytes message
    //   - First byte is the command
    //   - Second byte is the parameter       
    cmd = Wire.read();
    param = Wire.read();

  } else {
    while (Wire.available() > 0) {
      // Flush message buffer
      Wire.read();
    }
  }
}

// Callback function for I2C requests
void requestEvent() {
  byte data[] = {lightState, motorCurrentA, motorCurrentB, panAngle, tiltAngle};
  Wire.write(data, 5);
}

// Switch light status
void switchLight() {
  digitalWrite(PIN_LIGHT, !(digitalRead(PIN_LIGHT)));
}

// Move pan servo left
void moveServoPanLeft() {
  if (MAX_RIGHT_ANGLE > MAX_LEFT_ANGLE) {
    panAngle--;
    panAngle = constrain(panAngle, MAX_LEFT_ANGLE, MAX_RIGHT_ANGLE);
  } else { 
    panAngle++;
    panAngle = constrain(panAngle, MAX_RIGHT_ANGLE, MAX_LEFT_ANGLE);
  }
  servoPan.write(panAngle);
}

// Move pan servo right
void moveServoPanRight() {
  // Depending on servo placement, you may have to use panAngle++ instead
  if (MAX_RIGHT_ANGLE > MAX_LEFT_ANGLE) {
    panAngle++;
    panAngle = constrain(panAngle, MAX_LEFT_ANGLE, MAX_RIGHT_ANGLE);
  } else { 
    panAngle--;
    panAngle = constrain(panAngle, MAX_RIGHT_ANGLE, MAX_LEFT_ANGLE);
  }
  servoPan.write(panAngle);
}

// Move tilt servo up
void moveServoTiltUp() {
  if (MAX_UP_ANGLE > MAX_DOWN_ANGLE) {
    tiltAngle++;
    tiltAngle = constrain(tiltAngle, MAX_DOWN_ANGLE, MAX_UP_ANGLE);
  } else {
    tiltAngle--;
    tiltAngle = constrain(tiltAngle, MAX_UP_ANGLE, MAX_DOWN_ANGLE);
  }
  servoTilt.write(tiltAngle);
}

// Move tilt servo down
void moveServoTiltDown() {
  if (MAX_UP_ANGLE > MAX_DOWN_ANGLE) {
    tiltAngle--;
    tiltAngle = constrain(tiltAngle, MAX_DOWN_ANGLE, MAX_UP_ANGLE);
  } else {
    tiltAngle++;
    tiltAngle = constrain(tiltAngle, MAX_UP_ANGLE, MAX_DOWN_ANGLE);
  }
  servoTilt.write(tiltAngle);
}

// Center servos
void moveServoCenter() {
  panAngle = 90;
  tiltAngle = 90;
  servoPan.write(panAngle);
  servoTilt.write(tiltAngle);
}

// Make rover stop moving
// We don't use brakes, just let them stop by themselves
void moveStop() {
  analogWrite(PIN_MOTOR_PWM_A, 0);
  analogWrite(PIN_MOTOR_PWM_B, 0);
}

// Make rover move forward
void moveForward() {
  digitalWrite(PIN_MOTOR_DIR_A, HIGH);
  digitalWrite(PIN_MOTOR_DIR_B, HIGH);
  
  analogWrite(PIN_MOTOR_PWM_A, 255);
  analogWrite(PIN_MOTOR_PWM_B, 255);
}

// Make rover move backward
void moveBackward() {
  digitalWrite(PIN_MOTOR_DIR_A, LOW);
  digitalWrite(PIN_MOTOR_DIR_B, LOW);
  
  analogWrite(PIN_MOTOR_PWM_A, 255);
  analogWrite(PIN_MOTOR_PWM_B, 255);
}

// Make rover turn left
void turnLeft() {
  digitalWrite(PIN_MOTOR_DIR_A, HIGH);
  digitalWrite(PIN_MOTOR_DIR_B, LOW);
  
  analogWrite(PIN_MOTOR_PWM_A, 255);
  analogWrite(PIN_MOTOR_PWM_B, 255);
}

// Make rover turn right
void turnRight() {
  digitalWrite(PIN_MOTOR_DIR_A, LOW);
  digitalWrite(PIN_MOTOR_DIR_B, HIGH);
  
  analogWrite(PIN_MOTOR_PWM_A, 255);
  analogWrite(PIN_MOTOR_PWM_B, 255);
}

// Make rover goes to default state
//  - Light switched off
//  - Motors stopped
//  - Servos centered
void roverDisconnect() {
  digitalWrite(PIN_LIGHT, LOW);
  moveStop();
  servoPan.detach(PIN_SERVO_PAN);
  servoTilt.detach(PIN_SERVO_TILT);
}

void roverConnect() {
  digitalWrite(PIN_LIGHT, LOW);
  moveStop();
  servoPan.attach(PIN_SERVO_PAN);
  servoTilt.attach(PIN_SERVO_TILT);
  moveServoCenter();
}
  


