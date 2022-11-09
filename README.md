RaspiDuinoRover
===============

RaspiDuinoRover is a project about making a rover with a Raspberry Pi (and its camera module) and an Arduino Uno, and controlling it with an iPhone.

* [Youtube video of work in progress](http://www.youtube.com/watch?v=DCWTQt_jFEk)
* [Youtube video with tracked chassis](http://www.youtube.com/watch?v=M8OIg37Q50M)

Architecture
------------

RaspiDuinoRover is made of three main parts :

* A Raspberry Pi which receives commands from a remote device through a TCP connection, and sends these commands to an Arduino Uno through an I2C connection. The same TCP channel is used to send back to the remote data grabbed from the Arduino Uno about pan and tilt servo positions, camera lighting status and motors current usage. The Raspberry Pi also provides an MJPEG video stream from its camera module. 
* An Arduino Uno which receives commands from the Raspberry Pi though an I2C connection, and accordingly drives rover motors (with the help of an Arduino Motor Shield) and positions pan and tilt servos. It regularly gets infos about pan and tilt servo positions, camera lighting status and motors current usage, and send it back to the Raspberry Pi when asked for.
* An iOS device which serves as a remote control for the rover. It connects to the Raspberry Pi through a TCP connection, and displays its MJPEG video stream.

<p align="center">
  <img src="/Images/flowchart.png" title="Wiring diagram" alt="Wiring diagram" />
  <br/>
  <em>Wiring diagram</em>
</p>

The base of the rover is made of a [Dagu Rover 5 Tracked Chassis](http://www.pololu.com/product/1550). The Raspberry Pi camera module is mounted on a pan/tilt support with servos, and a lighting feature based on three white LED is added to allow the use of the camera in the dark. It should be possible to replace camera module by a NoIR camera module and white LED with IR LED if you want / need a discreet illumination.

Servo motors, Raspberry Pi, Arduino Uno and camera lighting are powered by a common 5V power line. This 5V power may come from a wall power supply (at least 2A), while the chassis motors have their own power source. It may be possible to make a common power supply for all items, including chassis motors, but this page won't cover this topic.


Requirements
------------

* A Raspberry Pi.
* A Raspberry Pi camera module.
* An Arduno Uno R3.
* An Arduino Motor Shield R3.
* Some items listed into “bill_of_materials.ods” file.
* For server part :
	* Python (with Debian / Raspbian : packages “python”, “python-dev”).
	* SMBus library . On Raspbian, install package “python-smbus”.
	* Twisted library. On Raspbian, install package “python-twisted”.
	* UV4L (see below)
* For iPhone part :
	* An iPhone (or iPad, or iPod Touch) with iOS 7
	* XCode 5.0.x

To help you with the assembly, you may refer to the following files :

* RaspiDuinoRover.fzz: the global assembly, to open with Fritzing
  ([http://fritzing.org/](http://fritzing.org/)).
* CameraLighting.fzz: details for the camera support and lighting assembly, to open with Fritzing.
* PowerRail.fzz: details for the commond power rails.


Breadboard assembly and schematics
----------------------------------

<p align="center">
  <img src="/Images/breadboard.png" alt="Breadboard assembly" title="Breadboard assembly" />
  <br/>
  <em>Breadboard assembly</em>

  <br/><br/>

  <img src="/Images/schematics.png" alt="iOS remote" title="iOS remote" />
  <br/>
  <em>Schematics</em>
</p>


How to use RaspiDuinoRover (server)
-----------------------------------

You'll first have to upload “Arduino/Arduino.uno” sketch to your Ardunio Uno then build the assembly.

__Important:__ Don't forget to cut “Vin” jumper on the backside of the shield.

Then you have to install UV4L, following [these steps](https://www.linux-projects.org/uv4l/installation/). You'll need to install the following packages: “uv4l”, “uv4l-raspicam”, “uv4l-raspicam-extras” and “uv4l-server”.

You may want to use the following settings in “/etc/uv4l/uv4l-raspicam.conf” file (adapt to fit your needs):

```
width = 640
height = 360
framerate = 30
quality = 10
server-option = --port=8080
server-option = --use-ssl=no
```

then restart “uv4l_raspicam” service with “service uv4l_raspicam restart”.

Then update “./RaspberryPi/config.py” file to fit your needs.

When you're done, just launch RaspiDuinoRover with `./RaspberryPi/raspiduinorover.sh start` as root user. When you want / need to stop it, just execute `./RaspberryPi/raspiduinorover.sh stop` as root user.

The start script will start RaspiDuinoRover server.

Streaming will be started when a user connects to the server (have a look to ”./RaspberryPi/bin/stream.sh” script) and will be stopped when the last user disconnects.


How to use RaspiDuinoRemote (iPhone)
-----------------------------------------

Just open XCode project then build and install RaspiDuinoRemote on your iDevice. If you don't have an Apple iOS Developper account, you may use RaspiDuinoRemote within iOS Simulator.

When application is started, enter hostname (or IP adress) of your Raspberry Pi, the server port (default value is 8000, unless changed into “config.py” file) and MJPEG stream URL (it should be “http://&lt;raspberrypi_ip&gt;:8080/stream/video.mjpeg”. Then tap “Connect” button.


Some photos of the assembly
---------------------------

<p align="center">
  <img src="/Images/camera_module_details.jpg" title="Camera module lighting details" alt="Camera module lighting details" />
  <br/>
  <em>Camera module lighting details</em>

  <br/><br/>

  <img src="/Images/raspiduinorover_wip.jpg" title="Work in progress" alt="Work in progress" />
  <br/>
  <em>Work in progress</em>

  <br/><br/>

  <img src="/Images/remote_interface.png" title="iOS remote" alt="iOS remote" />
  <br/>
  <em>iOS remote, with motor current usage</em>
  
  <img src="/Images/battery_case.jpg" title="Optional 3D printed battery case" alt="Optional 3D printed battery case" />
  <br/>
  <em>Optional 3D printed battery case</em>

  <img src="/Images/battery_power_board.jpg" title="Optional battery power board" alt="Optional battery power board" />
  <br/>
  <em>Optional battery power board, used to provide +5V to common power rail and +8V to motor shield</em>
  
</p>
