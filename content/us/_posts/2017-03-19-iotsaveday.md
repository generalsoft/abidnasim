---
layout: post
title: IoT Saves the Day
description: How a Raspberry PI was used to keep Dryer running
date: '2017-03-19 00:00:00'
tags: [IoT, RaspberryPI]
section: hobby
image: /assets/content/hobbies/IoT/pidryer.jpg
image_alt: Raspberry PI and Relay for Dryer
permalink: /hobby/iotsaveday/
---

## The Problem

> Old tech out of LTS

Our dryer’s timer broke just when it was needed most. We just had guests arrive with kids (the type that soil clothing by the minute). We just had a blizzard. And of course, it was the weekend; no repair shops. Much later, I found out that the manufacturer no longer had a replacement part for our dryer, but at the time, I thought I just needed a temporary fix. 

![Schematics of the Dryer](/assets/content/hobbies/IoT/schematics.png "Dryer's Schematics") 

## Research

I opened the dryer’s front panel to look for an easy fix. At this point, I’d not known the cause of the breakdown; the symptom was that the dryer didn’t start. Inside the front panel, I found a schematic with some troubleshooting instructions. By the time I determined that the timer had gone bad, I also realized that the timer really was just a buzzer, coil, and about 7 relays on a board

## Solution

Why not create an electronic version of timer; maybe not the entire timer replacement but just get one cycle to function. Fortunately, I’d all the gizmos I needed:
1.	Raspberry pi Zero
2.	Protoboard
3.	Relay board
4.	WiFi Adapter
5.	I2C 4x20 Display. Sort of optional, but quite handy for feedback. 

### Implemenation

It took about an hour to assemble the hardware (see Figure 2 Pi Dryer). Raspberry pi Zero is in the wooden case with room for protoboard. It is powered by AC/DC adapter using USB port A. WiFi adapter is connected with USB port B. Relay logic strip is connected to the appropriate GPIO pins, with first and last pins connected to ground and power (VCC) respectively. High Voltage end of the relays are connected to the dryer. 

When pi boots, an rc.local launches Pi Dryer’s startup script which display’s the board’s IP address and initializes the relays. 

```python
    import socket 
    import fcntl
    import struct

    def get_ip_address(ifname):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        return socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname[:15])
        )[20:24])

    lo =  get_ip_address('lo')
    wlan = get_ip_address('wlan0')
```
I can then ssh into the device and run timer script.
```python
    import RPi.GPIO as GPIO
    import time

    relay_pins = {'one': 11, 'two':7, 'three':12, 'four':16, 'five':18, 'six':22, 'seven':15, 'eight':13}

    GPIO.setmode(GPIO.BOARD)  # use P1 header pin numbering convention
    GPIO.setwarnings(False)   # don't want to hear about how pins are already in use

    for relay_pin, board_pin in relay_pins.iteritems():
            GPIO.setup(board_pin, GPIO.OUT)
            GPIO.output(board_pin, GPIO.LOW) # turn off

    cycle_time = 1.0 # in seconds

    GPIO.output(relay_pins['one'], GPIO.HIGH)
    time.sleep(cycle_time)
    GPIO.output(relay_pins['one'], GPIO.LOW)
```
## Conclusion

This was a very simple project to make and pretty unintelligent at that. But it was very useful, at least for me. By the way, I’d bought Raspberry PI Zero for one dollar. (Altogether, about $25 worth of components).
