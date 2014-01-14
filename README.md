!! Beware - Work In Progress !!
===============================


RaspiDuinoRover
===============

RaspiDuinoRover is a project about making a rover with a Raspberry Pi (and its camera module) and an Arduino Uno, and controlling it with an iPhone.

The following links don't refer to this project

* [Youtube video of iPhone controls concept](http://www.youtube.com/watch?v=zaB3agbCoIY)
* [Youtube video of the final assembly](http://www.youtube.com/watch?v=nw-39-aKUKc)
* [MovingRaspi - Project's summary](http://goddess-gate.com/projects/en/raspi/movingraspi)
* [MovingRaspi - Part 1: First steps](http://goddess-gate.com/projects/en/raspi/movingraspip01)
* [MovingRaspi - Part 2: iPhone -> Raspberry Pi communication](http://goddess-gate.com/projects/en/raspi/movingraspip02)
* [MovingRaspi - Part 3: The final assembly](http://goddess-gate.com/projects/en/raspi/movingraspip03)


Architecture
------------

RaspiDuinoRover is made of three main parts :

* A Raspberry Pi which will receive commands from a remote device through a TCP connexion, and will send these commands to an Arduino Uno through an I2C connection. The same TCP channel will be use to send back to the remote data grabbed from the Arduino Uno about pan and tilt servo positions, camera lighting status and motors current usage. The Raspberry Pi also provides an MJPEG video stream from its camera module. 
* An Arduino Uno which will receive commands from the Raspberry Pi though an I2C connexion, and accordingly drives rover motors (with the help of an Arduino Motor Shield) and position pan and tilt servos. It will regularly get infos about pan and tilt servo positions, camera lighting status and motors current usage, and send it back to the Raspberry Pi when asked for.
* An iOS device which will serve as a remote control for the rover. It will connect to the Raspberry Pi through a TCP connection, and display its MJPEG video stream.

![Wiring diagram](/Images/flowchart.png "Wiring diagram")
<div style="text-align: center; font-style: italic">Wiring diagram</div>

The base of the rover will be made of a [Dagu Rover 5 Tracked Chassis](http://www.pololu.com/product/1550). The Raspberry Pi camera module will be mounted on a pan/tilt support with servos, and a lighting feature based on three white LED will be added to allow the use of the camera in the dark. It should be possible to replace camera module by a NoIR camera module and white LED with IR LED if you want / need a discreet illumination.

Servo motors, Raspberry Pi, Arduino Uno and camera lighting will be powered by a common 5V power line. This 5V power may come from a wall power supply (at least 2A), while the chassis motors will have their own power source. It may be possible to make a common power supply for all items, including chassis motors, but this page won't cover this topic.


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
	* MJPEG Streamer (but not the version from raspbian packages, see below)
	* (optionnal) a fresher version of raspimjpeg, see below
* For iPhone part :
	* An iPhone (or iPad, or iPod Touch) with iOS 7
	* XCode 5.0.x

To help you with the assembly, you may refer to the following files :

* RaspiDuinoRover.fzz: the global assembly, to open with Fritzing
  ([http://fritzing.org/](http://fritzing.org/)).
* CameraLighting.fzz: details for the camera support and lighting assembly, to open with Fritzing.
* PowerRail.fzz: details for the commond power rails.


How to use RaspiDuinoRover (server)
-----------------------------------

You'll first have to upload “Arduino/Arduino.uno” sketch to your Ardunio Uno then build the assembly.

Then you have to install MJPEG Streamer, following [these steps (steps 1 to 6)](http://blog.miguelgrinberg.com/post/how-to-build-and-run-mjpg-streamer-on-the-raspberry-pi).

You may want to install a fresher version of [raspimjpeg](http://www.raspberrypi.org/forums/viewtopic.php?t=61771) even if a working binary is provided (into ”./RaspberryPi/bin/” folder).

Then update “config.py” file to fit your needs.

When you're done, just launch MovingRaspi with `./RaspberryPi/raspiduinorover.sh start` as root user. When you want / need to stop it, just execute `./RaspberryPi/raspiduinorover.sh stop` as root user.

The start script will first start streaming from camera module (have a look to ”./RaspberryPi/bin/stream.sh” script) then start RaspiDuinoRover server.


How to use RaspiDuinoRemote (iPhone)
-----------------------------------------

Just open XCode project then build and install RaspiDuinoRemote on your iDevice. If you don't have an Apple iOS Developper account, you may use RaspiDuinoRemote within iOS Simulator.

When application is started, enter hostname (or IP adress) of your Raspberry Pi, the server port (default value is 8000, unless changed into “config.py” file) and MJPEG stream URL (if you use MJPEG Streamer, it should be “http://&lt;raspberrypi_ip&gt;:8080/?action=stream”. Then tap “Connect” button.


Some photos of the assembly
---------------------------

![Camera module lighting details](/Images/camera_module_details.jpg "Camera module lighting details")
<div style="text-align: center; font-style: italic">Camera module lighting details</div>

![iOS remote](/Images/remote_interface.png "iOS remote")
<div style="text-align: center; font-style: italic">iOS remote, with motor current usage</div>
