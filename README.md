Mijia-720P-hack project
=======================

WARNING - DISCLAIMER
====================
**Many files on the Mijia 720P are writable. Be very careful when you modify files on it, you might brick it forever.**

Purpose
=======

This project is a collection of scripts and binaries file to hack your Xiaomi Mijia 720P camera.

![Alt text](mijia720p.png?raw=true "Mijia 720P camera")

This camera has the default following features:
* Wifi
* Night vision
* Motion detection: a video file is generated if a motion have been detected in the last 60 seconds.
* Send video data over the network on Chinese servers in the cloud to allow people to view camera data from their smartphone wherever they are.
* Setup thanks to a smartphone application.
* Local video storage on a SD card
* No RTSP server

This hack includes:
* No more cloud feature (nothing goes out of your local network)
* No more need to use a smartphone application
* Telnet server - _Enabled by default._
* Web server with PHP support - _Enabled by default._
* RTSP server - _Enabled by default._
* SSH server - _Disabled by default._
* FTP server - _Disabled by default._
* Samba Server - _Disabled by default._
* Syslog to memory card - _Disabled by default._
* Configure Timezone and use ntpclient to set date and time over Internet

Planed futures:
* Configuration over web server
* Motor control
* Replace Chinese voice files with English

Installation on the Mijia 720P camera
=====================================

The memory card must stay in the camera ! If you remove it, the camera will start without using the hack.

Build the binaries
------------------

To build the binaries the GM8136 SDK toolchain must be installed in /usr/src/arm-linux-3.3/toolchain_gnueabi-4.4.0_ARMv5TE

Clone this repository on a computer:

    git clone https://github.com/ghoost82/mijia-720p-hack.git

Then change into the cloned directory, build the binaries and install them to the sdcard base directory

    cd mijia-720p-hack
    make
    make install

Prepare the memory card
-----------------------

You can use the self compiled image from the cloned repository or download a precompiled release.
    
Then, format a micro SD card in fat32 (vfat) format and copy the content of the **mijia-720p-hack/sdcard/** folder at the root of your memory card.

The memory card will so contain:

* ft: folder which contains the hack entry point
* ft_config.ini and manufacture.bin: files needed to enable the hack
* mijia-720p-hack: the folder which contains the hack scripts and binaries
* mijia-720p-hack.cfg: configuration file to configure the hack
* log: this folder will contains some log files from the hack and if enabled the system logs
* MIJIA_RECORD_VIDEO: this folder will only be created when some video records will be added on the memory card by the camera

Configure the Mijia camera on the memory card
---------------------------------------------

To configure the wifi network to use, edit the file **mijia-720p-hack.cfg**.

To configure the services which should run on the camera, open the file **mijia-720p-hack.cfg** and set the values.

Start the camera
----------------

* If plugged, unplug the Mijia camera
* Insert the memory card in the Mijia camera
* Plug the Mijia camera

The camera will start. The led will indicate the current status:
* yellow: camera startup
* blue blinking: network configuration in progress (connec to wifi, set up the IP address)
* blue: network configuration is OK. Camera is ready to use.

You can test is your camera is up and running this hack with your browser on url **http://your-camera-ip/**.

Use the camera
==============

Telnet server
-------------

If enabled the telnet server is on port 23.

Default login/password: 
* login = root
* password = 1234qwer (unless you specified another password in **mijia-720p-hack.cfg.cfg** file)

SSH server
----------

If enabled the SSH server is on port 22.

Default login/password: 
* login = root
* password = 1234qwer (unless you specified another password in **mijia-720p-hack.cfg.cfg** file)

RTSP Server
-----------

f enabled the RTSP server is on port 554.

You can connect to live video stream (currently only supports 720p) on:

rtsp://your-camera-ip/live/ch00_0

FTP server
----------

If enabled the FTP server is on port 21.

There is no login/password required.

Samba
-----

If enabled the MIJIA_RECORD_VIDEO directory can be accessed via CIFS.
The share is readable by everyone.

Default login/password for read/write access: 
* login = root
* password = 1234qwer (unless you specified another password in **mijia-720p-hack.cfg.cfg** file)

I want more !
=============

Some scripts are provided in the **sd/mijia-720p-hack/scripts** folder. Please read the **README.md** file in this folder for more informations.

Uninstall the hack
==================

There are no files altered on the camera so simply remove the SD card to uninstall the hack.


How it works ?
==============

Hack content
------------

```
ft/                            Folder that contains the start script for the hack
ft_config.ini                  Neccessary configuration file for the hack boot
manufacture.bin                Archive that contains the script test_drv that will enable the hack
mijia-720p-hack/               Mijia 720O hack folder
 bin/                          Contains server and system binaries for the hack
 etc/                          Configuration files for the services provided by the hack
 scripts/                      Some scripts
 www/                          root of the erb server
mijia-720p-hack.cfg            Mijia 720O hack configuration file
````

