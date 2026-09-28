---
layout: post
title: IoT نے دن بچا لیا
description: ڈرائر کو چلانے کے لیے Raspberry Pi کیسے استعمال کیا گیا
date: '2017-03-19 00:00:00'
tags: [IoT, RaspberryPI]
section: hobby
image: /assets/content/hobbies/IoT/pidryer.jpg
image_alt: ڈرائر کے لیے Raspberry PI اور ریلے
permalink: /hobby/iotsaveday/
---

## مسئلہ

> پرانی ٹیکنالوجی جو اب سپورٹ سے باہر تھی

ہمارے ڈرائر کا ٹائمر عین اس وقت خراب ہو گیا جب اس کی سب سے زیادہ ضرورت تھی۔ ابھی ابھی ہمارے ہاں بچوں کے ساتھ مہمان آئے تھے (وہ قسم جو ہر منٹ کپڑے میلے کرتی ہے)۔ ابھی ابھی برفانی طوفان آیا تھا۔ اور ظاہر ہے، یہ ویک اینڈ تھا؛ کوئی مرمت کی دکان کھلی نہ تھی۔ بہت بعد میں مجھے پتا چلا کہ مینوفیکچرر کے پاس ہمارے ڈرائر کا متبادل پرزہ اب موجود ہی نہیں تھا، لیکن اس وقت میرا خیال تھا کہ مجھے صرف ایک عارضی حل چاہیے۔

![ڈرائر کی اسکیمیٹکس](/assets/content/hobbies/IoT/schematics.png "ڈرائر کی اسکیمیٹکس")

## تحقیق

میں نے آسان حل تلاش کرنے کے لیے ڈرائر کا فرنٹ پینل کھولا۔ اس مرحلے تک مجھے خرابی کی وجہ معلوم نہیں تھی؛ علامت یہ تھی کہ ڈرائر اسٹارٹ نہیں ہو رہا تھا۔ فرنٹ پینل کے اندر مجھے کچھ ٹربل شوٹنگ ہدایات کے ساتھ ایک اسکیمیٹک ملا۔ جب تک میں نے یہ طے کیا کہ ٹائمر خراب ہو چکا ہے، مجھے یہ بھی معلوم ہو گیا کہ ٹائمر دراصل صرف ایک بزر، کوائل، اور بورڈ پر تقریباً 7 ریلے تھا۔

## حل

کیوں نہ ٹائمر کا ایک الیکٹرانک ورژن بنایا جائے؛ شاید پورے ٹائمر کی جگہ نہیں، بس ایک سائیکل کو کام کرنے کے قابل بنایا جائے۔ خوش قسمتی سے میرے پاس تمام ضروری سامان موجود تھا:
1. Raspberry pi Zero
2. پروٹو بورڈ
3. ریلے بورڈ
4. WiFi اڈاپٹر
5. I2C 4x20 ڈسپلے۔ کسی حد تک اختیاری، لیکن فیڈبیک کے لیے کافی مفید۔

### نفاذ

ہارڈ ویئر جوڑنے میں تقریباً ایک گھنٹہ لگا (دیکھیں تصویر 2، Pi Dryer)۔ Raspberry pi Zero ایک لکڑی کے خانے میں ہے جس میں پروٹو بورڈ کے لیے جگہ ہے۔ یہ USB پورٹ A کے ذریعے AC/DC اڈاپٹر سے چلتا ہے۔ WiFi اڈاپٹر USB پورٹ B سے جڑا ہے۔ ریلے لاجک اسٹرپ مناسب GPIO پنز سے جڑی ہے، جس میں پہلا اور آخری پن بالترتیب گراؤنڈ اور پاور (VCC) سے منسلک ہیں۔ ریلے کا ہائی وولٹیج سرا ڈرائر سے جڑا ہے۔

جب pi بوٹ ہوتا ہے تو ایک rc.local Pi Dryer کی اسٹارٹ اپ اسکرپٹ چلاتی ہے جو بورڈ کا IP ایڈریس دکھاتی ہے اور ریلے شروع کرتی ہے۔

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
اس کے بعد میں ڈیوائس میں ssh کر کے ٹائمر اسکرپٹ چلا سکتا ہوں۔
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
## نتیجہ

یہ بنانے میں ایک بہت سادہ پراجیکٹ تھا اور اس لحاظ سے کافی غیر ذہین بھی۔ لیکن یہ بہت کارآمد رہا، کم از کم میرے لیے۔ ویسے، میں نے Raspberry PI Zero ایک ڈالر میں خریدا تھا۔ (مجموعی طور پر، تقریباً 25 ڈالر مالیت کے پرزے۔)
