#!/bin/sh
# Gstreamer shell script, stream video to a linux laptop.  Since we're using
# DHCP this shell needs to wait for wlan0 and work out it's host address.
# 
LEDON="24=0" 
LEDOFF="24=1" 
NULLSTEER="18=0.14" 
NULLSPEED="17=0.14" 
STEERLEFT="18=0.105"
GPIO="/dev/pi-blaster"
#
# 0.zero / test PWM servos
#
echo $NULLSTEER > $GPIO
echo $NULLSPEED > $GPIO
echo $LEDON > $GPIO
sleep .1
echo $LEDOFF > $GPIO
sleep .5
#
# 1.wait for network, by pinging google!
#
echo wait for internet...
echo $LEDON > $GPIO
sleep .1
echo $LEDOFF > $GPIO
sleep .5
while ! ping  -c1 google.co.uk -W1 | grep " 0% p" ; do
  sleep 5
done
echo ok...
#
# 2.ok now get HOST IP
# 
echo $LEDON > $GPIO
sleep .1
echo $LEDOFF > $GPIO
sleep .5
HOST=$(ifconfig | grep "inet " | grep  "255.255" | cut -d':'  -f2 | cut -d' ' -f1)
#
# 3.run raspivid
#
echo $LEDON > $GPIO
sleep .1
echo $LEDOFF > $GPIO
sleep .5
#raspivid -t 999999 -h 720 -w 1080 -fps 25 -hf -b 2000000 -o - | gst-launch-1.0 -v fdsrc ! h264parse !  rtph264pay config-interval=1 pt=96 ! gdppay ! tcpserversink host=$HOST port=5000 &
raspivid -t 999999 -md 6 -w 640 -h 480 -fps 100 -hf -b 2000000 -o - | gst-launch-1.0 -v fdsrc ! h264parse !  rtph264pay config-interval=1 pt=96 ! gdppay ! tcpserversink host=$HOST port=5000 &
#
# 4.run servo ack
#
echo $STEERLEFT > $GPIO
echo $LEDON > $GPIO
sleep .1
echo $LEDOFF > $GPIO
sleep .5
#echo $NULLSTEER > $GPIO
#
# 5. Run Teleop server
#
cd /home/pi/Protobot/server
sudo ./teleop_server &
#
